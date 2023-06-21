//
//  NSDictionary+TUISafe.m
//  lottie-ios
//
//  Created by kayev on 2021/8/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "NSDictionary+TUISafe.h"

@implementation NSDictionary (TUISafe)

- (id)tui_objectForKey:(NSString *)aKey conformProtocol:(Protocol *)pro {
    NSParameterAssert(aKey);
    NSParameterAssert(pro);

    NSObject *value = [self objectForKey:aKey];
    if (value && ![value conformsToProtocol:pro]) {
        NSAssert(NO, @"value not conforms this protocol");
    }
    return value;
}

- (id)tui_objectForKey:(NSString *)aKey asClass:(Class)cls {
    NSParameterAssert(aKey);
    NSParameterAssert(cls);

    NSObject *value = [self objectForKey:aKey];
    if (value && ![value isKindOfClass:cls]) {
        NSAssert(NO, @"value's class is error");
    }
    return value;
}

@end
