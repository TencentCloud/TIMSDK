//
//  TUIGroupInfoDataProvider_Minimalist.m
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupInfoDataProvider_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUILogin.h>
#import <TIMCommon/TIMGroupInfo+TUIDataProvider.h>
#import <TIMCommon/TUICommonGroupInfoCellData_Minimalist.h>
#import "TUIGroupNoticeCell.h"
#import "TUIGroupProfileCardViewCell_Minimalist.h"
#import "TUIGroupConfig.h"
#import <TUICore/TUICore.h>

@interface TUIGroupInfoDataProvider_Minimalist () <V2TIMGroupListener>
@property(nonatomic, strong) TUICommonTextCellData *addOptionData;
@property(nonatomic, strong) TUICommonTextCellData *inviteOptionData;
@property(nonatomic, strong) TUICommonTextCellData *groupNickNameCellData;
@property(nonatomic, strong, readwrite) TUIProfileCardCellData *profileCellData;
@property(nonatomic, strong) V2TIMGroupMemberFullInfo *selfInfo;
@property(nonatomic, strong) NSString *groupID;
@property(nonatomic, assign) BOOL firstLoadData;
@end

@implementation TUIGroupInfoDataProvider_Minimalist

- (instancetype)initWithGroupID:(NSString *)groupID {
    self = [super init];
    if (self) {
        self.groupID = groupID;
        [[V2TIMManager sharedInstance] addGroupListener:self];
    }
    return self;
}

#pragma mark V2TIMGroupListener
- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    [self loadData];
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member {
    [self loadData];
}

- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    [self loadData];
}

- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    [self loadData];
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray<V2TIMGroupChangeInfo *> *)changeInfoList {
    if (![groupID isEqualToString:self.groupID]) {
        return;
    }

    [self loadData];
}

- (void)loadData {
    self.firstLoadData = YES;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self getGroupInfo:^{
      dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self getGroupMembers:^{
      dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self getSelfInfoInGroup:^{
      dispatch_group_leave(group);
    }];

    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      [weakSelf setupData];
    });
}

- (void)updateGroupInfo:(void (^)(void))callback {
    @weakify(self);
    [[V2TIMManager sharedInstance] getGroupsInfo:@[ self.groupID ]
        succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
          @strongify(self);
          if (groupResultList.count == 1) {
              self.groupInfo = groupResultList[0].info;
              [self setupData];
              if (callback) {
                  callback();
              }
          }
        }
        fail:^(int code, NSString *msg) {
            [self makeToastError:code msg:msg];
        }];
}

- (void)transferGroupOwner:(NSString *)groupID member:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [V2TIMManager.sharedInstance transferGroupOwner:groupID
        member:userID
        succ:^{
          succ();
        }
        fail:^(int code, NSString *desc) {
          fail(code, desc);
        }];
}

- (void)updateGroupAvatar:(NSString *)url succ:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.faceURL = url;
    [V2TIMManager.sharedInstance setGroupInfo:info succ:succ fail:fail];
}

- (void)getGroupInfo:(dispatch_block_t)callback {
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getGroupsInfo:@[ self.groupID ]
        succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
          weakSelf.groupInfo = groupResultList.firstObject.info;
          if (callback) {
              callback();
          }
        }
        fail:^(int code, NSString *msg) {
          if (callback) {
              callback();
          }
            [self makeToastError:code msg:msg];
        }];
}

