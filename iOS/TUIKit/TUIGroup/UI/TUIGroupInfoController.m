#import "TUIGroupInfoController.h"
#import "TUIProfileCardCell.h"
#import "TUIGroupMembersCell.h"
#import "TUIGroupMemberCell.h"
#import "TUIButtonCell.h"
#import "TUICommonSwitchCell.h"
#import "TUIGroupMemberController.h"
#import "TUIModifyView.h"
#import "TUIAddCell.h"
#import "TUICommonTextCell.h"
#import "TUIDefine.h"
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGroupInfoDataProvider.h"
#import "TUIAvatarViewController.h"

#define ADD_TAG @"-1"
#define DEL_TAG @"-2"

@interface TUIGroupInfoController () <TModifyViewDelegate, TUIGroupMembersCellDelegate, TUIProfileCardDelegate, TUIGroupInfoDataProviderDelegate>
@property(nonatomic, strong) TUIGroupInfoDataProvider *dataProvider;
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
}

- (void)setupViews {
    self.title = TUIKitLocalizableString(TUIKitGroupProfileDetails);
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:[UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1/1.0] dark:[UIColor blackColor]];
    //加入此行，会让反馈更加灵敏
    self.tableView.delaysContentTouches = NO;
}

- (void)updateData {
    [self.dataProvider loadData];
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
        //设置 profileCard 的委托
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
    if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didSelectMembersInGroup:groupInfo:)]){
        [_delegate groupInfoController:self didSelectMembersInGroup:_groupId groupInfo:self.dataProvider.groupInfo];
    }
}

- (void)didSelectAddOption:(UITableViewCell *)cell
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUIKitLocalizableString(TUIKitGroupProfileJoinType) preferredStyle:UIAlertControllerStyleActionSheet];

    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileJoinDisable) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.dataProvider setGroupAddOpt:V2TIM_GROUP_ADD_FORBID];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileAdminApprove) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.dataProvider setGroupAddOpt:V2TIM_GROUP_ADD_AUTH];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileAutoApproval) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.dataProvider setGroupAddOpt:V2TIM_GROUP_ADD_ANY];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectGroupNick:(TUICommonTextCell *)cell
{
    TModifyViewData *data = [[TModifyViewData alloc] init];
    data.title = TUIKitLocalizableString(TUIKitGroupProfileEditAlias);
    data.content = self.dataProvider.selfInfo.nameCard;
    data.desc = TUIKitLocalizableString(TUIKitGroupProfileEditAlias);
    data.enableNull = YES;
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 2;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectCommon
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([self.dataProvider.groupInfo isPrivate] || [TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileEditGroupName) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            TModifyViewData *data = [[TModifyViewData alloc] init];
            data.title = TUIKitLocalizableString(TUIKitGroupProfileEditGroupName);
            data.content = self.dataProvider.groupInfo.groupName;
            data.desc = TUIKitLocalizableString(TUIKitGroupProfileEditGroupName);
            TUIModifyView *modify = [[TUIModifyView alloc] init];
            modify.tag = 0;
            modify.delegate = self;
            [modify setData:data];
            [modify showInWindow:self.view.window];

        }]];
    }
    if ([TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileEditAnnouncement) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            TModifyViewData *data = [[TModifyViewData alloc] init];
            data.title = TUIKitLocalizableString(TUIKitGroupProfileEditAnnouncement);
            TUIModifyView *modify = [[TUIModifyView alloc] init];
            modify.tag = 1;
            modify.delegate = self;
            [modify setData:data];
            [modify showInWindow:self.view.window];
        }]];
    }

    if ([self.delegate respondsToSelector:@selector(groupInfoController:didSelectChangeAvatar:)]) {
        if ([TUIGroupInfoDataProvider isMeOwner:self.dataProvider.groupInfo]) {
            [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileEditAvatar) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.delegate groupInfoController:self didSelectChangeAvatar:self.groupId];
            }]];
        }
    }
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

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
    [self.dataProvider setGroupReceiveMessageOpt:opt];
}

- (void)didSelectOnTop:(TUICommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUIConversationPin sharedInstance] addTopConversation:[NSString stringWithFormat:@"group_%@",_groupId] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 设置失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [TUITool makeToast:errorMessage];
        }];
    } else {
        [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",_groupId] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 设置失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [TUITool makeToast:errorMessage];
        }];
    }
}

- (void)didDeleteGroup:(TUIButtonCell *)cell
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUIKitLocalizableString(TUIKitGroupProfileDeleteGroupTips) preferredStyle:UIAlertControllerStyleActionSheet];

    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Confirm) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        @weakify(self)
        if ([self.dataProvider.groupInfo canDelete]) {
            [self.dataProvider dismissGroup:^{
                @strongify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",self.groupId] callback:nil];
                    if(self.delegate && [self.delegate respondsToSelector:@selector(groupInfoController:didDeleteGroup:)]){
                        [self.delegate groupInfoController:self didDeleteGroup:self.groupId];
                    }
                });
            } fail:^(int code, NSString *msg) {
                [TUITool makeToastError:code msg:msg];
            }];
        } else {
            [self.dataProvider quitGroup:^{
                @strongify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",self.groupId] callback:nil];
                    if(self.delegate && [self.delegate respondsToSelector:@selector(groupInfoController:didQuitGroup:)]){
                        [self.delegate groupInfoController:self didQuitGroup:self.groupId];
                    }
                });
            } fail:^(int code, NSString *msg) {
                [TUITool makeToastError:code msg:msg];
            }];
        }
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didClearAllHistory:(TUIButtonCell *)cell
{
    @weakify(self)
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:TUIKitLocalizableString(TUIKitClearAllChatHistoryTips) preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Confirm) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self.dataProvider clearAllHistory:^{
            [TUITool makeToast:@"success"];
        } fail:^(int code, NSString *desc) {
            [TUITool makeToastError:code msg:desc];
        }];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark TUIProfileCardDelegate

-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    //点击头像的响应函数，换头像，上传头像URL
    @weakify(self)
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"choose_avatar_for_you", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        NSString *url = [TUITool randAvatarUrl];
        @weakify(self)
        [self.dataProvider updateGroupAvatar:url succ:^{
            @strongify(self)
            [self updateData];
        } fail:^(int code, NSString *desc) {
            [TUITool makeToast:[NSString stringWithFormat:@"%d, %@", code, desc]];
        }];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark TUIGroupMembersCellDelegate

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index
{
    TUIGroupMemberCellData *mem = self.dataProvider.groupMembersCellData.members[index];
    if(mem.tag == 1){
        //add
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didAddMembersInGroup:members:)]){
            [_delegate groupInfoController:self didAddMembersInGroup:_groupId members:self.dataProvider.membersData];
        }
    }
    else if(mem.tag == 2) {
        //delete
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didDeleteMembersInGroup:members:)]){
            [_delegate groupInfoController:self didDeleteMembersInGroup:_groupId members:self.dataProvider.membersData];
        }
    }
    else
    {
        // TODO:
    }
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

@end
