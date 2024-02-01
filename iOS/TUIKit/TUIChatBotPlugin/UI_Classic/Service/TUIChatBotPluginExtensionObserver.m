//
//  TUIChatBotPluginExtensionObserver.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginExtensionObserver.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatBotPluginDataProvider.h"
#import "TUIChatBotPluginPrivateConfig.h"
#import "TUIChatBotPluginAccountController.h"
#import <TUIChat/TUIBaseChatViewController.h>
#import "TUIChatBotPluginUserController.h"

@interface TUIChatBotPluginExtensionObserver () <TUIExtensionProtocol>

@property (nonatomic, weak) TUIBaseChatViewController *superVC;

@end

@implementation TUIChatBotPluginExtensionObserver

static id _instance = nil;
+ (void)load {
    [TUICore registerExtension:TUICore_TUIContactExtension_ContactMenu_ClassicExtensionID object:TUIChatBotPluginExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID object:TUIChatBotPluginExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_ClickAvatar_ClassicExtensionID object:TUIChatBotPluginExtensionObserver.shareInstance];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - TUIExtensionProtocol
#pragma mark -- GetExtension
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }

    if ([extensionID isEqualToString:TUICore_TUIContactExtension_ContactMenu_ClassicExtensionID]) {
        return [self getContactMenuExtensionForClassicChat:param];
    } else if ([extensionID isEqualToString:TUICore_TUIContactExtension_ContactMenu_MinimalistExtensionID]) {
        return [self getContactMenuExtensionForMinimalistChat:param];
    } else if ([extensionID isEqualToString:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID]) {
        return [self getNavigationMoreItemExtensionForClassicChat:param];
    } else if ([extensionID isEqualToString:TUICore_TUIChatExtension_ClickAvatar_ClassicExtensionID]) {
        return [self getClickAvtarExtensionForClassicChat:param];
    } else {
        return nil;
    }
}

// ContactMenu
- (NSArray<TUIExtensionInfo *> *)getContactMenuExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    [TUIChatBotPluginPrivateConfig checkCommercialAbility];
    
    UINavigationController *nav = [param tui_objectForKey:TUICore_TUIContactExtension_ContactMenu_Nav asClass:UINavigationController.class];
    [TUITool addValueAddedUnsupportNeedContactNotificationInVC:nav debugOnly:YES];
    
    TUIExtensionInfo *chatBotService = [[TUIExtensionInfo alloc] init];
    chatBotService.weight = 40;
    chatBotService.text = TIMCommonLocalizableString(TUIChatBotAccounts);
    chatBotService.icon = TUIChatBotPluginBundleThemeImage(@"chat_bot_contact_menu_icon_img", @"chat_bot");
    chatBotService.onClicked = ^(NSDictionary *_Nonnull param) {
        if (![TUIChatBotPluginPrivateConfig isChatBotSupported]) {
            [TUITool postValueAddedUnsupportNeedContactNotification:TIMCommonLocalizableString(TUIChatBot)];
            NSLog(@"TUIChatBot ability is not supported");
            return;
        }
        TUIChatBotPluginAccountController *vc = [TUIChatBotPluginAccountController new];
        [nav pushViewController:vc animated:YES];
    };
    return @[chatBotService];
}

- (NSArray<TUIExtensionInfo *> *)getContactMenuExtensionForMinimalistChat:(NSDictionary *)param {
    return nil;
}

// Navigation more item
- (NSArray<TUIExtensionInfo *> *)getNavigationMoreItemExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSString *userID = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_UserID
                                       asClass:NSString.class];
    if (userID.length == 0 || ![TUIChatBotPluginPrivateConfig.sharedInstance isChatBotAccount:userID]) {
        return nil;
    }
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.icon = TUIContactBundleThemeImage(@"chat_nav_more_menu_img", @"chat_nav_more_menu");
    info.weight = 200;
    info.onClicked = ^(NSDictionary *_Nonnull param) {
        UINavigationController *nav = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_PushVC
                                                      asClass:UINavigationController.class];
        if (nav) {
            [[V2TIMManager sharedInstance] getUsersInfo:@[userID]
                                                   succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                TUIChatBotPluginUserController *vc = [[TUIChatBotPluginUserController alloc] initWithUserInfo:infoList.firstObject];
                [nav pushViewController:vc animated:YES];
            } fail:^(int code, NSString *desc) {
                
            }];
        }
    };
    return @[info];
}

// Customizing action when clicking avatar
- (NSArray<TUIExtensionInfo *> *)getClickAvtarExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSString *userID = [param tui_objectForKey:TUICore_TUIChatExtension_ClickAvatar_UserID
                                       asClass:NSString.class];
    if (userID.length == 0 || ![TUIChatBotPluginPrivateConfig.sharedInstance isChatBotAccount:userID]) {
        return nil;
    }
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.onClicked = ^(NSDictionary *_Nonnull param) {
        UINavigationController *nav = [param tui_objectForKey:TUICore_TUIChatExtension_ClickAvatar_PushVC
                                                      asClass:UINavigationController.class];
        if (nav) {
            [[V2TIMManager sharedInstance] getUsersInfo:@[userID]
                                                   succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                TUIChatBotPluginUserController *vc = [[TUIChatBotPluginUserController alloc] initWithUserInfo:infoList.firstObject];
                [nav pushViewController:vc animated:YES];
            } fail:^(int code, NSString *desc) {
                
            }];
        }
    };
    return @[info];
}

@end
