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
 * 创建 TUICallKit 实例（单例模式）
 */
+ (instancetype)createInstance NS_SWIFT_NAME(createInstance());

/**
 * 设置用户的昵称、头像
 *
 * @param nickname 目标用户的昵称
 * @param avatar   目标用户的头像
 */
- (void)setSelfInfo:(NSString *_Nullable)nickname avatar:(NSString *_Nullable)avatar succ:(TUICallSucc)succ fail:(TUICallFail)fail NS_SWIFT_NAME(setSelfInfo(nickname:avatar:succ:fail:));

/**
 * 拨打电话（1v1通话）
 *
 * @param userId        目标用户的 userId
 * @param callMediaType 通话的媒体类型，比如视频通话、语音通话
 */
- (void)call:(NSString *)userId callMediaType:(TUICallMediaType)callMediaType NS_SWIFT_NAME(call(userId:callMediaType:));

/**
 * 拨打电话（1v1通话）
 *
 * @param userId        目标用户的 userId
 * @param callMediaType 通话的媒体类型，比如视频通话、语音通话
 * @param params        通话参数扩展字段，例如：离线推送自定义内容
 */
- (void)call:(NSString *)userId callMediaType:(TUICallMediaType)callMediaType params:(TUICallParams *)params succ:(TUICallSucc __nullable)succ fail:(TUICallFail __nullable)fail NS_SWIFT_NAME(call(userId:callMediaType:params:succ:fail:));

/**
 * 发起群组通话
 *
 * @param groupId       此次群组通话的群 ID
 * @param userIdList    目标用户的 userId 列表
 * @param callMediaType 通话的媒体类型，比如视频通话、语音通话
 */
- (void)groupCall:(NSString *)groupId userIdList:(NSArray<NSString *> *)userIdList callMediaType:(TUICallMediaType)callMediaType NS_SWIFT_NAME(groupCall(groupId:userIdList:callMediaType:));

/**
 * 发起群组通话
 *
 * @param groupId       此次群组通话的群 ID
 * @param userIdList    目标用户的 userId 列表
 * @param callMediaType 通话的媒体类型，比如视频通话、语音通话
 * @param params        通话参数扩展字段，例如：离线推送自定义内容
 */
- (void)groupCall:(NSString *)groupId
       userIdList:(NSArray<NSString *> *)userIdList
    callMediaType:(TUICallMediaType)callMediaType
           params:(TUICallParams *)params
             succ:(TUICallSucc __nullable)succ
             fail:(TUICallFail __nullable)fail NS_SWIFT_NAME(groupCall(groupId:userIdList:callMediaType:params:succ:fail:));

/**
 * 加入群组中已有的音视频通话
 *
 * @param roomId        此次通话的音视频房间 ID，目前仅支持数字房间号，后续版本会支持字符串房间号
 * @param groupId       此次群组通话的群 ID
 * @param callMediaType 通话的媒体类型，比如视频通话、语音通话
 */
- (void)joinInGroupCall:(TUIRoomId *)roomId groupId:(NSString *)groupId callMediaType:(TUICallMediaType)callMediaType NS_SWIFT_NAME(joinInGroupCall(roomId:groupId:callMediaType:));

/**
 * 设置自定义来电铃音
 *
 * @param filePath 被叫用户铃声地址
 */
- (void)setCallingBell:(NSString *)filePath NS_SWIFT_NAME(setCallingBell(filePath:));

/**
 * 开启/关闭静音模式
 */
- (void)enableMuteMode:(BOOL)enable NS_SWIFT_NAME(enableMuteMode(enable:));

/**
 * 开启/关闭悬浮窗功能
 * 默认为NO，通话界面左上角的悬浮窗按钮隐藏，设置为 YES 后显示。
 */
- (void)enableFloatWindow:(BOOL)enable NS_SWIFT_NAME(enableFloatWindow(enable:));

/**
 * 支持自定义View
 *
 * @param enable 支持自定义View
 */
- (void)enableCustomViewRoute:(BOOL)enable NS_SWIFT_NAME(enableCustomViewRoute(enable:));

- (UIViewController *_Nullable)getCallViewController NS_SWIFT_NAME(getCallViewController());

@end

NS_ASSUME_NONNULL_END
