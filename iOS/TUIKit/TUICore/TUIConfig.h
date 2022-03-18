//
//  TUIConfig.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云 TUIConfig
 *
 *
 *  本类依赖于腾讯云 IM SDK 实现
 *  TUIKit 中的组件在实现 UI 功能的同时，调用 IM SDK 相应的接口实现 IM 相关逻辑和数据的处理
 *  您可以在TUIKit的基础上做一些个性化拓展，即可轻松接入IM SDK
 *
 *  TUIConfig 实现了配置文件的默认初始化，您可以根据您的需求在此更改默认配置，或通过此类修改配置
 *  配置文件包括表情、默认图标等等
 *
 *  需要注意的是， TUIKit 里面的表情包都是有版权限制的，购买的 IM 服务不包括表情包的使用权，请在上线的时候替换成自己的表情包，否则会面临法律风险
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

#define DefaultAvatarImage ([TUIConfig defaultConfig].defaultAvatarImage)
#define DefaultGroupAvatarImage ([TUIConfig defaultConfig].defaultGroupAvatarImage)

typedef NS_ENUM(NSInteger, TUIKitAvatarType) {
    TAvatarTypeNone,             /*矩形直角头像*/
    TAvatarTypeRounded,          /*圆形头像*/
    TAvatarTypeRadiusCorner,     /*圆角头像*/
};

@interface TUIConfig : NSObject
/**
 *  获取 TUIConfig 实例
 */
+ (TUIConfig *)defaultConfig;
/**
 * 表情列表（需要注意的是， TUIKit 里面的表情包都是有版权限制的，购买的 IM 服务不包括表情包的使用权，请在上线的时候替换成自己的表情包，否则会面临法律风险）
 */
@property (nonatomic, strong) NSArray<TUIFaceGroup *> *faceGroups;
/**
 *  头像类型
 */
@property (nonatomic, assign) TUIKitAvatarType avatarType;
/**
 *  头像圆角大小
 */
@property (nonatomic, assign) CGFloat avatarCornerRadius;
/**
 *  默认头像图片
 */
@property (nonatomic, strong) UIImage *defaultAvatarImage;
/**
 *  默认群组头像图片
 */
@property (nonatomic, strong) UIImage *defaultGroupAvatarImage;

/**
 * 发消息不计入未读数 YES：启用 NO：关闭 默认：NO
 */
@property(nonatomic, assign) BOOL isExcludedFromUnreadCount;

/**
 * 发消息不更新会话的lastMesage，YES: 不更新，NO:更新。默认 NO。
 */
@property(nonatomic, assign) BOOL isExcludedFromLastMessage;

/**
 * 是否允许 SDK 内部默认弹框提示
 */
@property(nonatomic, assign) BOOL enableToast;

/**
 * 是否开启自定义铃音（仅针对 Android 有效）
 */
@property(nonatomic, assign) BOOL enableCustomRing;

- (void)setSceneOptimizParams:(NSString *)path;
@end
