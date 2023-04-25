//
//  TUIChatExtensionObserver_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2023/4/3.
//

#import "TUIChatExtensionObserver_Minimalist.h"

#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>

@interface TUIChatExtensionObserver_Minimalist () <TUIExtensionProtocol>

@end

@implementation TUIChatExtensionObserver_Minimalist

+ (void)load {
    [TUICore registerExtension:TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID object:TUIChatExtensionObserver_Minimalist.shareInstance];
    [TUICore registerExtension:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID object:TUIChatExtensionObserver_Minimalist.shareInstance];
}

static id _instace = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

#pragma mark - TUIExtensionProtocol
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }
    
    if ([extensionID isEqualToString:TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID]) {
        return [self getFriendProfileActionMenuExtensionForMinimalistContact:param];
    } else if ([extensionID isEqualToString:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID]) {
        return [self getGroupInfoCardActionMenuActionMenuExtensionForMinimalistContact:param];
    } else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getFriendProfileActionMenuExtensionForMinimalistContact:(NSDictionary *)param {
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.weight = 300;
    info.text = TIMCommonLocalizableString(TUIKitMessage);;
    info.icon = TUIDynamicImage(@"", TUIThemeModuleContact_Minimalist, [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_message")]);
    info.onClicked = ^(NSDictionary * _Nonnull actionParam) {
        NSString *userID = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID asClass:NSString.class];
        UIImage *icon = actionParam[TUICore_TUIContactExtension_FriendProfileActionMenu_UserIcon];
        NSString *userName = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserName asClass:NSString.class];
        UINavigationController *pushVC = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC asClass:UINavigationController.class];
        if (userID.length > 0 && pushVC) {
            NSDictionary *param = @{
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey : userID,
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_ConversationIDKey: [NSString stringWithFormat:@"c2c_%@", userID],
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey:userName,
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarImageKey: icon?:[UIImage new]
            };
            UIViewController *chatVC = [TUICore createObject:TUICore_TUIChatObjectFactory_Minimalist key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
            for (UIViewController *vc in pushVC.childViewControllers) {
                if ([vc isKindOfClass:chatVC.class]) {
                    [pushVC popToViewController:vc animated:YES];
                    return;
                }
            }
            [pushVC pushViewController:chatVC animated:YES];
        }
    };
    return @[info];
}

- (NSArray<TUIExtensionInfo *> *)getGroupInfoCardActionMenuActionMenuExtensionForMinimalistContact:(NSDictionary *)param{
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.weight = 300;
    info.text = TIMCommonLocalizableString(TUIKitMessage);;
    info.icon = TUIDynamicImage(@"", TUIThemeModuleContact_Minimalist, [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_message")]);
    info.onClicked = ^(NSDictionary * _Nonnull actionParam) {
        NSString *groupID = [actionParam tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID asClass:NSString.class];
        UINavigationController *pushVC = [actionParam tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC asClass:UINavigationController.class];
        if (groupID.length > 0 && pushVC) {
            NSDictionary *param = @{
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_GroupIDKey : groupID,
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_ConversationIDKey: [NSString stringWithFormat:@"group_%@", groupID]
            };
            UIViewController *chatVC = [TUICore createObject:TUICore_TUIChatObjectFactory_Minimalist key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
            for (UIViewController *vc in pushVC.childViewControllers) {
                if ([vc isKindOfClass:chatVC.class]) {
                    [pushVC popToViewController:vc animated:YES];
                    return;
                }
            }
            [pushVC pushViewController:chatVC animated:YES];
        }
    };
    return @[info];
}

@end