- (void)getGroupMembers:(dispatch_block_t)callback {
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupID
        filter:V2TIM_GROUP_MEMBER_FILTER_ALL
        nextSeq:0
        succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
          NSMutableArray *membersData = [NSMutableArray array];
          for (V2TIMGroupMemberFullInfo *fullInfo in memberList) {
              TUIGroupMemberCellData_Minimalist *data = [[TUIGroupMemberCellData_Minimalist alloc] init];
              data.identifier = fullInfo.userID;
              data.name = fullInfo.userID;
              data.avatarUrl = fullInfo.faceURL;
              data.showAccessory = YES;
              if (fullInfo.nameCard.length > 0) {
                  data.name = fullInfo.nameCard;
              } else if (fullInfo.friendRemark.length > 0) {
                  data.name = fullInfo.friendRemark;
              } else if (fullInfo.nickName.length > 0) {
                  data.name = fullInfo.nickName;
              }
              if ([fullInfo.userID isEqualToString:[V2TIMManager sharedInstance].getLoginUser]) {
                  weakSelf.selfInfo = fullInfo;
                  continue;
              } else {
                  [membersData addObject:data];
              }
          }
          weakSelf.membersData = membersData;
          if (callback) {
              callback();
          }
        }
        fail:^(int code, NSString *msg) {
            weakSelf.membersData = [NSMutableArray arrayWithCapacity:1];
            [self makeToastError:code msg:msg];
          if (callback) {
              callback();
          }
        }];
}

- (void)getSelfInfoInGroup:(dispatch_block_t)callback {
    NSString *loginUserID = [[V2TIMManager sharedInstance] getLoginUser];
    if (loginUserID.length == 0) {
        if (callback) {
            callback();
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getGroupMembersInfo:self.groupID
        memberList:@[ loginUserID ]
        succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
          for (V2TIMGroupMemberFullInfo *item in memberList) {
              if ([item.userID isEqualToString:loginUserID]) {
                  weakSelf.selfInfo = item;
                  break;
              }
          }
          if (callback) {
              callback();
          }
        }
        fail:^(int code, NSString *desc) {
         [self makeToastError:code msg:desc];
          if (callback) {
              callback();
          }
        }];
}

- (TUIGroupMemberCellData_Minimalist *)creatSelfData {
    TUIGroupMemberCellData_Minimalist *data = [[TUIGroupMemberCellData_Minimalist alloc] init];
    data.identifier = [V2TIMManager sharedInstance].getLoginUser;
    data.avatarUrl = [TUILogin getFaceUrl];

    data.showAccessory = YES;

    data.name = TIMCommonLocalizableString(YOU);
    data.showAccessory = NO;
    if ([TUIGroupInfoDataProvider_Minimalist isMeSuper:self.groupInfo]) {
        data.detailName = TIMCommonLocalizableString(TUIKitMembersRoleSuper);

    } else if ([TUIGroupInfoDataProvider_Minimalist isMeOwner:self.groupInfo]) {
        data.detailName = TIMCommonLocalizableString(TUIKitMembersRoleAdmin);
    } else {
        data.detailName = TIMCommonLocalizableString(TUIKitMembersRoleMember);
    }
    return data;
}


