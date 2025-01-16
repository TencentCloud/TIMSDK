
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIGroupInfoController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMGroupInfo+TUIDataProvider.h>
#import "TUIGroupInfoDataProvider.h"
#import <TIMCommon/TUICommonGroupInfoCellData.h>
#import "TUIGroupNoticeCell.h"
#import "TUIGroupNoticeController.h"
#define ADD_TAG @"-1"
#define DEL_TAG @"-2"

@interface TUIGroupInfoController () <TUIModifyViewDelegate,TUIProfileCardDelegate, TUIGroupInfoDataProviderDelegate>
@property(nonatomic, strong) TUIGroupInfoDataProvider *dataProvider;
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UIViewController *showContactSelectVC;
@end

@implementation TUIGroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    self.dataProvider = [[TUIGroupInfoDataProvider alloc] initWithGroupID:self.groupId];
    self.dataProvider.delegate = self;
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
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    self.tableView.delaysContentTouches = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
}

- (void)updateData {
    [self.dataProvider loadData];
}

- (void)updateGroupInfo {
    [self.dataProvider updateGroupInfo];
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
    if ([data isKindOfClass:[TUIProfileCardCellData class]]) {
        return [(TUIProfileCardCellData *)data heightOfWidth:Screen_Width];
    } else if ([data isKindOfClass:[TUIGroupMembersCellData class]]) {
        return [(TUIGroupMembersCellData *)data heightOfWidth:Screen_Width];
    } else if ([data isKindOfClass:[TUIButtonCellData class]]) {
        return [(TUIButtonCellData *)data heightOfWidth:Screen_Width];
    } else if ([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        return [(TUICommonSwitchCellData *)data heightOfWidth:Screen_Width];
    } else if ([data isKindOfClass:TUIGroupNoticeCellData.class]) {
        return 72.0;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = self.dataProvider.dataList[indexPath.section];
    NSObject *data = array[indexPath.row];
    if ([data isKindOfClass:[TUIProfileCardCellData class]]) {
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupCommonCell_ReuseId];
        if (!cell) {
            cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupCommonCell_ReuseId];
        }
        cell.delegate = self;
        [cell fillWithData:(TUIProfileCardCellData *)data];
        return cell;
    } else if ([data isKindOfClass:[TUICommonTextCellData class]]) {
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:TKeyValueCell_ReuseId];
        if (!cell) {
            cell = [[TUICommonTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TKeyValueCell_ReuseId];
        }
        [cell fillWithData:(TUICommonTextCellData *)data];
        return cell;
    } else if ([data isKindOfClass:[TUIGroupMembersCellData class]]) {
        TUICommonTableViewCell *cell = [[TUICommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupMembersCell_ReuseId];
        NSDictionary *param = @{
            @"data": data ,
            @"pushVC": self.navigationController,
            @"groupID": self.groupId ? self.groupId : @"",
            @"membersData": self.dataProvider.membersData ,
            @"groupMembersCellData": self.dataProvider.groupMembersCellData,
        };
        [TUICore raiseExtension:TUICore_TUIChatExtension_GroupProfileMemberListExtension_ClassicExtensionID
                      parentView:cell
                          param:param];
        return cell;
    } else if ([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        TUICommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:TSwitchCell_ReuseId];
        if (!cell) {
            cell = [[TUICommonSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSwitchCell_ReuseId];
        }
        [cell fillWithData:(TUICommonSwitchCellData *)data];
        return cell;
    } else if ([data isKindOfClass:[TUIButtonCellData class]]) {
        TUIButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if (!cell) {
            cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
        }
        [cell fillWithData:(TUIButtonCellData *)data];
        return cell;
    } else if ([data isKindOfClass:TUIGroupNoticeCellData.class]) {
        TUIGroupNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIGroupNoticeCell"];
        if (cell == nil) {
            cell = [[TUIGroupNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TUIGroupNoticeCell"];
        }
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
- (void)didSelectMembers {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (_groupId && _groupId.length >0) {
        param[@"groupID"] = _groupId;
    }
    
    if (self.dataProvider.groupInfo) {
        param[@"groupInfo"] = self.dataProvider.groupInfo;
    }
    
    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory
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

    __weak typeof(self) weakSelf = self;
    if ([self.dataProvider.groupInfo isPrivate] || [TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileEditGroupName)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        TUIModifyViewData *data = [[TUIModifyViewData alloc] init];
                                                        data.title = TIMCommonLocalizableString(TUIKitGroupProfileEditGroupName);
                                                        data.content = weakSelf.dataProvider.groupInfo.groupName;
                                                        data.desc = TIMCommonLocalizableString(TUIKitGroupProfileEditGroupName);
                                                        TUIModifyView *modify = [[TUIModifyView alloc] init];
                                                        modify.tag = 0;
                                                        modify.delegate = weakSelf;
                                                        [modify setData:data];
                                                        [modify showInWindow:weakSelf.view.window];
                                                      }]];
    }
    if ([TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileEditAnnouncement)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        TUIModifyViewData *data = [[TUIModifyViewData alloc] init];
                                                        data.title = TIMCommonLocalizableString(TUIKitGroupProfileEditAnnouncement);
                                                        TUIModifyView *modify = [[TUIModifyView alloc] init];
                                                        modify.tag = 1;
                                                        modify.delegate = weakSelf;
                                                        [modify setData:data];
                                                        [modify showInWindow:weakSelf.view.window];
                                                      }]];
    }

    if ([TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        @weakify(self);
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitGroupProfileEditAvatar)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        @strongify(self);
                                                        TUISelectAvatarController *vc = [[TUISelectAvatarController alloc] init];
                                                        vc.selectAvatarType = TUISelectAvatarTypeGroupAvatar;
                                                        vc.profilFaceURL = self.dataProvider.groupInfo.faceURL;
                                                        [self.navigationController pushViewController:vc animated:YES];
                                                        vc.selectCallBack = ^(NSString *_Nonnull urlStr) {
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
                                                      }]];
    }

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
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
                                            succ : ^(NSArray<V2TIMConversationOperationResult *> *result) {
                          cell.switchData.on = enableMark;
                          [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@", self.groupId]
                                                                            callback:^(BOOL success, NSString *_Nonnull errorMessage) {
                              @strongify(self);
                              [self updateGroupInfo];
                          }];
    } fail:nil];

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
    TUIGroupNoticeController *vc = [[TUIGroupNoticeController alloc] init];
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

#pragma mark TUIModifyViewDelegate

- (void)modifyView:(TUIModifyView *)modifyView didModiyContent:(NSString *)content {
    if (modifyView.tag == 0) {
        [self.dataProvider setGroupName:content];
    } else if (modifyView.tag == 1) {
        [self.dataProvider setGroupNotification:content];
    } else if (modifyView.tag == 2) {
        [self.dataProvider setGroupMemberNameCard:content];
    }
}

@end

@interface IUGroupView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUGroupView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
