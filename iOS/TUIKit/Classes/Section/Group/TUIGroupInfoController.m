//
//  GroupInfoController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/26.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupInfoController.h"
#import "TUIProfileCardCell.h"
#import "TUIGroupMembersCell.h"
#import "TUIGroupMemberCell.h"
#import "TUIButtonCell.h"
#import "TCommonSwitchCell.h"
#import "TAddGroupOptionView.h"
#import "THeader.h"
#import "TUIGroupMemberController.h"
#import "TPickView.h"
#import "TSelectView.h"
#import "TModifyView.h"
#import "TAddCell.h"
#import "TAlertView.h"
#import "TUILocalStorage.h"
#import "UIImage+TUIKIT.h"
#import "TCommonTextCell.h"
#import "TUIKit.h"

@import ImSDK;

@interface TUIGroupInfoController () <TPickViewDelegate, TSelectViewDelegate, TModifyViewDelegate, TGroupMembersCellDelegate,  TAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *memberData;
@property (nonatomic, strong) TIMGroupInfo *groupInfo;
@end

@implementation TUIGroupInfoController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self updateData];
}

- (void)setupViews
{
    self.title = @"详细资料";
   
    //left
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:TUIKitResource(@"back")] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10.0f;
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)) {
        leftButton.contentEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
        leftButton.imageEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
    }
    self.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
    self.parentViewController.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TGroupInfoController_Background_Color;
}

- (void)updateData
{
    _memberData = [NSMutableArray array];
    _data = [NSMutableArray array];
    __weak typeof(self) ws = self;
    [[TIMGroupManager sharedInstance] getGroupInfo:@[_groupId] succ:^(NSArray *arr) {
        if(arr.count == 1){
            ws.groupInfo = arr[0];
            //common
            NSMutableArray *commonArray = [NSMutableArray array];
            TUIProfileCardCellData *commonData = [[TUIProfileCardCellData alloc] init];
            commonData.avatarImage = DefaultGroupAvatarImage;
            commonData.name = ws.groupInfo.groupName;
            commonData.identifier = ws.groupInfo.group;
            commonData.signature = ws.groupInfo.notification;
            commonData.cselector = @selector(didSelectCommon);
            commonData.showAccessory = YES;
            [commonArray addObject:commonData];
            [ws.data addObject:commonArray];
            //members count
            NSMutableArray *memberArray = [NSMutableArray array];
            TCommonTextCellData *countData = [[TCommonTextCellData alloc] init];
            countData.key = @"群成员";
            countData.value = [NSString stringWithFormat:@"%d人", ws.groupInfo.memberNum];
            countData.cselector = @selector(didSelectMembers);
            [memberArray addObject:countData];
            
            
            
            [[TIMGroupManager sharedInstance] getGroupMembers:ws.groupId succ:^(NSArray *members) {
                TIMGroupMemberInfo *selfInfo;
                
                //members
                for (NSInteger i = 0; i < members.count; ++i) {
                    TIMGroupMemberInfo *member = members[i];
                    if([member.member isEqualToString:[TIMManager sharedInstance].getLoginUser]){
                        selfInfo = member;
                    }
                    TGroupMemberCellData *data = [[TGroupMemberCellData alloc] init];
                    data.identifier = member.member;
                    data.head = TUIKitResource(@"default_head");
                    data.name = member.member;
                    [ws.memberData addObject:data];
                }
                NSMutableArray *tmpArray = [ws getShowMembers:ws.memberData];
                TGroupMembersCellData *membersData = [[TGroupMembersCellData alloc] init];
                membersData.members = tmpArray;
                [memberArray addObject:membersData];
                [ws.data addObject:memberArray];
                
                
                //group info
                NSMutableArray *groupInfoArray = [NSMutableArray array];
                TCommonTextCellData *typeData = [[TCommonTextCellData alloc] init];
                typeData.key = @"群类型";
                typeData.value = [ws getShowGroupType:ws.groupInfo.groupType];
                [groupInfoArray addObject:typeData];
                
                TCommonTextCellData *addOptionData = [[TCommonTextCellData alloc] init];
                addOptionData.key = @"加群方式";
                addOptionData.value = [ws getShowAddOption:ws.groupInfo.addOpt];
                addOptionData.cselector = @selector(didSelectAddOption:);
                addOptionData.showAccessory = YES;
                [groupInfoArray addObject:addOptionData];
                [ws.data addObject:groupInfoArray];
                
                //personal info
                NSMutableArray *personalArray = [NSMutableArray array];
                TCommonTextCellData *nickData = [[TCommonTextCellData alloc] init];
                nickData.key = @"我的群昵称";
                nickData.value = selfInfo.nameCard;
                nickData.cselector = @selector(didSelectGroupNick:);
                nickData.showAccessory = YES;
                [personalArray addObject:nickData];
                
                TCommonSwitchCellData *switchData = [[TCommonSwitchCellData alloc] init];
                if ([[[TUILocalStorage sharedInstance] topConversationList] containsObject:ws.groupId]) {
                    switchData.on = YES;
                }
                switchData.title = @"置顶聊天";
                switchData.cswitchSelector = @selector(didSelectOnTop:);
                [personalArray addObject:switchData];
                
                [ws.data addObject:personalArray];
                
                NSMutableArray *buttonArray = [NSMutableArray array];
                TUIButtonCellData *buttonData = [[TUIButtonCellData alloc] init];
                if([self canDelete:ws.groupInfo]){
                    buttonData.title = @"解散群组";
                }
                else{
                    buttonData.title = @"退出群组";
                }
                buttonData.style = ButtonRedText;
                buttonData.cbuttonSelector = @selector(deleteGroup:);
                [buttonArray addObject:buttonData];
                [ws.data addObject:buttonArray];
                
                [ws.tableView reloadData];
            } fail:^(int code, NSString *msg) {
                NSLog(@"");
            }];
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    SEL selector = nil;
    if([data isKindOfClass:[TGroupMembersCellData class]]){
        selector = ((TGroupMembersCellData *)data).selector;
    }
    if(selector){
        [self performSelector:selector];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupCommonCell_ReuseId];
        if(!cell){
            cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupCommonCell_ReuseId];
        }
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
    //私有群禁止加入
    if ([self.groupInfo.groupType isEqualToString:@"Private"]) {
        return;
    }
    NSMutableArray *addOptionData = [NSMutableArray array];
    [addOptionData addObject:@"禁止加入"];
    [addOptionData addObject:@"管理员审批"];
    [addOptionData addObject:@"自动审批"];
    
    TPickView *pick = [[TPickView alloc] init];
    pick.delegate = self;
    [pick setData:addOptionData];
    [pick showInWindow:self.view.window];
}

- (void)pickView:(TPickView *)pickView didSelectRowAtIndex:(NSInteger)index
{
    __weak typeof(self) ws = self;
    [[TIMGroupManager sharedInstance] modifyGroupAddOpt:_groupId opt:(TIMGroupAddOpt)index succ:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger section = 2;
            NSInteger row = 1;
            NSMutableArray *array = ws.data[section];
            TCommonTextCellData *data = array[row];
            data.value = [ws getShowAddOption:(TIMGroupAddOpt)index];
            [ws.tableView reloadData];
        });
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
}

- (void)didSelectGroupNick:(TCommonTextCell *)cell
{
    TModifyViewData *data = [[TModifyViewData alloc] init];
    data.title = @"修改我的群昵称";
    TModifyView *modify = [[TModifyView alloc] init];
    modify.tag = 2;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectCommon
{
    NSMutableArray *data = [NSMutableArray arrayWithObjects:@"修改群名称", @"修改群公告", nil];
    TSelectView *select = [[TSelectView alloc] init];
    select.delegate = self;
    [select setData:data];
    [select showInWindow:self.view.window];
    
}

- (void)didSelectOnTop:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:_groupId];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:_groupId];
    }
}

