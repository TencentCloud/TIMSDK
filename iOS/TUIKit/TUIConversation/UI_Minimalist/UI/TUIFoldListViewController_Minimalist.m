//
//  TUIFoldListViewController_Minimalist.m
//  TUIKitDemo
//
//  Created by wyl on 2022/11/4.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIFoldListViewController_Minimalist.h"
#import <TUICore/TUICore.h>
#import "TUIConversationListController_Minimalist.h"
#import "TUIFoldConversationListDataProvider_Minimalist.h"

@interface TUIFoldListViewController_Minimalist () <TUINavigationControllerDelegate, TUIConversationListControllerListener>

@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, copy) NSString *mainTitle;
@property(nonatomic, strong) TUIConversationListController_Minimalist *conv;
@property(nonatomic, strong) UILabel *noDataTipsLabel;

@end

@implementation TUIFoldListViewController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conv = [[TUIConversationListController_Minimalist alloc] init];

    self.conv.dataProvider = [[TUIFoldConversationListDataProvider_Minimalist alloc] init];
    self.conv.dataProvider.delegate = (id)self.conv;
    self.conv.isShowBanner = NO;
    self.conv.delegate = self;

    @weakify(self);
    self.conv.dataSourceChanged = ^(NSInteger count) {
      @strongify(self);
      self.noDataTipsLabel.hidden = count > 0;
    };
    [self addChildViewController:self.conv];
    [self.view addSubview:self.conv.view];

    [self setupNavigator];
    [self.view addSubview:self.noDataTipsLabel];
}

- (void)setTitle:(NSString *)title {
    self.mainTitle = title;
}

- (void)setupNavigator {
    TUINavigationController *naviController = (TUINavigationController *)self.navigationController;
    naviController.uiNaviDelegate = self;
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    [self.titleView setTitle:TIMCommonLocalizableString(TUIKitConversationMarkFoldGroups)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.noDataTipsLabel.frame = CGRectMake(10, 120, self.view.bounds.size.width - 20, 40);
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    TUINavigationController *naviController = (TUINavigationController *)self.navigationController;
    naviController.uiNaviDelegate = self;
}

#pragma mark - TUINavigationControllerDelegate
- (void)navigationControllerDidClickLeftButton:(TUINavigationController *)controller {
    [self excuteDismissCallback];
}

- (void)navigationControllerDidSideSlideReturn:(TUINavigationController *)controller fromViewController:(UIViewController *)fromViewController {
    [self excuteDismissCallback];
}

- (void)excuteDismissCallback {
    if (self.dismissCallback) {
        NSMutableAttributedString *foldSubTitle = [[NSMutableAttributedString alloc] initWithString:@""];
        TUIFoldConversationListDataProvider_Minimalist *foldProvider = (TUIFoldConversationListDataProvider_Minimalist *)self.conv.dataProvider;
        NSArray *needRemoveFromCacheMapArray = foldProvider.needRemoveConversationList;
        if (self.conv.dataProvider.conversationList.count > 0) {
            NSMutableArray *sortArray = [NSMutableArray arrayWithArray:self.conv.dataProvider.conversationList];
            [self sortDataList:sortArray];
            TUIConversationCellData *lastItem = sortArray[0];
            if (lastItem && [lastItem isKindOfClass:TUIConversationCellData.class]) {
                foldSubTitle = lastItem.foldSubTitle;
            }
            self.dismissCallback(foldSubTitle, sortArray, needRemoveFromCacheMapArray);
        } else {
            self.dismissCallback(foldSubTitle, @[], needRemoveFromCacheMapArray);
        }
    }
}

- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList {
    [dataList sortUsingComparator:^NSComparisonResult(TUIConversationCellData *obj1, TUIConversationCellData *obj2) {
      return obj1.orderKey < obj2.orderKey;
    }];
}
#pragma mark TUIConversationListControllerListener

- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    V2TIMMessage *msg = conversation.lastMessage;
    if (msg.customElem == nil || msg.customElem.data == nil) {
        return nil;
    }
    NSDictionary *param = [TUITool jsonData2Dictionary:msg.customElem.data];
    if (param != nil && [param isKindOfClass:[NSDictionary class]]) {
        NSString *businessID = param[@"businessID"];
        if (![businessID isKindOfClass:[NSString class]]) {
            return nil;
        }
        if ([businessID isEqualToString:BussinessID_TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
            NSString *desc = param[@"text"];
            if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
                
                V2TIMUserFullInfo *info = msg.revokerInfo;
                NSString *  revokeReason = msg.revokeReason;
                BOOL hasRiskContent = msg.hasRiskContent;
                if (hasRiskContent) {
                    desc =  TIMCommonLocalizableString(TUIKitMessageTipsRecallRiskContent);
                }
                else if (info) {
                    NSString *userName = info.nickName;
                    desc  = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
                else if (msg.isSelf) {
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
                } else if (msg.userID.length > 0) {
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsOthersRecallMessage);
                } else if (msg.groupID.length > 0) {
                    NSString *userName = msg.nameCard;
                    if (userName.length == 0) {
                        userName = msg.nickName ?: msg.sender;
                    }
                    desc = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
            }
            return desc;
        }
    }
    return nil;
}

- (void)conversationListController:(TUIConversationListController_Minimalist *)conversationController
             didSelectConversation:(TUIConversationCellData *)conversation {
    NSDictionary *param = @{
        TUICore_TUIChatObjectFactory_ChatViewController_ConversationID : conversation.conversationID ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_UserID : conversation.userID ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_GroupID : conversation.groupID ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_Title : conversation.title ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : conversation.faceUrl ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : conversation.avatarImage ?: [UIImage new],
        TUICore_TUIChatObjectFactory_ChatViewController_Draft : conversation.draftText ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs : conversation.atMsgSeqs ?: @[]
    };
    [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
}

- (UILabel *)noDataTipsLabel {
    if (_noDataTipsLabel == nil) {
        _noDataTipsLabel = [[UILabel alloc] init];
        _noDataTipsLabel.textColor = [UIColor tui_colorWithHex:@"#999999"];
        _noDataTipsLabel.font = [UIFont systemFontOfSize:14.0];
        _noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noDataTipsLabel.text = TIMCommonLocalizableString(TUIKitContactNoGroupChats);
        _noDataTipsLabel.hidden = YES;
    }
    return _noDataTipsLabel;
}
@end
