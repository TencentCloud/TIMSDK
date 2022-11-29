#import "TUIGroupInfoController.h"
#import "TUIProfileCardCell.h"
#import "TUIGroupMembersCell.h"
#import "TUIGroupMemberCell.h"
#import "TUICommonSwitchCell.h"
#import "TUIGroupMemberController.h"
#import "TUIModifyView.h"
#import "TUIAddCell.h"
#import "TUICommonTextCell.h"
#import "TUIDefine.h"
#import "TUICore.h"
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGroupInfoDataProvider.h"
#import "TUIAvatarViewController.h"
#import "TUIGroupManageController.h"
#import "TUIThemeManager.h"
#import "TUIGroupNoticeCell.h"
#import "TUIGroupNoticeController.h"
#import "TUISelectGroupMemberViewController.h"
#import "TUISelectAvatarController.h"
#import "TUILogin.h"

#define ADD_TAG @"-1"
#define DEL_TAG @"-2"

@interface TUIGroupInfoController () <TModifyViewDelegate, TUIGroupMembersCellDelegate, TUIProfileCardDelegate, TUIGroupInfoDataProviderDelegate, TUINotificationProtocol>
@property(nonatomic, strong) TUIGroupInfoDataProvider *dataProvider;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UIViewController *showContactSelectVC;
@property NSInteger tag;
@end

@implementation TUIGroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    self.dataProvider = [[TUIGroupInfoDataProvider alloc] initWithGroupID:self.groupId];
    self.dataProvider.delegate = self;
    [self.dataProvider loadData];
    
    @weakify(self)
    [RACObserve(self.dataProvider, dataList) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
    
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    [_titleView setTitle:TUIKitLocalizableString(ProfileDetails)];
    
    [TUICore registerEvent:TUICore_TUIContactNotify subKey:TUICore_TUIContactNotify_SelectedContactsSubKey object:self];
}

