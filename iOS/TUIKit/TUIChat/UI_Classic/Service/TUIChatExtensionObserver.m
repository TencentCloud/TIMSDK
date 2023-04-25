//
//  TUIChatExtensionObserver.m
//  TUIChat
//
//  Created by cologne on 2023/3/30.
//

#import "TUIChatExtensionObserver.h"
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMCommonModel.h>

@interface TUIChatExtensionObserver () <TUIExtensionProtocol>

@end

@implementation TUIChatExtensionObserver

+ (void)load {
    [self registerFriendProfileActionMenuExtension];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)registerFriendProfileActionMenuExtension {
    [TUICore registerExtension:TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID object:TUIChatExtensionObserver.shareInstance];
}

#pragma mark - TUIExtensionProtocol
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }
    
    if ([extensionID isEqualToString:TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID]) {
        return [self getFriendProfileActionMenuExtensionForClassicContact:param];
    } else {
        return nil;
    }
    
}

- (NSArray<TUIExtensionInfo *> *)getFriendProfileActionMenuExtensionForClassicContact:(NSDictionary *)param {
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.weight = 300;
    info.text = TIMCommonLocalizableString(ProfileSendMessages);
    info.onClicked = ^(NSDictionary * _Nonnull actionParam) {
        NSString *userID = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID asClass:NSString.class];
        UINavigationController *pushVC = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC asClass:UINavigationController.class];
        if (userID.length > 0 && pushVC) {
            NSDictionary *param = @{
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey : userID,
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_ConversationIDKey: [NSString stringWithFormat:@"c2c_%@", userID]
            };
            UIViewController *chatVC = [TUICore createObject:TUICore_TUIChatObjectFactory key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
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
