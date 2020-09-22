//
//  TElemDataProviderService.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import <Foundation/Foundation.h>
#import "TUIMessageDataProviderServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProviderService : NSObject<TUIMessageDataProviderServiceProtocol>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
