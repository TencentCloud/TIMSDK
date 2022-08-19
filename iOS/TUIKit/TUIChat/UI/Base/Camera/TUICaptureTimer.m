
#import "TUICaptureTimer.h"

@interface TUICaptureTimer ()
@property (nonatomic, strong) dispatch_source_t gcdTimer;
@property (nonatomic, assign) CGFloat captureDuration;
@end

@implementation TUICaptureTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxCaptureTime = 15.0f;
    }
    return self;
}

- (void)startTimer {

    self.gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));

    NSTimeInterval delayTime = 0.f;
    NSTimeInterval timeInterval = 0.1f;
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(self.gcdTimer, startDelayTime, timeInterval * NSEC_PER_SEC, timeInterval * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(self.gcdTimer, ^{
        self.captureDuration += timeInterval;
        /**
         * 主线程更新 UI
         * Updating UI on the main thread
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) {
                self.progressBlock(self.captureDuration/self.maxCaptureTime, self.captureDuration);
            }
        });
        
        /**
         * 完成
         * Fnish
         */
        if (self.captureDuration >= self.maxCaptureTime) {
            /**
             * 取消定时器
             * Invalid timer
             */
            CGFloat ratio = self.captureDuration/self.maxCaptureTime;
            CGFloat recordTime = self.captureDuration;
            [self cancel];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.progressFinishBlock) self.progressFinishBlock(ratio, recordTime);
            });
        }
    });
    /**
     * 启动任务，GCD 定时器创建后需要手动启动
     * Start the task. After the GCD timer is created, it needs to be started manually
     */
    dispatch_resume(self.gcdTimer);
}

- (void)stopTimer {
    [self cancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressCancelBlock) self.progressCancelBlock();
    });
}

- (void)cancel {
    if (self.gcdTimer) {
        dispatch_source_cancel(self.gcdTimer);
        self.gcdTimer = nil;
    }
    self.captureDuration = 0;
}

@end
