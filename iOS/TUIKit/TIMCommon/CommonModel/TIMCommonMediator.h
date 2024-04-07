//
//  TIMCommonMediator.h
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIMCommonMediator : NSObject

+ (instancetype)share;

///  Protocol : Class
/// Register Protocol : Class
- (void)registerService:(Protocol *)service class:(Class)cls;

///  Protocol  [Class new]
/// get  [class new]  by Protocol 
- (id)getObject:(Protocol *)service;

@end

NS_ASSUME_NONNULL_END
