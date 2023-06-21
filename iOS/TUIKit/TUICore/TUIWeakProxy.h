//
//  TUIWeakProxy.h
//  TUICore
//
//  Created by harvy on 2023/4/17.
//  Copyright (c) 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIWeakProxy : NSProxy

@property(nonatomic, weak, readonly, nullable) id target;

- (nonnull instancetype)initWithTarget:(nonnull id)target;
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target;

@end

NS_ASSUME_NONNULL_END
