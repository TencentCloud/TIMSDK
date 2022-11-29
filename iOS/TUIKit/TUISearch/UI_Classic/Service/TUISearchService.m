#import "TUISearchService.h"
#import "TUISearchBar.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUISearchService

+ (void)load {
    [TUICore registerExtension:TUICore_TUIConversationExtension_GetSearchBar object:[TUISearchService shareInstance]];
    TUIRegisterThemeResourcePath(TUISearchThemePath, TUIThemeModuleSearch);
}

+ (TUISearchService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUISearchService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUISearchService alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUIExtensionProtocol
- (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIConversationExtension_GetSearchBar] ||
        [key isEqualToString:TUICore_TUIConversationExtension_GetSearchBar_Minimalist]) {
        UIViewController *parentVC = [param tui_objectForKey:TUICore_TUIConversationExtension_ParentVC asClass:UIViewController.class];
        return @{TUICore_TUIConversationExtension_SearchBar : [self createSearchBar:key parentVC:parentVC]};
    }
    return nil;
}

- (UIView *)createSearchBar:(NSString *)key parentVC:(UIViewController *)parentVC {
    TUISearchBar *searchBar = [[TUISearchBar alloc] init];
    [searchBar setParentVC:parentVC];
    [searchBar setEntrance:YES];
    return searchBar;
}

@end
