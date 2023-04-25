#import "TUISearchService.h"

#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>

#import "TUISearchBar.h"

@implementation TUISearchService

+ (void)load {
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

@end
