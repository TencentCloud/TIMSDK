//
//  TUIAIPlaceholderTypingMessageManager.m
//  TUIChat
//
//  Created by AI Assistant on 2025/1/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIAIPlaceholderTypingMessageManager.h"
#import <TIMCommon/TUIMessageCellData.h>

@interface TUIAIPlaceholderTypingMessageManager ()
@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIMessageCellData *> *aiPlaceholderTypingMessages;
@property(nonatomic, strong) dispatch_queue_t accessQueue;
@end

@implementation TUIAIPlaceholderTypingMessageManager

+ (instancetype)sharedInstance {
    static TUIAIPlaceholderTypingMessageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUIAIPlaceholderTypingMessageManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _aiPlaceholderTypingMessages = [NSMutableDictionary dictionary];
        _accessQueue = dispatch_queue_create("com.tencent.tuichat.ai.placeholder.typing.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)setAIPlaceholderTypingMessage:(nullable TUIMessageCellData *)message forConversation:(NSString *)conversationID {
    if (!conversationID || conversationID.length == 0) {
        return;
    }
    
    dispatch_barrier_async(self.accessQueue, ^{
        if (message) {
            self.aiPlaceholderTypingMessages[conversationID] = message;
        } else {
            [self.aiPlaceholderTypingMessages removeObjectForKey:conversationID];
        }
    });
}

- (nullable TUIMessageCellData *)getAIPlaceholderTypingMessageForConversation:(NSString *)conversationID {
    if (!conversationID || conversationID.length == 0) {
        return nil;
    }
    
    __block TUIMessageCellData *message = nil;
    dispatch_sync(self.accessQueue, ^{
        message = self.aiPlaceholderTypingMessages[conversationID];
    });
    return message;
}

- (void)removeAIPlaceholderTypingMessageForConversation:(NSString *)conversationID {
    if (!conversationID || conversationID.length == 0) {
        return;
    }
    
    dispatch_barrier_async(self.accessQueue, ^{
        [self.aiPlaceholderTypingMessages removeObjectForKey:conversationID];
    });
}

- (BOOL)hasAIPlaceholderTypingMessageForConversation:(NSString *)conversationID {
    if (!conversationID || conversationID.length == 0) {
        return NO;
    }
    
    __block BOOL hasMessage = NO;
    dispatch_sync(self.accessQueue, ^{
        hasMessage = (self.aiPlaceholderTypingMessages[conversationID] != nil);
    });
    return hasMessage;
}

- (void)clearAllAIPlaceholderTypingMessages {
    dispatch_barrier_async(self.accessQueue, ^{
        [self.aiPlaceholderTypingMessages removeAllObjects];
    });
}

@end 