- (void)setupViews {
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
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


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = self.dataProvider.dataList[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = self.dataProvider.dataList[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        return [(TUIProfileCardCellData *)data heightOfWidth:Screen_Width];
    }
    else if([data isKindOfClass:[TUIGroupMembersCellData class]]){
        return [TUIGroupMembersCell getHeight:(TUIGroupMembersCellData *)data];
    }
    else if([data isKindOfClass:[TUIButtonCellData class]]){
        return [(TUIButtonCellData *)data heightOfWidth:Screen_Width];;
    }
    else if ([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        return [(TUICommonSwitchCellData *)data heightOfWidth:Screen_Width];;
    }
    else if ([data isKindOfClass:TUIGroupNoticeCellData.class]) {
        return 72.0;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = self.dataProvider.dataList[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupCommonCell_ReuseId];
        if(!cell){
            cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupCommonCell_ReuseId];
        }
        cell.delegate = self;
        [cell fillWithData:(TUIProfileCardCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TUICommonTextCellData class]]){
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:TKeyValueCell_ReuseId];
        if(!cell){
            cell = [[TUICommonTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TKeyValueCell_ReuseId];
        }
        [cell fillWithData:(TUICommonTextCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TUIGroupMembersCellData class]]){
        TUIGroupMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupMembersCell_ReuseId];
        if(!cell){
            cell = [[TUIGroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupMembersCell_ReuseId];
            cell.delegate = self;
        }
        [cell setData:(TUIGroupMembersCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TUICommonSwitchCellData class]]){
        TUICommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:TSwitchCell_ReuseId];
        if(!cell){
            cell = [[TUICommonSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSwitchCell_ReuseId];
        }
        [cell fillWithData:(TUICommonSwitchCellData *)data];
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
    else if([data isKindOfClass:TUIGroupNoticeCellData.class]) {
        TUIGroupNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIGroupNoticeCell"];
        if (cell == nil) {
            cell = [[TUIGroupNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TUIGroupNoticeCell"];
        }
        cell.cellData = data;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)leftBarButtonClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TUIGroupInfoDataProviderDelegate

- (void)didSelectMembers
{
    TUIGroupMemberController *membersController = [[TUIGroupMemberController alloc] init];
    membersController.groupId = _groupId;
    membersController.groupInfo = self.dataProvider.groupInfo;
    [self.navigationController pushViewController:membersController animated:YES];
}

- (void)didSelectAddOption:(UITableViewCell *)cell
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUIKitLocalizableString(TUIKitGroupProfileJoinType) preferredStyle:UIAlertControllerStyleActionSheet];

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileJoinDisable) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.dataProvider setGroupAddOpt:V2TIM_GROUP_ADD_FORBID];
    }]];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileAdminApprove) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.dataProvider setGroupAddOpt:V2TIM_GROUP_ADD_AUTH];
    }]];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileAutoApproval) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.dataProvider setGroupAddOpt:V2TIM_GROUP_ADD_ANY];
    }]];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectGroupNick:(TUICommonTextCell *)cell
{
    TModifyViewData *data = [[TModifyViewData alloc] init];
    data.title = TUIKitLocalizableString(TUIKitGroupProfileEditAlias);
    data.content = self.dataProvider.selfInfo.nameCard;
    data.desc = TUIKitLocalizableString(TUIKitGroupProfileEditAliasDesc);
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 2;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectCommon
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    __weak typeof(self) weakSelf = self;
    if ([self.dataProvider.groupInfo isPrivate] || [TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileEditGroupName) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            TModifyViewData *data = [[TModifyViewData alloc] init];
            data.title = TUIKitLocalizableString(TUIKitGroupProfileEditGroupName);
            data.content = weakSelf.dataProvider.groupInfo.groupName;
            data.desc = TUIKitLocalizableString(TUIKitGroupProfileEditGroupName);
            TUIModifyView *modify = [[TUIModifyView alloc] init];
            modify.tag = 0;
            modify.delegate = weakSelf;
            [modify setData:data];
            [modify showInWindow:weakSelf.view.window];

        }]];
    }
    if ([TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileEditAnnouncement) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            TModifyViewData *data = [[TModifyViewData alloc] init];
            data.title = TUIKitLocalizableString(TUIKitGroupProfileEditAnnouncement);
            TUIModifyView *modify = [[TUIModifyView alloc] init];
            modify.tag = 1;
            modify.delegate = weakSelf;
            [modify setData:data];
            [modify showInWindow:weakSelf.view.window];
        }]];
    }

    if ([TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        @weakify(self)
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileEditAvatar) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self)
            TUISelectAvatarController * vc = [[TUISelectAvatarController alloc] init];
            vc.selectAvatarType = TUISelectAvatarTypeGroupAvatar;
            vc.profilFaceURL = self.dataProvider.groupInfo.faceURL;
            [self.navigationController pushViewController:vc animated:YES];
            vc.selectCallBack = ^(NSString * _Nonnull urlStr) {
                if (urlStr.length > 0) {
                    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
                    info.groupID = self.groupId;
                    info.faceURL = urlStr;
                    [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
                        [self updateGroupInfo];
                    } fail:^(int code, NSString *msg) {
                        [TUITool makeToastError:code msg:msg];
                    }];
                }
            };
        }]];
    }
    
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectOnNotDisturb:(TUICommonSwitchCell *)cell
{
    V2TIMReceiveMessageOpt opt;
    if (cell.switcher.on) {
        opt = V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
    } else {
        opt = V2TIM_RECEIVE_MESSAGE;
    }
    @weakify(self)
    [V2TIMManager.sharedInstance markConversation:@[[NSString stringWithFormat:@"group_%@",self.groupId]] markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD) enableMark:NO succ:nil fail:nil];
    
    [self.dataProvider setGroupReceiveMessageOpt:opt Succ:^{
        @strongify(self)
        [self updateGroupInfo];
    } fail:^(int code, NSString *desc) {}];
    
}

- (void)didSelectOnTop:(TUICommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUIConversationPin sharedInstance] addTopConversation:[NSString stringWithFormat:@"group_%@",_groupId] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            cell.switcher.on = !cell.switcher.isOn;
            [TUITool makeToast:errorMessage];
        }];
    } else {
        [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",_groupId] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            cell.switcher.on = !cell.switcher.isOn;
            [TUITool makeToast:errorMessage];
        }];
    }
}

