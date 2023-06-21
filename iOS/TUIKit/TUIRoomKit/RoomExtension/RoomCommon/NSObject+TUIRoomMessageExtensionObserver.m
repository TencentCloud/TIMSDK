//
//  NSObject+TUIRoomMessageExtensionObserver.m
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "NSObject+TUIRoomMessageExtensionObserver.h"
#import "TUICore.h"

@implementation NSObject (TUIRoomMessageExtensionObserver)

+ (void) load {
    if ([self respondsToSelector:@selector(tuiRoomKitExtensionLoad)]) {
        [self performSelector:@selector(tuiRoomKitExtensionLoad)];
    }
}

@end
