//
//  TUIChatBotPluginService.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginService.h"
#import <TIMCommon/TIMDefine.h>
#import <TUIChat/TUIChatConfig.h>
#import <TUIChat/TUIChatConversationModel.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUIChatBotPluginDataProvider.h"
#import "TUIChatBotPluginPrivateConfig.h"
#import "TUIChatBotPluginExtensionObserver.h"

@interface TUIChatBotPluginService() <TUINotificationProtocol, TUIExtensionProtocol>

@end

@implementation TUIChatBotPluginService

+ (void)load {
    NSLog(@"TUIChatBotPluginService load");
    [TUIChatBotPluginService sharedInstance];
    TUIRegisterThemeResourcePath(TUIChatBotPluginThemePath, TUIThemeModuleChatBot);
}

+ (TUIChatBotPluginService *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUIChatBotPluginService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIChatBotPluginService alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self registerEvent];
        [self registerExtension];
        [self registerCustomMessageCell];
    }
    return self;
}

- (void)registerEvent {
    [TUICore registerEvent:TUICore_TUIChatNotify
                    subKey:TUICore_TUIChatNotify_ChatVC_ViewDidLoadSubKey
                    object:self];
}

- (void)registerExtension {
    [TUICore registerExtension:TUICore_TUIChatExtension_GetChatConversationModelParams object:self];
}

- (void)registerCustomMessageCell {
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetChatBotBussinessID(BussinessID_Src_ChatBot_Welcome_Clarify_Selected),
                           TMessageCell_Name : @"TUIChatBotPluginBranchCell",
                           TMessageCell_Data_Name : @"TUIChatBotPluginBranchCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetChatBotBussinessID(BussinessID_Src_ChatBot_Stream_Text),
                           TMessageCell_Name : @"TUIChatBotPluginStreamTextCell",
                           TMessageCell_Data_Name : @"TUIChatBotPluginStreamTextCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetChatBotBussinessID(BussinessID_Src_ChatBot_Rich_Text),
                           TMessageCell_Name : @"TUIChatBotPluginRichTextCell",
                           TMessageCell_Data_Name : @"TUIChatBotPluginRichTextCellData"
                         }
    ];
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIChatNotify] &&
        [subKey isEqualToString:TUICore_TUIChatNotify_ChatVC_ViewDidLoadSubKey]) {
        if (param == nil) {
            NSLog(@"TUIChat notify param is invalid");
            return;
        }
        NSString *userID = [param objectForKey:TUICore_TUIChatNotify_ChatVC_ViewDidLoadSubKey_UserID];
        if (![TUIChatBotPluginPrivateConfig.sharedInstance isChatBotAccount:userID]) {
            return;
        }
        NSData *data = [TUITool dictionary2JsonData:@{BussinessID_ChatBot : @(1), @"src": BussinessID_Src_ChatBot_Request}];
        [TUIChatBotPluginDataProvider sendCustomMessageWithoutUpdateUI:data];
    }
}

#pragma mark - TUIExtensionProtocol
- (nullable NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(nullable NSDictionary *)param {
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_GetChatConversationModelParams]) {
        if (extensionID == nil) {
            NSLog(@"extensionID is invalid");
            return nil;
        }
        NSString *userID = [param objectForKey:TUICore_TUIChatExtension_GetChatConversationModelParams_UserID];
        if (!userID || ![TUIChatBotPluginPrivateConfig.sharedInstance isChatBotAccount:userID]) {
            return nil;
        }
        TUIExtensionInfo *extensionInfo = [[TUIExtensionInfo alloc] init];
        extensionInfo.data = @{TUICore_TUIChatExtension_GetChatConversationModelParams_MsgNeedReadReceipt : @(NO),
                               TUICore_TUIChatExtension_GetChatConversationModelParams_EnableVideoCall : @(NO),
                               TUICore_TUIChatExtension_GetChatConversationModelParams_EnableAudioCall : @(NO),
                               TUICore_TUIChatExtension_GetChatConversationModelParams_EnableWelcomeCustomMessage : @(NO)};
        return @[extensionInfo];
    }
    return nil;
}

@end
