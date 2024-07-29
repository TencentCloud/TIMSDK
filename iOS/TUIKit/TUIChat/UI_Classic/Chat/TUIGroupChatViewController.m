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
#import "TUIBaseChatViewController+ProtectedAPI.h"
#import "TUIGroupChatViewController.h"
#import "TUIGroupPendencyController.h"
#import "TUIGroupPendencyDataProvider.h"
#import "TUILinkCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUITextMessageCellData.h"
#import "TUIChatFlexViewController.h"
#import "TUIMessageController.h"
#import "TUIGroupPinCell.h"
#import "TUIGroupPinPageViewController.h"

@interface TUIGroupChatViewController () <V2TIMGroupListener>

//@property (nonatomic, strong) UIButton *atBtn;
@property(nonatomic, strong) UIView *tipsView;
@property(nonatomic, strong) UILabel *pendencyLabel;
@property(nonatomic, strong) UIButton *pendencyBtn;

@property(nonatomic, strong) TUIGroupPendencyDataProvider *pendencyViewModel;
@property(nonatomic, strong) NSMutableArray<TUIUserModel *> *atUserList;
@property(nonatomic, assign) BOOL responseKeyboard;
@property(nonatomic, strong) TUIGroupPinCellView *oneGroupPinView;
@property(nonatomic, strong) NSArray *groupPinList;
@property(nonatomic, strong) TUIGroupPinPageViewController *pinPageVC;
@end

@implementation TUIGroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTipsView];
    [self setupGroupPinTips];
    [[V2TIMManager sharedInstance] addGroupListener:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTipsView)
                                                 name:TUICore_TUIChatExtension_ChatViewTopArea_ChangedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTipsView];
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
          [self refreshTipsView];
      } else {
          self.tipsView.alpha = 0;
      }
    }];

    [self getPendencyList];
}

- (void)refreshTipsView {
    UIView *topView = [TUIGroupChatViewController topAreaBottomView];
    CGRect transRect = [topView convertRect:topView.bounds toView:self.view];
    self.tipsView.frame = CGRectMake(0, transRect.origin.y + transRect.size.height, self.tipsView.frame.size.width, self.tipsView.frame.size.height);
}

- (void)setupGroupPinTips {
    self.oneGroupPinView = [[TUIGroupPinCellView alloc] init];
    CGFloat margin = 0 ;
    self.oneGroupPinView.frame = CGRectMake(0, margin, self.view.frame.size.width, 62);
    UIView *topView = [TUIGroupChatViewController groupPinTopView];
    for (UIView *subview in topView.subviews) {
        [subview removeFromSuperview];
    }
    topView.frame = CGRectMake(0, 0, self.view.mm_w, 0);
    [topView addSubview:self.oneGroupPinView];
    @weakify(self);
    self.oneGroupPinView.isFirstPage = YES;
    self.oneGroupPinView.onClickCellView = ^(V2TIMMessage *originMessage) {
        @strongify(self);
        if (self.groupPinList.count >= 2) {
            [self gotoDetailPopPinPage];
        }
        else {
            [self jump2GroupPinHighlightLine:originMessage];
        }
    };
    self.oneGroupPinView.onClickRemove = ^(V2TIMMessage *originMessage) {
        @strongify(self);
        [self.messageController unPinGroupMessage:originMessage];
    };
    self.messageController.pinGroupMessageChanged = ^(NSArray * _Nonnull groupPinList) {
        @strongify(self);
        if (groupPinList.count > 0 ) {
            if (!self.oneGroupPinView.superview) {
                [topView addSubview:self.oneGroupPinView];
            }
            TUIMessageCellData * cellData = [TUIMessageDataProvider getCellData:[groupPinList lastObject]];
            [self.oneGroupPinView fillWithData:cellData];
            if (groupPinList.count >= 2) {
                [self.oneGroupPinView showMultiAnimation];
                topView.frame = CGRectMake(0, 0, self.view.mm_w, self.oneGroupPinView.frame.size.height +20 + margin);
                self.oneGroupPinView.removeButton.hidden = YES;
            }
            else {
                [self.oneGroupPinView hiddenMultiAnimation];
                topView.frame = CGRectMake(0, 0, self.view.mm_w, self.oneGroupPinView.frame.size.height + margin);
                if ([self.messageController isCurrentUserRoleSuperAdminInGroup]) {
                    self.oneGroupPinView.removeButton.hidden = NO;
                }
                else {
                    self.oneGroupPinView.removeButton.hidden = YES;
                }
            }
        }
        else {
            [self.oneGroupPinView removeFromSuperview];
            topView.frame = CGRectMake(0, 0, self.view.mm_w, 0);
        }
        self.groupPinList = groupPinList;
        [[NSNotificationCenter defaultCenter] postNotificationName:TUICore_TUIChatExtension_ChatViewTopArea_ChangedNotification object:nil];
        if (self.pinPageVC) {
            NSMutableArray *formatGroupPinList = [NSMutableArray arrayWithArray:groupPinList.reverseObjectEnumerator.allObjects];
            self.pinPageVC.groupPinList = formatGroupPinList;
            self.pinPageVC.canRemove = [self.messageController isCurrentUserRoleSuperAdminInGroup];
            if (groupPinList.count > 0) {
                [self reloadPopPinPage];
            }
            else {
                [self.pinPageVC dismissViewControllerAnimated:NO completion:nil];
            }
        }
    };
    
    self.messageController.groupRoleChanged = ^(V2TIMGroupMemberRole role) {
        @strongify(self);
        self.messageController.pinGroupMessageChanged(self.groupPinList);
        if (self.pinPageVC) {
            self.pinPageVC.canRemove = [self.messageController isCurrentUserRoleSuperAdminInGroup];
            [self.pinPageVC.tableview reloadData];
        }
    };
}

