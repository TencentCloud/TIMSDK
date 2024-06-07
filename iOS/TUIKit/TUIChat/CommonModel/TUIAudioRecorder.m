
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
//
//  TUIAudioRecorder.m
//  TUIChat
//

#import "TUIAudioRecorder.h"

#import <AVFoundation/AVFoundation.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUIAIDenoiseSignatureManager.h"

@interface TUIAudioRecorder () <AVAudioRecorderDelegate, TUINotificationProtocol>

@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) NSTimer *recordTimer;

@property(nonatomic, assign) BOOL isUsingCallKitRecorder;

@property(nonatomic, copy, readwrite) NSString *recordedFilePath;
@property(nonatomic, assign) NSTimeInterval currentRecordTime;

@end

@implementation TUIAudioRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configNotify];
    }
    return self;
}

- (void)configNotify {
    [TUICore registerEvent:TUICore_RecordAudioMessageNotify subKey:TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey object:self];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

#pragma mark - Public
- (void)record {
    [self checkMicPermissionWithCompletion:^(BOOL isGranted, BOOL isFirstChek) {
      if (TUILogin.getCurrentBusinessScene != None) {
          [TUITool makeToast:TIMCommonLocalizableString(TUIKitMessageTypeOtherUseMic) duration:3];
          return;
      }
      if (isFirstChek) {
          if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:didCheckPermission:isFirstTime:)]) {
              [self.delegate audioRecorder:self didCheckPermission:isGranted isFirstTime:YES];
          }
          return;
      }
      if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:didCheckPermission:isFirstTime:)]) {
          [self.delegate audioRecorder:self didCheckPermission:isGranted isFirstTime:NO];
      }
      if (isGranted) {
          [self createRecordedFilePath];
          if (![self startCallKitRecording]) {
              [self startSystemRecording];
          }
      }
    }];
}

- (void)stop {
    [self stopRecordTimer];

    if (self.isUsingCallKitRecorder) {
        [self stopCallKitRecording];
    } else {
        [self stopSystemRecording];
    }
}

- (void)cancel {
    [self stopRecordTimer];

    if (self.isUsingCallKitRecorder) {
        [self stopCallKitRecording];
    } else {
        [self cancelSystemRecording];
    }
}

#pragma mark - Private
- (void)createRecordedFilePath {
    self.recordedFilePath = [TUIKit_Voice_Path stringByAppendingString:[TUITool genVoiceName:nil withExtension:@"m4a"]];
}

- (void)stopRecordTimer {
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}

#pragma mark-- Timer
- (void)triggerRecordTimer {
    self.currentRecordTime = 0;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onRecordTimerTriggered:) userInfo:nil repeats:YES];
}

- (void)onRecordTimerTriggered:(NSTimer *)timer {
    [self.recorder updateMeters];

    if (self.isUsingCallKitRecorder) {
        /// To ensure the callkit recorder's recording time is enough for 60 seconds.
        self.currentRecordTime += 0.2;
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:didRecordTimeChanged:)]) {
            [self.delegate audioRecorder:self didRecordTimeChanged:self.currentRecordTime];
        }
    } else {
        float power = [self.recorder averagePowerForChannel:0];
        NSTimeInterval currentTime = self.recorder.currentTime;
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:didPowerChanged:)]) {
            [self.delegate audioRecorder:self didPowerChanged:power];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:didRecordTimeChanged:)]) {
            [self.delegate audioRecorder:self didRecordTimeChanged:currentTime];
        }
    }
}

- (void)checkMicPermissionWithCompletion:(void (^)(BOOL isGranted, BOOL isFirstChek))completion {
    AVAudioSessionRecordPermission permission = AVAudioSession.sharedInstance.recordPermission;

    /**
     * For the first request for authorization after a new installation, it is necessary to
     * determine whether it is Undetermined again to avoid errors.
     */
    if (permission == AVAudioSessionRecordPermissionDenied || permission == AVAudioSessionRecordPermissionUndetermined) {
        [AVAudioSession.sharedInstance requestRecordPermission:^(BOOL granted) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(granted, YES);
            }
          });
        }];
        return;
    }

    BOOL isGranted = permission == AVAudioSessionRecordPermissionGranted;
    if (completion) {
        completion(isGranted, NO);
    }
}

