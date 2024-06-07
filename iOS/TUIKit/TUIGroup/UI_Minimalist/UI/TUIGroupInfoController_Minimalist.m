
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIGroupInfoController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGroupButtonCell_Minimalist.h"
#import "TUIGroupInfoDataProvider_Minimalist.h"
#import "TUIGroupManageController_Minimalist.h"
#import "TUIGroupMemberCell.h"
#import "TUIGroupMemberController_Minimalist.h"
#import "TUIGroupMemberTableViewCell_Minimalist.h"
#import "TUIGroupMembersCell.h"
#import "TUIGroupNoticeCell.h"
#import "TUIGroupNoticeController_Minimalist.h"
#import "TUIGroupProfileCardViewCell_Minimalist.h"
#import "TUISelectGroupMemberViewController_Minimalist.h"

#define ADD_TAG @"-1"
#define DEL_TAG @"-2"

@interface TUIGroupInfoController_Minimalist () <TUIModifyViewDelegate,
                                                 TUIGroupMembersCellDelegate,
                                                 TUIProfileCardDelegate,
                                                 TUIGroupInfoDataProviderDelegate_Minimalist,
                                                 UITableViewDelegate,
                                                 UITableViewDataSource>
@property(nonatomic, strong) TUIGroupInfoDataProvider_Minimalist *dataProvider;
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, assign) NSInteger tag;
@end

@implementation TUIGroupInfoController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataProvider = [[TUIGroupInfoDataProvider_Minimalist alloc] initWithGroupID:self.groupId];
    self.dataProvider.delegate = self;

    [self setupViews];
    [self.dataProvider loadData];

    @weakify(self);
    [RACObserve(self.dataProvider, dataList) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      [self.tableView reloadData];
    }];

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    [_titleView setTitle:TIMCommonLocalizableString(ProfileDetails)];
}

- (void)setupViews {
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TIMCommonDynamicColor(@"", @"#FFFFFF");
    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -58, 0, 0);
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];

    self.tableView.tableFooterView = [[UIView alloc] init];
    TUIGroupProfileHeaderView_Minimalist *headerView = [[TUIGroupProfileHeaderView_Minimalist alloc] init];
    self.tableView.tableHeaderView = headerView;
    [self updateGroupInfo];

    @weakify(self);
    headerView.headImgClickBlock = ^{
      @strongify(self);
      [self didSelectAvatar];
    };
    headerView.editBtnClickBlock = ^{
      @strongify(self);
      [self didSelectEditGroupName];
    };

    // Extension
    NSMutableArray<TUIGroupProfileHeaderItemView_Minimalist *> *itemViewList = [NSMutableArray array];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.groupId.length > 0) {
        param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID] = self.groupId;
    }
    param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterVideoCall] = @(NO);
    param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterAudioCall] = @(NO);
    if (self.navigationController) {
        param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC] = self.navigationController;
    }
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID param:param];
    for (TUIExtensionInfo *info in extensionList) {
        if (info.icon && info.text && info.onClicked) {
            TUIGroupProfileHeaderItemView_Minimalist *itemView = [[TUIGroupProfileHeaderItemView_Minimalist alloc] init];
            itemView.iconView.image = info.icon;
            itemView.textLabel.text = info.text;
            itemView.messageBtnClickBlock = ^{
              info.onClicked(param);
            };
            [itemViewList addObject:itemView];
        }
    }
    headerView.itemViewList = itemViewList;

    if (itemViewList.count > 0) {
        headerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 355);
    } else {
        headerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 257);
    }
}

- (void)updateData {
    [self.dataProvider loadData];
}

