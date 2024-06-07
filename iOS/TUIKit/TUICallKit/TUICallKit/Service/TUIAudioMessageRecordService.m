//
//  TUIAudioMessageRecordService.m
//  TUICallKit
//
//  Created by noah on 2022/11/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TUIAudioMessageRecordService.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "NSDictionary+TUISafe.h"
#import "TUICallEngineHeader.h"
#import "TUILogin.h"
#import "TUICallKitHeader.h"
#import "TUICallingCommon.h"
#import "TUICallingStatusManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIAudioRecordInfo : NSObject
/// 录制文件地址
@property (nonatomic, copy) NSString *path;
/// 应用的 SDKAppID
@property (nonatomic, assign) NSInteger sdkAppId;
/// AI 降噪签名
@property (nonatomic, copy) NSString *signature;

@end

NS_ASSUME_NONNULL_END

@implementation TUIAudioRecordInfo

@end

@interface TUIAudioMessageRecordService () <TUIServiceProtocol, TUINotificationProtocol, TRTCCloudDelegate, TUICallObserver>

@property (nonatomic, strong) TUIAudioRecordInfo *mAudioRecordInfo;
@property (nonatomic, assign) AVAudioSessionCategory mCategory;
@property (nonatomic, assign) AVAudioSessionCategoryOptions mCategoryOptions;
/**
 * Result callback for calling other service
 */
@property (nonatomic, copy) TUICallServiceResultCallback callback;

@end

@implementation TUIAudioMessageRecordService

+ (void)load {
    [TUICore registerService:TUICore_TUIAudioMessageRecordService object:[TUIAudioMessageRecordService shareInstance]];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[self alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionInterruptionNotification:)
                                                     name:AVAudioSessionInterruptionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSuccessNotification)
                                                     name:TUILoginSuccessNotification object:nil];
    }
    return self;
}

- (void)loginSuccessNotification {
    [[TUICallEngine createInstance] addObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    return nil;
}

- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param resultCallback:(TUICallServiceResultCallback) resultCallback {
    self.callback = resultCallback;
    
    if ([method isEqualToString:TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod]) {
        if (![TUICallingCommon checkDictionaryValid:param]) {
            [self notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey
                                        errCode:TUICore_RecordAudioMessageNotifyError_InvalidParam
                                           path:nil];
            return nil;
        }
        
        /// 如果当前在通话中,不支持录音
        if (TUICallStatusNone != [TUICallingStatusManager shareInstance].callStatus) {
            [self notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey
                                        errCode:TUICore_RecordAudioMessageNotifyError_StatusInCall
                                           path:nil];
            return nil;
        }
        
        /// 当前已经在录音中
        if (self.mAudioRecordInfo) {
            [self notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey
                                        errCode:TUICore_RecordAudioMessageNotifyError_StatusIsAudioRecording
                                           path:nil];
            return nil;
        }
        
        __weak typeof(self) weakSelf = self;
        [self requestRecordAuthorization:^(BOOL granted) {
            __strong typeof(self) strongSelf = weakSelf;
            if (granted) {
                /// 获取音频焦点
                if (![strongSelf requestAudioFocus]) {
                    [strongSelf notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey
                                                      errCode:TUICore_RecordAudioMessageNotifyError_RequestAudioFocusFailed
                                                         path:nil];
                } else {
                    strongSelf.mAudioRecordInfo = [TUIAudioRecordInfo new];
                    NSString *pathKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_PathKey;
                    strongSelf.mAudioRecordInfo.path = [param tui_objectForKey:pathKey
                                                                       asClass:NSString.class];
                    NSNumber *sdkAppId = [param tui_objectForKey:TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SdkappidKey
                                                         asClass:NSNumber.class];
                    if (sdkAppId) {
                        strongSelf.mAudioRecordInfo.sdkAppId = [sdkAppId integerValue];
                    }
                    NSString *signatureKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SignatureKey;
                    strongSelf.mAudioRecordInfo.signature = [param tui_objectForKey:signatureKey
                                                                            asClass:NSString.class];
                    /// 开启音频采集
                    [[TRTCCloud sharedInstance] setDelegate:strongSelf];
                    /// 启用音量大小
                    [[TRTCCloud sharedInstance] enableAudioVolumeEvaluation:500 enable_vad:YES];
                    [strongSelf startRecordAudioMessage];
                }
            } else {
                __strong typeof(self) strongSelf = weakSelf;
                /// 获取麦克风权限失败
                [strongSelf notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey
                                                  errCode:TUICore_RecordAudioMessageNotifyError_MicPermissionRefused
                                                     path:nil];
            }
        }];
        return nil;
    } else if ([method isEqualToString:TUICore_TUIAudioMessageRecordService_StopRecordAudioMessageMethod]) {
        [self stopRecordAudioMessage];
    }
    
    return nil;
}

- (void)requestRecordAuthorization:(void (^)(BOOL granted))response {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission permission = session.recordPermission;
    
    if (permission == AVAudioSessionRecordPermissionUndetermined) {
        [session requestRecordPermission:response];
    } else if (permission == AVAudioSessionRecordPermissionGranted) {
        if (response) {
            response(YES);
        }
    } else if (permission == AVAudioSessionRecordPermissionDenied) {
        if (response) {
            response(NO);
        }
    }
}

- (void)startRecordAudioMessage {
    if (!self.mAudioRecordInfo) {
        return;
    }
    NSString *sdkAppIdKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SdkappidKey;
    NSString *pathKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_PathKey;
    NSDictionary *jsonDic =
    @{@"api": @"startRecordAudioMessage",
      @"params": @{@"key": self.mAudioRecordInfo.signature ?: @"",
                   sdkAppIdKey: @(self.mAudioRecordInfo.sdkAppId),
                   pathKey: self.mAudioRecordInfo.path ?: @""}};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSAssert(NO, @"invalid jsonDic");
        return;
    }
    [[TRTCCloud sharedInstance] callExperimentalAPI:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (void)stopRecordAudioMessage {
    if (!self.mAudioRecordInfo) {
        return;
    }
    NSDictionary *jsonDic = @{@"api": @"stopRecordAudioMessage",
                              @"params": @{}};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSAssert(NO, @"invalid jsonDic");
        return;
    }
    [[TRTCCloud sharedInstance] callExperimentalAPI:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [[TRTCCloud sharedInstance] enableAudioVolumeEvaluation:0 enable_vad:NO];
    [[TRTCCloud sharedInstance] stopLocalAudio];
    // 清空录制信息
    self.mAudioRecordInfo = nil;
    // 释放音频焦点
    [self abandonAudioFocus];
}

#pragma mark - AVAudioSessionInterruptionNotification

- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (AVAudioSessionInterruptionTypeBegan == type) {
        [self stopRecordAudioMessage];
    }
}

#pragma mark - TUICallObserver

- (void)onCallReceived:(NSString *)callerId
          calleeIdList:(NSArray<NSString *> *)calleeIdList
               groupId:(NSString *)groupId
         callMediaType:(TUICallMediaType)callMediaType
              userData:(NSString *)userData{
    // 收到通话邀请,停止录制
    [self stopRecordAudioMessage];
}

#pragma mark - TRTCCloudDelegate

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    if (errCode == TUICore_RecordAudioMessageNotifyError_MicStartFail ||
        errCode == TUICore_RecordAudioMessageNotifyError_MicNotAuthorized ||
        errCode == TUICore_RecordAudioMessageNotifyError_MicSetParamFail ||
        errCode == TUICore_RecordAudioMessageNotifyError_MicOccupy) {
        [self notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey
                                    errCode:errCode
                                       path:nil];
    }
}

