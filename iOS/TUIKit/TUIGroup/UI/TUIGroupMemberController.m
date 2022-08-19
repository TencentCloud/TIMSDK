//
//  GroupMemberController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "TUIDefine.h"
#import "TUICore.h"
#import "TUIAddCell.h"
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGroupMemberDataProvider.h"

#import "TUIMemberInfoCell.h"
#import "TUIMemberInfoCellData.h"
#import "TUIThemeManager.h"

@interface TUIGroupMemberController () </*TUIGroupMembersViewDelegate*/UITableViewDelegate, UITableViewDataSource, TUINotificationProtocol>
@property(nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UIViewController *showContactSelectVC;
@property(nonatomic, strong) TUIGroupMemberDataProvider *dataProvider;
@property (nonatomic, strong) NSMutableArray<TUIMemberInfoCellData *> *members;
@property NSInteger tag;
@end

@implementation TUIGroupMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
    self.dataProvider = [[TUIGroupMemberDataProvider alloc] initWithGroupID:self.groupId];
    self.dataProvider.groupInfo = self.groupInfo;
    [self refreshData];
    
    [TUICore registerEvent:TUICore_TUIContactNotify subKey:TUICore_TUIContactNotify_SelectedContactsSubKey object:self];
}

- (void)refreshData
{
    @weakify(self)
    [self.dataProvider loadDatas:^(BOOL success, NSString * _Nonnull err, NSArray * _Nonnull datas) {
        @strongify(self)
        NSString *title = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupProfileGroupCountFormat), (long)datas.count];
        self.title = title;
        self.members = [NSMutableArray arrayWithArray:datas];
        [self.tableView reloadData];
    }];
}

- (void)setupViews
{
    self.view.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");

    //left
    UIImage *image = TUIGroupDynamicImage(@"group_nav_back_img", [UIImage imageNamed:TUIGroupImagePath(@"back")]);
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10.0f;
    if (([[TUITool deviceVersion] floatValue] >= 11.0)) {
        leftButton.contentEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
        leftButton.imageEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
    }
    self.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
    self.parentViewController.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];

    //right
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:TUIKitLocalizableString(TUIKitGroupProfileManage) forState:UIControlStateNormal];
    [rightButton setTitleColor:TUICoreDynamicColor(@"nav_title_text_color", @"#000000") forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
    
    
    self.indicatorView.frame = CGRectMake(0, 0, self.view.bounds.size.width, TMessageController_Header_Height);
    
    self.tableView.frame = self.view.bounds;
    self.tableView.tableFooterView = self.indicatorView;
    [self.view addSubview:self.tableView];
    
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    [_titleView setTitle:TUIKitLocalizableString(GroupMember)];
}

- (void)leftBarButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonClick {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSMutableArray *ids = NSMutableArray.new;
    for (TUIGroupMemberCellData *cd in self.members) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
        }
    }

    if ([self.dataProvider.groupInfo canInviteMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileManageAdd) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // add
            self.tag = 1;
            self.showContactSelectVC = [TUICore callService:TUICore_TUIContactService
                                                 method:TUICore_TUIContactService_GetContactSelectControllerMethod
                                                  param:@{TUICore_TUIContactService_GetContactSelectControllerMethod_TitleKey :                 TUIKitLocalizableString(GroupAddFirend),
                                                          TUICore_TUIContactService_GetContactSelectControllerMethod_DisableIdsKey:ids}];
            [self.navigationController pushViewController:self.showContactSelectVC animated:YES];
        }]];
    }
    if ([self.dataProvider.groupInfo canRemoveMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileManageDelete) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // delete
            self.tag = 2;
            self.showContactSelectVC = [TUICore callService:TUICore_TUIContactService
                                                 method:TUICore_TUIContactService_GetContactSelectControllerMethod
                                                  param:@{TUICore_TUIContactService_GetContactSelectControllerMethod_TitleKey : TUIKitLocalizableString(GroupDeleteFriend),
                                                          TUICore_TUIContactService_GetContactSelectControllerMethod_SourceIdsKey:ids}];
            [self.navigationController pushViewController:self.showContactSelectVC animated:YES];
        }]];
    }
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members
{
    @weakify(self)
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId userList:members succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        @strongify(self)
        [self refreshData];
        [TUITool makeToast:TUIKitLocalizableString(add_success)];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members
{
    @weakify(self)
    [[V2TIMManager sharedInstance] kickGroupMember:groupId memberList:members reason:@"" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        @strongify(self)
        [self refreshData];
        [TUITool makeToast:TUIKitLocalizableString(delete_success)];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIMemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    TUIMemberInfoCellData *data = self.members[indexPath.row];
    cell.data = data;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 0 && (scrollView.contentOffset.y >= scrollView.bounds.origin.y)) {
        if (self.indicatorView.isAnimating) {
            return;
        }
        [self.indicatorView startAnimating];
        
        // There's no more data, stop loading.
        if (self.dataProvider.isNoMoreData) {
            [self.indicatorView stopAnimating];
            [TUITool makeToast:TUIKitLocalizableString(TUIKitMessageReadNoMoreData)];
            return;
        }
        
        @weakify(self);
        [self.dataProvider loadDatas:^(BOOL success, NSString * _Nonnull err, NSArray * _Nonnull datas) {
            @strongify(self);
            [self.indicatorView stopAnimating];
            if (!success) {
                return;
            }
            [self.members addObjectsFromArray:datas];
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            if (datas.count == 0) {
                [self.tableView setContentOffset:CGPointMake(0, scrollView.contentOffset.y - TMessageController_Header_Height) animated:YES];
            }
        }];
    }
}


- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}


- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:TUIMemberInfoCell.class forCellReuseIdentifier:@"cell"];
        _tableView.rowHeight = 48.0;
    }
    return _tableView;
}

#pragma mark - TUICore
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIContactNotify]
        && [subKey isEqualToString:TUICore_TUIContactNotify_SelectedContactsSubKey]
        && anObject == self.showContactSelectVC) {

        NSArray<TUICommonContactSelectCellData *> *selectArray = [param tui_objectForKey:TUICore_TUIContactNotify_SelectedContactsSubKey_ListKey asClass:NSArray.class];
        if (![selectArray.firstObject isKindOfClass:TUICommonContactSelectCellData.class]) {
            NSAssert(NO, @"value type error");
        }
        
        if (self.tag == 1) {
            // add
            NSMutableArray *list = @[].mutableCopy;
            for (TUICommonContactSelectCellData *data in selectArray) {
                [list addObject:data.identifier];
            }
            [self.navigationController popToViewController:self animated:YES];
            [self addGroupId:_groupId memebers:list];
        } else if (self.tag == 2) {
            // delete
            NSMutableArray *list = @[].mutableCopy;
            for (TUICommonContactSelectCellData *data in selectArray) {
                [list addObject:data.identifier];
            }
            [self.navigationController popToViewController:self animated:YES];
            [self deleteGroupId:_groupId memebers:list];
        }
    }
}
@end


