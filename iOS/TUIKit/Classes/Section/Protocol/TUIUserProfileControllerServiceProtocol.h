//
//  TUIUserProfileControllerServiceProtocol.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/15.
//

#import <Foundation/Foundation.h>
#import "TCServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PCA_NONE,
    PCA_ADD_FRIEND,    // 需要加好友
    PCA_PENDENDY_CONFIRM,   // 需要同意好友
    PCA_GROUP_CONFIRM,   // 同意进群
} ProfileControllerAction;

@class TIMUserProfile;
@class TUIGroupPendencyCellData;
@class TCommonPendencyCellData;

@protocol TUIUserProfileControllerServiceProtocol <TCServiceProtocol>
@property TIMUserProfile *userProfile;
@property TUIGroupPendencyCellData *groupPendency;
@property TCommonPendencyCellData *pendency;
@property ProfileControllerAction actionType;
@end

NS_ASSUME_NONNULL_END
