
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/** 腾讯云 TUIKit
 *  - 本类依赖于腾讯云 IM SDK 实现
 *  - TUIKit 中的组件在实现 UI 功能的同时，调用 IM SDK 相应的接口实现 IM 相关逻辑和数据的处理
 *  - 您可以在TUIKit的基础上做一些个性化拓展，即可轻松接入IM SDK
 *
 * Tencent Cloud TUIKit
 * - This class depends on the implementation of Tencent Cloud Chat SDK
 * - While implementing UI functions, components in TUIKit call corresponding interfaces of IM SDK to process IM-related logic and data
 * - You can make some customized extensions on the basis of TUIKit, and you can easily access the IM SDK
 */

#import <UIKit/UIKit.h>
@import ImSDK_Plus;

/**
 *  TUIKit 用户状态枚举
 *
 *  TUser_Status_ForceOffline   用户被强制下线
 *  TUser_Status_ReConnFailed   用户重连失败
 *  TUser_Status_SigExpired     用户身份（usersig）过期
 */

/**
 *  The definition of user status in TUIKit
 *
 *  TUser_Status_ForceOffline   The user was forced offline
 *  TUser_Status_ReConnFailed   The user failed to reconnect
 *  TUser_Status_SigExpired     The user identify (usersig) expired
 */
typedef NS_ENUM(NSUInteger, TUIUserStatus) {
    TUser_Status_ForceOffline,
    TUser_Status_ReConnFailed,
    TUser_Status_SigExpired,
};

@interface TUIKit : NSObject

+ (instancetype)sharedInstance;

/**
 *  收到音视频通话邀请推送
 *
 *  Receiving an audio or video call invitation push
 *
 */
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;

/**
 *  IMSDK sdkAppId
 */
@property(readonly) UInt32 sdkAppId;

/**
 *  userID
 */
@property(readonly) NSString *userID;

/**
 *  userSig
 */
@property(readonly) NSString *userSig;

/**
 * nickName
 */
@property(readonly) NSString *nickName;

/**
 * faceUrl
 */
@property(readonly) NSString *faceUrl;

@end
