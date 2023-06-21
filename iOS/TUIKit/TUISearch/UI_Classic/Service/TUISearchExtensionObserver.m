//
//  TUISearchExtensionObserver.m
//  TUISearch
//
//  Created by harvy on 2023/4/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISearchExtensionObserver.h"

#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>

#import "TUISearchBar.h"

@interface TUISearchExtensionObserver () <TUIExtensionProtocol>

@end

@implementation TUISearchExtensionObserver

+ (void)load {
    [TUICore registerExtension:TUICore_TUIConversationExtension_ConversationListBanner_ClassicExtensionID object:TUISearchExtensionObserver.shareInstance];
}

static id gShareInstance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      gShareInstance = [[self alloc] init];
    });
    return gShareInstance;
}

#pragma mark - TUIExtensionProtocol
- (BOOL)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return NO;
    }

    if ([extensionID isEqualToString:TUICore_TUIConversationExtension_ConversationListBanner_ClassicExtensionID]) {
        if (![param isKindOfClass:NSDictionary.class] || parentView == nil || ![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
        UIViewController *modalVC = [param tui_objectForKey:TUICore_TUIConversationExtension_ConversationListBanner_ModalVC asClass:UIViewController.class];
        NSString *sizeStr = [param tui_objectForKey:TUICore_TUIConversationExtension_ConversationListBanner_BannerSize asClass:NSString.class];
        CGSize size = CGSizeFromString(sizeStr);

        TUISearchBar *searchBar = [[TUISearchBar alloc] init];
        searchBar.frame = CGRectMake(0, 0, size.width, size.height);
        [searchBar setParentVC:modalVC];
        [searchBar setEntrance:YES];
        [parentView addSubview:searchBar];
        return YES;
    } else {
        // do nothing
        return NO;
    }
}

@end
