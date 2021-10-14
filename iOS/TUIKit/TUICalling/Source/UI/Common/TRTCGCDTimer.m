//
//  TRTCGCDTimer.m
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import "TRTCGCDTimer.h"

@implementation TRTCGCDTimer

static NSMutableDictionary *trtcTimers;
dispatch_semaphore_t trtcSemaphore;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trtcTimers = [NSMutableDictionary dictionary];
        trtcSemaphore = dispatch_semaphore_create(1);
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
    dispatch_semaphore_wait(trtcSemaphore, DISPATCH_TIME_FOREVER);
    NSString *timerName = [NSString stringWithFormat:@"%zd", trtcTimers.count];
    trtcTimers[timerName] = timer;
    dispatch_semaphore_signal(trtcSemaphore);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) {
            [self canelTimer:timerName];
        }
    });
    dispatch_resume(timer);
    return timerName;
}

+ (void)canelTimer:(NSString *)timerName {
    if (timerName.length == 0) {
        return;
    }
    
    dispatch_semaphore_wait(trtcSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = trtcTimers[timerName];
    
    if (timer) {
        dispatch_source_cancel(timer);
        [trtcTimers removeObjectForKey:timerName];
    }
    
    dispatch_semaphore_signal(trtcSemaphore);
}

@end
