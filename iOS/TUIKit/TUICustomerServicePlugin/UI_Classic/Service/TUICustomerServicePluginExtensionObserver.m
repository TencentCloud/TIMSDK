//
//  TUICustomerServicePluginExtensionObserver.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/6/12.
//

#import "TUICustomerServicePluginExtensionObserver.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICustomerServicePluginDataProvider.h"
#import "TUICustomerServicePluginCardInputView.h"
#import "TUICustomerServicePluginConfig.h"
#import "TUICustomerServicePluginPrivateConfig.h"
#import "TUICustomerServicePluginAccountController.h"
#import "TUICustomerServicePluginMenuView.h"
#import "TUICustomerServicePluginPhraseView.h"
#import <TUIChat/TUIBaseChatViewController.h>
#import "TUICustomerServicePluginProductInfo.h"
#import "TUICustomerServicePluginUserController.h"

@interface TUICustomerServicePluginExtensionObserver () <TUIExtensionProtocol>

@property (nonatomic, weak) TUIBaseChatViewController *superVC;

@end

@implementation TUICustomerServicePluginExtensionObserver

static id _instance = nil;
+ (void)load {
    [TUICore registerExtension:TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID object:TUICustomerServicePluginExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIContactExtension_ContactMenu_ClassicExtensionID object:TUICustomerServicePluginExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_ChatVCBottomContainer_ClassicExtensionID object:TUICustomerServicePluginExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID object:TUICustomerServicePluginExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_ClickAvatar_ClassicExtensionID object:TUICustomerServicePluginExtensionObserver.shareInstance];
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

    if ([extensionID isEqualToString:TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID]) {
        return [self getInputViewMoreItemExtensionForClassicChat:param];
    } else if ([extensionID isEqualToString:TUICore_TUIChatExtension_InputViewMoreItem_MinimalistExtensionID]) {
        return [self getInputViewMoreItemExtensionForMinimalistChat:param];
    } else if ([extensionID isEqualToString:TUICore_TUIContactExtension_ContactMenu_ClassicExtensionID]) {
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

// InputViewMoreItem
- (NSArray<TUIExtensionInfo *> *)getInputViewMoreItemExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSString *userID = [param tui_objectForKey:TUICore_TUIChatExtension_InputViewMoreItem_UserID asClass:NSString.class];
    if (![TUICustomerServicePluginPrivateConfig.sharedInstance isCustomerServiceAccount:userID]) {
        return nil;
    }
    if (![TUICustomerServicePluginPrivateConfig sharedInstance].canEvaluate) {
        return nil;
    }
    
    TUIExtensionInfo *evaluation = [[TUIExtensionInfo alloc] init];
    evaluation.weight = 100;
    evaluation.text = TIMCommonLocalizableString(TUIKitMoreEvaluation);
    evaluation.icon = TIMCommonBundleThemeImage(@"service_more_customer_service_evaluation_img", @"more_customer_service_evaluation");
    evaluation.onClicked = ^(NSDictionary *_Nonnull param) {
        NSData *data = [TUITool dictionary2JsonData:@{@"src": BussinessID_Src_CustomerService_EvaluationTrigger}];
        [TUICustomerServicePluginDataProvider sendCustomMessageWithoutUpdateUI:data];
    };
    return @[evaluation];
}

- (NSArray<TUIExtensionInfo *> *)getInputViewMoreItemExtensionForMinimalistChat:(NSDictionary *)param {
    // todo: 精简版 chat 页面底部输入框扩展
    return nil;
}

// ContactMenu
- (NSArray<TUIExtensionInfo *> *)getContactMenuExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    [TUICustomerServicePluginPrivateConfig checkCommercialAbility];
    
    UINavigationController *nav = [param tui_objectForKey:TUICore_TUIContactExtension_ContactMenu_Nav asClass:UINavigationController.class];
    [TUITool addValueAddedUnsupportNeedContactNotificationInVC:nav debugOnly:YES];
    
    TUIExtensionInfo *customerService = [[TUIExtensionInfo alloc] init];
    customerService.weight = 50;
    customerService.text = TIMCommonLocalizableString(TUICustomerServiceAccounts);
    customerService.icon = TUICustomerServicePluginBundleThemeImage(@"customer_service_contact_menu_icon_img", @"contact_customer_service");
    customerService.onClicked = ^(NSDictionary *_Nonnull param) {
        if (![TUICustomerServicePluginPrivateConfig isCustomerServiceSupported]) {
            [TUITool postValueAddedUnsupportNeedContactNotification:TIMCommonLocalizableString(TUICustomerService)];
            NSLog(@"TUICustomerService ability is not supported");
            return;
        }
        TUICustomerServicePluginAccountController *vc = [TUICustomerServicePluginAccountController new];
        [nav pushViewController:vc animated:YES];
    };
    return @[customerService];
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
    if (userID.length == 0 || ![TUICustomerServicePluginPrivateConfig.sharedInstance isCustomerServiceAccount:userID]) {
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
                TUICustomerServicePluginUserController *vc = [[TUICustomerServicePluginUserController alloc] initWithUserInfo:infoList.firstObject];
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
    if (userID.length == 0 || ![TUICustomerServicePluginPrivateConfig.sharedInstance isCustomerServiceAccount:userID]) {
        return nil;
    }
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.onClicked = ^(NSDictionary *_Nonnull param) {
        UINavigationController *nav = [param tui_objectForKey:TUICore_TUIChatExtension_ClickAvatar_PushVC
                                                      asClass:UINavigationController.class];
        if (nav) {
            [[V2TIMManager sharedInstance] getUsersInfo:@[userID]
                                                   succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                TUICustomerServicePluginUserController *vc = [[TUICustomerServicePluginUserController alloc] initWithUserInfo:infoList.firstObject];
                [nav pushViewController:vc animated:YES];
            } fail:^(int code, NSString *desc) {
                
            }];
        }
    };
    return @[info];
}

