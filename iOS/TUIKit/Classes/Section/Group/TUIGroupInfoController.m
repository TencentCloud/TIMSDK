#import "TUIGroupInfoController.h"
#import "TUIProfileCardCell.h"
#import "TUIGroupMembersCell.h"
#import "TUIGroupMemberCell.h"
#import "TUIButtonCell.h"
#import "TCommonSwitchCell.h"
#import "TUIGroupMemberController.h"
#import "TModifyView.h"
#import "TAddCell.h"
#import "TUILocalStorage.h"
#import "UIImage+TUIKIT.h"
#import "TCommonTextCell.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMGroupInfo+DataProvider.h"
#import "TUIAvatarViewController.h"
#import "UIColor+TUIDarkMode.h"

#define ADD_TAG @"-1"
#define DEL_TAG @"-2"

@interface TUIGroupInfoController () <TModifyViewDelegate, TGroupMembersCellDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *memberData;
@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property V2TIMGroupMemberInfo *selfInfo;
@property TGroupMembersCellData *groupMembersCellData;
@property TCommonTextCellData *groupMembersCountCellData;
@property TCommonTextCellData *addOptionData;
@property TUIProfileCardCellData *profileCellData;
@property TCommonTextCellData *groupNickNameCellData;
@end

@implementation TUIGroupInfoController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self updateData];
}

- (void)setupViews
{
    self.title = TUILocalizableString(TUIKitGroupProfileDetails);
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    //加入此行，会让反馈更加灵敏
    self.tableView.delaysContentTouches = NO;
}