- (void)gotoDetailPopPinPage {
    TUIGroupPinPageViewController *vc = [[TUIGroupPinPageViewController alloc] init];
    self.pinPageVC = vc;
    NSMutableArray *formatGroupPinList = [NSMutableArray arrayWithArray:self.groupPinList.reverseObjectEnumerator.allObjects];
    vc.groupPinList = formatGroupPinList;
    vc.canRemove = [self.messageController isCurrentUserRoleSuperAdminInGroup];
    vc.view.frame = self.view.frame;
    CGFloat cellHight = (62);
    CGFloat maxOnePage = 4;
    float height = (self.groupPinList.count) * cellHight;
    height = MIN(cellHight * maxOnePage , height);
    UIView *topView = [TUIGroupChatViewController groupPinTopView];
    CGRect transRect = [topView convertRect:topView.bounds toView:[UIApplication sharedApplication].delegate.window];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    @weakify(self);
    [self presentViewController:vc animated:NO completion:^{
        vc.tableview.frame = CGRectMake(0, CGRectGetMinY(transRect), self.view.frame.size.width, 60);
        vc.customArrowView.frame = CGRectMake(0, CGRectGetMaxY(vc.tableview.frame), vc.tableview.frame.size.width, 0);
        vc.bottomShadow.frame = CGRectMake(0, CGRectGetMaxY(vc.customArrowView.frame), vc.tableview.frame.size.width, 0);
        [UIView animateWithDuration:0.3 animations:^{
            vc.tableview.frame = CGRectMake(0, CGRectGetMinY(transRect), self.view.frame.size.width, height);
            vc.customArrowView.frame = CGRectMake(0, CGRectGetMaxY(vc.tableview.frame), vc.tableview.frame.size.width, 40);
            vc.bottomShadow.frame = CGRectMake(0, CGRectGetMaxY(vc.customArrowView.frame), 
                                               vc.tableview.frame.size.width,
                                               self.view.frame.size.height);
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:vc.customArrowView.bounds 
                                                           byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                                 cornerRadii:CGSizeMake(10.0, 10.0)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = vc.customArrowView.bounds;
            maskLayer.path = maskPath.CGPath;
            vc.customArrowView.layer.mask = maskLayer;
        }];
    }];
    
    vc.onClickRemove = ^(V2TIMMessage *originMessage) {
        @strongify(self);
        [self.messageController unPinGroupMessage:originMessage];
    };
    
    vc.onClickCellView = ^(V2TIMMessage *originMessage) {
        @strongify(self);
        [self jump2GroupPinHighlightLine:originMessage];
    };
    
}

