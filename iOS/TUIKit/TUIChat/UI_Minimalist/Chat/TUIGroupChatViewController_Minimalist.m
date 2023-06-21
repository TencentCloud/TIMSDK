//
//  TUIGroupChatViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "ReactiveObjC/ReactiveObjC.h"

#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUIBaseChatViewController_Minimalist+ProtectedAPI.h"
#import "TUIGroupChatViewController_Minimalist.h"
#import "TUIGroupPendencyController.h"
#import "TUIGroupPendencyDataProvider.h"
#import "TUILinkCellData_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUITextMessageCellData_Minimalist.h"

@interface TUIGroupChatViewController_Minimalist () <V2TIMGroupListener>

//@property (nonatomic, strong) UIButton *atBtn;
@property(nonatomic, strong) UIView *tipsView;
@property(nonatomic, strong) UILabel *pendencyLabel;
@property(nonatomic, strong) UIButton *pendencyBtn;

@property(nonatomic, strong) TUIGroupPendencyDataProvider *pendencyViewModel;
@property(nonatomic, strong) NSMutableArray<TUIUserModel *> *atUserList;
@property(nonatomic, assign) BOOL responseKeyboard;

@end

@implementation TUIGroupChatViewController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTipsView];

    [[V2TIMManager sharedInstance] addGroupListener:self];
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
    [self.pendencyBtn setTitle:TIMCommonLocalizableString(TUIKitChatPendencyTitle) forState:UIControlStateNormal];
    [self.pendencyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pendencyBtn addTarget:self action:@selector(openPendency:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendencyBtn sizeToFit];
    self.tipsView.alpha = 0;

    @weakify(self);
    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
      @strongify(self);
      if ([unReadCnt intValue]) {
          self.pendencyLabel.text = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitChatPendencyRequestToJoinGroupFormat), unReadCnt];
          [self.pendencyLabel sizeToFit];
          CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyBtn.mm_w - 8) / 2;
          self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h / 2);
          self.pendencyBtn.mm_hstack(8);

          self.tipsView.alpha = 1;
          UIView *topView = [TUIGroupChatViewController_Minimalist customTopView];
          self.tipsView.mm_top(topView ? topView.mm_h : 0);
      } else {
          self.tipsView.alpha = 0;
      }
    }];

    [self getPendencyList];
}

- (void)getPendencyList {
    if (self.conversationData.groupID.length > 0) [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender {
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    @weakify(self);
    vc.cellClickBlock = ^(TUIGroupPendencyCell *_Nonnull cell) {
      if (cell.pendencyData.isRejectd || cell.pendencyData.isAccepted) {
          // 选择后不再进详情页了
          return;
      }
      @strongify(self);
      [[V2TIMManager sharedInstance] getUsersInfo:@[ cell.pendencyData.fromUser ]
                                             succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
                                               // 显示用户资料 VC
                                               NSDictionary *param = @{
                                                   TUICore_TUIContactObjectFactory_UserProfileController_UserProfile : profiles.firstObject,
                                                   TUICore_TUIContactObjectFactory_UserProfileController_PendencyData : cell.pendencyData,
                                                   TUICore_TUIContactObjectFactory_UserProfileController_ActionType : @(3)
                                               };
                                               [self.navigationController pushViewController:TUICore_TUIContactObjectFactory_UserProfileController_Minimalist
                                                                                       param:param
                                                                                   forResult:nil];
                                             }
                                             fail:nil];
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

#pragma mark - V2TIMGroupListener
- (void)onReceiveJoinApplication:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member opReason:(NSString *)opReason {
    [self getPendencyList];
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray<V2TIMGroupChangeInfo *> *)changeInfoList {
    if (![groupID isEqualToString:self.conversationData.groupID]) {
        return;
    }
    for (V2TIMGroupChangeInfo *changeInfo in changeInfoList) {
        if (changeInfo.type == V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
            self.conversationData.title = changeInfo.value;
        } else if (changeInfo.type == V2TIM_GROUP_INFO_CHANGE_TYPE_FACE) {
            self.conversationData.faceUrl = changeInfo.value;
        }
    }
}

#pragma mark - TUIInputControllerDelegate
- (void)inputController:(TUIInputController_Minimalist *)inputController didSendMessage:(V2TIMMessage *)msg {
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

- (void)inputControllerDidInputAt:(TUIInputController_Minimalist *)inputController {
    [super inputControllerDidInputAt:inputController];
    /**
     * 检测到 @ 字符的输入
     * Input of @ character detected
     */
    if (self.conversationData.groupID.length > 0) {
        if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"TUISelectGroupMemberViewController_Minimalist")]) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID] = self.conversationData.groupID;
        param[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Name] = TIMCommonLocalizableString(TUIKitAtSelectMemberTitle);
        param[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_OptionalStyle] = @(1);
        [self.navigationController
            pushViewController:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Minimalist
                         param:param
                     forResult:^(NSDictionary *_Nonnull param) {
                       NSArray<TUIUserModel *> *modelList = [param tui_objectForKey:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList
                                                                            asClass:NSArray.class];
                       NSMutableString *atText = [[NSMutableString alloc] init];
                       for (int i = 0; i < modelList.count; i++) {
                           TUIUserModel *model = modelList[i];
                           if (![model isKindOfClass:TUIUserModel.class]) {
                               NSAssert(NO, @"Error data-type in modelList");
                               continue;
                           }
                           [self.atUserList addObject:model];
                           if (i == 0) {
                               [atText appendString:[NSString stringWithFormat:@"%@ ", model.name]];
                           } else {
                               [atText appendString:[NSString stringWithFormat:@"@%@ ", model.name]];
                           }
                       }

                       UIFont *textFont = kTUIInputNoramlFont;
                       NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:atText attributes:@{NSFontAttributeName : textFont}];
                       [weakSelf.inputController.inputBar.inputTextView.textStorage
                           insertAttributedString:spaceString
                                          atIndex:weakSelf.inputController.inputBar.inputTextView.textStorage.length];
                       [weakSelf.inputController.inputBar updateTextViewFrame];
                     }];
    }
}

- (void)inputController:(TUIInputController_Minimalist *)inputController didDeleteAt:(NSString *)atText {
    [super inputController:inputController didDeleteAt:atText];

    for (TUIUserModel *user in self.atUserList) {
        if ([atText rangeOfString:user.name].location != NSNotFound) {
            [self.atUserList removeObject:user];
            break;
        }
    }
}

#pragma mark - TUIBaseMessageControllerDelegate
- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onLongSelectMessageAvatar:(TUIMessageCell *)cell {
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

        NSString *nameString = [NSString stringWithFormat:@"@%@ ", user.name];
        UIFont *textFont = kTUIInputNoramlFont;
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:nameString attributes:@{NSFontAttributeName : textFont}];
        [self.inputController.inputBar.inputTextView.textStorage insertAttributedString:spaceString
                                                                                atIndex:self.inputController.inputBar.inputTextView.textStorage.length];
        [self.inputController.inputBar.inputTextView becomeFirstResponder];
        self.inputController.inputBar.inputTextView.selectedRange =
            NSMakeRange(spaceString.length + self.inputController.inputBar.inputTextView.textStorage.length, 0);
    }
}

#pragma mark - Override Methods
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    return TIMCommonLocalizableString(TUIKitRelayGroupChatHistory);
}

@end