- (void)setupData {
    NSMutableArray *dataList = [NSMutableArray array];
    if (self.groupInfo) {
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_MuteAndPin]) {
            NSMutableArray *avatarAndInfoArray = [NSMutableArray array];
            // Mute Notifications
            TUICommonSwitchCellData *muteData = [[TUICommonSwitchCellData alloc] init];
            if (![self.groupInfo.groupType isEqualToString:GroupType_Meeting]) {
                muteData.on = (self.groupInfo.recvOpt == V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE);
                muteData.title = TIMCommonLocalizableString(TUIKitGroupProfileMessageDoNotDisturb);
                muteData.cswitchSelector = @selector(didSelectOnNotDisturb:);
                [avatarAndInfoArray addObject:muteData];
            }
            // Minimize
            TUICommonSwitchCellData *minimize = [[TUICommonSwitchCellData alloc] init];
            minimize.title = TIMCommonLocalizableString(TUIKitConversationMarkFold);
            minimize.displaySeparatorLine = YES;
            minimize.cswitchSelector = @selector(didSelectOnFoldConversation:);
            if (muteData.on) {
                [avatarAndInfoArray addObject:minimize];
            }
            // Pin
            TUICommonSwitchCellData *pinData = [[TUICommonSwitchCellData alloc] init];
            pinData.title = TIMCommonLocalizableString(TUIKitGroupProfileStickyOnTop);
            [avatarAndInfoArray addObject:pinData];
            [dataList addObject:avatarAndInfoArray];
            
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
            @weakify(self);
            [V2TIMManager.sharedInstance getConversation:[NSString stringWithFormat:@"group_%@", self.groupID]
                                                    succ:^(V2TIMConversation *conv) {
                @strongify(self);
                minimize.on = [self.class isMarkedByFoldType:conv.markList];
                pinData.cswitchSelector = @selector(didSelectOnTop:);
                pinData.on = conv.isPinned;
                if (minimize.on) {
                    pinData.on = NO;
                    pinData.disableChecked = YES;
                }
                self.dataList = dataList;
            }
                                                    fail:^(int code, NSString *desc) {
            }];
#else
            NSString *groupID = [NSString stringWithFormat:@"group_%@", self.groupID];
            if ([[[TUIConversationPin sharedInstance] topConversationList] containsObject:groupID]) {
                pinData.on = YES;
            }
#endif
        }
        
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_Manage]) {
            NSMutableArray *groupInfoArray = [NSMutableArray array];
            
            // Notice
            TUIGroupNoticeCellData *notice = [[TUIGroupNoticeCellData alloc] init];
            notice.name = TIMCommonLocalizableString(TUIKitGroupNotice);
            notice.desc = self.groupInfo.notification ?: TIMCommonLocalizableString(TUIKitGroupNoticeNull);
            notice.target = self;
            notice.selector = @selector(didSelectNotice);
            [groupInfoArray addObject:notice];
            
            // Manage
            {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                param[@"pushVC"] = self.delegate.pushNavigationController;
                param[@"groupID"] = self.groupID.length > 0 ? self.groupID : @"";
                NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:
                                                              TUICore_TUIChatExtension_GroupProfileSettingsItemExtension_MinimalistExtensionID
                                                                                 param:param];
                for (TUIExtensionInfo *info in extensionList) {
                    if (info.text && info.onClicked) {
                        TUICommonTextCellData *manageData = [[TUICommonTextCellData alloc] init];
                        manageData.key = info.text; //TIMCommonLocalizableString(TUIKitGroupProfileManage);
                        manageData.value = @"";
                        manageData.tui_extValueObj = info;
                        manageData.showAccessory = YES;
                        manageData.cselector = @selector(groupProfileExtensionButtonClick:);
                        if (info.weight == 100 ) {
                            if ([TUIGroupInfoDataProvider_Minimalist isMeOwner:self.groupInfo]) {
                                [groupInfoArray addObject:manageData];
                            }
                        }
                        else {
                            [groupInfoArray addObject:manageData];
                        }
                    }
                }
            }
            
            // Group Type
            TUICommonTextCellData *typeData = [[TUICommonTextCellData alloc] init];
            typeData.key = TIMCommonLocalizableString(TUIKitGroupProfileType);
            typeData.value = [TUIGroupInfoDataProvider_Minimalist getGroupTypeName:self.groupInfo];
            [groupInfoArray addObject:typeData];
            
            // Group Joining Method
            TUICommonTextCellData *joinData = [[TUICommonTextCellData alloc] init];
            joinData.key = TIMCommonLocalizableString(TUIKitGroupProfileJoinType);
            if ([TUIGroupInfoDataProvider_Minimalist isMeOwner:self.groupInfo]) {
                joinData.cselector = @selector(didSelectAddOption:);
                joinData.showAccessory = YES;
            }
            joinData.value = [TUIGroupInfoDataProvider_Minimalist getAddOption:self.groupInfo];
            [groupInfoArray addObject:joinData];
            self.addOptionData = joinData;
            
            // Group Inviting Method
            TUICommonTextCellData *inviteOptionData = [[TUICommonTextCellData alloc] init];
            inviteOptionData.key = TIMCommonLocalizableString(TUIKitGroupProfileInviteType);
            if ([TUIGroupInfoDataProvider_Minimalist isMeOwner:self.groupInfo]) {
                inviteOptionData.cselector = @selector(didSelectAddOption:);
                inviteOptionData.showAccessory = YES;
            }
            inviteOptionData.value = [TUIGroupInfoDataProvider_Minimalist getApproveOption:self.groupInfo];
            [groupInfoArray addObject:inviteOptionData];
            self.inviteOptionData = inviteOptionData;
            
            [dataList addObject:groupInfoArray];
        }
        
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_Alias]) {
            // My Alias in Group
            TUICommonTextCellData *aliasData = [[TUICommonTextCellData alloc] init];
            aliasData.key = TIMCommonLocalizableString(TUIKitGroupProfileAlias);
            aliasData.value = self.selfInfo.nameCard;
            aliasData.cselector = @selector(didSelectGroupNick:);
            aliasData.showAccessory = YES;
            self.groupNickNameCellData = aliasData;
            [dataList addObject:@[ aliasData ]];
        }
        
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_Background]) {
            // Background
            TUICommonTextCellData *changeBackgroundImageItem = [[TUICommonTextCellData alloc] init];
            changeBackgroundImageItem.key = TIMCommonLocalizableString(ProfileSetBackgroundImage);
            changeBackgroundImageItem.cselector = @selector(didSelectOnChangeBackgroundImage:);
            changeBackgroundImageItem.showAccessory = YES;
            [dataList addObject:@[ changeBackgroundImageItem ]];
        }
        
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_Members]) {
            // Group Members
            NSMutableArray *memberArray = [NSMutableArray array];
            
            TUICommonTextCellData *countData = [[TUICommonTextCellData alloc] init];
            countData.key = TIMCommonLocalizableString(TUIKitGroupProfileMember);
            countData.value = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitGroupProfileMemberCount), self.groupInfo.memberCount];
            countData.cselector = @selector(didSelectMembers);
            countData.showAccessory = YES;
            [memberArray addObject:countData];
            
            TUIGroupButtonCellData_Minimalist *addMembers = [[TUIGroupButtonCellData_Minimalist alloc] init];
            addMembers.title = TIMCommonLocalizableString(TUIKitAddMembers);
            addMembers.style = ButtonBule;
            addMembers.isInfoPageLeftButton = YES;
            addMembers.cbuttonSelector = @selector(didAddMemebers);
            if ([self.groupInfo canInviteMember]) {
                [memberArray addObject:addMembers];
            }
            
            [memberArray addObject:[self creatSelfData]];
            
            int otherMemberCount = 0;
            for (TUIGroupMemberCellData_Minimalist *memberObj in self.membersData) {
//                memberObj.cselector = @selector(didCurrentMemberAtCell:);
                [memberArray addObject:memberObj];
                otherMemberCount++;
                if (otherMemberCount > 1) {
                    break;
                }
            }
            [dataList addObject:memberArray];
        }
        
        NSMutableArray *buttonArray = [NSMutableArray array];
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_ClearChatHistory]) {
            // Clear Chat History
            TUIGroupButtonCellData_Minimalist *clearHistory = [[TUIGroupButtonCellData_Minimalist alloc] init];
            clearHistory.title = TIMCommonLocalizableString(TUIKitClearAllChatHistory);
            clearHistory.style = ButtonRedText;
            clearHistory.cbuttonSelector = @selector(didClearAllHistory:);
            [buttonArray addObject:clearHistory];
        }
        
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_DeleteAndLeave]) {
            // Delete and Leave
            TUIGroupButtonCellData_Minimalist *quitButton = [[TUIGroupButtonCellData_Minimalist alloc] init];
            quitButton.title = TIMCommonLocalizableString(TUIKitGroupProfileDeleteAndExit);
            quitButton.style = ButtonRedText;
            quitButton.cbuttonSelector = @selector(didDeleteGroup:);
            [buttonArray addObject:quitButton];
        }
        
        if ([self.class isMeSuper:self.groupInfo] && 
            ![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_Transfer]) {
            // Transfer Group
            
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"pushVC"] = self.delegate.pushNavigationController;
            param[@"groupID"] = self.groupID.length > 0 ? self.groupID : @"";
            void (^updateGroupInfoCallback)(void) = ^{
                [self updateGroupInfo:nil];
            };
            param[@"updateGroupInfoCallback"] = updateGroupInfoCallback;
            NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:
                                                          TUICore_TUIChatExtension_GroupProfileBottomItemExtension_MinimalistExtensionID
                                                                             param:param];
            for (TUIExtensionInfo *info in extensionList) {
                if (info.text && info.onClicked) {
                    TUIGroupButtonCellData_Minimalist *transferButton = [[TUIGroupButtonCellData_Minimalist alloc] init];
                    transferButton.title = info.text;//TIMCommonLocalizableString(TUIKitGroupTransferOwner);
                    transferButton.style = ButtonRedText;
                    transferButton.tui_extValueObj = info;
                    transferButton.cbuttonSelector = @selector(groupProfileExtensionButtonClick:);
                    [buttonArray addObject:transferButton];
                }
            }
        }
        
        if ([self.groupInfo canDismissGroup] && 
            ![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_Dismiss]) {
            // Disband Group
            TUIGroupButtonCellData_Minimalist *deletebutton = [[TUIGroupButtonCellData_Minimalist alloc] init];
            deletebutton.title = TIMCommonLocalizableString(TUIKitGroupProfileDissolve);
            deletebutton.style = ButtonRedText;
            deletebutton.cbuttonSelector = @selector(didDeleteGroup:);
            [buttonArray addObject:deletebutton];
        }
        
        if (![[TUIGroupConfig sharedConfig] isItemHiddenInGroupConfig:TUIGroupConfigItem_Report]) {
            // Report
            TUIGroupButtonCellData_Minimalist *reportButton = [[TUIGroupButtonCellData_Minimalist alloc] init];
            reportButton.title = TIMCommonLocalizableString(TUIKitGroupProfileReport);
            reportButton.style = ButtonRedText;
            reportButton.cbuttonSelector = @selector(didReportGroup:);
            [buttonArray addObject:reportButton];
        }
        
        if (buttonArray.count > 1) {
            TUIGroupButtonCellData_Minimalist *lastCellData = [buttonArray lastObject];
            lastCellData.hideSeparatorLine = YES;
            [dataList addObject:buttonArray];
        }
            
        self.dataList = dataList;
    }
}