- (void)updateGroupInfo {
    __weak typeof(self) weakSelf = self;
    [self.dataProvider updateGroupInfo:^{
      TUIGroupProfileHeaderView_Minimalist *headerView = (TUIGroupProfileHeaderView_Minimalist *)self.tableView.tableHeaderView;
      headerView.groupInfo = weakSelf.dataProvider.groupInfo;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataProvider.dataList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = self.dataProvider.dataList[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = self.dataProvider.dataList[indexPath.section];
    NSObject *data = array[indexPath.row];
    if ([data isKindOfClass:[TUIGroupMemberCellData_Minimalist class]]) {
        return [(TUIGroupMemberCellData_Minimalist *)data heightOfWidth:Screen_Width];
    } else if ([data isKindOfClass:[TUIGroupButtonCellData_Minimalist class]]) {
        return [(TUIGroupButtonCellData_Minimalist *)data heightOfWidth:Screen_Width];
        ;
    } else if ([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        return [(TUICommonSwitchCellData *)data heightOfWidth:Screen_Width];
        ;
    } else if ([data isKindOfClass:TUIGroupNoticeCellData.class]) {
        return 72.0;
    }
    return kScale390(55);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = self.dataProvider.dataList[indexPath.section];
    NSObject *data = array[indexPath.row];
    @weakify(self);

    if ([data isKindOfClass:[TUICommonTextCellData class]]) {
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:TKeyValueCell_ReuseId];
        if (!cell) {
            cell = [[TUICommonTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TKeyValueCell_ReuseId];
        }
        [cell fillWithData:(TUICommonTextCellData *)data];
        cell.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        cell.contentView.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");

        return cell;
    } else if ([data isKindOfClass:[TUIGroupMemberCellData_Minimalist class]]) {
        TUIGroupMemberTableViewCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:TGroupMembersCell_ReuseId];
        if (!cell) {
            cell = [[TUIGroupMemberTableViewCell_Minimalist alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupMembersCell_ReuseId];
        }
        [cell fillWithData:(TUIGroupMemberCellData_Minimalist *)data];
        cell.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        cell.contentView.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");

        return cell;
    } else if ([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        TUICommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:TSwitchCell_ReuseId];
        if (!cell) {
            cell = [[TUICommonSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSwitchCell_ReuseId];
        }
        [cell fillWithData:(TUICommonSwitchCellData *)data];
        cell.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        cell.contentView.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        return cell;
    } else if ([data isKindOfClass:[TUIGroupButtonCellData_Minimalist class]]) {
        TUIGroupButtonCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if (!cell) {
            cell = [[TUIGroupButtonCell_Minimalist alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
        }
        [cell fillWithData:(TUIGroupButtonCellData_Minimalist *)data];
        return cell;
    } else if ([data isKindOfClass:TUIGroupNoticeCellData.class]) {
        TUIGroupNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIGroupNoticeCell"];
        if (cell == nil) {
            cell = [[TUIGroupNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TUIGroupNoticeCell"];
        }
        cell.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        cell.contentView.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        cell.cellData = data;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)leftBarButtonClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TUIGroupInfoDataProviderDelegate

- (void)onSendMessage:(TUIGroupProfileCardViewCell_Minimalist *)cell {
    TUIGroupProfileCardCellData_Minimalist *cellData = cell.cardData;

    UIImage *avataImage = [UIImage new];
    if (cell.headerView.headImg.image) {
        avataImage = cell.headerView.headImg.image;
    }

    NSDictionary *param = @{
        TUICore_TUIChatObjectFactory_ChatViewController_Title : cellData.name ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_GroupID : cellData.identifier ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : avataImage ?: [UIImage new]
    };
    [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
}

- (void)didSelectMembers {
    TUIGroupMemberController_Minimalist *membersController = [[TUIGroupMemberController_Minimalist alloc] init];
    membersController.groupId = _groupId;
    membersController.groupInfo = self.dataProvider.groupInfo;
    [self.navigationController pushViewController:membersController animated:YES];
}

- (void)didSelectAddOption:(TUICommonTextCell *)cell {
    TUICommonTextCellData *data = cell.textData;
    BOOL isApprove = [data.key isEqualToString:TIMCommonLocalizableString(TUIKitGroupProfileInviteType)];
    __weak typeof(self) weakSelf = self;
    UIAlertController *ac = [UIAlertController
        alertControllerWithTitle:nil
                         message:isApprove ? TIMCommonLocalizableString(TUIKitGroupProfileInviteType) : TIMCommonLocalizableString(TUIKitGroupProfileJoinType)
                  preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *actionList = @[
        @{
            @(V2TIM_GROUP_ADD_FORBID) : isApprove ? TIMCommonLocalizableString(TUIKitGroupProfileInviteDisable)
                                                  : TIMCommonLocalizableString(TUIKitGroupProfileJoinDisable)
        },
        @{@(V2TIM_GROUP_ADD_AUTH) : TIMCommonLocalizableString(TUIKitGroupProfileAdminApprove)},
        @{@(V2TIM_GROUP_ADD_ANY) : TIMCommonLocalizableString(TUIKitGroupProfileAutoApproval)}
    ];
    for (NSDictionary *map in actionList) {
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:map.allValues.firstObject
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        V2TIMGroupAddOpt opt = (V2TIMGroupAddOpt)[map.allKeys.firstObject intValue];
                                                        if (isApprove) {
                                                            [weakSelf.dataProvider setGroupApproveOpt:opt];
                                                        } else {
                                                            [weakSelf.dataProvider setGroupAddOpt:opt];
                                                        }
                                                      }]];
    }
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectGroupNick:(TUICommonTextCell *)cell {
    TUIModifyViewData *data = [[TUIModifyViewData alloc] init];
    data.title = TIMCommonLocalizableString(TUIKitGroupProfileEditAlias);
    data.content = self.dataProvider.selfInfo.nameCard;
    data.desc = TIMCommonLocalizableString(TUIKitGroupProfileEditAliasDesc);
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 2;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectCommon {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([self.dataProvider.groupInfo isPrivate] || [TUIGroupInfoDataProvider_Minimalist isMeOwner:self.dataProvider.groupInfo]) {
        @weakify(self);
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileEditGroupName)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        @strongify(self);
                                                        [self didSelectEditGroupName];
                                                      }]];
    }
    if ([TUIGroupInfoDataProvider_Minimalist isMeOwner:self.dataProvider.groupInfo]) {
        @weakify(self);
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileEditAnnouncement)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        @strongify(self);
                                                        [self didSelectEditAnnouncement];
                                                      }]];
    }

    if ([TUIGroupInfoDataProvider_Minimalist isMeOwner:self.dataProvider.groupInfo]) {
        @weakify(self);
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileEditAvatar)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        @strongify(self);
                                                        [self didSelectAvatar];
                                                      }]];
    }

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectEditGroupName {
    TUIModifyViewData *data = [[TUIModifyViewData alloc] init];
    data.title = TIMCommonLocalizableString(TUIKitGroupProfileEditGroupName);
    data.content = self.dataProvider.groupInfo.groupName;
    data.desc = TIMCommonLocalizableString(TUIKitGroupProfileEditGroupName);
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 0;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}
- (void)didSelectEditAnnouncement {
    TUIModifyViewData *data = [[TUIModifyViewData alloc] init];
    data.title = TIMCommonLocalizableString(TUIKitGroupProfileEditAnnouncement);
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 1;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}
- (void)didSelectAvatar {
    TUISelectAvatarController *vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeGroupAvatar;
    vc.profilFaceURL = self.dataProvider.groupInfo.faceURL;
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self);
    vc.selectCallBack = ^(NSString *_Nonnull urlStr) {
      @strongify(self);
      if (urlStr.length > 0) {
          V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
          info.groupID = self.groupId;
          info.faceURL = urlStr;
          @weakify(self);
          [[V2TIMManager sharedInstance] setGroupInfo:info
              succ:^{
                @strongify(self);
                [self updateGroupInfo];
              }
              fail:^(int code, NSString *msg) {
                [TUITool makeToastError:code msg:msg];
              }];
      }
    };
}
- (void)didSelectOnNotDisturb:(TUICommonSwitchCell *)cell {
    V2TIMReceiveMessageOpt opt;
    if (cell.switcher.on) {
        opt = V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
    } else {
        opt = V2TIM_RECEIVE_MESSAGE;
    }
    @weakify(self);
    [V2TIMManager.sharedInstance markConversation:@[ [NSString stringWithFormat:@"group_%@", self.groupId] ]
                                         markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD)
                                       enableMark:NO
                                             succ:nil
                                             fail:nil];

    [self.dataProvider setGroupReceiveMessageOpt:opt
                                            Succ:^{
                                              @strongify(self);
                                              [self updateGroupInfo];
                                            }
                                            fail:^(int code, NSString *desc){
                                            }];
}

