#import "TUISearchService_Minimalist.h"
#import "TUISearchBar_Minimalist.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUISearchService_Minimalist

+ (void)load {
    [TUICore registerExtension:TUICore_TUIConversationExtension_GetSearchBar_Minimalist object:[TUISearchService_Minimalist shareInstance]];
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUISearchTheme_Minimalist",TUISearchBundle_Key_Class), TUIThemeModuleSearch_Minimalist);
}

+ (TUISearchService_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUISearchService_Minimalist * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUISearchService_Minimalist alloc] init];
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
    TUISearchBar_Minimalist *searchBar = [[TUISearchBar_Minimalist alloc] init];
    [searchBar setParentVC:parentVC];
    [searchBar setEntrance:YES];
    return searchBar;
}

@end