#pragma mark - TUIGroupInfoDataProviderDelegate_Minimalist
- (void)groupProfileExtensionButtonClick:(TUICommonTextCell *)cell {
    //Implemented through self.delegate, because of TUIButtonCellData cbuttonSelector mechanism
}
- (void)didSelectMembers {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMembers)]) {
        [self.delegate didSelectMembers];
    }
}

- (void)didAddMemebers {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAddMemebers)]) {
        [self.delegate didAddMemebers];
    }
}

- (void)didSelectGroupNick:(TUICommonTextCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectGroupNick:)]) {
        [self.delegate didSelectGroupNick:cell];
    }
}

- (void)didSelectAddOption:(UITableViewCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAddOption:)]) {
        [self.delegate didSelectAddOption:cell];
    }
}

- (void)didSelectCommon {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCommon)]) {
        [self.delegate didSelectCommon];
    }
}

- (void)didSelectOnNotDisturb:(TUICommonSwitchCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectOnNotDisturb:)]) {
        [self.delegate didSelectOnNotDisturb:cell];
    }
}

- (void)didSelectOnTop:(TUICommonSwitchCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectOnTop:)]) {
        [self.delegate didSelectOnTop:cell];
    }
}

- (void)didSelectOnFoldConversation:(TUICommonSwitchCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectOnFoldConversation:)]) {
        [self.delegate didSelectOnFoldConversation:cell];
    }
}

