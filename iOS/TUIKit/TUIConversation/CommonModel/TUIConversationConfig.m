//
//  TUIConversationConfig.m
//  TUIConversation
//
//  Created by Tencent on 2024/9/6.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "TUIConversationConfig.h"
#import <TUICore/TUIConfig.h>

@implementation TUIConversationConfig

+ (TUIConversationConfig *)sharedConfig {
    static dispatch_once_t onceToken;
    static TUIConversationConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIConversationConfig alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showCellUnreadCount = YES;
    }
    return self;
}

- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius {
    [TUIConfig defaultConfig].avatarCornerRadius = avatarCornerRadius;
}

- (CGFloat)avatarCornerRadius {
    return [TUIConfig defaultConfig].avatarCornerRadius;
}

- (void)setShowUserOnlineStatusIcon:(BOOL)showUserOnlineStatusIcon {
    [TUIConfig defaultConfig].displayOnlineStatusIcon = showUserOnlineStatusIcon;
}

- (BOOL)showUserOnlineStatusIcon {
    return [TUIConfig defaultConfig].displayOnlineStatusIcon;
}

@end
