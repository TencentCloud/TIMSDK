//
//  TUIGroupChatViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//

#import "ReactiveObjC/ReactiveObjC.h"

#import "TUIBaseChatViewController+ProtectedAPI.h"
#import "TUIGroupChatViewController.h"
#import "TUIGroupPendencyDataProvider.h"
#import "TUIGroupPendencyController.h"
#import "TUITextMessageCellData.h"
#import "TUILinkCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUICommonModel.h"
#import "TUILogin.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "NSDictionary+TUISafe.h"
#import "NSString+TUIEmoji.h"

@interface TUIGroupChatViewController () <V2TIMGroupListener, TUINotificationProtocol>

//@property (nonatomic, strong) UIButton *atBtn;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) UILabel *pendencyLabel;
@property (nonatomic, strong) UIButton *pendencyBtn;

@property (nonatomic, strong) TUIGroupPendencyDataProvider *pendencyViewModel;
@property (nonatomic, strong) NSMutableArray<TUIUserModel *> *atUserList;
@property (nonatomic, assign) BOOL responseKeyboard;

@property (nonatomic, weak) UIViewController *atSelectGroupMemberVC;

@property (nonatomic, weak) UIViewController *callingSelectGroupMemberVC;
@property (nonatomic, copy) NSString *callingType;

@end

@implementation TUIGroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTipsView];

    [[V2TIMManager sharedInstance] addGroupListener:self];
    
    [TUICore registerEvent:TUICore_TUIGroupNotify subKey:TUICore_TUIGroupNotify_SelectGroupMemberSubKey object:self];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

- (void)setupTipsView {
    self.tipsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tipsView.backgroundColor = RGB(246, 234, 190);
    [self.view addSubview:self.tipsView];
    self.tipsView.mm_height(24).mm_width(self.view.mm_w);

    self.pendencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tipsView addSubview:self.pendencyLabel];
    self.pendencyLabel.font = [UIFont systemFontOfSize:12];

    self.pendencyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tipsView addSubview:self.pendencyBtn];
    [self.pendencyBtn setTitle:TUIKitLocalizableString(TUIKitChatPendencyTitle) forState:UIControlStateNormal];
    [self.pendencyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pendencyBtn addTarget:self action:@selector(openPendency:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendencyBtn sizeToFit];
    self.tipsView.alpha = 0;

    @weakify(self)
    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
        @strongify(self)
        if ([unReadCnt intValue]) {
            self.pendencyLabel.text = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitChatPendencyRequestToJoinGroupFormat), unReadCnt];
            [self.pendencyLabel sizeToFit];
            CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyBtn.mm_w-8)/2;
            self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h/2);
            self.pendencyBtn.mm_hstack(8);

            self.tipsView.alpha = 1;
            UIView *topView = [TUIGroupChatViewController customTopView];
            self.tipsView.mm_top(topView ? topView.mm_h : 0);
        } else {
            self.tipsView.alpha = 0;
        }
    }];
    
    [self getPendencyList];
}

- (void)getPendencyList {
    if (self.conversationData.groupID.length > 0)
        [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender {
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    @weakify(self);
    vc.cellClickBlock = ^(TUIGroupPendencyCell * _Nonnull cell) {
        if (cell.pendencyData.isRejectd || cell.pendencyData.isAccepted) {
            //选择后不再进详情页了
            return;
        }
        @strongify(self);
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.fromUser] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            // 显示用户资料 VC
            NSDictionary *param = @{
                TUICore_TUIContactService_GetUserProfileControllerMethod_UserProfileKey : profiles.firstObject,
                TUICore_TUIContactService_GetUserProfileControllerMethod_PendencyDataKey : cell.pendencyData,
                TUICore_TUIContactService_GetUserProfileControllerMethod_ActionTypeKey : @(3)
            };
            UIViewController *vc = [TUICore callService:TUICore_TUIContactService
                                                 method:TUICore_TUIContactService_GetUserProfileControllerMethod
                                                  param:param];
            [self.navigationController pushViewController:vc animated:YES];
        } fail:nil];
    };
    vc.viewModel = self.pendencyViewModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setConversationData:(TUIChatConversationModel *)conversationData {
    [super setConversationData:conversationData];
    
    if (self.conversationData.groupID.length > 0) {
        _pendencyViewModel = [TUIGroupPendencyDataProvider new];
        _pendencyViewModel.groupId = conversationData.groupID;
    }
    
    self.atUserList = [NSMutableArray array];
}