- (void)updateData
{
    @weakify(self)
    _memberData = [NSMutableArray array];

    [[V2TIMManager sharedInstance] getGroupsInfo:@[_groupId] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        @strongify(self)
        if(groupResultList.count == 1){
            self.groupInfo = groupResultList[0].info;
            [self setupData];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupId filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        for (V2TIMGroupMemberFullInfo *fullInfo in memberList) {
            if([fullInfo.userID isEqualToString:[V2TIMManager sharedInstance].getLoginUser]){
                self.selfInfo = fullInfo;
            }
            TGroupMemberCellData *data = [[TGroupMemberCellData alloc] init];
            data.identifier = fullInfo.userID;
            data.name = fullInfo.userID;
            if (fullInfo.nameCard.length > 0) {
                data.name = fullInfo.nameCard;
            } else if (fullInfo.friendRemark.length > 0) {
                data.name = fullInfo.friendRemark;
            } else if (fullInfo.nickName.length > 0) {
                data.name = fullInfo.nickName;
            }
            [self.memberData addObject:data];
        }
        [self setupData];;
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)setupData
{
    _data = [NSMutableArray array];
    if (self.groupInfo) {

        NSMutableArray *commonArray = [NSMutableArray array];
        TUIProfileCardCellData *commonData = [[TUIProfileCardCellData alloc] init];
        commonData.avatarImage = DefaultGroupAvatarImage;
        commonData.avatarUrl = [NSURL URLWithString:self.groupInfo.faceURL];
        commonData.name = self.groupInfo.groupName;
        commonData.identifier = self.groupInfo.groupID;
        commonData.signature = self.groupInfo.notification;
    
        if([self.groupInfo isMeOwner] || [self.groupInfo isPrivate]){
            commonData.cselector = @selector(didSelectCommon);
            commonData.showAccessory = YES;
        }
        self.profileCellData = commonData;

        [commonArray addObject:commonData];
        [self.data addObject:commonArray];


        NSMutableArray *memberArray = [NSMutableArray array];
        TCommonTextCellData *countData = [[TCommonTextCellData alloc] init];
        countData.key = TUILocalizableString(TUIKitGroupProfileMember);
        countData.value = [NSString stringWithFormat:TUILocalizableString(TUIKitGroupProfileMemberCount), self.groupInfo.memberCount];
        countData.cselector = @selector(didSelectMembers);
        countData.showAccessory = YES;
        self.groupMembersCountCellData = countData;
        [memberArray addObject:countData];

        NSMutableArray *tmpArray = [self getShowMembers:self.memberData];
        TGroupMembersCellData *membersData = [[TGroupMembersCellData alloc] init];
        membersData.members = tmpArray;
        [memberArray addObject:membersData];
        self.groupMembersCellData = membersData;
        [self.data addObject:memberArray];


        //group info
        NSMutableArray *groupInfoArray = [NSMutableArray array];
        TCommonTextCellData *typeData = [[TCommonTextCellData alloc] init];
        typeData.key = TUILocalizableString(TUIKitGroupProfileType);
        typeData.value = [self.groupInfo showGroupType];
        [groupInfoArray addObject:typeData];

        TCommonTextCellData *addOptionData = [[TCommonTextCellData alloc] init];
        addOptionData.key = TUILocalizableString(TUIKitGroupProfileJoinType);

        //私有群禁止加入，只能邀请
        if ([self.groupInfo.groupType isEqualToString:@"Work"]) {
            addOptionData.value = TUILocalizableString(TUIKitGroupProfileInviteJoin);
        } else if ([self.groupInfo.groupType isEqualToString:@"Meeting"]) {
            addOptionData.value = TUILocalizableString(TUIKitGroupProfileAutoApproval);
        } else {
            if ([self.groupInfo isMeOwner]) {
                addOptionData.cselector = @selector(didSelectAddOption:);
                addOptionData.showAccessory = YES;
            }
            addOptionData.value = [self.groupInfo showAddOption];
        }
        [groupInfoArray addObject:addOptionData];
        self.addOptionData = addOptionData;
        [self.data addObject:groupInfoArray];

        //personal info
        NSMutableArray *personalArray = [NSMutableArray array];
        TCommonTextCellData *nickData = [[TCommonTextCellData alloc] init];
        nickData.key = TUILocalizableString(TUIKitGroupProfileAlias);
        nickData.value = self.selfInfo.nameCard;
        nickData.cselector = @selector(didSelectGroupNick:);
        nickData.showAccessory = YES;
        self.groupNickNameCellData = nickData;
        [personalArray addObject:nickData];
        
        TCommonSwitchCellData *messageSwitchData = [[TCommonSwitchCellData alloc] init];
        messageSwitchData.on = (self.groupInfo.recvOpt == V2TIM_NOT_RECEIVE_MESSAGE);
        messageSwitchData.title = TUILocalizableString(TUIKitGroupProfileMessageDoNotDisturb);
        messageSwitchData.cswitchSelector = @selector(didSelectOnNotDisturb:);
        [personalArray addObject:messageSwitchData];

        TCommonSwitchCellData *switchData = [[TCommonSwitchCellData alloc] init];
        
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
        __weak typeof(self) weakSelf = self;
        [V2TIMManager.sharedInstance getConversation:[NSString stringWithFormat:@"group_%@",self.groupId] succ:^(V2TIMConversation *conv) {
            switchData.on = conv.isPinned;
            [weakSelf.tableView reloadData];
        } fail:^(int code, NSString *desc) {
            NSLog(@"");
        }];
#else
        if ([[[TUILocalStorage sharedInstance] topConversationList] containsObject:[NSString stringWithFormat:@"group_%@",self.groupId]]) {
            switchData.on = YES;
        }
#endif
        switchData.title = TUILocalizableString(TUIKitGroupProfileStickyOnTop);
        switchData.cswitchSelector = @selector(didSelectOnTop:);
        [personalArray addObject:switchData];

        [self.data addObject:personalArray];

        NSMutableArray *buttonArray = [NSMutableArray array];

        //群删除按钮
        TUIButtonCellData *quitButton = [[TUIButtonCellData alloc] init];
        quitButton.title = TUILocalizableString(TUIKitGroupProfileDeleteAndExit);
        quitButton.style = ButtonRedText;
        quitButton.cbuttonSelector = @selector(deleteGroup:);
        [buttonArray addObject:quitButton];

        //群解散按钮
        if ([self.groupInfo canDelete]) {
              TUIButtonCellData *Deletebutton = [[TUIButtonCellData alloc] init];
              Deletebutton.title = TUILocalizableString(TUIKitGroupProfileDissolve);
              Deletebutton.style = ButtonRedText;
              Deletebutton.cbuttonSelector = @selector(deleteGroup:);
              [buttonArray addObject:Deletebutton];
        }

        [self.data addObject:buttonArray];

        [self.tableView reloadData];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        return [(TUIProfileCardCellData *)data heightOfWidth:Screen_Width];
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        return [TUIGroupMembersCell getHeight:(TGroupMembersCellData *)data];
    }
    else if([data isKindOfClass:[TUIButtonCellData class]]){
        return [(TUIButtonCellData *)data heightOfWidth:Screen_Width];;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupCommonCell_ReuseId];
        if(!cell){
            cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupCommonCell_ReuseId];
        }
        //设置 profileCard 的委托
        cell.delegate = self;
        [cell fillWithData:(TUIProfileCardCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TCommonTextCellData class]]){
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:TKeyValueCell_ReuseId];
        if(!cell){
            cell = [[TCommonTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TKeyValueCell_ReuseId];
        }
        [cell fillWithData:(TCommonTextCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        TUIGroupMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupMembersCell_ReuseId];
        if(!cell){
            cell = [[TUIGroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupMembersCell_ReuseId];
            cell.delegate = self;
        }
        [cell setData:(TGroupMembersCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TCommonSwitchCellData class]]){
        TCommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:TSwitchCell_ReuseId];
        if(!cell){
            cell = [[TCommonSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSwitchCell_ReuseId];
        }
        [cell fillWithData:(TCommonSwitchCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TUIButtonCellData class]]){
        TUIButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if(!cell){
            cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
        }
        [cell fillWithData:(TUIButtonCellData *)data];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)leftBarButtonClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectMembers
{
    if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didSelectMembersInGroup:)]){
        [_delegate groupInfoController:self didSelectMembersInGroup:_groupId];
    }
}

