//
//  NSObject+Extension.m
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/23.
//  Copyright (c) 2022年 Tencent. All rights reserved.
//

#import "NSObject+Extension.h"
@implementation NSObject (Extension)

+ (void)load {
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(swiftLoad)]) {
        [self performSelector:@selector(swiftLoad)];
    }
}
@end
