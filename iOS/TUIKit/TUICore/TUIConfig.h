//
//  TUIConfig.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/**
 *  本类依赖于腾讯云 IM SDK 实现
 *
 *  TUIConfig 实现了配置文件的默认初始化，您可以根据您的需求在此更改默认配置
 *  配置文件包括表情、默认图标等等
 *
 *  需要注意的是， TUIKit 里面的表情包都是有版权限制的，购买的 IM 服务不包括表情包的使用权，请在上线的时候替换成自己的表情包，否则会面临法律风险
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
 *  头像类型
 *  Type of avatar
 */
@property(nonatomic, assign) TUIKitAvatarType avatarType;

/**
 *  头像圆角大小
 *  The size of the rounded corners of the avatar
 */
@property(nonatomic, assign) CGFloat avatarCornerRadius;

/**
 *  默认头像图片
 *  Default user avatar
 */
@property(nonatomic, strong) UIImage *defaultAvatarImage;

/**
 *  默认群组头像图片
 *  Default group avatar
 */
@property(nonatomic, strong) UIImage *defaultGroupAvatarImage;

/**
 * 发消息不计入未读数，默认为 NO
 * When sending a message, the flag used to identify whether the current message is not counted as unread, the default is NO
 */
@property(nonatomic, assign) BOOL isExcludedFromUnreadCount;

/**
 * 发消息不更新会话的lastMesage，默认为 NO
 * When sending a message, the flag used to identify whether the current message does not update the lastMessage of the conversation, the default is NO
 */
@property(nonatomic, assign) BOOL isExcludedFromLastMessage;

/**
 * 是否允许 TUIKit 内部默认弹框提示
 * Whether to allow default pop-up prompts inside TUIKit
 */
@property(nonatomic, assign) BOOL enableToast;

/**
 * 是否开启自定义铃音（仅针对 Android 有效）
 * Whether to enable custom ringtone (only valid for Android)
 */
@property(nonatomic, assign) BOOL enableCustomRing;

/**
 * 在会话、联系人中展示用户的在线状态图标， 默认是 NO
 * Display users' online status in session and contact list. NO in default.
 */
@property(nonatomic, assign) BOOL displayOnlineStatusIcon;

/**
 * 群组头像，允许展示九宫格样式的头像，默认为 YES
 * Group avatar, allows to display avatars in the nine-square grid style, default is YES
 */
@property(nonatomic, assign) BOOL enableGroupGridAvatar;

- (UIImage *)getGroupAvatarImageByGroupType:(NSString *)groupType;

- (void)setSceneOptimizParams:(NSString *)path;  //(For RTC,Don't delete)

@end
