
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * Tencent Cloud TUIKit
 * - This class depends on the implementation of Tencent Cloud Chat SDK
 * - While implementing UI functions, components in TUIKit call corresponding interfaces of IM SDK to process IM-related logic and data
 * - You can make some customized extensions on the basis of TUIKit, and you can easily access the IM SDK
 */

#import <UIKit/UIKit.h>
@import ImSDK_Plus;

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
 *  
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
