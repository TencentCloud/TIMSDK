//
//  TUILiveGiftAnimationManager.m
//  Pods
//
//  Created by harvy on 2020/9/17.
//

#import <pthread.h>
#import "TUILiveGiftAnimationManager.h"
#import "TUILiveGiftInfo.h"

#define kTaskTimeout 10

@interface TUILiveGiftAnimationTask : NSObject

/// 正在被处理
@property (nonatomic, assign) BOOL dealing;
@property (nonatomic, assign) NSTimeInterval dealingTime;

/// 任务上下文信息
@property (nonatomic, strong) id context;


@end

@interface TUILiveGiftAnimationQueue : NSObject

/// 入队
- (void)enqueue:(TUILiveGiftAnimationTask *)task;

/// 出队
- (TUILiveGiftAnimationTask *)dequeue;

/// 获取队头元素，不出队
- (TUILiveGiftAnimationTask *)getQueueHeaderTask;

/// 是否为空
- (BOOL)isEmpty;

@end

#define TUIGiftQueueLock pthread_mutex_lock(&_mutex);
#define TUIGiftQueueUnLock pthread_mutex_unlock(&_mutex);

/// 队列默认的长度
#define kQueueDefaultMaxLength 500

@interface TUILiveGiftAnimationQueue ()

@property (nonatomic, strong) NSMutableArray *queue;

@end

@implementation TUILiveGiftAnimationQueue {
    pthread_mutex_t _mutex;
    pthread_mutexattr_t _attr;
}

- (void)dealloc
{
    pthread_mutexattr_destroy(&_attr);
    pthread_mutex_destroy(&_mutex);
}


- (instancetype)init
{
    if (self = [super init]) {
        [self initial];
    }
    return self;
}

- (void)initial
{
    pthread_mutexattr_init(&_attr);
    pthread_mutexattr_settype(&_attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_mutex, &_attr);
}


/// 入队
- (void)enqueue:(TUILiveGiftAnimationTask *)task
{
    TUIGiftQueueLock
    if (self.queue.count >= kQueueDefaultMaxLength) {
        TUILiveGiftAnimationTask *task = self.queue.firstObject;
        if (task.dealing) {
            task = [self.queue objectAtIndex:1];
        }
        [self.queue removeObject:task];
    }
    [self.queue addObject:task];
    TUIGiftQueueUnLock
}

/// 出队
- (TUILiveGiftAnimationTask *)dequeue
{
    TUILiveGiftAnimationTask *task = nil;
    TUIGiftQueueLock
    task = self.queue.firstObject;
    if (task) {
        [self.queue removeObject:task];
    }
    TUIGiftQueueUnLock
    return task;
}

/// 获取队头元素，不出队
- (TUILiveGiftAnimationTask *)getQueueHeaderTask
{
    TUILiveGiftAnimationTask *task = nil;
    task = self.queue.firstObject;
    return task;
}

/// 是否为空
- (BOOL)isEmpty
{
    return (self.queue.count == 0);
}

#pragma mark - Lazy
- (NSMutableArray *)queue
{
    if (_queue == nil) {
        _queue = [NSMutableArray array];
    }
    return _queue;
}

@end


@implementation TUILiveGiftAnimationTask


@end




@interface TUILiveGiftAnimationManager ()

@property (nonatomic, strong) TUILiveGiftAnimationQueue *queue;

/// 是否正在处理任务
@property (nonatomic, assign) BOOL handling;

@end

@implementation TUILiveGiftAnimationManager

- (void)onRecevieGiftInfo:(TUILiveGiftInfo *)giftInfo
{
    TUILiveGiftAnimationTask *task = [[TUILiveGiftAnimationTask alloc] init];
    task.context = giftInfo;
    
    [self.queue enqueue:task];
    [self handleTask];
}

- (void)handleTask
{
    @synchronized (self) {
        if (self.handling || [self.queue isEmpty]) {
            NSLog(@">>>>>>>>>>>> smallyou:正在执行动画或者队列为空 %d", [self.queue isEmpty]);
            return;
        }
        self.handling = YES;
    }
    
    // 取出当前队列的第一个任务,判断任务是否超时
    TUILiveGiftAnimationTask *task = [self.queue getQueueHeaderTask];
    if (task.dealing) {
        if ([[NSDate new] timeIntervalSince1970] - task.dealingTime >= kTaskTimeout) {
            task.dealingTime = NO;
            [self handleNextTask];
            return;
        }
    } else {
        task.dealing = YES;
        task.dealingTime = [[NSDate new] timeIntervalSince1970];
    }
    
    // 通知代理执行任务
    [self notifyDelegateHandleTask:task];
}

- (void)handleNextTask
{
    @synchronized (self) {
        self.handling = NO;
    }
    // 出队
    [self.queue dequeue];
    
    // 执行下一个任务
    [self handleTask];
}

- (void)notifyDelegateHandleTask:(TUILiveGiftAnimationTask *)task
{
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notifyDelegateHandleTask:task];
        });
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(giftAnimationManager:handleGiftAnimation:completion:)]) {
        [self.delegate giftAnimationManager:self handleGiftAnimation:task.context completion:^{
            task.dealing = NO;
            [weakSelf handleNextTask];
        }];
        return;
    }
    
    task.dealing = NO;
    [self handleNextTask];
}

- (TUILiveGiftAnimationQueue *)queue
{
    if (_queue == nil) {
        _queue = [[TUILiveGiftAnimationQueue alloc] init];
    }
    return _queue;
}

@end
