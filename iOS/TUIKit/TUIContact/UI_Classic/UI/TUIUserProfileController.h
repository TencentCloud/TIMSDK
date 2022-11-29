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

#import <UIKit/UIKit.h>
#import "TUIDefine.h"
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