- (void)didSelectOnChangeBackgroundImage:(TUICommonTextCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectOnChangeBackgroundImage:)]) {
        [self.delegate didSelectOnChangeBackgroundImage:cell];
    }
}

- (void)didDeleteGroup:(TUIButtonCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteGroup:)]) {
        [self.delegate didDeleteGroup:cell];
    }
}

- (void)didClearAllHistory:(TUIButtonCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClearAllHistory:)]) {
        [self.delegate didClearAllHistory:cell];
    }
}

- (void)didSelectNotice {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectGroupNotice)]) {
        [self.delegate didSelectGroupNotice];
    }
}

- (void)didReportGroup:(TUIButtonCell *)cell {
    NSURL *url = [NSURL URLWithString:@"https://cloud.tencent.com/act/event/report-platform"];
    [TUITool openLinkWithURL:url];
}

- (NSMutableArray *)getShowMembers:(NSMutableArray *)members {
    int maxCount = TGroupMembersCell_Column_Count * TGroupMembersCell_Row_Count;
    if ([self.groupInfo canInviteMember]) maxCount--;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    NSMutableArray *tmpArray = [NSMutableArray array];

    for (NSInteger i = 0; i < members.count && i < maxCount; ++i) {
        [tmpArray addObject:members[i]];
    }
    if ([self.groupInfo canInviteMember]) {
        TUIGroupMemberCellData_Minimalist *add = [[TUIGroupMemberCellData_Minimalist alloc] init];
        add.avatarImage = TUIContactCommonBundleImage(@"add");
        add.tag = 1;
        [tmpArray addObject:add];
    }
    if ([self.groupInfo canRemoveMember]) {
        TUIGroupMemberCellData_Minimalist *delete = [[TUIGroupMemberCellData_Minimalist alloc] init];
        delete.avatarImage = TUIContactCommonBundleImage(@"delete");
        delete.tag = 2;
        [tmpArray addObject:delete];
    }
    return tmpArray;
}

