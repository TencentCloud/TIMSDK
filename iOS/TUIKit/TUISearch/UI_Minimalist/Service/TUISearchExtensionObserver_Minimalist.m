//
//  TUISearchExtensionObserver_Minimalist.m
//  TUISearch
//
//  Created by harvy on 2023/4/3.
//

#import "TUISearchExtensionObserver_Minimalist.h"

#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>

#import "TUISearchBar_Minimalist.h"

@interface TUISearchExtensionObserver_Minimalist () <TUIExtensionProtocol>

@end

@implementation TUISearchExtensionObserver_Minimalist

+ (void)load {
    [TUICore registerExtension:TUICore_TUIConversationExtension_ConversationListBanner_MinimalistExtensionID object:TUISearchExtensionObserver_Minimalist.shareInstance];
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
    
    if ([extensionID isEqualToString:TUICore_TUIConversationExtension_ConversationListBanner_MinimalistExtensionID]) {
        if (![param isKindOfClass:NSDictionary.class]) {
            return;
        }
        UIViewController *modalVC = [param tui_objectForKey:TUICore_TUIConversationExtension_ConversationListBanner_ModalVC asClass:UIViewController.class];
        NSString *sizeStr = [param tui_objectForKey:TUICore_TUIConversationExtension_ConversationListBanner_BannerSize asClass:NSString.class];
        CGSize size = CGSizeFromString(sizeStr);
        
        TUISearchBar_Minimalist *searchBar = [[TUISearchBar_Minimalist alloc] init];
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
