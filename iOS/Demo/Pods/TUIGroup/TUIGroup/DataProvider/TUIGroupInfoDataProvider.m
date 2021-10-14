
#import "TUIGroupInfoDataProvider.h"
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIProfileCardCell.h"
#import "TUIAddCellData.h"
#import "TUICommonTextCell.h"
#import "TUIGroupMemberCellData.h"
#import "TUIGroupMembersCellData.h"
#import "TUICommonSwitchCell.h"
#import "TUIButtonCell.h"
#import "TUIDefine.h"

@interface TUIGroupInfoDataProvider()<V2TIMGroupListener>
@property (nonatomic, strong) TUICommonTextCellData *addOptionData;
@property (nonatomic, strong) TUICommonTextCellData *groupNickNameCellData;
@property (nonatomic, strong) TUIProfileCardCellData *profileCellData;
@property (nonatomic, strong) V2TIMGroupMemberFullInfo *selfInfo;
@property (nonatomic, strong) NSString *groupID;
@end

@implementation TUIGroupInfoDataProvider

- (instancetype)initWithGroupID:(NSString *)groupID {
    self = [super init];
    if (self) {
        self.groupID = groupID;
        [[V2TIMManager sharedInstance] addGroupListener:self];
    }
    return self;
}

#pragma mark V2TIMGroupListener
- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    [self loadData];
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member{
    [self loadData];
}

- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    [self loadData];
}

- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    [self loadData];
}

- (void)loadData
{
    [self getGroupInfo];
}

