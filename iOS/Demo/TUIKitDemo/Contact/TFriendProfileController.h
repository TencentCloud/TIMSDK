//
//  TFriendController.h
//  TUIKit
//
//  Created by annidyfeng on 2019/4/29.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo好友信息视图
 *  本文件实现了好友简介视图控制器，只在显示好友时使用该视图控制器
 *  若要显示非好友的用户信息，请查看TUIKitDemo/Chat/TUserProfileController.m
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>
@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface TFriendProfileController : UITableViewController

/**
 *  本属性为 IM SDK 中声明的类。
 *  包括好友 ID、好友备注、好友的用户信息等。
 */
@property (nonatomic, strong) V2TIMFriendInfo *friendProfile;

@end

NS_ASSUME_NONNULL_END
