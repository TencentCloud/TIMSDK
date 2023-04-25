//
//  TUIContactExtensionObserver.m
//  TUIContact
//
//  Created by harvy on 2023/3/29.
//

#import "TUIContactExtensionObserver.h"
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMCommonModel.h>


@interface TUIContactExtensionObserver () <TUIExtensionProtocol>

@end

@implementation TUIContactExtensionObserver

+ (void)load {
    [TUICore registerExtension:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID object:TUIContactExtensionObserver.shareInstance];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - TUIExtensionProtocol
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID]) {
        return [self getNavigationMoreItemExtensionForClassicChat:param];
    } else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getNavigationMoreItemExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSString *userID = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_UserID asClass:NSString.class];
    if (userID.length > 0) {
        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.icon = TUIContactBundleThemeImage(@"chat_nav_more_menu_img", @"chat_nav_more_menu");
        info.onClicked = ^(NSDictionary * _Nonnull param) {
            UINavigationController *pushVC = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_PushVC asClass:UINavigationController.class];
            if (pushVC) {
                NSDictionary *param = @{
                    TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
                    TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: ^(UIViewController *vc){
                        [pushVC pushViewController:vc animated:YES];
                    },
                    TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: ^(int code, NSString * desc){}
                };
                [TUICore createObject:TUICore_TUIContactObjectFactory key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];                
            }
        };
        return @[info];
    } else {
        return nil;
    }
}

@end
