
#import "TUIConversationService.h"

@implementation TUIConversationService

static NSString *g_serviceName = nil;

+ (void)load {
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

@end