- (void)didSelectOnTop:(TUICommonSwitchCell *)cell {
    if (cell.switcher.on) {
        [[TUIConversationPin sharedInstance] addTopConversation:[NSString stringWithFormat:@"group_%@", _groupId]
                                                       callback:^(BOOL success, NSString *_Nonnull errorMessage) {
                                                         if (success) {
                                                             return;
                                                         }
                                                         cell.switcher.on = !cell.switcher.isOn;
                                                         [TUITool makeToast:errorMessage];
                                                       }];
    } else {
        [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@", _groupId]
                                                          callback:^(BOOL success, NSString *_Nonnull errorMessage) {
                                                            if (success) {
                                                                return;
                                                            }
                                                            cell.switcher.on = !cell.switcher.isOn;
                                                            [TUITool makeToast:errorMessage];
                                                          }];
    }
}

- (void)didDeleteGroup:(TUIButtonCell *)cell {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                message:TIMCommonLocalizableString(TUIKitGroupProfileDeleteGroupTips)
                                                         preferredStyle:UIAlertControllerStyleActionSheet];

    @weakify(self);
    [ac tuitheme_addAction:[UIAlertAction
                               actionWithTitle:TIMCommonLocalizableString(Confirm)
                                         style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *_Nonnull action) {
                                         @strongify(self);
                                         @weakify(self);
                                         if ([self.dataProvider.groupInfo canDismissGroup]) {
                                             [self.dataProvider
                                                 dismissGroup:^{
                                                   @strongify(self);
                                                   @weakify(self);
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                     @strongify(self);
                                                     UIViewController *vc = [self findConversationListViewController];
                                                     [[TUIConversationPin sharedInstance]
                                                         removeTopConversation:[NSString stringWithFormat:@"group_%@", self.groupId]
                                                                      callback:nil];
                                                     [V2TIMManager.sharedInstance markConversation:@[ [NSString stringWithFormat:@"group_%@", self.groupId] ]
                                                         markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD)
                                                         enableMark:NO
                                                         succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
                                                           [self.navigationController popToViewController:vc animated:YES];
                                                         }
                                                         fail:^(int code, NSString *desc) {
                                                           [self.navigationController popToViewController:vc animated:YES];
                                                         }];
                                                   });
                                                 }
                                                 fail:^(int code, NSString *msg) {
                                                   [TUITool makeToastError:code msg:msg];
                                                 }];
                                         } else {
                                             [self.dataProvider
                                                 quitGroup:^{
                                                   @strongify(self);
                                                   @weakify(self);
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                     @strongify(self);
                                                     UIViewController *vc = [self findConversationListViewController];
                                                     [[TUIConversationPin sharedInstance]
                                                         removeTopConversation:[NSString stringWithFormat:@"group_%@", self.groupId]
                                                                      callback:nil];
                                                     [V2TIMManager.sharedInstance markConversation:@[ [NSString stringWithFormat:@"group_%@", self.groupId] ]
                                                         markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD)
                                                         enableMark:NO
                                                         succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
                                                           [self.navigationController popToViewController:vc animated:YES];
                                                         }
                                                         fail:^(int code, NSString *desc) {
                                                           [self.navigationController popToViewController:vc animated:YES];
                                                         }];
                                                   });
                                                 }
                                                 fail:^(int code, NSString *msg) {
                                                   [TUITool makeToastError:code msg:msg];
                                                 }];
                                         }
                                       }]];

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}
- (void)didReportGroup:(TUIButtonCell *)cell {
    NSURL *url = [NSURL URLWithString:@"https://cloud.tencent.com/act/event/report-platform"];
    [TUITool openLinkWithURL:url];
}
- (UIViewController *)findConversationListViewController {
    UIViewController *vc = self.navigationController.viewControllers[0];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"TUIFoldListViewController")]) {
            return vc;
        }
    }
    return vc;
}

