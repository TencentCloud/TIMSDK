//
//  NSDictionary+TUISafe.h
//  lottie-ios
//
//  Created by kayev on 2021/8/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (TUISafe)

- (id)tui_objectForKey:(NSString *)aKey conformProtocol:(Protocol *)pro;

- (id)tui_objectForKey:(NSString *)aKey asClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