#pragma mark-- Record audio using system framework
- (void)startSystemRecording {
    self.isUsingCallKitRecorder = NO;

    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setActive:YES error:&error];

    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                            /**
                                                             * Sampling rate: 8000/11025/22050/44100/96000 (this parameter affects the audio
                                                             * quality)
                                                             */
                                                            [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                                            /**
                                                             * Audio format
                                                             */
                                                            [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                                            /**
                                                             * Sampling bits: 8, 16, 24, 32, default is 16
                                                             */
                                                            [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                                            /**
                                                             * Number of audio channels 1 or 2
                                                             */
                                                            [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                                            /**
                                                             * Recording quality
                                                             */
                                                            [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey, nil];

    [self createRecordedFilePath];

    NSURL *url = [NSURL fileURLWithPath:self.recordedFilePath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    [self.recorder record];
    [self.recorder updateMeters];

    [self triggerRecordTimer];
    NSLog(@"start system recording");
}

- (void)stopSystemRecording {
    if (AVAudioSession.sharedInstance.recordPermission == AVAudioSessionRecordPermissionDenied) {
        return;
    }

    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }

    self.recorder = nil;
    NSLog(@"stop system recording");
}

- (void)cancelSystemRecording {
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }

    NSString *path = self.recorder.url.path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    self.recorder = nil;
    NSLog(@"cancel system recording");
}

#pragma mark-- Record audio using TUICallKit framework
- (BOOL)startCallKitRecording {
    if (![TUICore getService:TUICore_TUIAudioMessageRecordService]) {
        NSLog(@"TUICallKit audio recording service does not exist");
        return NO;
    }
    NSString *signature = [TUIAIDenoiseSignatureManager sharedInstance].signature;
    if (signature.length == 0) {
        NSLog(@"denoise signature is empty");
        return NO;
    }

    NSMutableDictionary *audioRecordParam = [[NSMutableDictionary alloc] init];
    [audioRecordParam setValue:signature forKey:TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SignatureKey];
    [audioRecordParam setValue:@([TUILogin getSdkAppID]) forKey:TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SdkappidKey];
    [audioRecordParam setValue:self.recordedFilePath forKey:TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_PathKey];

    @weakify(self);
    void (^startCallBack)(NSInteger errorCode, NSString *errorMessage, NSDictionary *param) =
        ^(NSInteger errorCode, NSString *errorMessage, NSDictionary *param) {
          @strongify(self);
          NSString *method = param[@"method"];
          if ([method isEqualToString:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey]) {
              [self onTUICallKitRecordStarted:errorCode];
          }
        };

    [TUICore callService:TUICore_TUIAudioMessageRecordService
                  method:TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod
                   param:audioRecordParam
          resultCallback:startCallBack];

    self.isUsingCallKitRecorder = YES;
    NSLog(@"start TUICallKit recording");
    return true;
}

- (void)stopCallKitRecording {
    @weakify(self);
    void (^stopCallBack)(NSInteger errorCode, NSString *errorMessage, NSDictionary *param) =
        ^(NSInteger errorCode, NSString *errorMessage, NSDictionary *param) {
          @strongify(self);
          NSString *method = param[@"method"];
          if ([method isEqualToString:TUICore_RecordAudioMessageNotify_StopRecordAudioMessageSubKey]) {
              [self onTUICallKitRecordCompleted:errorCode];
          }
        };

    [TUICore callService:TUICore_TUIAudioMessageRecordService
                  method:TUICore_TUIAudioMessageRecordService_StopRecordAudioMessageMethod
                   param:nil
          resultCallback:stopCallBack];

    NSLog(@"stop TUICallKit recording");
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_RecordAudioMessageNotify]) {
        if (param == nil) {
            NSLog(@"TUICallKit notify param is invalid");
            return;
        }
        if ([subKey isEqualToString:TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey]) {
            NSUInteger volume = [param[@"volume"] unsignedIntegerValue];
            [self onTUICallKitVolumeChanged:volume];
        }
    }
}

- (void)onTUICallKitRecordStarted:(NSInteger)errorCode {
    switch (errorCode) {
        case TUICore_RecordAudioMessageNotifyError_None: {
            [self triggerRecordTimer];
            break;
        }
        case TUICore_RecordAudioMessageNotifyError_MicPermissionRefused: {
            break;
        }
        case TUICore_RecordAudioMessageNotifyError_StatusInCall: {
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitInputRecordRejectedInCall)];
            break;
        }
        case TUICore_RecordAudioMessageNotifyError_StatusIsAudioRecording: {
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitInputRecordRejectedIsRecording)];
            break;
        }
        case TUICore_RecordAudioMessageNotifyError_RequestAudioFocusFailed:
        case TUICore_RecordAudioMessageNotifyError_RecordInitFailed:
        case TUICore_RecordAudioMessageNotifyError_PathFormatNotSupport:
        case TUICore_RecordAudioMessageNotifyError_MicStartFail:
        case TUICore_RecordAudioMessageNotifyError_MicNotAuthorized:
        case TUICore_RecordAudioMessageNotifyError_MicSetParamFail:
        case TUICore_RecordAudioMessageNotifyError_MicOccupy: {
            [self stopCallKitRecording];
            NSLog(@"start TUICallKit recording failed, errorCode: %ld", (long)errorCode);
            break;
        }
        case TUICore_RecordAudioMessageNotifyError_InvalidParam:
        case TUICore_RecordAudioMessageNotifyError_SignatureError:
        case TUICore_RecordAudioMessageNotifyError_SignatureExpired:
        default: {
            [self stopCallKitRecording];
            [self startSystemRecording];
            NSLog(@"start TUICallKit recording failed, errorCode: %ld, switch to system recorder", (long)errorCode);
            break;
        }
    }
}

- (void)onTUICallKitRecordCompleted:(NSInteger)errorCode {
    switch (errorCode) {
        case TUICore_RecordAudioMessageNotifyError_None: {
            [self stopRecordTimer];
            break;
        }
        case TUICore_RecordAudioMessageNotifyError_NoMessageToRecord:
        case TUICore_RecordAudioMessageNotifyError_RecordFailed: {
            NSLog(@"stop TUICallKit recording failed, errorCode: %ld", (long)errorCode);
        }
        default:
            break;
    }
}

- (void)onTUICallKitVolumeChanged:(NSUInteger)volume {
    /// Adapt volume to power.
    float power = (NSInteger)volume - 90;
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:didPowerChanged:)]) {
        [self.delegate audioRecorder:self didPowerChanged:power];
    }
}

@end