- (void)didSelectAddOption:(UITableViewCell *)cell
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUILocalizableString(TUIKitGroupProfileJoinType) preferredStyle:UIAlertControllerStyleActionSheet];

    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileJoinDisable) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setGroupAddOpt:V2TIM_GROUP_ADD_FORBID];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileAdminApprove) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setGroupAddOpt:V2TIM_GROUP_ADD_AUTH];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileAutoApproval) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setGroupAddOpt:V2TIM_GROUP_ADD_ANY];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)setGroupAddOpt:(V2TIMGroupAddOpt)opt
{
    @weakify(self)
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = _groupId;
    info.groupAddOpt = opt;
    [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
        @strongify(self)
        self.addOptionData.value = [self.groupInfo showAddOption:opt];
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)didSelectGroupNick:(TCommonTextCell *)cell
{
    TModifyViewData *data = [[TModifyViewData alloc] init];
    data.title = TUILocalizableString(TUIKitGroupProfileEditAlias);
    TModifyView *modify = [[TModifyView alloc] init];
    modify.tag = 2;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectCommon
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([self.groupInfo isPrivate] || [self.groupInfo isMeOwner]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileEditGroupName) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            TModifyViewData *data = [[TModifyViewData alloc] init];
            data.title = TUILocalizableString(TUIKitGroupProfileEditGroupName);
            TModifyView *modify = [[TModifyView alloc] init];
            modify.tag = 0;
            modify.delegate = self;
            [modify setData:data];
            [modify showInWindow:self.view.window];

        }]];
    }
    if ([self.groupInfo isMeOwner]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileEditAnnouncement) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            TModifyViewData *data = [[TModifyViewData alloc] init];
            data.title = TUILocalizableString(TUIKitGroupProfileEditAnnouncement);
            TModifyView *modify = [[TModifyView alloc] init];
            modify.tag = 1;
            modify.delegate = self;
            [modify setData:data];
            [modify showInWindow:self.view.window];
        }]];
    }

    if ([self.delegate respondsToSelector:@selector(groupInfoController:didSelectChangeAvatar:)]) {
        if ([self.groupInfo isMeOwner]) {
            [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileEditAvatar) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.delegate groupInfoController:self didSelectChangeAvatar:self.groupId];
            }]];
        }
    }
    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectOnNotDisturb:(TCommonSwitchCell *)cell
{
    V2TIMReceiveMessageOpt opt;
    if (cell.switcher.on) {
        opt = V2TIM_NOT_RECEIVE_MESSAGE;
    } else {
        opt = V2TIM_RECEIVE_MESSAGE;
    }
    [[V2TIMManager sharedInstance] setGroupReceiveMessageOpt:self.groupId opt:opt succ:nil fail:nil];
}

- (void)didSelectOnTop:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:[NSString stringWithFormat:@"group_%@",_groupId] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 设置失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [THelper makeToast:errorMessage];
        }];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",_groupId] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 设置失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [THelper makeToast:errorMessage];
        }];
    }
}


