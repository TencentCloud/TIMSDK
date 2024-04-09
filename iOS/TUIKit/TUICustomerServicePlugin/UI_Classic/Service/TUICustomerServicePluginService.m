//
//  TUICustomerServicePluginService.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginService.h"
#import <TUIChat/TUIChatConfig.h>
#import <TUIChat/TUIChatConversationModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUICustomerServicePluginDataProvider.h"
#import "TUICustomerServicePluginPrivateConfig.h"
#import "TUICustomerServicePluginExtensionObserver.h"

@interface TUICustomerServicePluginService() <TUINotificationProtocol, TUIExtensionProtocol>

@end

@implementation TUICustomerServicePluginService

+ (void)load {
    NSLog(@"TUICustomerServicePluginService load");
    [TUICustomerServicePluginService sharedInstance];
    TUIRegisterThemeResourcePath(TUICustomerServicePluginThemePath, TUIThemeModuleCustomerService);
}

+ (TUICustomerServicePluginService *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUICustomerServicePluginService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICustomerServicePluginService alloc] init];
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
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_Evaluation),
                           TMessageCell_Name : @"TUICustomerServicePluginEvaluationCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginEvaluationCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_EvaluationSelected),
                           TMessageCell_Name : @"TUICustomerServicePluginInvisibleCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginInvisibleCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_Typing),
                           TMessageCell_Name : @"TUIMessageCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginTypingCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_Branch),
                           TMessageCell_Name : @"TUICustomerServicePluginBranchCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginBranchCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_End),
                           TMessageCell_Name : @"TUIMessageCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginInvisibleCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_Timeout),
                           TMessageCell_Name : @"TUICustomerServicePluginInvisibleCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginInvisibleCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_EvaluationRule),
                           TMessageCell_Name : @"TUICustomerServicePluginInvisibleCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginInvisibleCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_EvaluationTrigger),
                           TMessageCell_Name : @"TUICustomerServicePluginInvisibleCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginInvisibleCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_Collection),
                           TMessageCell_Name : @"TUICustomerServicePluginCollectionCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginCollectionCellData"
                         }
    ];
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : GetCustomerServiceBussinessID(BussinessID_Src_CustomerService_Card),
                           TMessageCell_Name : @"TUICustomerServicePluginCardCell",
                           TMessageCell_Data_Name : @"TUICustomerServicePluginCardCellData"
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
        if (![TUICustomerServicePluginPrivateConfig.sharedInstance isCustomerServiceAccount:userID]) {
            return;
        }
        NSData *data = [TUITool dictionary2JsonData:@{@"src": BussinessID_Src_CustomerService_Request}];
        [TUICustomerServicePluginDataProvider sendCustomMessageWithoutUpdateUI:data];
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
        if (!userID || ![TUICustomerServicePluginPrivateConfig.sharedInstance isCustomerServiceAccount:userID]) {
            return nil;
        }
        TUIExtensionInfo *extensionInfo = [[TUIExtensionInfo alloc] init];
        extensionInfo.data = @{TUICore_TUIChatExtension_GetChatConversationModelParams_MsgNeedReadReceipt : @(YES),
                               TUICore_TUIChatExtension_GetChatConversationModelParams_EnableVideoCall : @(NO),
                               TUICore_TUIChatExtension_GetChatConversationModelParams_EnableAudioCall : @(NO),
                               TUICore_TUIChatExtension_GetChatConversationModelParams_EnableWelcomeCustomMessage : @(NO)};
        return @[extensionInfo];
    }
    return nil;
}

@end