- (void)didDeleteGroup:(TUIButtonCell *)cell
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUIKitLocalizableString(TUIKitGroupProfileDeleteGroupTips) preferredStyle:UIAlertControllerStyleActionSheet];

    @weakify(self)
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Confirm) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        @strongify(self)
        @weakify(self)
        if ([self.dataProvider.groupInfo canDelete]) {
            [self.dataProvider dismissGroup:^{
                @strongify(self)
                @weakify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    UIViewController *vc = [self findConversationListViewController];
                    [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",self.groupId] callback:nil];
                    [V2TIMManager.sharedInstance markConversation:@[[NSString stringWithFormat:@"group_%@",self.groupId]] markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD) enableMark:NO succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
                        [self.navigationController popToViewController:vc animated:YES];
                    } fail:^(int code, NSString *desc) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }];
                    
                });
            } fail:^(int code, NSString *msg) {
                [TUITool makeToastError:code msg:msg];
            }];
        } else {
            [self.dataProvider quitGroup:^{
                @strongify(self)
                @weakify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    UIViewController *vc = [self findConversationListViewController];
                    [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",self.groupId] callback:nil];
                    [V2TIMManager.sharedInstance markConversation:@[[NSString stringWithFormat:@"group_%@",self.groupId]] markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD) enableMark:NO succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
                        [self.navigationController popToViewController:vc animated:YES];
                    } fail:^(int code, NSString *desc) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }];
                });
            } fail:^(int code, NSString *msg) {
                [TUITool makeToastError:code msg:msg];
            }];
        }
    }]];

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
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
    cell.switchData.on = enableMark;

    @weakify(self)

    [V2TIMManager.sharedInstance markConversation:@[[NSString stringWithFormat:@"group_%@",self.groupId]] markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD) enableMark:enableMark succ:nil fail:nil];

    [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",self.groupId] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
        @strongify(self)
        [self updateGroupInfo];
    }];
}

