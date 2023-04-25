#import "TUISearchService_Minimalist.h"
#import "TUISearchBar_Minimalist.h"

#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUISearchService_Minimalist

+ (void)load {
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUISearchTheme_Minimalist",TUISearchBundle_Key_Class), TUIThemeModuleSearch_Minimalist);
}

static id _instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

@end
