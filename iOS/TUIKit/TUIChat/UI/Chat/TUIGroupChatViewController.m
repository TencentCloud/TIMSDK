//
//  TUIGroupChatViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//

#import "ReactiveObjC/ReactiveObjC.h"

#import "TUIBaseChatViewController+ProtectedAPI.h"
#import "TUIGroupChatViewController.h"
#import "TUIGroupPendencyViewDataProvider.h"
#import "TUIGroupPendencyController.h"
#import "TUITextMessageCellData.h"
#import "TUILinkCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUICommonModel.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "NSDictionary+TUISafe.h"

@interface TUIGroupChatViewController () <V2TIMGroupListener, TUINotificationProtocol>

//@property (nonatomic, strong) UIButton *atBtn;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) UILabel *pendencyLabel;
@property (nonatomic, strong) UIButton *pendencyBtn;

@property (nonatomic, strong) TUIGroupPendencyViewDataProvider *pendencyViewModel;
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
    self.tipsView.hidden = YES;


    @weakify(self)
    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
        @strongify(self)
        if ([unReadCnt intValue]) {
            self.pendencyLabel.text = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitChatPendencyRequestToJoinGroupFormat), unReadCnt]; ; // @"%@条入群请求"
            [self.pendencyLabel sizeToFit];
            CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyBtn.mm_w-8)/2;
            self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h/2);
            self.pendencyBtn.mm_hstack(8);

            [UIView animateWithDuration:1.f animations:^{
                self.tipsView.hidden = NO;
                self.tipsView.mm_top(self.navigationController.navigationBar.mm_maxY);
            }];
        } else {
            self.tipsView.hidden = YES;
        }
    }];
    [self getPendencyList];
    
    //监听入群请求通知
    [[V2TIMManager sharedInstance] addGroupListener:self];
    
    //群 @ ,UI 细节比较多，放在二期实现
//    if (self.conversationData.groupID.length > 0 && self.conversationData.atMsgSeqList.count > 0) {
//        self.atBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.mm_w - 100, 100, 100, 40)];
//        [self.atBtn setTitle:@"有人@我" forState:UIControlStateNormal];
//        [self.atBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [self.atBtn setBackgroundColor:[UIColor whiteColor]];
//        [self.atBtn addTarget:self action:@selector(loadMessageToAT) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_atBtn];
//    }
    
    [TUICore registerEvent:TUICore_TUIGroupNotify subKey:TUICore_TUIGroupNotify_SelectGroupMemberSubKey object:self];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

