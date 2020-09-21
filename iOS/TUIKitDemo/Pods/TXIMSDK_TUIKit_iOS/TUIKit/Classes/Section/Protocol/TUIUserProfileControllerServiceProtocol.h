/******************************************************************************
 *
 *  本文件声明了管理用户信息的协议。
 *  实现了本协议的类，可以根据用户的当前状态对用户信息进行显示。
 *  如当前用户需要加好友时，则展示出用户的基本信息，并进一步展示出申请理由和“同意“、”拒绝“按钮。
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "TCServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                        ProfileControllerAction
//
/////////////////////////////////////////////////////////////////////////////////


typedef enum : NSUInteger {
    PCA_NONE,
    PCA_ADD_FRIEND,    // 需要加好友
    PCA_PENDENDY_CONFIRM,   // 需要同意好友
    PCA_GROUP_CONFIRM,   // 同意进群
} ProfileControllerAction;

@class V2TIMUserFullInfo;
@class TUIGroupPendencyCellData;
@class TCommonPendencyCellData;

/////////////////////////////////////////////////////////////////////////////////
//
//                        TUIUserProfileControllerServiceProtocol
//
/////////////////////////////////////////////////////////////////////////////////


@protocol TUIUserProfileControllerServiceProtocol <TCServiceProtocol>

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
@property TCommonPendencyCellData *pendency;

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

NS_ASSUME_NONNULL_END
