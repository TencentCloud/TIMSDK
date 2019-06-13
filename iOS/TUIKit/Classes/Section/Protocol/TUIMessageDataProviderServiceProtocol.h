//
//  TMessageDataProviderServiceProtocol.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIMMessage;

@protocol TUIMessageDataProviderServiceProtocol <NSObject>

- (NSString *)getDisplayString:(TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