- (void)getPendencyList
{
    if (self.conversationData.groupID.length > 0)
        [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender
{
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    @weakify(self);
    vc.cellClickBlock = ^(TUIGroupPendencyCell * _Nonnull cell) {
        @strongify(self);
        if (self.openUserProfileVCBlock) {
            self.openUserProfileVCBlock(cell);
        }
    };
    vc.viewModel = self.pendencyViewModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setConversationData:(TUIChatConversationModel *)conversationData {
    [super setConversationData:conversationData];
    
    if (self.conversationData.groupID.length > 0) {
        _pendencyViewModel = [TUIGroupPendencyViewDataProvider new];
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
        // @ 转发选择完用户回调
        NSArray<TUIUserModel *> *modelList = [param tui_objectForKey:TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserListKey asClass:NSArray.class];
        NSMutableString *atText = [[NSMutableString alloc] init];
        for (int i = 0; i < modelList.count; i++) {
            TUIUserModel *model = modelList[i];
            if (![model isKindOfClass:TUIUserModel.class]) {
                NSAssert(NO, @"modelList的数据类型错误");
                continue;
            }
            [self.atUserList addObject:model];
            if (i == 0) {
                [atText appendString:[NSString stringWithFormat:@"%@ ",model.name]];
            } else {
                [atText appendString:[NSString stringWithFormat:@"@%@ ",model.name]];
            }
        }
        NSString *inputText = self.inputController.inputBar.inputTextView.text;
        self.inputController.inputBar.inputTextView.text = [NSString stringWithFormat:@"%@%@ ",inputText,atText];
        [self.inputController.inputBar updateTextViewFrame];
        
        [self.atSelectGroupMemberVC.navigationController popViewControllerAnimated:YES];
    }
    else if ([key isEqualToString:TUICore_TUIGroupNotify]
             && [subKey isEqualToString:TUICore_TUIGroupNotify_SelectGroupMemberSubKey]
             && self.callingSelectGroupMemberVC == anObject) {
        // 发起呼叫 选择完毕回调
        
        NSArray<TUIUserModel *> *modelList = [param tui_objectForKey:TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserListKey asClass:NSArray.class];
        NSMutableArray *userIDs = [NSMutableArray arrayWithCapacity:modelList.count];
        for (TUIUserModel *user in modelList) {
            NSParameterAssert(user.userId);
            [userIDs addObject:user.userId];
        }
        [self.callingSelectGroupMemberVC.navigationController popViewControllerAnimated:YES];
        
        
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

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList
{
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


#pragma mark - TInputControllerDelegate
- (void)inputController:(TUIInputController *)inputController didSendMessage:(TUIMessageCellData *)msg
{
    // @
    if ([msg isKindOfClass:[TUITextMessageCellData class]]) {
        NSMutableArray *userIDList = [NSMutableArray array];
        for (TUIUserModel *model in self.atUserList) {
            [userIDList addObject:model.userId];
        }
        if (userIDList.count > 0) {
            [msg setAtUserList:userIDList];
        }
        //消息发送完后 atUserList 要重置
        [self.atUserList removeAllObjects];
    }
    
    
    [super inputController:inputController didSendMessage:msg];
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController
{
    [super inputControllerDidInputAt:inputController];
    
    // 检测到 @ 字符的输入
    if (self.conversationData.groupID.length > 0) {
        if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"TUISelectGroupMemberViewController")]) {
            return;
        }
        NSDictionary *param = @{
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey : self.conversationData.groupID,
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey : TUIKitLocalizableString(TUIKitAtSelectMemberTitle), // @"选择群成员";
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey : @(1),
        };
        UIViewController *vc = [TUICore callService:TUICore_TUIGroupService
                                             method:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
                                              param:param];
        [self.navigationController pushViewController:vc animated:YES];
        self.atSelectGroupMemberVC = vc;
    }
}

- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText
{
    [super inputController:inputController didDeleteAt:atText];
    
    // 删除了 @ 信息，atText 格式为：@xxx空格
    for (TUIUserModel *user in self.atUserList) {
        if ([atText rangeOfString:user.name].location != NSNotFound) {
            [self.atUserList removeObject:user];
            break;
        }
    }
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell
{
    [super inputController:inputController didSelectMoreCell:cell];
    
    NSString *key = cell.data.key;
    if ([key isEqualToString:TUIInputMoreCellKey_VideoCall]   // 视频通话
        || [key isEqualToString:TUIInputMoreCellKey_AudioCall]) {    // 语音通话
        // 群通话先选择需要通话的群成员
        NSDictionary *param = @{
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey : self.conversationData.groupID,
            TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey : TUIKitLocalizableString(Make-a-call),
        };
        UIViewController *vc = [TUICore callService:TUICore_TUIGroupService
                                             method:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
                                              param:param];
        [self.navigationController pushViewController:vc animated:YES];
        
        self.callingSelectGroupMemberVC = vc;
        if ([key isEqualToString:TUIInputMoreCellKey_VideoCall]) {    // 视频通话
            self.callingType = @"1";
        } else if ([key isEqualToString:TUIInputMoreCellKey_AudioCall]) {     // 语音通话
            self.callingType = @"0";
        }
    }
    else if ([key isEqualToString:TUIInputMoreCellKey_GroupLive]) { // 群直播
        NSDictionary *param = @{@"serviceID"   : @"kTUINotifyGroupLiveOnSelectGroupLive",
                                @"groupID"     : self.conversationData.groupID ? : @"",
                                @"userID"      : self.conversationData.userID ? : @"",
                                @"msgSender"   : self};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyMenusServiceAction"
                                                            object:self
                                                            userInfo:param];
    }
    else if ([key isEqualToString:TUIInputMoreCellKey_Link]) {  // 自定义消息
        NSString *text = TUIKitLocalizableString(TUIKitWelcome);;
        NSString *link = @"https://cloud.tencent.com/document/product/269/3794";
        TUILinkCellData *cellData = [[TUILinkCellData alloc] initWithDirection:MsgDirectionOutgoing];
        cellData.text = text;
        cellData.link = link;
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"version": @(TextLink_Version),@"businessID": TextLink,@"text":text,@"link":link} options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
            return;
        }
        cellData.innerMessage = [TUIMessageDataProvider customMessageWithJsonData:data];
        [self sendMessage:cellData];
    }
}

#pragma mark - Override Methods
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    return TUIKitLocalizableString(TUIKitRelayGroupChatHistory);
}

@end
