//
//  TUIC2CChatViewController_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//

#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIBaseChatViewController_Minimalist+ProtectedAPI.h"
#import "TUILinkCellData_Minimalist.h"
#import "TUIMessageController_Minimalist.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIChatConfig.h"

#define kC2CTypingTime 30.0

@interface TUIC2CChatViewController_Minimalist ()

//如果满足了一次sendTypingBaseCondation 则当前会话未退出前都使用 sendTypingBaseCondationInVC
//If one sendTypingBaseCondation is satisfied, sendTypingBaseCondationInVC is used until the current session exits

@property (nonatomic ,assign) BOOL sendTypingBaseCondationInVC;

@end

@implementation TUIC2CChatViewController_Minimalist

- (void)dealloc {
    self.sendTypingBaseCondationInVC = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sendTypingBaseCondationInVC = NO;
}

- (void)videoCallBtnClick:(UIButton *)btn {
    if(self.conversationData.userID.length > 0) {
        [self c2cCall:self.conversationData.userID isVideoCall:YES];
    }
}

#pragma mark - Call
- (void)c2cCall:(NSString *)userID isVideoCall:(BOOL)isVideoCall {
    NSDictionary *param = @{
        TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[userID],
        TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : isVideoCall ? @"1" : @"0"
    };
    [TUICore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_ShowCallingViewMethod
                   param:param];
}


#pragma mark - Override Methods
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr
{
    return [NSString stringWithFormat:TUIKitLocalizableString(TUIKitRelayChatHistoryForSomebodyFormat), self.conversationData.title, nameStr];
}

- (void)inputController:(TUIInputController_Minimalist *)inputController didSelectMoreCellAction:(NSString *)actionName {
    [super inputController:inputController didSelectMoreCellAction:actionName];
    if([actionName isEqualToString:TUIInputMoreCellKey_Link]) {  // 自定义消息
        NSString *text = TUIKitLocalizableString(TUIKitWelcome);
        NSString *link = TUITencentCloudHomePageEN;
        NSString *language = [TUIGlobalization tk_localizableLanguageKey];
        if ([language containsString:@"zh-"]) {
            link =  TUITencentCloudHomePageCN;
        }
        NSError *error = nil;
        NSDictionary *param = @{BussinessID: BussinessID_TextLink, @"text":text, @"link":link};
        NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
            return;
        }
        V2TIMMessage *message = [TUIMessageDataProvider_Minimalist getCustomMessageWithJsonData:data];
        [self sendMessage:message];
    }
}
- (void)inputControllerBeginTyping:(TUIInputController_Minimalist *)inputController {

    [super inputControllerBeginTyping:inputController];

    [self sendTypingMsgByStatus:YES];

}

- (void)inputControllerEndTyping:(TUIInputController_Minimalist *)inputController {

    [super inputControllerEndTyping:inputController];

    [self sendTypingMsgByStatus:NO];
    
}


- (BOOL)sendTypingBaseCondation {
    
    if (self.sendTypingBaseCondationInVC) {
        return YES;
    }
    
    if ([self.messageController isKindOfClass:TUIMessageController_Minimalist.class]) {
        TUIMessageController_Minimalist *vc = (TUIMessageController_Minimalist *)self.messageController;
        NSDictionary * messageFeatureDic = (id)[vc.C2CIncomingLastMsg parseCloudCustomData:messageFeature];
        
        if (messageFeatureDic && [messageFeatureDic isKindOfClass:[NSDictionary class]]  && [messageFeatureDic.allKeys containsObject:@"needTyping"] && [messageFeatureDic.allKeys containsObject:@"version"]) {

            BOOL needTyping = NO;
            
            BOOL versionControl = NO;
            
            BOOL timeControl = NO;

            
            if ( [messageFeatureDic[@"needTyping"] intValue] == 1) {
                needTyping = YES;
            }
            
            if ([messageFeatureDic[@"version"] intValue]  == 1) {
                versionControl = YES;
            }
            
            CFTimeInterval current = [NSDate.new timeIntervalSince1970];
            long currentTimeFloor = floor(current);
            long otherSideTimeFloor = floor([vc.C2CIncomingLastMsg.timestamp timeIntervalSince1970]);
            long interval = currentTimeFloor - otherSideTimeFloor;
            if (interval <= kC2CTypingTime) {
                timeControl = YES;
            }
            
            if (needTyping && versionControl && timeControl) {
                self.sendTypingBaseCondationInVC = YES;
                return YES;
            }
        }

    }
    return NO;
}
- (void)sendTypingMsgByStatus:(BOOL)editing {
    
    //switch control
    if (![TUIChatConfig defaultConfig].enableTypingStatus) {
        return ;
    }
    
    if (![self sendTypingBaseCondation]) {
        return;
    }
    
    NSError *error = nil;
    NSDictionary *param = @{BussinessID: BussinessID_Typing,
                            @"typingStatus":editing?@1:@0,
                            @"version":@1,
                            @"userAction":@14,
                            @"actionParam":editing?@"EIMAMSG_InputStatus_Ing":@"EIMAMSG_InputStatus_End",
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];

    V2TIMMessage *msg = [TUIMessageDataProvider_Minimalist getCustomMessageWithJsonData:data];
    
    [TUIMessageDataProvider_Minimalist sendMessage:msg toConversation:self.conversationData isSendPushInfo:NO isOnlineUserOnly:YES priority:V2TIM_PRIORITY_DEFAULT Progress:^(uint32_t progress) {
        
    } SuccBlock:^{
        NSLog(@"success");
    } FailBlock:^(int code, NSString *desc) {
        NSLog(@"Fail");
    }];
}
@end
