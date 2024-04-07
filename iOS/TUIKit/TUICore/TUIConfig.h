//
//  TUIConfig.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018 Tencent. All rights reserved.
//
/**
 *
 *
 * This class depends on the implementation of Tencent Cloud Chat SDK
 *
 * TUIConfig implements the default initialization of the configuration file, you can change the default configuration here according to your needs
 * Configuration file include emoticons, default icons, and more
 *
 * It should be noted that the emoticons in TUIKit are copyrighted. The purchased IM service does not include the right to use the emoticons. Please replace
 * them with your own emoticons when you go online, otherwise you will face legal risks.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

#define DefaultAvatarImage ([TUIConfig defaultConfig].defaultAvatarImage)
#define DefaultGroupAvatarImage ([TUIConfig defaultConfig].defaultGroupAvatarImage)
#define DefaultGroupAvatarImageByGroupType(groupType) ([[TUIConfig defaultConfig] getGroupAvatarImageByGroupType:groupType])

typedef NS_ENUM(NSInteger, TUIKitAvatarType) {
    TAvatarTypeNone,
    TAvatarTypeRounded,
    TAvatarTypeRadiusCorner,
};

@interface TUIConfig : NSObject

+ (TUIConfig *)defaultConfig;
/**
 *  Type of avatar
 */
@property(nonatomic, assign) TUIKitAvatarType avatarType;

/**
 *  The size of the rounded corners of the avatar
 */
@property(nonatomic, assign) CGFloat avatarCornerRadius;

/**
 *  Default user avatar
 */
@property(nonatomic, strong) UIImage *defaultAvatarImage;

/**
 *  Default group avatar
 */
@property(nonatomic, strong) UIImage *defaultGroupAvatarImage;

/**
 * When sending a message, the flag used to identify whether the current message is not counted as unread, the default is NO
 */
@property(nonatomic, assign) BOOL isExcludedFromUnreadCount;

/**
 * When sending a message, the flag used to identify whether the current message does not update the lastMessage of the conversation, the default is NO
 */
@property(nonatomic, assign) BOOL isExcludedFromLastMessage;

/**
 * Whether to allow default pop-up prompts inside TUIKit
 */
@property(nonatomic, assign) BOOL enableToast;

/**
 * Whether to enable custom ringtone (only valid for Android)
 */
@property(nonatomic, assign) BOOL enableCustomRing;

/**
 * Display users' online status in session and contact list. NO in default.
 */
@property(nonatomic, assign) BOOL displayOnlineStatusIcon;

/**
 * Group avatar, allows to display avatars in the nine-square grid style, default is YES
 */
@property(nonatomic, assign) BOOL enableGroupGridAvatar;

- (UIImage *)getGroupAvatarImageByGroupType:(NSString *)groupType;

- (void)setSceneOptimizParams:(NSString *)path;  //(For RTC,Don't delete)

@end