- (void)onLocalRecordBegin:(NSInteger)errCode storagePath:(NSString *)storagePath {
    if (errCode == TUICore_RecordAudioMessageNotifyError_None) {
        [[TRTCCloud sharedInstance] startLocalAudio:TRTCAudioQualitySpeech];
    }
    NSInteger tempCode = [self convertErrorCode:@"onLocalRecordBegin" errorCode:errCode];
    [self notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey
                                errCode:tempCode
                                   path:storagePath];
}

- (void)onLocalRecordComplete:(NSInteger)errCode storagePath:(NSString *)storagePath {
    NSInteger tempCode = [self convertErrorCode:@"onLocalRecordComplete" errorCode:errCode];
    [self notifyAudioMessageRecordEvent:TUICore_RecordAudioMessageNotify_StopRecordAudioMessageSubKey
                                errCode:tempCode
                                   path:storagePath];
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    for (TRTCVolumeInfo *volumeInfo in userVolumes) {
        if (!volumeInfo.userId || volumeInfo.userId.length == 0) {
            NSDictionary *param = @{TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey_VolumeKey: @(volumeInfo.volume)};
            [TUICore notifyEvent:TUICore_RecordAudioMessageNotify
                          subKey:TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey
                          object:nil
                           param:param];
            break;
        }
    }
}

#pragma mark - Private

- (BOOL)requestAudioFocus {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    self.mCategory = session.category;
    self.mCategoryOptions = session.categoryOptions;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    NSError *error = nil;
    if ([session setActive:YES error:&error] == NO) {
        return NO;
    }
    return YES;
}

- (BOOL)abandonAudioFocus {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:self.mCategory withOptions:self.mCategoryOptions error:nil];
    
    NSError *error = nil;
    if ([session setActive:NO
               withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                     error:&error] == NO) {
        return NO;
    }
    return YES;
}

- (void)notifyAudioMessageRecordEvent:(NSString *)method errCode:(NSInteger)errCode path:(NSString *)path {
    NSDictionary *param = @{@"method": method ?: @"", @"errorCode": @(errCode), @"path": path ?: @""};
    if (self.callback) {
        self.callback(errCode,@"",param);
    }
}

- (NSInteger)convertErrorCode:(NSString *)method errorCode:(NSInteger)errorCode {
    NSInteger targetCode;
    switch (errorCode) {
        case -1:
            if (method && [method isEqualToString:@"onLocalRecordBegin"]) {
                targetCode = TUICore_RecordAudioMessageNotifyError_RecordInitFailed;
            } else {
                targetCode = TUICore_RecordAudioMessageNotifyError_RecordFailed;
            }
            break;
        case -2:
            targetCode = TUICore_RecordAudioMessageNotifyError_PathFormatNotSupport;
            break;
        case -3:
            targetCode = TUICore_RecordAudioMessageNotifyError_NoMessageToRecord;
            break;
        case -4:
            targetCode = TUICore_RecordAudioMessageNotifyError_SignatureError;
            break;
        case -5:
            targetCode = TUICore_RecordAudioMessageNotifyError_SignatureExpired;
            break;
        default:
            targetCode = TUICore_RecordAudioMessageNotifyError_None;
            break;
    }
    return targetCode;
}

@end
