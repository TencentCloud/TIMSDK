//
//  TProfileController.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo 用户信息视图
 *  本文件实现了用户信息的视图，在您想要查看其他用户信息时提供UI
 *  在这里，用户是指非好友身份的其他用户
 *  好友信息视图请参照TFriendProfileController
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */

#import <UIKit/UIKit.h>
#import "TUIUserProfileControllerServiceProtocol.h"

@interface TUserProfileController : UITableViewController<TUIUserProfileControllerServiceProtocol>
@end

