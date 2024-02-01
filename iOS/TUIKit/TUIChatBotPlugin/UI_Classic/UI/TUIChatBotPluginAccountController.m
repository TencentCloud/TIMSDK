//
//  TUIChatBotPluginAccountController.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginAccountController.h"

#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "ReactiveObjC.h"
#import <TUIContact/TUICommonContactCell.h>
#import "TUIChatBotPluginPrivateConfig.h"
#import <TUIChat/TUIChatConversationModel.h>
#import <TUIChat/TUIC2CChatViewController.h>

@interface TUIChatBotPluginAccountController()

@property (nonatomic, strong) NSMutableArray *cellDatas;

@end

@implementation TUIChatBotPluginAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(TUIChatBotAccounts);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    [self.tableView registerClass:[TUICommonContactCell class] forCellReuseIdentifier:@"CustomerServiceCell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.rowHeight = 56;
    
    [self getUserInfo];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerServiceCell"
                                                                 forIndexPath:indexPath];
    if (self.cellDatas.count == 0) {
        return nil;
    }
    TUICommonContactCellData *data = self.cellDatas[indexPath.row];
    data.cselector = @selector(didSelectCustomerServiceAccount:);
    [cell fillWithData:data];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

#pragma mark - Event response
- (void)didSelectCustomerServiceAccount:(TUICommonContactCell *)cell {
    NSString *userID = cell.contactData.identifier;
    if (userID.length == 0) {
        return;
    }
    TUIChatConversationModel *conversationModel = [[TUIChatConversationModel alloc] init];
    conversationModel.userID = userID;
    conversationModel.conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
    TUIC2CChatViewController *chatVC = [[TUIC2CChatViewController alloc] init];
    chatVC.conversationData = conversationModel;
    chatVC.title = conversationModel.title;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)getUserInfo {
    NSArray *accounts = TUIChatBotPluginPrivateConfig.sharedInstance.chatBotAccounts;
    [[V2TIMManager sharedInstance] getUsersInfo:accounts
                                           succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        for (NSString *account in accounts) {
            for (V2TIMUserFullInfo *info in infoList) {
                if ([account isEqualToString:info.userID]) {
                    TUICommonContactCellData *data = [TUICommonContactCellData new];
                    data.identifier = info.userID;
                    data.avatarUrl = [NSURL URLWithString:info.faceURL];
                    data.title = info.nickName;
                    [self.cellDatas addObject:data];
                    break;
                }
            }
        }
        [self.tableView reloadData];
    } fail:^(int code, NSString *desc) {
        
    }];
}

#pragma mark - Getter
- (NSMutableArray *)cellDatas {
    if (!_cellDatas) {
        _cellDatas = [[NSMutableArray alloc] init];
    }
    return _cellDatas;
}

@end
