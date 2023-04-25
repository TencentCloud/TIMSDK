//
//  TUIFoldListViewController.m
//  TUIChat
//
//  Created by wyl on 2022/7/21.
//

#import "TUIFoldListViewController.h"
#import "TUIConversationListController.h"
#import "TUIFoldConversationListDataProvider.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUITool.h>
#import <TUICore/TUICore.h>

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TUIFoldListViewController ()<TUINavigationControllerDelegate,TUIConversationListControllerListener>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, copy) NSString *mainTitle;
@property (nonatomic, strong) TUIConversationListController *conv;
@property (nonatomic, strong) UILabel *noDataTipsLabel;


@end

@implementation TUIFoldListViewController

- (void)dealloc {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.conv = [[TUIConversationListController alloc] init];
    self.conv.dataProvider = [[TUIFoldConversationListDataProvider alloc] init];
    self.conv.dataProvider.delegate = (id)self.conv;
    self.conv.isShowBanner = NO;
    self.conv.delegate = self;
    
    @weakify(self)
    self.conv.dataSourceChanged = ^(NSInteger count) {
        @strongify(self)
        self.noDataTipsLabel.hidden = count > 0 ;
    };
    [self addChildViewController:self.conv];
    [self.view addSubview:self.conv.view];

    
    [self setupNavigator];
    [self.view addSubview:self.noDataTipsLabel];

}

- (void)setTitle:(NSString *)title
{
    self.mainTitle = title;
}


- (void)setupNavigator
{
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

- (void)navigationControllerDidSideSlideReturn:(TUINavigationController *)controller
                            fromViewController:(UIViewController *)fromViewController {
    [self excuteDismissCallback];
}

- (void)excuteDismissCallback {
    if (self.dismissCallback) {
        NSMutableAttributedString *foldSubTitle =  [[NSMutableAttributedString alloc] initWithString:@""];
        TUIFoldConversationListDataProvider * foldProvider = (TUIFoldConversationListDataProvider *)self.conv.dataProvider;
        NSArray * needRemoveFromCacheMapArray = foldProvider.needRemoveConversationList;
        if (self.conv.dataProvider.conversationList.count > 0) {
            NSMutableArray * sortArray = [NSMutableArray arrayWithArray:self.conv.dataProvider.conversationList];
            [self sortDataList:sortArray];
            TUIConversationCellData *lastItem = sortArray[0];
            if (lastItem && [lastItem isKindOfClass:TUIConversationCellData.class]) {
                foldSubTitle =  lastItem.foldSubTitle;
            }
            self.dismissCallback(foldSubTitle,sortArray,needRemoveFromCacheMapArray);
        }
        else {
            self.dismissCallback(foldSubTitle,@[],needRemoveFromCacheMapArray);
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
        // 判断是不是自定义跳转消息
        if ([businessID isEqualToString:BussinessID_TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
            NSString *desc = param[@"text"];
            if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
                if(msg.isSelf){
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
                } else if (msg.userID.length > 0){
                    desc = TIMCommonLocalizableString(TUIkitMessageTipsOthersRecallMessage);
                } else if (msg.groupID.length > 0) {
                    //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
                    NSString *userName = msg.nameCard;
                    if (userName.length == 0) {
                        userName = msg.nickName?:msg.sender;
                    }
                    desc = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
            }
            return desc;
        }
        else if ([businessID isEqualToString:BussinessID_GroupCreate] || [param.allKeys containsObject:BussinessID_GroupCreate]) {
            return [NSString stringWithFormat:@"\"%@\"%@",param[@"opUser"],param[@"content"]];
        }
    }
    return nil;
}

- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCellData *)conversation
{
    NSDictionary *param = @{
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_ConversationIDKey : conversation.conversationID ?: @"",
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey : conversation.userID ?: @"",
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_GroupIDKey : conversation.groupID ?: @"",
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey : conversation.title ?: @"",
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarUrlKey : conversation.faceUrl ?: @"",
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarImageKey : conversation.avatarImage ? : [UIImage new],
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_DraftKey : conversation.draftText ?: @"",
        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AtMsgSeqsKey : conversation.atMsgSeqs ?: @[]
    };
    
    UIViewController *chatVC = (UIViewController *)[TUICore createObject:TUICore_TUIChatObjectFactory key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
    [self.navigationController pushViewController:(UIViewController *)chatVC animated:YES];
}

- (UILabel *)noDataTipsLabel
{
    if (_noDataTipsLabel == nil) {
        _noDataTipsLabel = [[UILabel alloc] init];
        _noDataTipsLabel.textColor = TUIContactDynamicColor(@"contact_add_contact_nodata_tips_text_color", @"#999999");
        _noDataTipsLabel.font = [UIFont systemFontOfSize:14.0];
        _noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noDataTipsLabel.text = TIMCommonLocalizableString(TUIKitContactNoGroupChats);
        _noDataTipsLabel.hidden = YES;

    }
    return _noDataTipsLabel;
}
@end
