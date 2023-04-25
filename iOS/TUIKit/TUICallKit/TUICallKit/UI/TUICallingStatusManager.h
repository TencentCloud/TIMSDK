//
//  TUICallingStatusManager.h
//  TUICalling
//
//  Created by noah on 2022/7/12.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import "TUICallEngineHeader.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const EventSubCallStatusChanged;
FOUNDATION_EXTERN NSString * const EventSubCallMediaTypeChanged;
FOUNDATION_EXTERN NSString * const EventSubMicMuteChanged;

/**
 Status Manager Protocol
 */
@protocol TUICallingStatusManagerProtocol <NSObject>

- (void)updateCallType;

- (void)updateCallStatus;

- (void)updateIsCloseCamera;

- (void)updateMicMute;

- (void)updateAudioPlaybackDevice;

@end

/**
 Status Manager Class Protocol
 */
@interface TUICallingStatusManager : NSObject

/// Status Manager Protocol
@property (nonatomic, weak) id<TUICallingStatusManagerProtocol> delegate;
/// Calling Role
@property (nonatomic, assign) TUICallRole callRole;
/// Calling Media Type
@property (nonatomic, assign) TUICallMediaType callMediaType;
/// Calling Status
@property (nonatomic, assign) TUICallStatus callStatus;
/// Calling Scene
@property (nonatomic, assign) TUICallScene callScene;
/// is MicMute
@property (nonatomic, assign) BOOL isMicMute;
/// is Close Camera
@property (nonatomic, assign) BOOL isCloseCamera;
/// Audio Playback Device Type
@property (nonatomic, assign) TUIAudioPlaybackDevice audioPlaybackDevice;
/// Camera Type
@property (nonatomic, assign) TUICamera camera;
/// Group ID
@property (nonatomic, copy) NSString * _Nullable groupId;


+ (instancetype)shareInstance;

- (void)clearAllStatus;

@end

NS_ASSUME_NONNULL_END
