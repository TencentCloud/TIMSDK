//
//  TUICallingAction.h
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUICallEngineHeader.h"

@class TUIUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingAction : NSObject

+ (void)accept;

+ (void)reject;

+ (void)hangup;

+ (void)switchToAudioCall;

+ (void)openCamera:(TUICamera)camera videoView:(TUIVideoView *)videoView;

+ (void)closeCamera;

+ (void)switchCamera;

+ (void)openMicrophone;

+ (void)closeMicrophone;

+ (void)selectAudioPlaybackDevice;

+ (void)inviteUser:(NSArray<TUIUserModel *> *)userList succ:(void(^)(NSArray *userIDs))succ fail:(TUICallFail)fail;

+ (void)startRemoteView:(NSString *)userId
              videoView:(TUIVideoView *)videoView
              onPlaying:(void(^)(NSString *userId))onPlaying
              onLoading:(void(^)(NSString *userId))onLoading
                onError:(void(^)(NSString *userId, int code, NSString *errMsg))onError;

+ (void)stopRemoteView:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
