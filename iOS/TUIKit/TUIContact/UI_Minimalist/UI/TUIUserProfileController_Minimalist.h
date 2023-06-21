
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  腾讯云通讯服务界面组件 TUIKIT - 用户信息视图界面
 *
 *  本文件实现了用户简介视图控制器，用户是指非好友身份的其他用户。
 *  好友信息视图请参照 TUIFriendProfileController
 *
 *  Tencent Cloud Communication Service Interface Components TUIKIT - User Information View Interface
 *  This file implements the user profile view controller. User refers to other users who are not friends.
 *  If friend, use TUIFriendProfileController
 */

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUICommonPendencyCellData.h"
#import "TUICommonPendencyCellData_Minimalist.h"

typedef enum : NSUInteger {
    PCA_NONE_MINI,
    PCA_ADD_FRIEND_MINI,
    PCA_PENDENDY_CONFIRM_MINI,
    PCA_GROUP_CONFIRM_MINI,
} ProfileControllerAction_Minimalist;

@interface TUIUserProfileController_Minimalist : UITableViewController

@property V2TIMUserFullInfo *userFullInfo;

@property TUIGroupPendencyCellData *groupPendency;

@property TUICommonPendencyCellData *pendency;

@property ProfileControllerAction_Minimalist actionType;

@end
