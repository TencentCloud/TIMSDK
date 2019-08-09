//
//  FriendRequestViewController.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/4/18.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo 添加好友视图
 *  本文件实现了添加好友时的视图，在您想要添加其他用户为好友时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>
#import "TIMFriendshipManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestViewController : UIViewController
@property TIMUserProfile *profile;
@end

NS_ASSUME_NONNULL_END
