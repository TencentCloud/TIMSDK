// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaSignatureChecker : NSObject
+ (instancetype)shareInstance;
- (void)startUpdateSignature:(void (^)(void)) UpdateSignatureSuccessful;
- (BOOL)isFunctionSupport;
@end

NS_ASSUME_NONNULL_END
