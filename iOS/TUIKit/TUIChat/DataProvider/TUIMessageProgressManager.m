//
//  TUIMessageProgressManager.m
//  TUIChat
//
//  Created by harvy on 2022/1/4.
//

#import "TUIMessageProgressManager.h"
#import <ImSDK_Plus/ImSDK_Plus.h>

@interface TUIMessageProgressManager () <V2TIMSDKListener>

// 上传进度
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *uploadProgress;

@property (nonatomic, strong) NSHashTable *delegates;

@end

@implementation TUIMessageProgressManager

static id _instance;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


- (instancetype)init
{
    if (self = [super init]) {
        [V2TIMManager.sharedInstance addIMSDKListener:self];
    }
    return self;
}

- (void)addDelegate:(id<TUIMessageProgressManagerDelegate>)delegate
{
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf addDelegate:delegate];
        });
        return;
    }
    
    if ([self.delegates containsObject:delegate]) {
        return;
    }
    
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<TUIMessageProgressManagerDelegate>)delegate
{
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf removeDelegate:delegate];
        });
        return;
    }
    
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

- (void)callback:(NSString *)msgID
{
    NSNumber *progress = @(100);
    if ([self.uploadProgress.allKeys containsObject:msgID]) {
        progress = [self.uploadProgress objectForKey:msgID];
    }
    for (id<TUIMessageProgressManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(onProgress:progress:)]) {
            [delegate onProgress:msgID progress:progress.integerValue];
        }
    }
}

- (void)appendProgress:(NSString *)msgID progress:(NSInteger)progress
{
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf appendProgress:msgID progress:progress];
        });
        return;
    }
    
    if (msgID.length == 0) {
        return;
    }
    
    if ([self.uploadProgress.allKeys containsObject:msgID]) {
        [self.uploadProgress removeObjectForKey:msgID];
    }
    if (progress >= 100 || progress <= 0) {
        [self callback:msgID];
        return;
    }
    
    [self.uploadProgress setObject:@(progress) forKey:msgID];
    [self callback:msgID];
}

- (NSInteger)progressForMessage:(NSString *)msgID
{
    if (![self.uploadProgress.allKeys containsObject:msgID]) {
        return 0;
    }
    
    NSInteger progress = 0;
    @synchronized (self) {
        progress = [[self.uploadProgress objectForKey:msgID] integerValue];
    }
    
    return progress;
}

- (void)reset
{
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reset];
        });
        return;
    }
    
    [self.uploadProgress removeAllObjects];
}


- (NSMutableDictionary<NSString *,NSNumber *> *)uploadProgress
{
    if (_uploadProgress == nil) {
        _uploadProgress = [NSMutableDictionary dictionary];
    }
    return _uploadProgress;
}

- (NSHashTable *)delegates
{
    if (_delegates == nil) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)onConnecting
{
    [self reset];
}


@end
