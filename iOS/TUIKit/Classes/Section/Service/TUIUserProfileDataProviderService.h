#import <Foundation/Foundation.h>
#import "TUIUserProfileDataProviderServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIUserProfileDataProviderService : NSObject<TUIUserProfileDataProviderServiceProtocol>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