#pragma mark -- RaiseExtension
- (BOOL)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_ChatVCBottomContainer_ClassicExtensionID]) {
        if (param == nil) {
            NSLog(@"TUIChat notify param is invalid");
            return NO;
        }
        NSString *userID = [param objectForKey:TUICore_TUIChatExtension_ChatVCBottomContainer_UserID];
        if (![TUICustomerServicePluginPrivateConfig.sharedInstance isOnlineShopping:userID]) {
            return NO;
        }
        if (![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
        self.superVC = [param objectForKey:TUICore_TUIChatExtension_ChatVCBottomContainer_VC];
        TUICustomerServicePluginMenuView *view = [[TUICustomerServicePluginMenuView alloc] initWithDataSource:TUICustomerServicePluginConfig.sharedInstance.menuItems];
        [parentView addSubview:view];
        [view updateFrame];
        
        [self notifyHeightChanged];
        return YES;
    }
    return NO;
}

// Menu Event reponse
- (void)notifyHeightChanged {
    NSDictionary *param = @{TUICore_TUIPluginNotify_PluginViewDidAddToSuperviewSubKey_PluginViewHeight: @46};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_PluginViewDidAddToSuperview
                  object:nil
                   param:param];
}

- (void)onProductClicked {
    TUICustomerServicePluginProductInfo *info = TUICustomerServicePluginConfig.sharedInstance.productInfo;
    NSDictionary *dict = @{BussinessID_CustomerService: @0,
                           @"src": BussinessID_Src_CustomerService_Card,
                           @"content": @{@"header": info.title ?: @"",
                                         @"desc": info.desc ?: @"",
                                         @"pic": info.picURL ?: @"",
                                         @"url": info.linkURL ?: @""}
    };
    NSData *data = [TUITool dictionary2JsonData:dict];
    [TUICustomerServicePluginDataProvider sendCustomMessage:data];
}

- (void)onPhraseClicked {
    [self.superVC.inputController reset];
    TUICustomerServicePluginPhraseView *view = [[TUICustomerServicePluginPhraseView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    UIWindow *window = [TUITool applicationKeywindow];
    [window addSubview:view];
}

@end
