//
//  TUIChatBotPluginConfig.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginConfig.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import "TUIChatBotPluginDataProvider.h"
#import "TUIChatBotPluginExtensionObserver.h"

#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation TUIChatBotPluginConfig

+ (TUIChatBotPluginConfig *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUIChatBotPluginConfig * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIChatBotPluginConfig alloc] init];
        
    });
    return g_sharedInstance;
}

@end