- (void)setGroupAddOpt:(V2TIMGroupAddOpt)opt {
    @weakify(self);
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.groupAddOpt = opt;

    [[V2TIMManager sharedInstance] setGroupInfo:info
        succ:^{
          @strongify(self);
          self.groupInfo.groupAddOpt = opt;
          self.addOptionData.value = [TUIGroupInfoDataProvider_Minimalist getAddOptionWithV2AddOpt:opt];
        }
        fail:^(int code, NSString *desc) {
            [self makeToastError:code msg:desc];
        }];
}

- (void)setGroupApproveOpt:(V2TIMGroupAddOpt)opt {
    @weakify(self);
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.groupApproveOpt = opt;

    [[V2TIMManager sharedInstance] setGroupInfo:info
        succ:^{
          @strongify(self);
          self.groupInfo.groupApproveOpt = opt;
          self.inviteOptionData.value = [TUIGroupInfoDataProvider_Minimalist getApproveOption:self.groupInfo];
        }
        fail:^(int code, NSString *desc) {
            [self makeToastError:code msg:desc];
        }];
}

- (void)setGroupReceiveMessageOpt:(V2TIMReceiveMessageOpt)opt Succ:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [[V2TIMManager sharedInstance] setGroupReceiveMessageOpt:self.groupID opt:opt succ:succ fail:fail];
}

- (void)setGroupName:(NSString *)groupName succ:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.groupName = groupName;
    @weakify(self);
    [[V2TIMManager sharedInstance] setGroupInfo:info
        succ:^{
          @strongify(self);
          self.profileCellData.name = groupName;
          if (succ) {
              succ();
          }
        }
        fail:^(int code, NSString *msg) {
            [self makeToastError:code msg:msg];
          if (fail) {
              fail(code, msg);
          }
        }];
}

- (void)setGroupNotification:(NSString *)notification {
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.notification = notification;
    @weakify(self);
    [[V2TIMManager sharedInstance] setGroupInfo:info
        succ:^{
          @strongify(self);
          self.profileCellData.signature = notification;
        }
        fail:^(int code, NSString *msg) {
            [self makeToastError:code msg:msg];
        }];
}

- (void)setGroupMemberNameCard:(NSString *)nameCard {
    NSString *userID = [V2TIMManager sharedInstance].getLoginUser;
    V2TIMGroupMemberFullInfo *info = [[V2TIMGroupMemberFullInfo alloc] init];
    info.userID = userID;
    info.nameCard = nameCard;
    @weakify(self);
    [[V2TIMManager sharedInstance] setGroupMemberInfo:self.groupID
        info:info
        succ:^{
          @strongify(self);
          self.groupNickNameCellData.value = nameCard;
          self.selfInfo.nameCard = nameCard;
        }
        fail:^(int code, NSString *msg) {
            [self makeToastError:code msg:msg];
        }];
}

