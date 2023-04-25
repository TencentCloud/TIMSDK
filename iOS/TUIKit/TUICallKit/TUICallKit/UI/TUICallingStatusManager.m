//
//  TUICallingStatusManager.m
//  TUICalling
//
//  Created by noah on 2022/7/12.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingStatusManager.h"

NSString * const EventSubCallStatusChanged = @"eventSubCallStatusChanged";
NSString * const EventSubCallMediaTypeChanged = @"eventSubCallMediaTypeChanged";
NSString * const EventSubMicMuteChanged = @"eventSubMicMuteChanged";

@implementation TUICallingStatusManager

+ (instancetype)shareInstance {
    static dispatch_once_t gOnceToken;
    static TUICallingStatusManager * gSharedInstance = nil;
    dispatch_once(&gOnceToken, ^{
        gSharedInstance = [[TUICallingStatusManager alloc] init];
    });
    return gSharedInstance;
}

- (void)clearAllStatus {
    self.callRole = TUICallRoleNone;
    self.callMediaType = TUICallMediaTypeUnknown;
    self.callStatus = TUICallStatusNone;
    self.isMicMute = NO;
    self.isCloseCamera = NO;
    self.audioPlaybackDevice = TUIAudioPlaybackDeviceSpeakerphone;
    self.camera = TUICameraFront;
    self.groupId = nil;
}

- (void)setIsMicMute:(BOOL)isMicMute {
    if (_isMicMute == isMicMute) {
        return;
    }
    
    _isMicMute = isMicMute;
    [[NSNotificationCenter defaultCenter] postNotificationName:EventSubMicMuteChanged object:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateMicMute)]) {
        [self.delegate updateMicMute];
    }
}

- (void)setCamera:(TUICamera)camera {
    if (_camera == camera) {
        return;
    }
    
    _camera = camera;
}

- (void)setIsCloseCamera:(BOOL)isCloseCamera {
    if (_isCloseCamera == isCloseCamera) {
        return;
    }
    
    _isCloseCamera = isCloseCamera;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateIsCloseCamera)]) {
        [self.delegate updateIsCloseCamera];
    }
}

- (void)setCallStatus:(TUICallStatus)callStatus {
    if (_callStatus == callStatus) {
        return;
    }
    
    _callStatus = callStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:EventSubCallStatusChanged object:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateCallStatus)]) {
        [self.delegate updateCallStatus];
    }
}

- (void)setCallMediaType:(TUICallMediaType)callType {
    if (_callMediaType == callType) {
        return;
    }
    
    _callMediaType = callType;
    [[NSNotificationCenter defaultCenter] postNotificationName:EventSubCallMediaTypeChanged object:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateCallType)]) {
        [self.delegate updateCallType];
    }
}

- (void)setAudioPlaybackDevice:(TUIAudioPlaybackDevice)audioPlaybackDevice {
    if (_audioPlaybackDevice == audioPlaybackDevice) {
        return;
    }
    
    _audioPlaybackDevice = audioPlaybackDevice;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateAudioPlaybackDevice)]) {
        [self.delegate updateAudioPlaybackDevice];
    }
}

@end
