//
//  TUIKitListenerManager.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/5/17.
//

#import "TUIKitListenerManager.h"

@implementation TUIKitListenerManager
{
    NSHashTable<id<TUIConversationListControllerListener>> *convListeners_;
    NSHashTable<id<TUIChatControllerListener>> *chatListeners_;
}

+ (instancetype)sharedInstance
{
    static TUIKitListenerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUIKitListenerManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        convListeners_ = [NSHashTable weakObjectsHashTable];
        chatListeners_ = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addConversationListControllerListener:(id<TUIConversationListControllerListener>)listener {
    @synchronized (self) {
        if (listener && ![convListeners_ containsObject:listener]) {
            [convListeners_ addObject:listener];
        }
    }
}

- (void)removeConversationListControllerListener:(id<TUIConversationListControllerListener>)listener {
    @synchronized (self) {
        if (listener && [convListeners_ containsObject:listener]) {
            [convListeners_ removeObject:listener];
        }
    }
}

- (void)addChatControllerListener:(id<TUIChatControllerListener>)listener {
    @synchronized (self) {
        if (listener && ![chatListeners_ containsObject:listener]) {
            [chatListeners_ addObject:listener];
        }
    }
}

- (void)removeChatControllerListener:(id<TUIChatControllerListener>)listener {
    @synchronized (self) {
        if (listener && [chatListeners_ containsObject:listener]) {
            [chatListeners_ removeObject:listener];
        }
    }
}

- (NSHashTable<id<TUIConversationListControllerListener>>*)convListeners {
    return convListeners_;
}

- (NSHashTable<id<TUIChatControllerListener>> *)chatListeners {
    return chatListeners_;
}

@end
