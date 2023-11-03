//
//  TUICallingAction.m
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingAction.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import "TUICallEngineHeader.h"
#import "TUICallingStatusManager.h"
#import "TUICommonModel.h"
#import "TUICallKitOfflinePushInfoConfig.h"
#import "TUICallingUserManager.h"
#import "TUICallKitConstants.h"

@implementation TUICallingAction

+ (void)accept {
    [[TUICallEngine createInstance] accept:^{
        [TUICallingStatusManager shareInstance].callStatus = TUICallStatusAccept;
    } fail:^(int code, NSString *errMsg) {
        [TUICallingStatusManager shareInstance].callStatus = TUICallStatusNone;
    }];
}

+ (void)reject {
    [[TUICallEngine createInstance] reject:^{
        [TUICallingStatusManager shareInstance].callStatus = TUICallStatusNone;
    } fail:^(int code, NSString *errMsg) {
        [TUICallingStatusManager shareInstance].callStatus = TUICallStatusNone;
    }];
}

+ (void)hangup {
    [[TUICallEngine createInstance] hangup:^{
        [TUICallingStatusManager shareInstance].callStatus = TUICallStatusNone;
    } fail:^(int code, NSString *errMsg) {
        [TUICallingStatusManager shareInstance].callStatus = TUICallStatusNone;
    }];
}

+ (void)switchToAudioCall {
    [[TUICallEngine createInstance] switchCallMediaType:TUICallMediaTypeAudio];
}

+ (void)openCamera:(TUICamera)camera videoView:(TUIVideoView *)videoView {
    [[TUICallEngine createInstance] openCamera:camera videoView:videoView succ:^{
        [TUICallingStatusManager shareInstance].isCloseCamera = NO;
    } fail:^(int code, NSString *errMsg) {
    }];
}

+ (void)closeCamera {
    [[TUICallEngine createInstance] closeCamera];
    [TUICallingStatusManager shareInstance].isCloseCamera = YES;
}

+ (void)switchCamera{
    TUICamera callingCamera = TUICameraFront;
    
    if ([TUICallingStatusManager shareInstance].camera == TUICameraFront) {
        callingCamera = TUICameraBack;
    }
    
    [[TUICallEngine createInstance] switchCamera:callingCamera];
    [TUICallingStatusManager shareInstance].camera = callingCamera;
}

+ (void)openMicrophone {
    if ([TUICallingStatusManager shareInstance].callStatus != TUICallStatusAccept) {
        [TUICallingStatusManager shareInstance].isMicMute = YES;
        return;
    }
    [[TUICallEngine createInstance] openMicrophone:^{
        [TUICallingStatusManager shareInstance].isMicMute = YES;
        [TUICore notifyEvent:TUICore_TUICallKitVoIPExtensionNotify
                      subKey:TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey
                      object:nil param:nil];
    } fail:^(int code, NSString *errMsg) {
    }];
}

+ (void)closeMicrophone {
    if ([TUICallingStatusManager shareInstance].callStatus != TUICallStatusAccept) {
        [TUICallingStatusManager shareInstance].isMicMute = NO;
        return;
    }
    [[TUICallEngine createInstance] closeMicrophone];
    [TUICore notifyEvent:TUICore_TUICallKitVoIPExtensionNotify
                  subKey:TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey
                  object:nil param:nil];
    [TUICallingStatusManager shareInstance].isMicMute = NO;
}

+ (void)selectAudioPlaybackDevice {
    TUIAudioPlaybackDevice device = TUIAudioPlaybackDeviceSpeakerphone;
    
    if ([TUICallingStatusManager shareInstance].audioPlaybackDevice == TUIAudioPlaybackDeviceSpeakerphone) {
        device = TUIAudioPlaybackDeviceEarpiece;
    }
    
    [[TUICallEngine createInstance] selectAudioPlaybackDevice:device];
    [TUICallingStatusManager shareInstance].audioPlaybackDevice = device;
}

+ (void)inviteUser:(NSArray<TUIUserModel *> *)userList succ:(void(^)(NSArray *userIDs))succ fail:(TUICallFail)fail {
    NSMutableArray *userIdList = [NSMutableArray array];
    for (TUIUserModel *userModel in userList) {
        if (userModel.userId) {
            [userIdList addObject:userModel.userId];
        }
    }
    if (userIdList.count <= 0) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"inviteUser invalid userList");
        }
        return;
    }
    if ((userIdList.count + [TUICallingUserManager allUserIdList].count) > 9) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"TUICalling currently supports call with up to 9 people.");
        }
        return;
    }
    TUIOfflinePushInfo *offlinePushInfo = [TUICallKitOfflinePushInfoConfig createOfflinePushInfo];
    TUICallParams *callParams = [TUICallParams new];
    callParams.offlinePushInfo = offlinePushInfo;
    callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME;
    [[TUICallEngine createInstance] inviteUser:[userIdList copy] params:callParams succ:succ fail:fail];
}

+ (void)startRemoteView:(NSString *)userId
              videoView:(TUIVideoView *)videoView
              onPlaying:(void(^)(NSString *userId))onPlaying
              onLoading:(void(^)(NSString *userId))onLoading
                onError:(void(^)(NSString *userId, int code, NSString *errMsg))onError {
    [[TUICallEngine createInstance] startRemoteView:userId videoView:videoView onPlaying:onPlaying onLoading:onLoading onError:onError];
}

+ (void)stopRemoteView:(NSString *)userId {
    [[TUICallEngine createInstance] stopRemoteView:userId];
}

@end
