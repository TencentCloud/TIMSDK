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

/**
 * Create a TUICallKit instance
 */
+ (instancetype)createInstance NS_SWIFT_NAME(createInstance());

/**
 * Set user profile
 *
 * @param nickname  User name, which can contain up to 500 bytes
 * @param avatar  User profile photo URL, which can contain up to 500 bytes
 * For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
 */
- (void)setSelfInfo:(NSString *_Nullable)nickname avatar:(NSString *_Nullable)avatar succ:(TUICallSucc)succ fail:(TUICallFail)fail NS_SWIFT_NAME(setSelfInfo(nickname:avatar:succ:fail:));

/**
 * Make a call
 *
 * @param userId  Callees
 * @param callMediaType  Call type
 */
- (void)call:(NSString *)userId callMediaType:(TUICallMediaType)callMediaType NS_SWIFT_NAME(call(userId:callMediaType:));

/**
 * Make a call
 *
 * @param userId  Callees
 * @param callMediaType  Call type
 * @param params  Extension param: eg: offlinePushInfo
 */
- (void)call:(NSString *)userId callMediaType:(TUICallMediaType)callMediaType params:(TUICallParams *)params succ:(TUICallSucc __nullable)succ fail:(TUICallFail __nullable)fail NS_SWIFT_NAME(call(userId:callMediaType:params:succ:fail:));

/**
 * Make a group call
 *
 * @param groupId  GroupId
 * @param userIdList  List of userId
 * @param callMediaType  Call type
 */
- (void)groupCall:(NSString *)groupId userIdList:(NSArray<NSString *> *)userIdList callMediaType:(TUICallMediaType)callMediaType NS_SWIFT_NAME(groupCall(groupId:userIdList:callMediaType:));

/**
 * Make a group call
 *
 * @param groupId  GroupId
 * @param userIdList  List of userId
 * @param callMediaType  Call type
 * @param params  Extension param: eg: offlinePushInfo
 */
- (void)groupCall:(NSString *)groupId
       userIdList:(NSArray<NSString *> *)userIdList
    callMediaType:(TUICallMediaType)callMediaType
           params:(TUICallParams *)params
             succ:(TUICallSucc __nullable)succ
             fail:(TUICallFail __nullable)fail NS_SWIFT_NAME(groupCall(groupId:userIdList:callMediaType:params:succ:fail:));

/**
 * Join a current call
 *
 * @param roomId  Current call room ID
 * @param groupId  Current group ID
 * @param callMediaType  Call type
 */
- (void)joinInGroupCall:(TUIRoomId *)roomId groupId:(NSString *)groupId callMediaType:(TUICallMediaType)callMediaType NS_SWIFT_NAME(joinInGroupCall(roomId:groupId:callMediaType:));

/**
 * Set the ringtone (preferably shorter than 30s)
 *
 * @param filePath  Callee ringtone path
 */
- (void)setCallingBell:(NSString *)filePath NS_SWIFT_NAME(setCallingBell(filePath:));

/**
 * Enable the mute mode (the callee doesn't ring)
 */
- (void)enableMuteMode:(BOOL)enable NS_SWIFT_NAME(enableMuteMode(enable:));

/**
 * Enable the floating window
 */
- (void)enableFloatWindow:(BOOL)enable NS_SWIFT_NAME(enableFloatWindow(enable:));

/**
 * Support custom View
 */
- (void)enableCustomViewRoute:(BOOL)enable NS_SWIFT_NAME(enableCustomViewRoute(enable:));

/**
 * Get TUICallKit ViewController
 */
- (UIViewController *_Nullable)getCallViewController NS_SWIFT_NAME(getCallViewController());

@end

NS_ASSUME_NONNULL_END
