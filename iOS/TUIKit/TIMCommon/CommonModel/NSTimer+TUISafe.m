//
//  NSTimer+TUISafe.m
//  TUICore
//
//  Created by wyl on 2022/7/5.
//

#import "NSTimer+TUISafe.h"

@implementation NSTimer (TUISafe)
+ (NSTimer *)tui_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(tui_callBlock:) userInfo:[block copy] repeats:repeats];
}

+ (void)tui_callBlock:(NSTimer *)timer {
    void (^block)(NSTimer *timer) = timer.userInfo;
    !block ?: block(timer);
}

@end