- (void)didSelectOnChangeBackgroundImage:(TUICommonTextCell *)cell {
    @weakify(self)
    NSString *conversationID = [NSString stringWithFormat:@"group_%@",self.groupId];
    TUISelectAvatarController * vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeConversationBackGroundCover;
    vc.profilFaceURL =  [self getBackgroundImageUrlByConversationID:conversationID];
    [self.navigationController pushViewController:vc animated:YES];
    vc.selectCallBack = ^(NSString * _Nonnull urlStr) {
        @strongify(self)
        [self appendBackgroundImage:urlStr conversationID:conversationID];
        if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
            [TUICore notifyEvent:TUICore_TUIGroupNotify subKey:TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey object:self param:@{TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey_ConversationID : conversationID}];
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
    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@",targerConversationID,[TUILogin getUserID]];
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
    
    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@",conversationID,[TUILogin getUserID]];
    NSMutableDictionary *originDataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (imgUrl.length == 0) {
        [originDataDict removeObjectForKey:conversationID_UserID];
    }
    else {
        [originDataDict setObject:imgUrl forKey:conversationID_UserID];
    }
    
    [NSUserDefaults.standardUserDefaults setObject:originDataDict forKey:@"conversation_backgroundImage_map"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)didTransferGroup:(TUIButtonCell *)cell {

    TUISelectGroupMemberViewController *vc = [[TUISelectGroupMemberViewController alloc] init];
    vc.optionalStyle = TUISelectMemberOptionalStyleTransferOwner;
    vc.groupId = self.groupId;
    vc.name = TUIKitLocalizableString(TUIKitGroupTransferOwner);
    @weakify(self);
    vc.selectedFinished = ^(NSMutableArray<TUIUserModel *> * _Nonnull modelList) {
        @strongify(self);
        TUIUserModel *userModel = modelList[0];
        NSString *groupId = self.groupId;
        NSString *member = userModel.userId;
        if (userModel && [userModel isKindOfClass:[TUIUserModel class]]) {
            @weakify(self);
            [self.dataProvider transferGroupOwner:groupId member:member succ:^{
                @strongify(self);
                [self updateGroupInfo];
                [TUITool makeToast:TUIKitLocalizableString(TUIKitGroupTransferOwnerSuccess)];
            } fail:^(int code, NSString *desc) {
                [TUITool makeToastError:code msg:desc];
            }];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didClearAllHistory:(TUIButtonCell *)cell
{
    @weakify(self)
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUIKitLocalizableString(TUIKitClearAllChatHistoryTips) preferredStyle:UIAlertControllerStyleAlert];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Confirm) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self.dataProvider clearAllHistory:^{
            [TUICore notifyEvent:TUICore_TUIConversationNotify
                          subKey:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey
                          object:self
                           param:nil];
            [TUITool makeToast:@"success"];
        } fail:^(int code, NSString *desc) {
            [TUITool makeToastError:code msg:desc];
        }];
    }]];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectGroupManage
{
    TUIGroupManageController *vc = [[TUIGroupManageController alloc] init];
    vc.groupID = self.groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectGroupNotice
{
    TUIGroupNoticeController *vc = [[TUIGroupNoticeController alloc] init];
    vc.groupID = self.groupId;
    __weak typeof(self) weakSelf = self;
    vc.onNoticeChanged = ^{
        [weakSelf updateGroupInfo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark TUIProfileCardDelegate

-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUISelectAvatarController * vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeGroupAvatar;
    vc.profilFaceURL = self.dataProvider.groupInfo.faceURL;
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    vc.selectCallBack = ^(NSString * _Nonnull urlStr) {
        @strongify(self)
        if (urlStr.length > 0) {
            V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
            info.groupID = self.groupId;
            info.faceURL = urlStr;
            [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
                [self updateGroupInfo];
            } fail:^(int code, NSString *msg) {
                [TUITool makeToastError:code msg:msg];
            }];
        }
    };
}

#pragma mark TUIGroupMembersCellDelegate

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index
{
    TUIGroupMemberCellData *mem = self.dataProvider.groupMembersCellData.members[index];
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableDictionary *displayNames = [NSMutableDictionary dictionary];
    for (TUIGroupMemberCellData *cd in self.dataProvider.membersData) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
            [displayNames setObject:cd.name?:@"" forKey:cd.identifier?:@""];
        }
    }
    
    self.tag = mem.tag;
    if(self.tag == 1){
        // add
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIContactService_GetContactSelectControllerMethod_TitleKey] = TUIKitLocalizableString(GroupAddFirend);
        param[TUICore_TUIContactService_GetContactSelectControllerMethod_DisableIdsKey] = ids;
        param[TUICore_TUIContactService_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
        self.showContactSelectVC = [TUICore callService:TUICore_TUIContactService
                                                 method:TUICore_TUIContactService_GetContactSelectControllerMethod
                                                  param:param];
        [self.navigationController pushViewController:self.showContactSelectVC animated:YES];
    } else if(self.tag == 2) {
        // delete
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIContactService_GetContactSelectControllerMethod_TitleKey] = TUIKitLocalizableString(GroupDeleteFriend);
        param[TUICore_TUIContactService_GetContactSelectControllerMethod_SourceIdsKey] = ids;
        param[TUICore_TUIContactService_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
        self.showContactSelectVC = [TUICore callService:TUICore_TUIContactService
                                                 method:TUICore_TUIContactService_GetContactSelectControllerMethod
                                                  param:param];
        [self.navigationController pushViewController:self.showContactSelectVC animated:YES];
    } else {
        // TODO:
    }
}


- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members
{
    @weakify(self)
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId userList:members succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        @strongify(self)
        [self updateData];
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
        [self updateData];
        [TUITool makeToast:TUIKitLocalizableString(delete_success)];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

#pragma mark TModifyViewDelegate

- (void)modifyView:(TUIModifyView *)modifyView didModiyContent:(NSString *)content
{
    if(modifyView.tag == 0){
        [self.dataProvider setGroupName:content];
    }
    else if(modifyView.tag == 1){
        [self.dataProvider setGroupNotification:content];
    }
    else if(modifyView.tag == 2){
        [self.dataProvider setGroupMemberNameCard:content];
    }
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
