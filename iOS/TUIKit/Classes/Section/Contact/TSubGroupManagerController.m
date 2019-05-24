//
//  TSubGroupManagerController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/18.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TSubGroupManagerController.h"
#import "THeader.h"
@import ImSDK;

@interface TSubGroupManagerController ()<UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;
@end

@implementation TSubGroupManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.frame = self.view.bounds;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    
    self.view.backgroundColor = RGBA(240, 240, 240, 1.0);
    
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.editing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return _subGroups.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddSubGroup"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddSubGroup"];
            cell.textLabel.textColor = RGB(80, 120, 200);
        }
        
        cell.textLabel.text = @"添加分组";
        cell.imageView.image = [UIImage imageNamed:TUIKitResource(@"addsubgroup")];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubGroup"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddSubGroup"];
            cell.textLabel.textColor = RGB(80, 80, 80);
        }
        cell.textLabel.text = [_subGroups objectAtIndex:indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self inputNewSubGroupName];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *groupName = [_subGroups objectAtIndex:indexPath.row];
        
        [[TIMFriendshipManager sharedInstance] deleteFriendGroup:@[groupName] succ:^{
            [self.tableView beginUpdates];
            [self.subGroups removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        } fail:^(int code, NSString *msg) {
            
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UITextField *tf= [alertView textFieldAtIndex:0];
        if (tf.text.length > 0)
        {
            if (tf.text.length  > 30)
            {
//                [[HUDHelper sharedInstance] tipMessage:@"分组名超过长度限制(最长30个字符)"];
            }
            else
            {
                [self onInputSubGroupName:tf.text];
            }
        }
        else
        {
//            [[HUDHelper sharedInstance] tipMessage:@"分组名不能不空"];
        }
    }
}

- (void)inputNewSubGroupName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"创建分组" message:@"填写新分组的名字" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}


- (void)onInputSubGroupName:(NSString *)sgName
{
    // 检查当前分组名是否与现有的重复
    if ([self.subGroups containsObject:sgName] || [sgName isEqualToString:@"我的好友"])
    {
//        [[HUDHelper sharedInstance] tipMessage:@"该分组名已存在"];
        return;
    }
    
    [[TIMFriendshipManager sharedInstance] createFriendGroup:@[sgName] users:nil succ:^(NSArray<TIMFriendResult *> *results) {
        [self.tableView beginUpdates];
        [self.subGroups addObject:sgName];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.subGroups.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } fail:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return NO;
    }
    else
    {
        return indexPath.row != 0;
    }
}
@end