- (void)dismissGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [[V2TIMManager sharedInstance] dismissGroup:self.groupID succ:succ fail:fail];
}

- (void)quitGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [[V2TIMManager sharedInstance] quitGroup:self.groupID succ:succ fail:fail];
}

- (void)clearAllHistory:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [V2TIMManager.sharedInstance clearGroupHistoryMessage:self.groupID succ:succ fail:fail];
}

- (void)makeToastError:(NSInteger)code msg:(NSString *)msg {
    if (!self.firstLoadData) {
        [TUITool makeToastError:code msg:msg];
    }
}
+ (NSString *)getGroupTypeName:(V2TIMGroupInfo *)groupInfo {
    if (groupInfo.groupType) {
        if ([groupInfo.groupType isEqualToString:@"Work"]) {
            return TIMCommonLocalizableString(TUIKitWorkGroup);
        } else if ([groupInfo.groupType isEqualToString:@"Public"]) {
            return TIMCommonLocalizableString(TUIKitPublicGroup);
        } else if ([groupInfo.groupType isEqualToString:@"Meeting"]) {
            return TIMCommonLocalizableString(TUIKitChatRoom);
        } else if ([groupInfo.groupType isEqualToString:@"Community"]) {
            return TIMCommonLocalizableString(TUIKitCommunity);
        }
    }

    return @"";
}

+ (NSString *)getAddOption:(V2TIMGroupInfo *)groupInfo {
    switch (groupInfo.groupAddOpt) {
        case V2TIM_GROUP_ADD_FORBID:
            return TIMCommonLocalizableString(TUIKitGroupProfileJoinDisable);
            break;
        case V2TIM_GROUP_ADD_AUTH:
            return TIMCommonLocalizableString(TUIKitGroupProfileAdminApprove);
            break;
        case V2TIM_GROUP_ADD_ANY:
            return TIMCommonLocalizableString(TUIKitGroupProfileAutoApproval);
            break;
        default:
            break;
    }
    return @"";
}

+ (NSString *)getAddOptionWithV2AddOpt:(V2TIMGroupAddOpt)opt {
    switch (opt) {
        case V2TIM_GROUP_ADD_FORBID:
            return TIMCommonLocalizableString(TUIKitGroupProfileJoinDisable);
            break;
        case V2TIM_GROUP_ADD_AUTH:
            return TIMCommonLocalizableString(TUIKitGroupProfileAdminApprove);
            break;
        case V2TIM_GROUP_ADD_ANY:
            return TIMCommonLocalizableString(TUIKitGroupProfileAutoApproval);
            break;
        default:
            break;
    }
    return @"";
}

+ (NSString *)getApproveOption:(V2TIMGroupInfo *)groupInfo {
    switch (groupInfo.groupApproveOpt) {
        case V2TIM_GROUP_ADD_FORBID:
            return TIMCommonLocalizableString(TUIKitGroupProfileInviteDisable);
            break;
        case V2TIM_GROUP_ADD_AUTH:
            return TIMCommonLocalizableString(TUIKitGroupProfileAdminApprove);
            break;
        case V2TIM_GROUP_ADD_ANY:
            return TIMCommonLocalizableString(TUIKitGroupProfileAutoApproval);
            break;
        default:
            break;
    }
    return @"";
}

+ (BOOL)isMarkedByFoldType:(NSArray *)markList {
    for (NSNumber *num in markList) {
        if (num.unsignedLongValue == V2TIM_CONVERSATION_MARK_TYPE_FOLD) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isMarkedByHideType:(NSArray *)markList {
    for (NSNumber *num in markList) {
        if (num.unsignedLongValue == V2TIM_CONVERSATION_MARK_TYPE_HIDE) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isMeOwner:(V2TIMGroupInfo *)groupInfo {
    return [groupInfo.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] || (groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN);
}

+ (BOOL)isMeSuper:(V2TIMGroupInfo *)groupInfo {
    return [groupInfo.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] && (groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_SUPER);
}
@end
