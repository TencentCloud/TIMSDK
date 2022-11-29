
#import "TUIConversationService_Minimalist.h"
#import "TUIConversationListController_Minimalist.h"
#import "TUIConversationSelectController_Minimalist.h"
#import "TUIThemeManager.h"

@implementation TUIConversationService_Minimalist

+ (void)load {
    [TUICore registerService:TUICore_TUIConversationService_Minimalist object:[TUIConversationService_Minimalist shareInstance]];
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUIConversationTheme_Minimalist",TUIConversationBundle_Key_Class), TUIThemeModuleConversation_Minimalist);
}

+ (TUIConversationService_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIConversationService_Minimalist * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIConversationService_Minimalist alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUICoreServiceProtocol
- (id)onCall:(NSString *)method param:(NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIConversationService_GetConversationControllerMethod]) {
        return [self createConversationController];
    } else if ([method isEqualToString:TUICore_TUIConversationService_GetConversationSelectControllerMethod]) {
        return [self createConversationSelectController];
    }
    return nil;
}

- (UIViewController *)createConversationController {
    return [[TUIConversationListController_Minimalist alloc] init];
}

- (UIViewController *)createConversationSelectController {
    return [[TUIConversationSelectController_Minimalist alloc] init];
}

@end
