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
#import "TUIDefine.h"
#import "TUIGroupPendencyCellData.h"
#import "TUICommonPendencyCellData.h"

typedef enum : NSUInteger {
    PCA_NONE,
    PCA_ADD_FRIEND,    // 需要加好友
    PCA_PENDENDY_CONFIRM,   // 需要同意好友
    PCA_GROUP_CONFIRM,   // 同意进群
} ProfileControllerAction;

@interface TUserProfileController : UITableViewController

/**
 *  用户信息。
 *  存储了用户的详细信息，包括用户 ID、用户昵称、用户头像、用户签名、用户所在地等等。
 *  TIMUserProfile 的详细信息请参考 IMSDK\Framework\ImSDK.framework\Headers\TIMComm.h 中关于 TIMUserProfile 的定义。
 */
@property V2TIMUserFullInfo *userFullInfo;

/**
 *  群组请求数据。
 *  若当前用户申请加群，我们需要展示用户信息和加群请求中的相关信息，这时便需要群组请求的信息。
 *  若当前用户无操作或者为加好友操作时，本属性不会被使用。
 */
@property TUIGroupPendencyCellData *groupPendency;

/**
 *  好友请求数据。
 *  若当前用户申请加好友，我们需要展示用户信息和加还有请求中的相关信息，这时便需要好友请求的信息。
 *  若当前用户无操作或者为加群操作时，本属性不会被使用。
 */
@property TUICommonPendencyCellData *pendency;

/**
 *  操作类型。
 *  我们需要根据当前的操作类型选择显示的信息，本属性便提供了我们选择的依据。
 *  PCA_NONE 无操作，仅浏览用户信息
 *  PCA_ADD_FRIEND 需要加好友
 *  PCA_PENDENDY_CONFIRM 需要同意好友
 *  PCA_GROUP_CONFIRM 同意进群
 */
@property ProfileControllerAction actionType;

@end

