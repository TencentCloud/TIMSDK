//
//  TRTCCall+Room.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import "TUICall.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICall (Room)
///进入房间
- (void)enterRoom;

///退出房间
- (void)quitRoom;

///开启远程用户视频渲染
- (void)startRemoteView:(NSString *)userID view:(UIView *)view;

///关闭远程用户视频渲染
- (void)stopRemoteView:(NSString *)userID;

///打开摄像头
- (void)openCamera:(BOOL)frontCamera view:(UIView *)view;

///关闭摄像头
- (void)closeCamara;

///切换摄像头
- (void)switchCamera:(BOOL)frontCamera;

///静音操作
- (void)mute:(BOOL)isMute;

///免提操作
- (void)handsFree:(BOOL)isHandsFree;

///是否静音状态
- (BOOL)micMute;

///是否免提状态
- (BOOL)handsFreeOn;
@end

NS_ASSUME_NONNULL_END
