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
} ProfileControllerAction;

@class TIMUserProfile;
@protocol TUIUserProfileControllerServiceProtocol <TCServiceProtocol>
@property TIMUserProfile *userProfile;
@property ProfileControllerAction actionType;
@end

NS_ASSUME_NONNULL_END
