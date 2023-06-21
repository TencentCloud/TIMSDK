//
//  TUIGroupExtensionObserver.m
//  TUIGroup
//
//  Created by harvy on 2023/3/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupExtensionObserver.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUICore.h>

#import "TUIGroupInfoController.h"

@interface TUIGroupExtensionObserver () <TUIExtensionProtocol>

@end

@implementation TUIGroupExtensionObserver

+ (void)load {
    [TUICore registerExtension:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID object:TUIGroupExtensionObserver.shareInstance];
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
    NSString *groupID = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_GroupID asClass:NSString.class];
    if (groupID.length > 0) {
        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.icon = TUIGroupBundleThemeImage(@"chat_nav_more_menu_img", @"chat_nav_more_menu");
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
