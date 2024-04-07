
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  Tencent Cloud Communication Service Interface Components TUIKIT - Friends Information Interface
 *  This file implements the friend profile view controller, which is only used when displaying friends.
 *  To display user information for non-friends, see TUIUserProfileController.h
 */

#import <UIKit/UIKit.h>
@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface TUIFriendProfileController_Minimalist : UIViewController

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) V2TIMFriendInfo *friendProfile;

@end

NS_ASSUME_NONNULL_END
