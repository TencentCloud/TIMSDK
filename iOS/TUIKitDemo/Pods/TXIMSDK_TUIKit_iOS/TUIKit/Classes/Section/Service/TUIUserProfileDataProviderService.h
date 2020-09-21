//
//  TUIUserProfileDataProviderService.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//

#import <Foundation/Foundation.h>
#import "TUIUserProfileDataProviderServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIUserProfileDataProviderService : NSObject<TUIUserProfileDataProviderServiceProtocol>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
