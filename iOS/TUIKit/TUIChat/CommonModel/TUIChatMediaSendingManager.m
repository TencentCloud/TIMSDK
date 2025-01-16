//
//  TUIChatMediaSendingManager.m
//  TUIChat
//
//  Created by yiliangwang on 2025/1/6.
//  Copyright © 2025 Tencent. All rights reserved.


#import "TUIChatMediaSendingManager.h"

@implementation TUIChatMediaTask

@end
@implementation TUIChatMediaSendingManager

+ (instancetype)sharedInstance {
    static  TUIChatMediaSendingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUIChatMediaSendingManager alloc] init];
        instance.tasks = [NSMutableDictionary dictionary];
        instance.mediaSendingControllers = [NSHashTable weakObjectsHashTable];
    });
    return instance;
}

- (void)addMediaTask:(TUIChatMediaTask *)task forKey:(NSString *)key {
    self.tasks[key] = task;
}

- (void)updateProgress:(float)progress forKey:(NSString *)key {
    TUIChatMediaTask *task = self.tasks[key];;
    
    TUIMessageCellData *message = task.placeHolderCellData;
    if (message) {
        message.videoTranscodingProgress = progress;
    }
}

- (void)removeMediaTaskForKey:(NSString *)key {
    [self.tasks removeObjectForKey:key];
}

- (NSMutableArray<TUIChatMediaTask *> *)findPlaceHolderListByConversationID:(NSString *)conversationID {
    NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:1];
    for (TUIChatMediaTask * task in  self.tasks.allValues) {
        if ([task.conversationID isEqualToString:conversationID]) {
            [tasks addObject:task];
        }
    }
    return tasks;
}

- (void)addCurrentVC:(UIViewController *)vc {
    [self.mediaSendingControllers addObject:vc];
}

- (void)removeCurrentVC:(UIViewController *)vc {
    [self.mediaSendingControllers removeObject:vc];
}

@end