#pragma mark - TUICore
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    [super onNotifyEvent:key subKey:subKey object:anObject param:param];
    
    if ([key isEqualToString:TUICore_TUIGroupNotify]
        && [subKey isEqualToString:TUICore_TUIGroupNotify_SelectGroupMemberSubKey]
        && self.atSelectGroupMemberVC == anObject) {
        NSArray<TUIUserModel *> *modelList = [param tui_objectForKey:TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserListKey asClass:NSArray.class];
        NSMutableString *atText = [[NSMutableString alloc] init];
        for (int i = 0; i < modelList.count; i++) {
            TUIUserModel *model = modelList[i];
            if (![model isKindOfClass:TUIUserModel.class]) {
                NSAssert(NO, @"Error data-type in modelList");
                continue;
            }
            [self.atUserList addObject:model];
            if (i == 0) {
                [atText appendString:[NSString stringWithFormat:@"%@ ",model.name]];
            } else {
                [atText appendString:[NSString stringWithFormat:@"@%@ ",model.name]];
            }
        }
        

        UIFont *textFont = kTUIInputNoramlFont;
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:atText attributes:@{NSFontAttributeName: textFont}];
        [self.inputController.inputBar.inputTextView.textStorage insertAttributedString:spaceString atIndex:self.inputController.inputBar.inputTextView.textStorage.length];
        [self.inputController.inputBar updateTextViewFrame];
    }
    else if ([key isEqualToString:TUICore_TUIGroupNotify]
             && [subKey isEqualToString:TUICore_TUIGroupNotify_SelectGroupMemberSubKey]
             && self.callingSelectGroupMemberVC == anObject) {
        
        NSArray<TUIUserModel *> *modelList = [param tui_objectForKey:TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserListKey asClass:NSArray.class];
        NSMutableArray *userIDs = [NSMutableArray arrayWithCapacity:modelList.count];
        for (TUIUserModel *user in modelList) {
            NSParameterAssert(user.userId);
            [userIDs addObject:user.userId];
        }
        
        // 显示通话VC
        NSDictionary *param = @{
            TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey : self.conversationData.groupID,
            TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : userIDs,
            TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : self.callingType
        };
        [TUICore callService:TUICore_TUICallingService
                      method:TUICore_TUICallingService_ShowCallingViewMethod
                       param:param];
    }
}

