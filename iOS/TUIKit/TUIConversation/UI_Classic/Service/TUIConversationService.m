
#import "TUIConversationService.h"
#import "TUIConversationListController.h"
#import "TUIConversationSelectController.h"
#import "TUIThemeManager.h"

@implementation TUIConversationService

static NSString *g_serviceName = nil;

+ (void)load {
    [TUICore registerService:TUICore_TUIConversationService object:[TUIConversationService shareInstance]];
    TUIRegisterThemeResourcePath(TUIConversationThemePath, TUIThemeModuleConversation);
}

+ (TUIConversationService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIConversationService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIConversationService alloc] init];
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
    return [[TUIConversationListController alloc] init];
}

- (UIViewController *)createConversationSelectController {
    return [[TUIConversationSelectController alloc] init];
}

@end
