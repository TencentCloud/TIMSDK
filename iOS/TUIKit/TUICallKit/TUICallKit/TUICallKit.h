//
//  TUICallKit.h
//  TUICalling
//
//  Created by noah on 2021/8/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUICallEngineHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICallKit : NSObject

+ (instancetype)createInstance
NS_SWIFT_NAME(createInstance());

/// Set user info
/// @param nickname  Username, which can contain up to 500 bytes
/// @param avatar avatar User profile photo URL, which can contain up to 500 bytes
///        For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
/// @param succ success callback
/// @param fail fail callback
- (void)setSelfInfo:(NSString * _Nullable)nickname avatar:(NSString * _Nullable)avatar succ:(TUICallSucc)succ fail:(TUICallFail)fail
NS_SWIFT_NAME(setSelfInfo(nickname:avatar:succ:fail:));

/// Make a call
/// @param userId  callee
/// @param callMediaType Call type
- (void)call:(NSString *)userId callMediaType:(TUICallMediaType)callMediaType 
NS_SWIFT_NAME(call(userId:callMediaType:));

- (void)call:(NSString *)userId
callMediaType:(TUICallMediaType)callMediaType
      params:(TUICallParams *)params
        succ:(TUICallSucc __nullable)succ
        fail:(TUICallFail __nullable)fail
NS_SWIFT_NAME(call(userId:callMediaType:params:succ:fail:));

- (void)groupCall:(NSString *)groupId userIdList:(NSArray<NSString *> *)userIdList callMediaType:(TUICallMediaType)callMediaType
NS_SWIFT_NAME(groupCall(groupId:userIdList:callMediaType:));

- (void)groupCall:(NSString *)groupId
       userIdList:(NSArray<NSString *> *)userIdList
    callMediaType:(TUICallMediaType)callMediaType
           params:(TUICallParams *)params
             succ:(TUICallSucc __nullable)succ
             fail:(TUICallFail __nullable)fail
NS_SWIFT_NAME(groupCall(groupId:userIdList:callMediaType:params:succ:fail:));

/// Join a current call
/// @param roomId current call room ID
/// @param groupId group ID
/// @param callMediaType call type
- (void)joinInGroupCall:(TUIRoomId *)roomId groupId:(NSString *)groupId callMediaType:(TUICallMediaType)callMediaType
NS_SWIFT_NAME(joinInGroupCall(roomId:groupId:callMediaType:));

/// Set the ringtone (preferably shorter than 30s)
/// @param filePath Callee ringtone path
- (void)setCallingBell:(NSString *)filePath
NS_SWIFT_NAME(setCallingBell(filePath:));

/// Enable the mute mode (the callee doesn't ring)
- (void)enableMuteMode:(BOOL)enable
NS_SWIFT_NAME(enableMuteMode(enable:));

/// Enable the floating window
- (void)enableFloatWindow:(BOOL)enable
NS_SWIFT_NAME(enableFloatWindow(enable:));

/// Enable custom UI
/// @param enable After enabling custom UI, you will receive a `CallingView` instance in the callback for calling/being called, and can decide how to display the view by yourself.
- (void)enableCustomViewRoute:(BOOL)enable
NS_SWIFT_NAME(enableCustomViewRoute(enable:));

- (UIViewController * _Nullable)getCallViewController
NS_SWIFT_NAME(getCallViewController());

@end

NS_ASSUME_NONNULL_END
