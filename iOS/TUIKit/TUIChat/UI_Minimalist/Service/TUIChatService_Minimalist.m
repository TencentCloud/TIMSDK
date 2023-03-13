
#import "TUIChatService_Minimalist.h"
#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIGroupChatViewController_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIThemeManager.h"
#import "TUILogin.h"
#import "TUIChatConfig.h"
#import "NSDictionary+TUISafe.h"

@interface TUIChatService_Minimalist ()<TUINotificationProtocol, TUIExtensionProtocol>

@end

@implementation TUIChatService_Minimalist

+ (void)load {
    [TUICore registerService:TUICore_TUIChatService_Minimalist object:[TUIChatService_Minimalist shareInstance]];
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUIChatTheme_Minimalist",TUIChatBundle_Key_Class), TUIThemeModuleChat_Minimalist);
}

+ (TUIChatService_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIChatService_Minimalist * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIChatService_Minimalist alloc] init];
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
    [TUICore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_EnableMultiDeviceAbilityMethod
                   param:@{TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility:@(TUIChatConfig.defaultConfig.enableMultiDeviceForCall)}];
}

- (NSString *)getDisplayString:(V2TIMMessage *)message {
    return [TUIMessageDataProvider_Minimalist getDisplayString:message];
}


- (UIViewController *)createChatViewController:(NSString *)title
                                        userID:(NSString *)userID
                                       groupID:(NSString *)groupID
                                conversationID:(NSString *)conversationID
                                   avatarImage:(UIImage *)avatarImage
                                     avatarUrl:(NSString *)avatarUrl
                              highlightKeyword:(NSString *)highlightKeyword
                                 locateMessage:(V2TIMMessage *)locateMessage
                                     atMsgSeqs:(NSArray<NSNumber *> *)atMsgSeqs
                                         draft:(NSString *)draft {
    TUIChatConversationModel *conversationModel = [TUIChatConversationModel new];
    conversationModel.title = title;
    conversationModel.userID = userID;
    conversationModel.groupID = groupID;
    conversationModel.conversationID = conversationID;
    conversationModel.avatarImage = avatarImage;
    conversationModel.faceUrl = avatarUrl;
    conversationModel.atMsgSeqs = [NSMutableArray arrayWithArray:atMsgSeqs];
    conversationModel.draftText = draft;
    
    TUIBaseChatViewController_Minimalist *chatVC = nil;
    if (conversationModel.groupID.length > 0) {
        chatVC = [[TUIGroupChatViewController_Minimalist alloc] init];
    } else if (conversationModel.userID.length > 0) {
        chatVC = [[TUIC2CChatViewController_Minimalist alloc] init];
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
    } else if ([method isEqualToString:TUICore_TUIChatService_GetChatViewControllerMethod]) {
        return [self createChatViewController:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey asClass:NSString.class]
                                       userID:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey asClass:NSString.class]
                                      groupID:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey asClass:NSString.class]
                               conversationID:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_ConversationIDKey asClass:NSString.class]
                                  avatarImage:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_AvatarImageKey asClass:UIImage.class]
                                    avatarUrl:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_AvatarUrlKey asClass:NSString.class]
                             highlightKeyword:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_HighlightKeywordKey asClass:NSString.class]
                                locateMessage:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_LocateMessageKey asClass:V2TIMMessage.class]
                                    atMsgSeqs:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_AtMsgSeqsKey asClass:NSArray.class]
                                        draft:[param tui_objectForKey:TUICore_TUIChatService_GetChatViewControllerMethod_DraftKey asClass:NSString.class]];
    } else if ([method isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod]) {
        [param enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL * _Nonnull stop) {
            if (![key isKindOfClass:NSString.class] || ![obj isKindOfClass:NSNumber.class]) {
                return;
            }
            if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableVideoCallKey]) {
                TUIChatConfig.defaultConfig.enableVideoCall = obj.boolValue;
            } else if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableAudioCallKey]) {
                TUIChatConfig.defaultConfig.enableAudioCall = obj.boolValue;
            } else if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableLinkKey]) {
                TUIChatConfig.defaultConfig.enableLink = obj.boolValue;
            }
        }];
    }
    
    return nil;
}


@end