#pragma mark - V2TIMGroupListener
- (void)onReceiveJoinApplication:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member opReason:(NSString *)opReason {
    [self getPendencyList];
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList {
    if (![groupID isEqualToString:self.conversationData.groupID]) {
        return;
    }
    for (V2TIMGroupChangeInfo *changeInfo in changeInfoList) {
        if (changeInfo.type == V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
            self.conversationData.title = changeInfo.value;
            return;
        }
    }
}


#pragma mark - TUIInputControllerDelegate
- (void)inputController:(TUIInputController *)inputController didSendMessage:(V2TIMMessage *)msg {
    /**
     * 文本消息如果有 @ 用户，需要 createTextAtMessage
     * If the text message has @ user, createTextAtMessage is required
     */
    if (msg.elemType == V2TIM_ELEM_TYPE_TEXT) {
        NSMutableArray *atUserList = [NSMutableArray array];
        for (TUIUserModel *model in self.atUserList) {
            if (model.userId) {
                [atUserList addObject:model.userId];
            }
        }
        if (atUserList.count > 0) {
            NSData *cloudCustomData = msg.cloudCustomData;
            msg = [[V2TIMManager sharedInstance] createTextAtMessage:msg.textElem.text atUserList:atUserList];
            msg.cloudCustomData = cloudCustomData;
        }
        /**
         * 消息发送完后 atUserList 要重置
         * After the message is sent, the atUserList need to be reset
         */
        [self.atUserList removeAllObjects];
    }
    [super inputController:inputController didSendMessage:msg];
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController {
    [super inputControllerDidInputAt:inputController];
    /**
     * 检测到 @ 字符的输入
     * Input of @ character detected
     */
    if (self.conversationData.groupID.length > 0) {
        if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"TUISelectGroupMemberViewController")]) {
            return;
        }
        NSDictionary *param = @{
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey : self.conversationData.groupID,
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey : TUIKitLocalizableString(TUIKitAtSelectMemberTitle),
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey : @(1),
        };
        UIViewController *vc = [TUICore callService:TUICore_TUIGroupService
                                             method:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
                                              param:param];
        [self.navigationController pushViewController:vc animated:YES];
        self.atSelectGroupMemberVC = vc;
    }
}

- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText {
    [super inputController:inputController didDeleteAt:atText];
    
    for (TUIUserModel *user in self.atUserList) {
        if ([atText rangeOfString:user.name].location != NSNotFound) {
            [self.atUserList removeObject:user];
            break;
        }
    }
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell {
    [super inputController:inputController didSelectMoreCell:cell];
    
    NSString *key = cell.data.key;
    if ([key isEqualToString:TUIInputMoreCellKey_VideoCall]
        || [key isEqualToString:TUIInputMoreCellKey_AudioCall]) {
        NSDictionary *param = @{
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey : self.conversationData.groupID?:@"",
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey : TUIKitLocalizableString(Make-a-call),
        };
        UIViewController *vc = [TUICore callService:TUICore_TUIGroupService
                                             method:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
                                              param:param];
        [self.navigationController pushViewController:vc animated:YES];
        
        self.callingSelectGroupMemberVC = vc;
        if ([key isEqualToString:TUIInputMoreCellKey_VideoCall]) {
            self.callingType = @"1";
        } else if ([key isEqualToString:TUIInputMoreCellKey_AudioCall]) {
            self.callingType = @"0";
        }
    }
    else if ([key isEqualToString:TUIInputMoreCellKey_Link]) {
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
        V2TIMMessage *message = [TUIMessageDataProvider getCustomMessageWithJsonData:data];
        [self sendMessage:message];
    }
}

#pragma mark - TUIBaseMessageControllerDelegate
- (void)messageController:(TUIBaseMessageController *)controller onLongSelectMessageAvatar:(TUIMessageCell *)cell {
    if (!cell || !cell.messageData || !cell.messageData.identifier) {
        return;
    }
    if ([cell.messageData.identifier isEqualToString:[TUILogin getUserID]]) {
        return;
    }
    BOOL atUserExist = NO;
    for (TUIUserModel *model in self.atUserList) {
        if ([model.userId isEqualToString:cell.messageData.identifier]) {
            atUserExist = YES;
            break;
        }
    }
    if (!atUserExist) {
        TUIUserModel *user = [[TUIUserModel alloc] init];
        user.userId = cell.messageData.identifier;
        user.name = cell.messageData.name;
        [self.atUserList addObject:user];
        
        UIFont *textFont = kTUIInputNoramlFont;
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:user.name attributes:@{NSFontAttributeName: textFont}];
        [self.inputController.inputBar.inputTextView.textStorage insertAttributedString:spaceString atIndex:self.inputController.inputBar.inputTextView.textStorage.length];        
        [self.inputController.inputBar.inputTextView becomeFirstResponder];
    }
}

#pragma mark - Override Methods
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    return TUIKitLocalizableString(TUIKitRelayGroupChatHistory);
}

@end
