
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIGroupInfoController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMGroupInfo+TUIDataProvider.h>
#import <TIMCommon/TUICommonGroupInfoCellData_Minimalist.h>
#import <TIMCommon/TUIGroupButtonCell_Minimalist.h>
#import "TUIGroupInfoDataProvider_Minimalist.h"
#import "TUIGroupNoticeCell.h"
#import "TUIGroupNoticeController_Minimalist.h"
#import "TUIGroupProfileCardViewCell_Minimalist.h"

@interface TUIGroupInfoController_Minimalist () <TUIModifyViewDelegate,
                                                 TUIProfileCardDelegate,
                                                 TUIGroupInfoDataProviderDelegate_Minimalist,
                                                 UITableViewDelegate,
                                                 UITableViewDataSource>
@property(nonatomic, strong) TUIGroupInfoDataProvider_Minimalist *dataProvider;
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
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
        param[TUICore_TUIContactExtension_GroupInfoCardActionMenu_GroupID] = self.groupId;
    }
    param[TUICore_TUIContactExtension_GroupInfoCardActionMenu_FilterVideoCall] = @(NO);
    param[TUICore_TUIContactExtension_GroupInfoCardActionMenu_FilterAudioCall] = @(NO);
    if (self.navigationController) {
        param[TUICore_TUIContactExtension_GroupInfoCardActionMenu_PushVC] = self.navigationController;
    }
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:
                                                  TUICore_TUIContactExtension_GroupInfoCardActionMenu_MinimalistExtensionID
                                                                     param:param];
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
    } else if ([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        return [(TUICommonSwitchCellData *)data heightOfWidth:Screen_Width];
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
        TUICommonTableViewCell *cell = [[TUICommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupMembersCell_ReuseId];
        NSDictionary *param = @{
            @"data": data ,
            @"pushVC": self.navigationController,
            @"groupID": self.groupId ? self.groupId : @"",
            @"membersData": self.dataProvider.membersData,
        };
        [TUICore raiseExtension:
                                TUICore_TUIChatExtension_GroupProfileMemberListExtension_MinimalistExtensionID
                      parentView:cell
                          param:param];
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

- (void)groupProfileExtensionButtonClick:(TUICommonTextCell *)cell {
    
    TUIExtensionInfo *info = cell.data.tui_extValueObj;
    if (info == nil || ![info isKindOfClass:TUIExtensionInfo.class] || info.onClicked == nil) {
        return;
    }
    info.onClicked(@{});
}

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
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (_groupId && _groupId.length >0) {
        param[@"groupID"] = _groupId;
    }
    
    if (self.dataProvider.groupInfo) {
        param[@"groupInfo"] = self.dataProvider.groupInfo;
    }
    
    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                                             key:TUICore_TUIContactObjectFactory_GetGroupMemberVCMethod
                                           param:param];
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        [self.navigationController pushViewController:vc animated:YES];
    }
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
          [TUICore notifyEvent:TUICore_TUIContactNotify
                        subKey:TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey
                        object:self
                         param:@{TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey_ConversationID : conversationID}];
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

- (UINavigationController *)pushNavigationController {
    return self.navigationController;
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

- (void)didAddMemebers {
    [TUICore notifyEvent:TUICore_TUIContactNotify subKey:TUICore_TUIContactNotify_OnAddMemebersClickSubKey object:self param:nil];
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
