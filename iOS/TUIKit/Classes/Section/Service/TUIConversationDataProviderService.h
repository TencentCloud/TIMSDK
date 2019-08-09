//
//  TUIConversationDataProviderService.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/11.
//

#import <Foundation/Foundation.h>
#import "TUIConversationDataProviderServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationDataProviderService : NSObject<TUIConversationDataProviderServiceProtocol>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
