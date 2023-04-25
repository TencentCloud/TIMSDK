//
//  TUISearchExtensionObserver.m
//  TUISearch
//
//  Created by harvy on 2023/4/3.
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

static id _instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - TUIExtensionProtocol
- (void)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return;
    }
    
    if ([extensionID isEqualToString:TUICore_TUIConversationExtension_ConversationListBanner_ClassicExtensionID]) {
        if (![param isKindOfClass:NSDictionary.class]) {
            return;
        }
        UIViewController *modalVC = [param tui_objectForKey:TUICore_TUIConversationExtension_ConversationListBanner_ModalVC asClass:UIViewController.class];
        NSString *sizeStr = [param tui_objectForKey:TUICore_TUIConversationExtension_ConversationListBanner_BannerSize asClass:NSString.class];
        CGSize size = CGSizeFromString(sizeStr);
        
        TUISearchBar *searchBar = [[TUISearchBar alloc] init];
        searchBar.frame = CGRectMake(0, 0, size.width, size.height);
        [searchBar setParentVC:modalVC];
        [searchBar setEntrance:YES];
        if(parentView) {
            [parentView addSubview:searchBar];
        }
    } else {
        // do nothing
    }
}

@end
