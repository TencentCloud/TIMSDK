#import <Foundation/Foundation.h>
#import "TUIConversationDataProviderServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationDataProviderService : NSObject<TUIConversationDataProviderServiceProtocol>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