- (void)getGroupInfo {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupsInfo:@[self.groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        @strongify(self)
        if(groupResultList.count == 1){
            self.groupInfo = groupResultList[0].info;
            [self getGroupMembers];
        }
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
}

- (void)getGroupMembers {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        NSMutableArray *membersData = [NSMutableArray array];
        for (V2TIMGroupMemberFullInfo *fullInfo in memberList) {
            if([fullInfo.userID isEqualToString:[V2TIMManager sharedInstance].getLoginUser]){
                self.selfInfo = fullInfo;
            }
            TUIGroupMemberCellData *data = [[TUIGroupMemberCellData alloc] init];
            data.identifier = fullInfo.userID;
            data.name = fullInfo.userID;
            data.avatarUrl = fullInfo.faceURL;
            if (fullInfo.nameCard.length > 0) {
                data.name = fullInfo.nameCard;
            } else if (fullInfo.friendRemark.length > 0) {
                data.name = fullInfo.friendRemark;
            } else if (fullInfo.nickName.length > 0) {
                data.name = fullInfo.nickName;
            }
            [membersData addObject:data];
        }
        self.membersData = membersData;
        [self setupData];
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
}

- (void)setupData
{
    NSMutableArray *dataList = [NSMutableArray array];
    if (self.groupInfo) {

        NSMutableArray *commonArray = [NSMutableArray array];
        TUIProfileCardCellData *commonData = [[TUIProfileCardCellData alloc] init];
        commonData.avatarImage = DefaultGroupAvatarImage;
        commonData.avatarUrl = [NSURL URLWithString:self.groupInfo.faceURL];
        commonData.name = self.groupInfo.groupName;
        commonData.identifier = self.groupInfo.groupID;
        commonData.signature = self.groupInfo.notification;
    
        if([TUIGroupInfoDataProvider isMeOwner:self.groupInfo] || [self.groupInfo isPrivate]){
            commonData.cselector = @selector(didSelectCommon);
            commonData.showAccessory = YES;
        }
        self.profileCellData = commonData;

        [commonArray addObject:commonData];
        [dataList addObject:commonArray];


        NSMutableArray *memberArray = [NSMutableArray array];
        TUICommonTextCellData *countData = [[TUICommonTextCellData alloc] init];
        countData.key = TUIKitLocalizableString(TUIKitGroupProfileMember);
        countData.value = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupProfileMemberCount), self.groupInfo.memberCount];
        countData.cselector = @selector(didSelectMembers);
        countData.showAccessory = YES;
        [memberArray addObject:countData];

        NSMutableArray *tmpArray = [self getShowMembers:self.membersData];
        TUIGroupMembersCellData *membersData = [[TUIGroupMembersCellData alloc] init];
        membersData.members = tmpArray;
        [memberArray addObject:membersData];
        self.groupMembersCellData = membersData;
        [dataList addObject:memberArray];


        //group info
        NSMutableArray *groupInfoArray = [NSMutableArray array];
        TUICommonTextCellData *typeData = [[TUICommonTextCellData alloc] init];
        typeData.key = TUIKitLocalizableString(TUIKitGroupProfileType);
        typeData.value = [TUIGroupInfoDataProvider getGroupTypeName:self.groupInfo];
        [groupInfoArray addObject:typeData];

        TUICommonTextCellData *addOptionData = [[TUICommonTextCellData alloc] init];
        addOptionData.key = TUIKitLocalizableString(TUIKitGroupProfileJoinType);

        //私有群禁止加入，只能邀请
        if ([self.groupInfo.groupType isEqualToString:@"Work"]) {
            addOptionData.value = TUIKitLocalizableString(TUIKitGroupProfileInviteJoin);
        } else if ([self.groupInfo.groupType isEqualToString:@"Meeting"]) {
            addOptionData.value = TUIKitLocalizableString(TUIKitGroupProfileAutoApproval);
        } else {
            if ([TUIGroupInfoDataProvider isMeOwner:self.groupInfo]) {
                addOptionData.cselector = @selector(didSelectAddOption:);
                addOptionData.showAccessory = YES;
            }
            addOptionData.value = [TUIGroupInfoDataProvider getAddOption:self.groupInfo];
        }
        [groupInfoArray addObject:addOptionData];
        self.addOptionData = addOptionData;
        [dataList addObject:groupInfoArray];

        //personal info
        NSMutableArray *personalArray = [NSMutableArray array];
        TUICommonTextCellData *nickData = [[TUICommonTextCellData alloc] init];
        nickData.key = TUIKitLocalizableString(TUIKitGroupProfileAlias);
        nickData.value = self.selfInfo.nameCard;
        nickData.cselector = @selector(didSelectGroupNick:);
        nickData.showAccessory = YES;
        self.groupNickNameCellData = nickData;
        [personalArray addObject:nickData];
        
        TUICommonSwitchCellData *messageSwitchData = [[TUICommonSwitchCellData alloc] init];
        messageSwitchData.on = (self.groupInfo.recvOpt == V2TIM_NOT_RECEIVE_MESSAGE);
        messageSwitchData.title = TUIKitLocalizableString(TUIKitGroupProfileMessageDoNotDisturb);
        messageSwitchData.cswitchSelector = @selector(didSelectOnNotDisturb:);
        [personalArray addObject:messageSwitchData];

        TUICommonSwitchCellData *switchData = [[TUICommonSwitchCellData alloc] init];
        
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
        @weakify(self)
        [V2TIMManager.sharedInstance getConversation:[NSString stringWithFormat:@"group_%@",self.groupID] succ:^(V2TIMConversation *conv) {
            @strongify(self)
            switchData.on = conv.isPinned;
            self.dataList = dataList;
        } fail:^(int code, NSString *desc) {
            NSLog(@"");
        }];
#else
        if ([[[TUIConversationPin sharedInstance] topConversationList] containsObject:[NSString stringWithFormat:@"group_%@",self.groupID]]) {
            switchData.on = YES;
        }
#endif
        switchData.title = TUIKitLocalizableString(TUIKitGroupProfileStickyOnTop);
        switchData.cswitchSelector = @selector(didSelectOnTop:);
        [personalArray addObject:switchData];

        [dataList addObject:personalArray];

        NSMutableArray *buttonArray = [NSMutableArray array];

        //群删除按钮
        TUIButtonCellData *quitButton = [[TUIButtonCellData alloc] init];
        quitButton.title = TUIKitLocalizableString(TUIKitGroupProfileDeleteAndExit);
        quitButton.style = ButtonRedText;
        quitButton.cbuttonSelector = @selector(didDeleteGroup:);
        [buttonArray addObject:quitButton];

        //群解散按钮
        if ([self.groupInfo canDelete]) {
              TUIButtonCellData *Deletebutton = [[TUIButtonCellData alloc] init];
              Deletebutton.title = TUIKitLocalizableString(TUIKitGroupProfileDissolve);
              Deletebutton.style = ButtonRedText;
              Deletebutton.cbuttonSelector = @selector(didDeleteGroup:);
              [buttonArray addObject:Deletebutton];
        }

        [dataList addObject:buttonArray];
        
        self.dataList = dataList;
    }
}

- (void)didSelectMembers {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMembers)]) {
        [self.delegate didSelectMembers];
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

- (void)didDeleteGroup:(TUIButtonCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteGroup:)]) {
        [self.delegate didDeleteGroup:cell];
    }
}

- (NSMutableArray *)getShowMembers:(NSMutableArray *)members
{
    int maxCount = TGroupMembersCell_Column_Count * TGroupMembersCell_Row_Count;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    NSMutableArray *tmpArray = [NSMutableArray array];

    for (NSInteger i = 0; i < members.count && i < maxCount; ++i) {
        [tmpArray addObject:members[i]];
    }
    if ([self.groupInfo canInviteMember]) {
        TUIGroupMemberCellData *add = [[TUIGroupMemberCellData alloc] init];
        add.avatarImage = [UIImage d_imageNamed:@"add" bundle:TUIGroupBundle];
        add.tag = 1;
        [tmpArray addObject:add];
    }
    if ([self.groupInfo canRemoveMember]) {
        TUIGroupMemberCellData *delete = [[TUIGroupMemberCellData alloc] init];
        delete.avatarImage = [UIImage d_imageNamed:@"delete" bundle:TUIGroupBundle];
        delete.tag = 2;
        [tmpArray addObject:delete];
    }
    return tmpArray;
}

