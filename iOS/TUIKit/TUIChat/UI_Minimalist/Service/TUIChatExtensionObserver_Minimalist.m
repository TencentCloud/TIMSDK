//
//  TUIChatExtensionObserver_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2023/4/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatExtensionObserver_Minimalist.h"

#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>

#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIGroupChatViewController_Minimalist.h"

@interface TUIChatExtensionObserver_Minimalist () <TUIExtensionProtocol>

@end

@implementation TUIChatExtensionObserver_Minimalist

+ (void)load {
    [TUICore registerExtension:TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID
                        object:TUIChatExtensionObserver_Minimalist.shareInstance];
    [TUICore registerExtension:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID
                        object:TUIChatExtensionObserver_Minimalist.shareInstance];
}

static id gShareinstance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gShareinstance = [[self alloc] init];
    });
    return gShareinstance;
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
    info.text = TIMCommonLocalizableString(TUIKitMessage);
    ;
    info.icon = TUIDynamicImage(@"", TUIThemeModuleContact_Minimalist, [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_message")]);
    info.onClicked = ^(NSDictionary *_Nonnull actionParam) {
      NSString *userID = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID asClass:NSString.class];
      UIImage *icon = actionParam[TUICore_TUIContactExtension_FriendProfileActionMenu_UserIcon];
      NSString *userName = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserName asClass:NSString.class];
      UINavigationController *pushVC = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC
                                                             asClass:UINavigationController.class];
      if (userID.length > 0 && pushVC) {
          TUIChatConversationModel *conversationModel = [[TUIChatConversationModel alloc] init];
          conversationModel.title = userName;
          conversationModel.userID = userID;
          conversationModel.conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
          conversationModel.avatarImage = icon ?: [UIImage new];
          TUIBaseChatViewController_Minimalist *chatVC = [[TUIC2CChatViewController_Minimalist alloc] init];
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

- (NSArray<TUIExtensionInfo *> *)getGroupInfoCardActionMenuActionMenuExtensionForMinimalistContact:(NSDictionary *)param {
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.weight = 300;
    info.text = TIMCommonLocalizableString(TUIKitMessage);
    ;
    info.icon = TUIDynamicImage(@"", TUIThemeModuleContact_Minimalist, [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_message")]);
    info.onClicked = ^(NSDictionary *_Nonnull actionParam) {
      NSString *groupID = [actionParam tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID asClass:NSString.class];
      UINavigationController *pushVC = [actionParam tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC
                                                             asClass:UINavigationController.class];
      if (groupID.length > 0 && pushVC) {
          TUIChatConversationModel *conversationModel = [[TUIChatConversationModel alloc] init];
          conversationModel.groupID = groupID;
          conversationModel.conversationID = [NSString stringWithFormat:@"group_%@", groupID];
          TUIBaseChatViewController_Minimalist *chatVC = [[TUIGroupChatViewController_Minimalist alloc] init];
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

@end
