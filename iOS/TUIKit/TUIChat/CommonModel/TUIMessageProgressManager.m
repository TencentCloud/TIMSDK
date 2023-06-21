//
//  TUIMessageProgressManager.m
//  TUIChat
//
//  Created by harvy on 2022/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageProgressManager.h"
#import <ImSDK_Plus/ImSDK_Plus.h>

@interface TUIMessageProgressManager () <V2TIMSDKListener>

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *uploadProgress;

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dowonloadProgress;

@property(nonatomic, strong) NSHashTable *delegates;

@end

@implementation TUIMessageProgressManager

static id gShareInstance;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      gShareInstance = [[self alloc] init];
    });
    return gShareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [V2TIMManager.sharedInstance addIMSDKListener:self];
    }
    return self;
}

- (void)addDelegate:(id<TUIMessageProgressManagerDelegate>)delegate {
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

- (void)removeDelegate:(id<TUIMessageProgressManagerDelegate>)delegate {
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

- (NSString *)getUploadIdentityForMessage:(V2TIMMessage *)message {
    NSString *msgID = message.msgID;
    if (message.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        NSString *path = message.videoElem.videoPath;
        NSString *uuid = message.videoElem.videoUUID;
        return [msgID stringByAppendingString:message.videoElem.videoPath];
    } else if (message.elemType == V2TIM_ELEM_TYPE_IMAGE) {
        NSString *path = message.imageElem.path;
        return [msgID stringByAppendingString:message.imageElem.path];
    } else if (message.elemType == V2TIM_ELEM_TYPE_SOUND) {
        return [msgID stringByAppendingString:message.soundElem.path];
    }
    return msgID;
}

- (NSString *)getDownloadIdentityForMessage:(V2TIMMessage *)message {
    NSString *msgID = message.msgID;
    if (message.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        NSString *uuid = message.videoElem.videoUUID;
        NSString *snapShotuuid = message.videoElem.snapshotUUID;
        return [msgID stringByAppendingString:uuid];
    } else if (message.elemType == V2TIM_ELEM_TYPE_IMAGE) {
        NSMutableArray<V2TIMImage *> *imageList = message.imageElem.imageList;
        for (V2TIMImage *img in imageList) {
            if (img.type == V2TIM_IMAGE_TYPE_ORIGIN) {
                NSString *url = img.url;
            }
        }
        return @"";
    }
    return @"";
}

- (void)uploadCallback:(NSString *)msgID {
    NSNumber *progress = @(100);
    if ([self.uploadProgress.allKeys containsObject:msgID]) {
        progress = [self.uploadProgress objectForKey:msgID];
    }
    for (id<TUIMessageProgressManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(onUploadProgress:progress:)]) {
            [delegate onUploadProgress:msgID progress:progress.integerValue];
        }
    }
}
- (void)appendUploadProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf appendUploadProgress:msgID progress:progress];
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
        [self uploadCallback:msgID];
        return;
    }

    [self.uploadProgress setObject:@(progress) forKey:msgID];
    [self uploadCallback:msgID];
}

- (void)downloadCallback:(NSString *)msgID {
    NSNumber *progress = @(100);
    if ([self.dowonloadProgress.allKeys containsObject:msgID]) {
        progress = [self.dowonloadProgress objectForKey:msgID];
    }
    for (id<TUIMessageProgressManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(onDownloadProgress:progress:)]) {
            [delegate onDownloadProgress:msgID progress:progress.integerValue];
        }
    }
}
- (void)appendDownloadProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf appendDownloadProgress:msgID progress:progress];
        });
        return;
    }
    if (msgID.length == 0) {
        return;
    }

    if ([self.dowonloadProgress.allKeys containsObject:msgID]) {
        [self.dowonloadProgress removeObjectForKey:msgID];
    }
    if (progress >= 100 || progress <= 0) {
        [self downloadCallback:msgID];
        return;
    }

    [self.dowonloadProgress setObject:@(progress) forKey:msgID];
    [self downloadCallback:msgID];
}

- (void)notifyMessageSendingResult:(NSString *)msgID result:(TUIMessageSendingResultType)result {
    for (id<TUIMessageProgressManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(onMessageSendingResultChanged:messageID:)]) {
            [delegate onMessageSendingResultChanged:result messageID:msgID];
        }
    }
}

- (NSInteger)uploadProgressForMessage:(NSString *)msgID {
    if (![self.uploadProgress.allKeys containsObject:msgID]) {
        return 0;
    }

    NSInteger progress = 0;
    @synchronized(self) {
        progress = [[self.uploadProgress objectForKey:msgID] integerValue];
    }

    return progress;
}

- (NSInteger)downloadProgressForMessage:(NSString *)msgID {
    if (![self.dowonloadProgress.allKeys containsObject:msgID]) {
        return 0;
    }

    NSInteger progress = 0;
    @synchronized(self) {
        progress = [[self.dowonloadProgress objectForKey:msgID] integerValue];
    }

    return progress;
}

- (void)reset {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf reset];
        });
        return;
    }

    [self.uploadProgress removeAllObjects];
    [self.dowonloadProgress removeAllObjects];
}

- (NSMutableDictionary<NSString *, NSNumber *> *)uploadProgress {
    if (_uploadProgress == nil) {
        _uploadProgress = [NSMutableDictionary dictionary];
    }
    return _uploadProgress;
}

- (NSMutableDictionary<NSString *, NSNumber *> *)dowonloadProgress {
    if (_dowonloadProgress == nil) {
        _dowonloadProgress = [NSMutableDictionary dictionary];
    }
    return _dowonloadProgress;
}

- (NSHashTable *)delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)onConnecting {
    [self reset];
}

@end