- (void)didSelectOnFoldConversation:(TUICommonSwitchCell *)cell {
    BOOL enableMark = NO;
    if (cell.switcher.on) {
        enableMark = YES;
    }

    @weakify(self);

    [V2TIMManager.sharedInstance markConversation:@[ [NSString stringWithFormat:@"group_%@", self.groupId] ]
                                         markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD)
                                       enableMark:enableMark
                                             succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
        cell.switchData.on = enableMark;
        [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@", self.groupId]
                                                          callback:^(BOOL success, NSString *_Nonnull errorMessage) {
                                                            @strongify(self);
                                                            [self updateGroupInfo];
                                                          }];
    }
                                             fail:nil];

}

- (void)didSelectOnChangeBackgroundImage:(TUICommonTextCell *)cell {
    @weakify(self);
    NSString *conversationID = [NSString stringWithFormat:@"group_%@", self.groupId];
    TUISelectAvatarController *vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeConversationBackGroundCover;
    vc.profilFaceURL = [self getBackgroundImageUrlByConversationID:conversationID];
    [self.navigationController pushViewController:vc animated:YES];
    vc.selectCallBack = ^(NSString *_Nonnull urlStr) {
      @strongify(self);
      [self appendBackgroundImage:urlStr conversationID:conversationID];
      if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
          [TUICore notifyEvent:TUICore_TUIGroupNotify
                        subKey:TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey
                        object:self
                         param:@{TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey_ConversationID : conversationID}];
      }
    };
}

