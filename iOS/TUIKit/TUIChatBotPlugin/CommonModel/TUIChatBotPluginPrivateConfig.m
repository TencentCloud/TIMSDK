//
//  TUIChatBotPluginPrivateConfig.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginPrivateConfig.h"
#import <TUIChat/TUIChatConfig.h>

static const long long kTUIChatBotCommercialAbility = 1LL << 42;
static BOOL gEnableChatBot = NO;
static NSString *gChatBot = @"@RBT#XNAvyjz9bXcKG3q8";

@implementation TUIChatBotPluginPrivateConfig

+ (TUIChatBotPluginPrivateConfig *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUIChatBotPluginPrivateConfig * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIChatBotPluginPrivateConfig alloc] init];
        [self checkCommercialAbility];
    });
    return g_sharedInstance;
}

#pragma mark - Public
- (BOOL)isChatBotAccount:(NSString *)userID {
    if (userID.length == 0) {
        return NO;
    }
    return [self.chatBotAccounts containsObject:userID];
}

+ (BOOL)isChatBotSupported {
    return gEnableChatBot;
}

#pragma mark - Private
+ (void)checkCommercialAbility {
    [TUITool checkCommercialAbility:kTUIChatBotCommercialAbility
                               succ:^(BOOL enabled) {
        gEnableChatBot = enabled;
    }
                               fail:^(int code, NSString *desc) {
        gEnableChatBot = NO;
    }];
}

#pragma mark - Getter
// Developer can modify these userIDs by their account configs on console.
- (NSArray *)chatBotAccounts {
    return @[gChatBot]; // default
}

@end
