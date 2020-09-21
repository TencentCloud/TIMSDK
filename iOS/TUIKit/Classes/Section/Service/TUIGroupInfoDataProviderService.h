

#import <Foundation/Foundation.h>
#import "TUIGroupInfoDataProviderServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupInfoDataProviderService : NSObject<TUIGroupInfoDataProviderServiceProtocol>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
