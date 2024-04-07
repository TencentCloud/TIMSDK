//
//  GroupMemberController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIGroupMemberController_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGroupMemberCell.h"
#import "TUIGroupMemberDataProvider.h"

#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMemberInfoCell.h"
#import "TUIMemberInfoCellData.h"
#import "TUISettingAdminDataProvider.h"

@interface TUIGroupMemberController_Minimalist () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UIViewController *showContactSelectVC;
@property(nonatomic, strong) TUIGroupMemberDataProvider *dataProvider;
@property(nonatomic, strong) NSMutableArray<TUIMemberInfoCellData *> *members;
@property NSInteger tag;
@property(nonatomic, strong) TUISettingAdminDataProvider *adminDataprovier;
@end

@implementation TUIGroupMemberController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];

    self.dataProvider = [[TUIGroupMemberDataProvider alloc] initWithGroupID:self.groupId];
    self.dataProvider.groupInfo = self.groupInfo;

    self.adminDataprovier = [[TUISettingAdminDataProvider alloc] init];
    self.adminDataprovier.groupID = self.groupId;

    [self.adminDataprovier loadData:^(int code, NSString *error) {
      [self refreshData];
    }];
}

- (void)refreshData {
    @weakify(self);
    [self.dataProvider loadDatas:^(BOOL success, NSString *_Nonnull err, NSArray *_Nonnull datas) {
      @strongify(self);
      NSString *title = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitGroupProfileGroupCountFormat), (long)datas.count];
      self.title = title;
      self.members = [NSMutableArray arrayWithArray:datas];
      [self.tableView reloadData];
    }];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor whiteColor];

    // left
    UIImage *image = TUIGroupDynamicImage(@"group_nav_back_img", [UIImage imageNamed:TUIGroupImagePath(@"back")]);
    image = [image rtl_imageFlippedForRightToLeftLayoutDirection];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 10.0f;
    self.navigationItem.leftBarButtonItems = @[ leftItem ];
    self.parentViewController.navigationItem.leftBarButtonItems = @[ leftItem ];

    // right
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:TIMCommonLocalizableString(TUIKitGroupProfileManage) forState:UIControlStateNormal];
    [rightButton setTitleColor:TIMCommonDynamicColor(@"nav_title_text_color", @"#000000") forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];

    self.indicatorView.frame = CGRectMake(0, 0, self.view.bounds.size.width, TMessageController_Header_Height);

    self.tableView.frame = self.view.bounds;
    self.tableView.tableFooterView = self.indicatorView;
    [self.view addSubview:self.tableView];

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    [_titleView setTitle:TIMCommonLocalizableString(GroupMember)];
}

- (void)leftBarButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonClick {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSMutableArray *ids = [NSMutableArray array];
    NSMutableDictionary *displayNames = [NSMutableDictionary dictionary];
    for (TUIGroupMemberCellData *cd in self.members) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
            [displayNames setObject:cd.name ?: @"" forKey:cd.identifier ?: @""];
        }
    }

    @weakify(self);
    void (^selectContactCompletion)(NSArray<TUICommonContactSelectCellData *> *) = ^(NSArray<TUICommonContactSelectCellData *> *array) {
      @strongify(self);
      if (self.tag == 1) {
          // add
          NSMutableArray *list = @[].mutableCopy;
          for (TUICommonContactSelectCellData *data in array) {
              [list addObject:data.identifier];
          }
          [self.navigationController popToViewController:self animated:YES];
          [self addGroupId:self.groupId memebers:list];
      } else if (self.tag == 2) {
          // delete
          NSMutableArray *list = @[].mutableCopy;
          for (TUICommonContactSelectCellData *data in array) {
              [list addObject:data.identifier];
          }
          [self.navigationController popToViewController:self animated:YES];
          [self deleteGroupId:self.groupId memebers:list];
      }
    };
    if ([self.dataProvider.groupInfo canInviteMember]) {
        [ac tuitheme_addAction:[UIAlertAction
                                   actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileManageAdd)
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *_Nonnull action) {
                                             // add
                                             self.tag = 1;
                                             NSMutableDictionary *param = [NSMutableDictionary dictionary];
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey] =
                                                 TIMCommonLocalizableString(GroupAddFirend);
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey] = ids;
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey] = selectContactCompletion;
                                             self.showContactSelectVC = [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                                                                                          key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                                                                        param:param];
                                             [self.navigationController pushViewController:self.showContactSelectVC animated:YES];
                                           }]];
    }
    if ([self.dataProvider.groupInfo canRemoveMember]) {
        [ac tuitheme_addAction:[UIAlertAction
                                   actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileManageDelete)
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *_Nonnull action) {
                                             // delete
                                             self.tag = 2;
                                             NSMutableDictionary *param = [NSMutableDictionary dictionary];
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey] =
                                                 TIMCommonLocalizableString(GroupDeleteFriend);
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_SourceIdsKey] = ids;
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
                                             param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey] = selectContactCompletion;
                                             self.showContactSelectVC = [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                                                                                          key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                                                                        param:param];
                                             [self.navigationController pushViewController:self.showContactSelectVC animated:YES];
                                           }]];
    }
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members {
    @weakify(self);
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId
        userList:members
        succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
          @strongify(self);
          [self refreshData];
          [TUITool makeToast:TIMCommonLocalizableString(add_success)];
        }
        fail:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}

- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members {
    @weakify(self);
    [[V2TIMManager sharedInstance] kickGroupMember:groupId
        memberList:members
        reason:@""
        succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
          @strongify(self);
          [self refreshData];
          [TUITool makeToast:TIMCommonLocalizableString(delete_success)];
        }
        fail:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID SuccBlock:(void (^)(UIViewController *vc))succ failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIMemberInfoCell"];
    TUIMemberInfoCellData *data = self.members[indexPath.row];
    data.showAccessory = YES;
    cell.data = data;
    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.mm_h / 2;
    cell.avatarImageView.layer.masksToBounds = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TUIMemberInfoCellData *data = self.members[indexPath.row];

    if ([data.identifier isEqualToString:TUILogin.getUserID]) {
        // Can't manage yourself
        return;
    }

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;

    UIAlertAction *actionInfo = [UIAlertAction actionWithTitle:TIMCommonLocalizableString(Info)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                         __strong typeof(weakSelf) strongSelf = weakSelf;
                                                         [self getUserOrFriendProfileVCWithUserID:data.identifier
                                                                                        SuccBlock:^(UIViewController *vc) {
                                                                                          [strongSelf.navigationController pushViewController:vc animated:YES];
                                                                                        }
                                                                                        failBlock:^(int code, NSString *desc){

                                                                                        }];
                                                       }];

    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileManageDelete)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                           // delete
                                                           NSMutableArray *list = @[].mutableCopy;
                                                           [list addObject:data.identifier];
                                                           [weakSelf deleteGroupId:weakSelf.groupId memebers:list];
                                                         }];

    UIAlertAction *actionAddAdmin = [UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileAdmainAdd)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *_Nonnull action) {
                                                             TUIUserModel *user = [[TUIUserModel alloc] init];
                                                             user.userId = data.identifier;
                                                             [self.adminDataprovier settingAdmins:@[ user ]
                                                                                         callback:^(int code, NSString *errorMsg) {
                                                                                           if (code != 0) {
                                                                                               [weakSelf.view makeToast:errorMsg];
                                                                                           } else {
                                                                                               data.role = V2TIM_GROUP_MEMBER_ROLE_ADMIN;
                                                                                           }
                                                                                           [weakSelf.tableView reloadData];
                                                                                         }];
                                                           }];
    UIAlertAction *actionRemoveAdmin = [UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileAdmainDelete)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *_Nonnull action) {
                                                                TUIUserModel *user = [[TUIUserModel alloc] init];
                                                                user.userId = data.identifier;
                                                                [self.adminDataprovier removeAdmin:data.identifier
                                                                                          callback:^(int code, NSString *errorMsg) {
                                                                                            if (code != 0) {
                                                                                                [weakSelf.view makeToast:errorMsg];
                                                                                            } else {
                                                                                                data.role = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
                                                                                            }
                                                                                            [weakSelf.tableView reloadData];
                                                                                          }];
                                                                ;
                                                              }];

    [ac tuitheme_addAction:actionInfo];

    if (([self.dataProvider.groupInfo canSupportSetAdmain])) {
        if (data.role == V2TIM_GROUP_MEMBER_ROLE_MEMBER || data.role == V2TIM_GROUP_MEMBER_UNDEFINED) {
            [ac tuitheme_addAction:actionAddAdmin];
        } else {
            [ac tuitheme_addAction:actionRemoveAdmin];
        }
    }

    if ([self.dataProvider.groupInfo canRemoveMember]) {
        if ((data.role < self.dataProvider.groupInfo.role)) {
            [ac tuitheme_addAction:actionDelete];
        }
    }

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0 && (scrollView.contentOffset.y >= scrollView.bounds.origin.y)) {
        if (self.indicatorView.isAnimating) {
            return;
        }
        [self.indicatorView startAnimating];

        // There's no more data, stop loading.
        if (self.dataProvider.isNoMoreData) {
            [self.indicatorView stopAnimating];
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitMessageReadNoMoreData)];
            return;
        }

        @weakify(self);
        [self.dataProvider loadDatas:^(BOOL success, NSString *_Nonnull err, NSArray *_Nonnull datas) {
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

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:TUIMemberInfoCell.class forCellReuseIdentifier:@"TUIMemberInfoCell"];
        _tableView.rowHeight = kScale390(52);
    }
    return _tableView;
}
@end
