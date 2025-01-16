//
//  TUIChatExtensionObserver.m
//  TUIChat
//
//  Created by cologne on 2023/3/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatExtensionObserver.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUICore.h>
#import "TUIC2CChatViewController.h"
#import "TUIGroupInfoController.h"

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

    [TUICore registerExtension:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID object:TUIChatExtensionObserver.shareInstance];
}

#pragma mark - TUIExtensionProtocol
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }

    if ([extensionID isEqualToString:TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID]) {
        return [self getFriendProfileActionMenuExtensionForClassicContact:param];
    }
    else if ([extensionID isEqualToString:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID]) {
        return [self getNavigationMoreItemExtensionForClassicChat:param];
    }
    else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getFriendProfileActionMenuExtensionForClassicContact:(NSDictionary *)param {
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.weight = 300;
    info.text = TIMCommonLocalizableString(ProfileSendMessages);
    info.onClicked = ^(NSDictionary *_Nonnull actionParam) {
      NSString *userID = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID asClass:NSString.class];
      UINavigationController *pushVC = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC
                                                             asClass:UINavigationController.class];
      if (userID.length > 0 && pushVC) {
          TUIChatConversationModel *conversationModel = [[TUIChatConversationModel alloc] init];
          conversationModel.userID = userID;
          conversationModel.conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
          TUIBaseChatViewController *chatVC = [[TUIC2CChatViewController alloc] init];
          chatVC.conversationData = conversationModel;
          chatVC.title = conversationModel.title;
          for (UIViewController *vc in pushVC.childViewControllers) {
              if ([vc isKindOfClass:chatVC.class]) {
                  [pushVC popToViewController:vc animated:YES];
                  return;
              }
          }
          [pushVC pushViewController:chatVC animated:YES];
      }
    };
    return @[ info ];
}

- (NSArray<TUIExtensionInfo *> *)getNavigationMoreItemExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSString *groupID = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_GroupID asClass:NSString.class];
    if (groupID.length > 0) {
        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.icon = TIMCommonBundleThemeImage(@"chat_nav_more_menu_img", @"chat_nav_more_menu");
        info.onClicked = ^(NSDictionary *_Nonnull param) {
          UINavigationController *pushVC = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_PushVC asClass:UINavigationController.class];
          if (pushVC) {
              TUIGroupInfoController *vc = [[TUIGroupInfoController alloc] init];
              vc.groupId = groupID;
              [pushVC pushViewController:vc animated:YES];
          }
        };
        return @[ info ];
    } else {
        return nil;
    }
}
@end