- (void)jump2GroupPinHighlightLine:(V2TIMMessage *)originMessage {
    TUIMessageController *msgVC = (TUIMessageController *)self.messageController;
    NSString * originMsgID = originMessage.msgID;
    [msgVC findMessages:@[originMsgID ?: @""] callback:^(BOOL success, NSString * _Nonnull desc, NSArray<V2TIMMessage *> * _Nonnull messages) {
        if (success) {
            V2TIMMessage *message = messages.firstObject;
            if (message && message.status == V2TIM_MSG_STATUS_SEND_SUCC ) {
                [msgVC locateAssignMessage:originMessage matchKeyWord:@""];
            }
            else {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
            }
        }
    }];
}
- (void)reloadPopPinPage {
    CGFloat cellHight = (62);
    CGFloat maxOnePage = 4;
    float height = (self.groupPinList.count) * cellHight;
    height = MIN(cellHight * maxOnePage , height);
    self.pinPageVC.tableview.frame = CGRectMake(0, self.pinPageVC.tableview.frame.origin.y, self.view.frame.size.width, height);
    self.pinPageVC.customArrowView.frame = CGRectMake(0, CGRectGetMaxY(self.pinPageVC.tableview.frame), self.pinPageVC.tableview.frame.size.width, 40);
    self.pinPageVC.bottomShadow.frame = CGRectMake(0, CGRectGetMaxY(self.pinPageVC.customArrowView.frame),
                                                   self.pinPageVC.tableview.frame.size.width,
                                       self.view.frame.size.height);
    [self.pinPageVC.tableview reloadData];
}

- (void)getPendencyList {
    if (self.conversationData.groupID.length > 0) [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender {
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    @weakify(self);
    vc.cellClickBlock = ^(TUIGroupPendencyCell *_Nonnull cell) {
      if (cell.pendencyData.isRejectd || cell.pendencyData.isAccepted) {
          // After selecting, you will no longer enter the details page.
          return;
      }
      @strongify(self);
      [[V2TIMManager sharedInstance] getUsersInfo:@[ cell.pendencyData.fromUser ]
                                             succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
                                               // Show user profile VC
                                               NSDictionary *param = @{
                                                   TUICore_TUIContactObjectFactory_UserProfileController_UserProfile : profiles.firstObject,
                                                   TUICore_TUIContactObjectFactory_UserProfileController_PendencyData : cell.pendencyData,
                                                   TUICore_TUIContactObjectFactory_UserProfileController_ActionType : @(3)
                                               };
                                               [self.navigationController pushViewController:TUICore_TUIContactObjectFactory_UserProfileController_Classic
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
            return;
        }
    }
}

#pragma mark - TUIInputControllerDelegate
- (void)inputController:(TUIInputController *)inputController didSendMessage:(V2TIMMessage *)msg {
    /**
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
         * After the message is sent, the atUserList need to be reset
         */
        [self.atUserList removeAllObjects];
    }
    [super inputController:inputController didSendMessage:msg];
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController {
    [super inputControllerDidInputAt:inputController];
    /**
     * Input of @ character detected
     */
    if (self.conversationData.groupID.length > 0) {
        if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"TUISelectGroupMemberViewController")]) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID] = self.conversationData.groupID;
        param[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Name] = TIMCommonLocalizableString(TUIKitAtSelectMemberTitle);
        param[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_OptionalStyle] = @(1);
        [self.navigationController
            pushViewController:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic
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
                           [weakSelf.atUserList addObject:model];
                           [atText appendString:[NSString stringWithFormat:@"@%@ ", model.name]];
                       }

                       NSAttributedString *spaceString = [[NSAttributedString alloc]
                           initWithString:atText
                               attributes:@{NSFontAttributeName : kTUIInputNoramlFont, NSForegroundColorAttributeName : kTUIInputNormalTextColor}];
                      [weakSelf.inputController.inputBar addWordsToInputBar:spaceString ];
                     }];
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
        user.name = cell.messageData.senderName;
        [self.atUserList addObject:user];

        NSString *nameString = [NSString stringWithFormat:@"@%@ ", user.name];
        UIFont *textFont = kTUIInputNoramlFont;
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:nameString attributes:@{NSFontAttributeName : textFont}];
       [self.inputController.inputBar addWordsToInputBar:spaceString ];
    }
}

#pragma mark - Override Methods
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    return TIMCommonLocalizableString(TUIKitRelayGroupChatHistory);
}

@end