- (void)setGroupAddOpt:(V2TIMGroupAddOpt)opt
{
    @weakify(self)
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.groupAddOpt = opt;
    
    [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
        @strongify(self)
        self.groupInfo.groupAddOpt = opt;
        self.addOptionData.value = [TUIGroupInfoDataProvider getAddOptionWithV2AddOpt:opt];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

- (void)setGroupReceiveMessageOpt:(V2TIMReceiveMessageOpt)opt
{
    [[V2TIMManager sharedInstance] setGroupReceiveMessageOpt:self.groupID opt:opt succ:nil fail:nil];
}

- (void)setGroupName:(NSString *)groupName {
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.groupName = groupName;
    @weakify(self)
    [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
        @strongify(self)
        self.profileCellData.name = groupName;
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
}

- (void)setGroupNotification:(NSString *)notification {
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.notification = notification;
    @weakify(self)
    [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
        @strongify(self)
        self.profileCellData.signature = notification;
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
}

- (void)setGroupMemberNameCard:(NSString *)nameCard {
    NSString *userID = [V2TIMManager sharedInstance].getLoginUser;
    V2TIMGroupMemberFullInfo *info = [[V2TIMGroupMemberFullInfo alloc] init];
    info.userID = userID;
    info.nameCard = nameCard;
    @weakify(self)
    [[V2TIMManager sharedInstance] setGroupMemberInfo:self.groupID info:info succ:^{
        @strongify(self)
        self.groupNickNameCellData.value = nameCard;
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
}

- (void)dismissGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [[V2TIMManager sharedInstance] dismissGroup:self.groupID succ:succ fail:fail];
}

- (void)quitGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [[V2TIMManager sharedInstance] quitGroup:self.groupID succ:succ fail:fail];
}

+ (NSString *)getGroupTypeName:(V2TIMGroupInfo *)groupInfo {

    if (groupInfo.groupType) {
        if([groupInfo.groupType isEqualToString:@"Work"]){
            return TUIKitLocalizableString(TUIKitWorkGroup); // @"讨论组";
        }
        else if([groupInfo.groupType isEqualToString:@"Public"]){
            return TUIKitLocalizableString(TUIKitPublicGroup); // @"公开群";
        }
        else if([groupInfo.groupType isEqualToString:@"Meeting"]){
            return TUIKitLocalizableString(TUIKitChatRoom); // @"聊天室";
        }
    }

    return @"";
}

/**
 *  获取本群加群方式
 *
 *  @return 根据群组设置，返回“禁止加入”/“管理员审批”/“自动审批”。
 */
+ (NSString *)getAddOption:(V2TIMGroupInfo *)groupInfo {
    switch (groupInfo.groupAddOpt) {
        case V2TIM_GROUP_ADD_FORBID:
            return TUIKitLocalizableString(TUIKitGroupProfileJoinDisable); // @"禁止加入";
            break;
        case V2TIM_GROUP_ADD_AUTH:
            return TUIKitLocalizableString(TUIKitGroupProfileAdminApprove); // @"管理员审批";
            break;
        case V2TIM_GROUP_ADD_ANY:
            return TUIKitLocalizableString(TUIKitGroupProfileAutoApproval); // @"自动审批";
            break;
        default:
            break;
    }
    return @"";
}

/**
 *  获取本群加群方式
 */
+ (NSString *)getAddOptionWithV2AddOpt:(V2TIMGroupAddOpt)opt {
    switch (opt) {
        case V2TIM_GROUP_ADD_FORBID:
            return TUIKitLocalizableString(TUIKitGroupProfileJoinDisable); // @"禁止加入";
            break;
        case V2TIM_GROUP_ADD_AUTH:
            return TUIKitLocalizableString(TUIKitGroupProfileAdminApprove); // @"管理员审批";
            break;
        case V2TIM_GROUP_ADD_ANY:
            return TUIKitLocalizableString(TUIKitGroupProfileAutoApproval); // @"自动审批";
            break;
        default:
            break;
    }
    return @"";
}

/**
 *  判断当前用户在对与当前 TIMGroupInfo 来说是否是管理。
 *
 *  @return YES：是管理；NO：不是管理
 */
+ (BOOL)isMeOwner:(V2TIMGroupInfo *)groupInfo {
    return [groupInfo.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] || (groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN);
}
@end
