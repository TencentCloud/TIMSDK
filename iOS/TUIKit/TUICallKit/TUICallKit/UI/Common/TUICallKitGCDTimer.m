//
//  TUICallKitGCDTimer.m
//  TUICallKit
//
//  Created by noah on 2022/8/4.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallKitGCDTimer.h"

@implementation TUICallKitGCDTimer

static NSMutableDictionary *gCallKitTimers;
dispatch_semaphore_t callKitTimerSemaphore;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gCallKitTimers = [NSMutableDictionary dictionary];
        callKitTimerSemaphore = dispatch_semaphore_create(1);
    });
}

+ (NSString *)timerTask:(void(^)(void))task
                  start:(NSTimeInterval)start
               interval:(NSTimeInterval)interval
                repeats:(BOOL)repeats
                  async:(BOOL)async {
    if (!task || start < 0 || (interval <= 0 && repeats)) {
        return nil;
    }
    
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_semaphore_wait(callKitTimerSemaphore, DISPATCH_TIME_FOREVER);
    NSString *timerName = [NSString stringWithFormat:@"%zd", gCallKitTimers.count];
    gCallKitTimers[timerName] = timer;
    dispatch_semaphore_signal(callKitTimerSemaphore);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) {
            [self cancelTimer:timerName];
        }
    });
    dispatch_resume(timer);
    return timerName;
}

+ (void)cancelTimer:(NSString *)timerName {
    if (timerName.length == 0) {
        return;
    }
    
    dispatch_semaphore_wait(callKitTimerSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = gCallKitTimers[timerName];
    
    if (timer) {
        dispatch_source_cancel(timer);
        [gCallKitTimers removeObjectForKey:timerName];
    }
    
    dispatch_semaphore_signal(callKitTimerSemaphore);
}

@end