- (void)modifyView:(TModifyView *)modifyView didModiyContent:(NSString *)content
{
    @weakify(self)
    if(modifyView.tag == 0){
        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupID = _groupId;
        info.groupName = content;
        [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
            @strongify(self)
            self.profileCellData.name = content;
        } fail:^(int code, NSString *msg) {
            [THelper makeToastError:code msg:msg];
        }];
    }
    else if(modifyView.tag == 1){
        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupID = _groupId;
        info.notification = content;
        [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
            @strongify(self)
            self.profileCellData.signature = content;
        } fail:^(int code, NSString *msg) {
            [THelper makeToastError:code msg:msg];
        }];
    }
    else if(modifyView.tag == 2){
        NSString *user = [V2TIMManager sharedInstance].getLoginUser;
        V2TIMGroupMemberFullInfo *info = [[V2TIMGroupMemberFullInfo alloc] init];
        info.userID = user;
        info.nameCard = content;
        [[V2TIMManager sharedInstance] setGroupMemberInfo:_groupId info:info succ:^{
            @strongify(self)
            self.groupNickNameCellData.value = content;
        } fail:^(int code, NSString *msg) {
            [THelper makeToastError:code msg:msg];
        }];
    }
}

- (void)deleteGroup:(TUIButtonCell *)cell
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUILocalizableString(TUIKitGroupProfileDeleteGroupTips) preferredStyle:UIAlertControllerStyleActionSheet];

    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Confirm) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        @weakify(self)
        if ([self.groupInfo canDelete]) {
            [[V2TIMManager sharedInstance] dismissGroup:self.groupId succ:^{
                @strongify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",self.groupId] callback:nil];
                    if(self.delegate && [self.delegate respondsToSelector:@selector(groupInfoController:didDeleteGroup:)]){
                        [self.delegate groupInfoController:self didDeleteGroup:self.groupId];
                    }
                });
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        } else {
            [[V2TIMManager sharedInstance] quitGroup:self.groupId succ:^{
                @strongify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",self.groupId] callback:nil];
                    if(self.delegate && [self.delegate respondsToSelector:@selector(groupInfoController:didQuitGroup:)]){
                        [self.delegate groupInfoController:self didQuitGroup:self.groupId];
                    }
                });
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index
{
    TGroupMemberCellData *mem = self.groupMembersCellData.members[index];
    if(mem.tag == 1){
        //add
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didAddMembersInGroup:members:)]){
            [_delegate groupInfoController:self didAddMembersInGroup:_groupId members:_memberData];
        }
    }
    else if(mem.tag == 2) {
        //delete
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didDeleteMembersInGroup:members:)]){
            [_delegate groupInfoController:self didDeleteMembersInGroup:_groupId members:_memberData];
        }
    }
    else
    {
        // TODO:
    }
}

- (void)addMembers:(NSArray *)members
{
    for (TAddCellData *addMember in members) {
        TGroupMemberCellData *data = [[TGroupMemberCellData alloc] init];
        data.identifier = addMember.identifier;
        data.name = addMember.name;
        [_memberData addObject:data];
    }

    self.groupMembersCountCellData.value = [NSString stringWithFormat:TUILocalizableString(TUIKitGroupProfileMemberCountlu), (unsigned long)_memberData.count];
    self.groupMembersCellData.members = [self getShowMembers:_memberData];

    [self.tableView reloadData];
}

- (void)deleteMembers:(NSArray *)members
{
    NSMutableArray *delArray = [NSMutableArray array];
    for (TAddCellData *delMember in members) {
        for (TGroupMemberCellData *member in _memberData) {
            if([delMember.identifier isEqualToString:member.identifier]){
                [delArray addObject:member];
            }
        }
    }
    [_memberData removeObjectsInArray:delArray];

    self.groupMembersCountCellData.value = [NSString stringWithFormat:TUILocalizableString(TUIKitGroupProfileMemberCountlu), (unsigned long)_memberData.count];
    self.groupMembersCellData.members = [self getShowMembers:_memberData];

    [self.tableView reloadData];
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
        TGroupMemberCellData *add = [[TGroupMemberCellData alloc] init];
        add.avatarImage = [UIImage tk_imageNamed:@"add"];
        add.tag = 1;
        [tmpArray addObject:add];
    }
    if ([self.groupInfo canRemoveMember]) {
        TGroupMemberCellData *delete = [[TGroupMemberCellData alloc] init];
        delete.avatarImage = [UIImage tk_imageNamed:@"delete"];
        delete.tag = 2;
        [tmpArray addObject:delete];
    }
    return tmpArray;
}

/**
 *  点击头像查看大图的委托实现。
 */
-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

@end