- (void)selectView:(TSelectView *)selectView didSelectRowAtIndex:(NSInteger)index
{
    TModifyViewData *data = [[TModifyViewData alloc] init];
    if(index == 0){
        data.title = @"修改群名称";
    }
    else if(index == 1){
        data.title = @"修改群公告";
    }
    TModifyView *modify = [[TModifyView alloc] init];
    modify.tag = index;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)modifyView:(TModifyView *)modifyView didModiyContent:(NSString *)content
{
    if(modifyView.tag == 0){
        __weak typeof(self) ws = self;
        [[TIMGroupManager sharedInstance] modifyGroupName:_groupId groupName:content succ:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger section = 0;
                NSInteger row = 0;
                NSMutableArray *array = ws.data[section];
                TUIProfileCardCellData *data = array[row];
                data.name = content;
                [ws.tableView reloadData];
            });
        } fail:^(int code, NSString *msg) {
            NSLog(@"");
        }];
    }
    else if(modifyView.tag == 1){
        __weak typeof(self) ws = self;
        [[TIMGroupManager sharedInstance] modifyGroupNotification:_groupId notification:content succ:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger section = 0;
                NSInteger row = 0;
                NSMutableArray *array = ws.data[section];
                TUIProfileCardCellData *data = array[row];
                data.signature = content;
                [ws.tableView reloadData];
            });
        } fail:^(int code, NSString *msg) {
            NSLog(@"");
        }];
    }
    else if(modifyView.tag == 2){
        __weak typeof(self) ws = self;
        NSString *user = [TIMManager sharedInstance].getLoginUser;
        [[TIMGroupManager sharedInstance] modifyGroupMemberInfoSetNameCard:_groupId user:user nameCard:content succ:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger section = 3;
                NSInteger row = 0;
                NSMutableArray *array = ws.data[section];
                TCommonTextCellData *data = array[row];
                data.value = content;
                [ws.tableView reloadData];
            });
        } fail:^(int code, NSString *msg) {
            NSLog(@"");
        }];
    }
}

