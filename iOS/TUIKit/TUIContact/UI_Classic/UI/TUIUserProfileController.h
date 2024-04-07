
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  Tencent Cloud Communication Service Interface Components TUIKIT - User Information View Interface
 *  This file implements the user profile view controller. User refers to other users who are not friends.
 *  If friend, use TUIFriendProfileController
 */

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUICommonPendencyCellData.h"

typedef enum : NSUInteger {
    PCA_NONE,
    PCA_ADD_FRIEND,
    PCA_PENDENDY_CONFIRM,
    PCA_GROUP_CONFIRM,
} ProfileControllerAction;

@interface TUIUserProfileController : UITableViewController

@property V2TIMUserFullInfo *userFullInfo;

@property TUIGroupPendencyCellData *groupPendency;

@property TUICommonPendencyCellData *pendency;

@property ProfileControllerAction actionType;

@end
