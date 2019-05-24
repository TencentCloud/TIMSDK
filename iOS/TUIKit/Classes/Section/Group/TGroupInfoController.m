//
//  GroupInfoController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/26.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TGroupInfoController.h"
#import "TGroupCommonCell.h"
#import "TGroupMembersCell.h"
#import "TGroupMemberCell.h"
#import "TKeyValueCell.h"
#import "TButtonCell.h"
#import "TCommonSwitchCell.h"
#import "TAddGroupOptionView.h"
#import "THeader.h"
#import "TGroupMemberController.h"
#import "TPickView.h"
#import "TSelectView.h"
#import "TModifyView.h"
#import "TAddCell.h"
#import "TAlertView.h"
#import "TLocalStorage.h"
@import ImSDK;

@interface TGroupInfoController () <TPickViewDelegate, TSelectViewDelegate, TModifyViewDelegate, TGroupMembersCellDelegate, TButtonCellDelegate, TAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *memberData;
@property (nonatomic, strong) TIMGroupInfo *groupInfo;
@end

@implementation TGroupInfoController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self updateData];
}

- (void)setupViews
{
    self.title = @"群资料";
    self.parentViewController.title = @"群资料";
   
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
            TGroupCommonCellData *commonData = [[TGroupCommonCellData alloc] init];
            commonData.head = TUIKitResource(@"default_head");
            commonData.groupName = ws.groupInfo.groupName;
            commonData.groupId = ws.groupInfo.group;
            commonData.notification = ws.groupInfo.notification;
            commonData.selector = @selector(didSelectCommon);
            [commonArray addObject:commonData];
            [ws.data addObject:commonArray];
            //members count
            NSMutableArray *memberArray = [NSMutableArray array];
            TKeyValueCellData *countData = [[TKeyValueCellData alloc] init];
            countData.key = @"群成员";
            countData.value = [NSString stringWithFormat:@"%d人", ws.groupInfo.memberNum];
            countData.selector = @selector(didSelectMembers);
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
                TKeyValueCellData *typeData = [[TKeyValueCellData alloc] init];
                typeData.key = @"群类型";
                typeData.value = [ws getShowGroupType:ws.groupInfo.groupType];
                [groupInfoArray addObject:typeData];
                
                TKeyValueCellData *addOptionData = [[TKeyValueCellData alloc] init];
                addOptionData.key = @"加群方式";
                addOptionData.value = [ws getShowAddOption:ws.groupInfo.addOpt];
                addOptionData.selector = @selector(didSelectAddOption);
                [groupInfoArray addObject:addOptionData];
                [ws.data addObject:groupInfoArray];
                
                //personal info
                NSMutableArray *personalArray = [NSMutableArray array];
                TKeyValueCellData *nickData = [[TKeyValueCellData alloc] init];
                nickData.key = @"我的群昵称";
                nickData.value = selfInfo.nameCard;
                nickData.selector = @selector(didSelectGroupNick);
                [personalArray addObject:nickData];
                
                TCommonSwitchCellData *switchData = [[TCommonSwitchCellData alloc] init];
                if ([[[TLocalStorage sharedInstance] topConversationList] containsObject:ws.groupId]) {
                    switchData.on = YES;
                }
                switchData.title = @"置顶聊天";
                switchData.cswitchSelector = @selector(didSelectOnTop:);
                [personalArray addObject:switchData];
                
                [ws.data addObject:personalArray];
                
                NSMutableArray *buttonArray = [NSMutableArray array];
                TButtonCellData *buttonData = [[TButtonCellData alloc] init];
                if([self canDelete:ws.groupInfo]){
                    buttonData.title = @"解散群组";
                }
                else{
                    buttonData.title = @"退出群组";
                }
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
    if([data isKindOfClass:[TGroupCommonCellData class]]){
        return [TGroupCommonCell getHeight];
    }
    else if([data isKindOfClass:[TKeyValueCellData class]]){
        return [TKeyValueCell getHeight];
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        return [TGroupMembersCell getHeight:(TGroupMembersCellData *)data];
    }
    else if([data isKindOfClass:[TButtonCellData class]]){
        return [TButtonCell getHeight];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    SEL selector;
    if([data isKindOfClass:[TGroupCommonCellData class]]){
        selector = ((TGroupCommonCellData *)data).selector;
    }
    else if([data isKindOfClass:[TKeyValueCellData class]]){
        selector = ((TKeyValueCellData *)data).selector;
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        selector = ((TGroupMembersCellData *)data).selector;
    }
    if(selector){
        [self performSelector:selector];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TGroupCommonCellData class]]){
        TGroupCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupCommonCell_ReuseId];
        if(!cell){
            cell = [[TGroupCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupCommonCell_ReuseId];
        }
        [cell setData:(TGroupCommonCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TKeyValueCellData class]]){
        TKeyValueCell *cell = [tableView dequeueReusableCellWithIdentifier:TKeyValueCell_ReuseId];
        if(!cell){
            cell = [[TKeyValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TKeyValueCell_ReuseId];
        }
        [cell setData:(TKeyValueCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        TGroupMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupMembersCell_ReuseId];
        if(!cell){
            cell = [[TGroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupMembersCell_ReuseId];
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
    else if([data isKindOfClass:[TButtonCellData class]]){
        TButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if(!cell){
            cell = [[TButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
            cell.delegate = self;
        }
        [cell setData:(TButtonCellData *)data];
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

- (void)didSelectAddOption
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
            TKeyValueCellData *data = array[row];
            data.value = [ws getShowAddOption:(TIMGroupAddOpt)index];
            [ws.tableView reloadData];
        });
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
}

- (void)didSelectGroupNick
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
        [[TLocalStorage sharedInstance] addTopConversation:_groupId];
    } else {
        [[TLocalStorage sharedInstance] removeTopConversation:_groupId];
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
                TGroupCommonCellData *data = array[row];
                data.groupName = content;
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
                TGroupCommonCellData *data = array[row];
                data.notification = content;
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
                TKeyValueCellData *data = array[row];
                data.value = content;
                [ws.tableView reloadData];
            });
        } fail:^(int code, NSString *msg) {
            NSLog(@"");
        }];
    }
}

- (void)didTouchUpInsideInButtonCell:(TButtonCell *)cell
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

- (void)groupMembersCell:(TGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index
{
    NSInteger section = 1;
    NSInteger row = 1;
    NSMutableArray *array = _data[section];
    TGroupMembersCellData *data = array[row];
    if(index == data.members.count - 2){
        //add
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didAddMembersInGroup:)]){
            [_delegate groupInfoController:self didAddMembersInGroup:_groupId];
        }
    }
    else if(index == data.members.count - 1){
        //delete
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didDeleteMembersInGroup:)]){
            [_delegate groupInfoController:self didDeleteMembersInGroup:_groupId];
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
    TKeyValueCellData *count = array[0];
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
    TKeyValueCellData *count = array[0];
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