- (void)deleteGroup:(TUIButtonCell *)cell
{
    NSString *title;
    if([self canDelete:_groupInfo]){
        title = @"解散群组";
    }
    else{
        title = @"退出群组";
    }
    TAlertView *alert = [[TAlertView alloc] initWithTitle:title];
    alert.delegate = self;
    [alert showInWindow:self.view.window];
}

- (void)didConfirmInAlertView:(TAlertView *)alertView
{
    __weak typeof(self) ws = self;
    if([self canDelete:_groupInfo]){
        [[TIMGroupManager sharedInstance] deleteGroup:_groupId succ:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(groupInfoController:didDeleteGroup:)]){
                    [ws.delegate groupInfoController:ws didDeleteGroup:ws.groupId];
                }
            });
        } fail:^(int code, NSString *msg) {
            NSLog(@"");
        }];
    }
    else{
        [[TIMGroupManager sharedInstance] quitGroup:_groupId succ:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(groupInfoController:didQuitGroup:)]){
                    [ws.delegate groupInfoController:ws didQuitGroup:ws.groupId];
                }
            });
        } fail:^(int code, NSString *msg) {
            NSLog(@"");
        }];
    }
}

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index
{
    NSInteger section = 1;
    NSInteger row = 1;
    NSMutableArray *array = _data[section];
    TGroupMembersCellData *data = array[row];
    if(index == data.members.count - 2){
        //add
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didAddMembersInGroup:members:)]){
            [_delegate groupInfoController:self didAddMembersInGroup:_groupId members:_memberData];
        }
    }
    else if(index == data.members.count - 1){
        //delete
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didDeleteMembersInGroup:members:)]){
            [_delegate groupInfoController:self didDeleteMembersInGroup:_groupId members:_memberData];
        }
    }
}

- (void)addMembers:(NSArray *)members
{
    for (TAddCellData *addMember in members) {
        TGroupMemberCellData *data = [[TGroupMemberCellData alloc] init];
        data.identifier = addMember.identifier;
        data.head = addMember.head;
        data.name = addMember.name;
        [_memberData addObject:data];
    }
    NSMutableArray *array = _data[1];
    TCommonTextCellData *count = array[0];
    TGroupMembersCellData *member = array[1];
    
    count.value = [NSString stringWithFormat:@"%ld人", _memberData.count];
    member.members = [self getShowMembers:_memberData];
    
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
    NSMutableArray *array = _data[1];
    TCommonTextCellData *count = array[0];
    TGroupMembersCellData *member = array[1];
    
    count.value = [NSString stringWithFormat:@"%ld人", _memberData.count];
    member.members = [self getShowMembers:_memberData];

    [self.tableView reloadData];
}

- (NSMutableArray *)getShowMembers:(NSMutableArray *)members
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (NSInteger i = 0; i < members.count; ++i) {
        if(i >= TGroupMembersCell_Column_Count * TGroupMembersCell_Row_Count - 2){
            break;
        }
        [tmpArray addObject:members[i]];
    }
    TGroupMemberCellData *add = [[TGroupMemberCellData alloc] init];
    add.head = TUIKitResource(@"add");
    [tmpArray addObject:add];
    TGroupMemberCellData *delete = [[TGroupMemberCellData alloc] init];
    delete.head = TUIKitResource(@"delete");
    [tmpArray addObject:delete];
    return tmpArray;
}

- (NSString *)getShowGroupType:(NSString *)type
{
    if([type isEqualToString:@"Private"]){
        return @"私有群";
    }
    else if([type isEqualToString:@"Public"]){
        return @"公开群";
    }
    else if([type isEqualToString:@"ChatRoom"]){
        return @"聊天室";
    }
    return @"";
}

- (NSString *)getShowAddOption:(TIMGroupAddOpt )opt
{
    switch (opt) {
        case TIM_GROUP_ADD_FORBID:
            return @"禁止加入";
            break;
        case TIM_GROUP_ADD_AUTH:
            return @"管理员审批";
            break;
        case TIM_GROUP_ADD_ANY:
            return @"自动审批";
            break;
        default:
            break;
    }
    return @"";
}

- (BOOL)canDelete:(TIMGroupInfo *)info
{
    if([info.groupType isEqualToString:@"Private"]){
        return NO;
    }
    else{
        if([info.owner isEqualToString:[[TIMManager sharedInstance] getLoginUser]]){
            return YES;
        }
        else{
            return NO;
        }
    }
}
@end
