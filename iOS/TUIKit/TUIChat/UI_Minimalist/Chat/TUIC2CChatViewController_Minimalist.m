//
//  TUIC2CChatViewController_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIBaseChatViewController_Minimalist+ProtectedAPI.h"
#import "TUIChatConfig.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUILinkCellData.h"
#import "TUIMessageController_Minimalist.h"
#import "TUIMessageDataProvider.h"

#define kC2CTypingTime 30.0

@interface TUIC2CChatViewController_Minimalist ()

// If one sendTypingBaseCondation is satisfied, sendTypingBaseCondationInVC is used until the current session exits

@property(nonatomic, assign) BOOL sendTypingBaseCondationInVC;

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

#pragma mark - Override Methods
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    NSString *title = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitRelayChatHistoryForSomebodyFormat), self.conversationData.title, nameStr];
    return rtlString(title);
}

- (void)inputControllerDidInputAt:(TUIInputController_Minimalist *)inputController {
    [super inputControllerDidInputAt:inputController];
    NSAttributedString *spaceString = [[NSAttributedString alloc]
        initWithString:@"@"
            attributes:@{NSFontAttributeName : kTUIInputNoramlFont, NSForegroundColorAttributeName : kTUIInputNormalTextColor}];
    [self.inputController.inputBar addWordsToInputBar:spaceString];
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
        NSDictionary *messageFeatureDic = (id)[vc.C2CIncomingLastMsg parseCloudCustomData:messageFeature];

        if (messageFeatureDic && [messageFeatureDic isKindOfClass:[NSDictionary class]] && [messageFeatureDic.allKeys containsObject:@"needTyping"] &&
            [messageFeatureDic.allKeys containsObject:@"version"]) {
            BOOL needTyping = NO;

            BOOL versionControl = NO;

            BOOL timeControl = NO;

            if ([messageFeatureDic[@"needTyping"] intValue] == 1) {
                needTyping = YES;
            }

            if ([messageFeatureDic[@"version"] intValue] == 1) {
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
    // switch control
    if (![TUIChatConfig defaultConfig].enableTypingStatus) {
        return;
    }

    if (![self sendTypingBaseCondation]) {
        return;
    }

    NSError *error = nil;
    NSDictionary *param = @{
        BussinessID : BussinessID_Typing,
        @"typingStatus" : editing ? @1 : @0,
        @"version" : @1,
        @"userAction" : @14,
        @"actionParam" : editing ? @"EIMAMSG_InputStatus_Ing" : @"EIMAMSG_InputStatus_End",
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];

    V2TIMMessage *msg = [TUIMessageDataProvider getCustomMessageWithJsonData:data];
    [msg setIsExcludedFromContentModeration:YES];
    TUISendMessageAppendParams *appendParams = [[TUISendMessageAppendParams alloc] init];
    appendParams.isSendPushInfo = NO;
    appendParams.isOnlineUserOnly = YES;
    appendParams.priority = V2TIM_PRIORITY_DEFAULT;
    [TUIMessageDataProvider sendMessage:msg
        toConversation:self.conversationData
        appendParams:appendParams
        Progress:^(uint32_t progress) {

        }
        SuccBlock:^{
          NSLog(@"success");
        }
        FailBlock:^(int code, NSString *desc) {
          NSLog(@"Fail");
        }];
}
@end
