
#import "TUIChatService.h"
#import "NSDictionary+TUISafe.h"
#import "TUIMessageDataProvider.h"

#import "TUIThemeManager.h"
#import "TUILogin.h"
#import "TUIChatConfig.h"

@interface TUIChatService ()<TUINotificationProtocol, TUIExtensionProtocol>
@end

@implementation TUIChatService

+ (void)load {
    [TUICore registerService:TUICore_TUIChatService object:[TUIChatService shareInstance]];
    TUIRegisterThemeResourcePath(TUIChatThemePath, TUIThemeModuleChat);
}

+ (TUIChatService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIChatService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIChatService alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSuccessNotification)
                                                     name:TUILoginSuccessNotification object:nil];
    }
    return self;
}

- (void)loginSuccessNotification {
    [TUICore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_EnableFloatWindowMethod
                   param:@{TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow:@(TUIChatConfig.defaultConfig.enableFloatWindowForCall)}];
}

- (NSString *)getDisplayString:(V2TIMMessage *)message {
    return [TUIMessageDataProvider getDisplayString:message];
}

- (TUIBaseChatViewController *)createChatViewController:(NSString *)title
                                                 userID:(NSString *)userID
                                                groupID:(NSString *)groupID
                                         conversationID:(NSString *)conversationID
                                       highlightKeyword:(NSString *)highlightKeyword
                                          locateMessage:(V2TIMMessage *)locateMessage {
    TUIChatConversationModel *conversationModel = [TUIChatConversationModel new];
    conversationModel.title = title;
    conversationModel.userID = userID;
    conversationModel.groupID = groupID;
    conversationModel.conversationID = conversationID;
    
    TUIBaseChatViewController *chatVC = nil;
    if (conversationModel.groupID.length > 0) {
        chatVC = [[TUIGroupChatViewController alloc] init];
    } else if (conversationModel.userID.length > 0) {
        chatVC = [[TUIC2CChatViewController alloc] init];
    }
    chatVC.conversationData = conversationModel;
    chatVC.title = conversationModel.title;
    chatVC.highlightKeyword = highlightKeyword;
    chatVC.locateMessage = locateMessage;
    return chatVC;
}

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIChatService_GetDisplayStringMethod]) {
        return [self getDisplayString:param[TUICore_TUIChatService_GetDisplayStringMethod_MsgKey]];
    }
    else if ([method isEqualToString:TUICore_TUIChatService_GetChatViewControllerMethod]) {
        return [self createChatViewController:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey asClass:NSString.class] userID:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey asClass:NSString.class] groupID:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey asClass:NSString.class] conversationID:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_ConversationIDKey asClass:NSString.class] highlightKeyword:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_HighlightKeywordKey asClass:NSString.class] locateMessage:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_LocateMessageKey asClass:V2TIMMessage.class]];
    }
    
    return nil;
}


@end
