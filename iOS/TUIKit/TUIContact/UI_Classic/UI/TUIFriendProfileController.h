
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  腾讯云通讯服务界面组件 TUIKIT - 好友信息视图界面
 *
 *  本文件实现了好友简介视图控制器，只在显示好友时使用该视图控制器。
 *  若要显示非好友的用户信息，请查看 TUIUserProfileController.h
 *
 *  Tencent Cloud Communication Service Interface Components TUIKIT - Friends Information Interface
 *  This file implements the friend profile view controller, which is only used when displaying friends.
 *  To display user information for non-friends, see TUIUserProfileController.h
 */

#import <UIKit/UIKit.h>
@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface TUIFriendProfileController : UITableViewController

@property(nonatomic, strong) V2TIMFriendInfo *friendProfile;

@end

NS_ASSUME_NONNULL_END