- (NSString *)getBackgroundImageUrlByConversationID:(NSString *)targerConversationID {
    if (targerConversationID.length == 0) {
        return nil;
    }
    NSDictionary *dict = [NSUserDefaults.standardUserDefaults objectForKey:@"conversation_backgroundImage_map"];
    if (dict == nil) {
        dict = @{};
    }
    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@", targerConversationID, [TUILogin getUserID]];
    if (![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:conversationID_UserID]) {
        return nil;
    }
    return [dict objectForKey:conversationID_UserID];
}

- (void)appendBackgroundImage:(NSString *)imgUrl conversationID:(NSString *)conversationID {
    if (conversationID.length == 0) {
        return;
    }
    NSDictionary *dict = [NSUserDefaults.standardUserDefaults objectForKey:@"conversation_backgroundImage_map"];
    if (dict == nil) {
        dict = @{};
    }
    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@", conversationID, [TUILogin getUserID]];
    NSMutableDictionary *originDataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (imgUrl.length == 0) {
        [originDataDict removeObjectForKey:conversationID_UserID];
    } else {
        [originDataDict setObject:imgUrl forKey:conversationID_UserID];
    }

    [NSUserDefaults.standardUserDefaults setObject:originDataDict forKey:@"conversation_backgroundImage_map"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)didTransferGroup:(TUIButtonCell *)cell {
    TUISelectGroupMemberViewController_Minimalist *vc = [[TUISelectGroupMemberViewController_Minimalist alloc] init];
    vc.optionalStyle = TUISelectMemberOptionalStyleTransferOwner;
    vc.groupId = self.groupId;
    vc.name = TIMCommonLocalizableString(TUIKitGroupTransferOwner);
    @weakify(self);
    vc.selectedFinished = ^(NSMutableArray<TUIUserModel *> *_Nonnull modelList) {
      @strongify(self);
      TUIUserModel *userModel = modelList[0];
      NSString *groupId = self.groupId;
      NSString *member = userModel.userId;
      if (userModel && [userModel isKindOfClass:[TUIUserModel class]]) {
          @weakify(self);
          [self.dataProvider transferGroupOwner:groupId
              member:member
              succ:^{
                @strongify(self);
                [self updateGroupInfo];
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitGroupTransferOwnerSuccess)];
              }
              fail:^(int code, NSString *desc) {
                [TUITool makeToastError:code msg:desc];
              }];
      }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClearAllHistory:(TUIButtonCell *)cell {
    @weakify(self);
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                message:TIMCommonLocalizableString(TUIKitClearAllChatHistoryTips)
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm)
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    @strongify(self);
                                                    [self.dataProvider
                                                        clearAllHistory:^{
                                                          [TUICore notifyEvent:TUICore_TUIConversationNotify
                                                                        subKey:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey
                                                                        object:self
                                                                         param:nil];
                                                          [TUITool makeToast:@"success"];
                                                        }
                                                        fail:^(int code, NSString *desc) {
                                                          [TUITool makeToastError:code msg:desc];
                                                        }];
                                                  }]];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectGroupManage {
    TUIGroupManageController_Minimalist *vc = [[TUIGroupManageController_Minimalist alloc] init];
    vc.groupID = self.groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectGroupNotice {
    TUIGroupNoticeController_Minimalist *vc = [[TUIGroupNoticeController_Minimalist alloc] init];
    vc.groupID = self.groupId;
    __weak typeof(self) weakSelf = self;
    vc.onNoticeChanged = ^{
      [weakSelf updateGroupInfo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark TUIProfileCardDelegate

- (void)didTapOnAvatar:(TUIProfileCardCell *)cell {
    TUISelectAvatarController *vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeGroupAvatar;
    vc.profilFaceURL = self.dataProvider.groupInfo.faceURL;
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self);
    vc.selectCallBack = ^(NSString *_Nonnull urlStr) {
      @strongify(self);
      if (urlStr.length > 0) {
          V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
          info.groupID = self.groupId;
          info.faceURL = urlStr;
          [[V2TIMManager sharedInstance] setGroupInfo:info
              succ:^{
                [self updateGroupInfo];
              }
              fail:^(int code, NSString *msg) {
                [TUITool makeToastError:code msg:msg];
              }];
      }
    };
}

#pragma mark TUIGroupMembersCellDelegate

- (void)didAddMemebers {
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableDictionary *displayNames = [NSMutableDictionary dictionary];
    for (TUIGroupMemberCellData *cd in self.dataProvider.membersData) {
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

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey] = TIMCommonLocalizableString(GroupAddFirend);
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey] = ids;
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey] = selectContactCompletion;
    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                                             key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                           param:param];
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        [self.navigationController pushViewController:vc animated:YES];
    }
    self.tag = 1;
}

