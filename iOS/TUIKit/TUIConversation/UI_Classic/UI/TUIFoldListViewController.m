//
//  TUIFoldListViewController.m
//  TUIChat
//
//  Created by wyl on 2022/7/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFoldListViewController.h"
#import <TUICore/TUICore.h>
#import "TUIConversationCellData.h"
#import "TUIConversationListController.h"
#import "TUIFoldConversationListDataProvider.h"

@interface TUIFoldListViewController () <TUINavigationControllerDelegate, TUIConversationListControllerListener>
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, copy) NSString *mainTitle;
@property(nonatomic, strong) TUIConversationListController *conv;
@end

@implementation TUIFoldListViewController

- (void)dealloc {
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.conv = [[TUIConversationListController alloc] init];
    self.conv.dataProvider = [[TUIFoldConversationListDataProvider alloc] init];
    self.conv.dataProvider.delegate = (id)self.conv;
    self.conv.tableViewForAll.tipsMsgWhenNoConversation = TIMCommonLocalizableString(TUIKitContactNoGroupChats);
    self.conv.tableViewForAll.disableMoreActionExtension = YES;
    self.conv.isShowConversationGroup = NO;
    self.conv.isShowBanner = NO;
    self.conv.delegate = self;
    [self addChildViewController:self.conv];
    [self.view addSubview:self.conv.view];

    [self setupNavigator];
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
        TUIFoldConversationListDataProvider *foldProvider = (TUIFoldConversationListDataProvider *)self.conv.dataProvider;
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
        // Determine whether it is a custom jump message
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
                    // For the name display of group messages, the group business card is displayed first, the nickname is the second priority, and the user ID is the lowest priority.
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

- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCellData *)conversation {
    NSDictionary *param = @{
        TUICore_TUIChatObjectFactory_ChatViewController_ConversationID : conversation.conversationID ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_UserID : conversation.userID ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_GroupID : conversation.groupID ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_Title : conversation.title ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : conversation.faceUrl ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : conversation.avatarImage ?: [UIImage new],
        TUICore_TUIChatObjectFactory_ChatViewController_Draft : conversation.draftText ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AtTipsStr : conversation.atTipsStr ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs : conversation.atMsgSeqs ?: @[]
    };
    [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Classic param:param forResult:nil];
}

@end