- (void)didCurrentMemberAtCell:(TUIGroupMemberTableViewCell_Minimalist *)cell {
    TUIGroupMemberCellData_Minimalist *mem = (TUIGroupMemberCellData_Minimalist *)cell.data;
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableDictionary *displayNames = [NSMutableDictionary dictionary];
    for (TUIGroupMemberCellData *cd in self.dataProvider.membersData) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
            [displayNames setObject:cd.name ?: @"" forKey:cd.identifier ?: @""];
        }
    }

    NSString *userID = mem.identifier;
    @weakify(self);
    [self getUserOrFriendProfileVCWithUserID:userID
                                   SuccBlock:^(UIViewController *vc) {
                                     @strongify(self);
                                     [self.navigationController pushViewController:vc animated:YES];
                                   }
                                   failBlock:^(int code, NSString *desc){

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

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members {
    @weakify(self);
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId
        userList:members
        succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
          @strongify(self);
          [self updateData];
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
          [self updateData];
          [TUITool makeToast:TIMCommonLocalizableString(delete_success)];
        }
        fail:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}

#pragma mark TUIModifyViewDelegate

- (void)modifyView:(TUIModifyView *)modifyView didModiyContent:(NSString *)content {
    @weakify(self);
    if (modifyView.tag == 0) {
        [self.dataProvider setGroupName:content
                                   succ:^{
                                     @strongify(self);
                                     [self updateGroupInfo];
                                   }
                                   fail:^(int code, NSString *desc){
                                   }];
    } else if (modifyView.tag == 1) {
        [self.dataProvider setGroupNotification:content];
    } else if (modifyView.tag == 2) {
        [self.dataProvider setGroupMemberNameCard:content];
    }
}
@end

@interface IUGroupView_Minimalist : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUGroupView_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
