//
//  AddGroupViewController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AddGroupController.h"
#import "TAddCell.h"
#import "ChatViewController.h"
#import "TUIKit.h"
#import "TAlertView.h"

@interface AddGroupController () <TAddGroupControllerDelegate,UIAlertViewDelegate>

@end

@implementation AddGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSMutableArray *datas = [NSMutableArray array];
//    for (NSString *item in [[TUIKit sharedInstance] testUser]) {
//        TAddCellData *data = [[TAddCellData alloc] init];
//        data.head = TUIKitResource(@"default_head");
//        data.name = item;
//        data.identifier = item;
//        [datas addObject:data];
//    }
    TAddGroupController *add = [[TAddGroupController alloc] init];
    add.delegate = self;
    add.addGroupType = _addGroupType;
    //add.data = datas;
    [self addChildViewController:add];
    [self.view addSubview:add.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didCancelInAddGroupController:(TAddGroupController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addGroupController:(TAddGroupController *)controller didCreateGroupId:(NSString *)groupId groupName:(NSString *)groupName
{
    TConversationCellData *data = [[TConversationCellData alloc] init];
    data.convId = groupId;
    data.convType = TConv_Type_Group;
    data.title = groupName;
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversation = data;
    [self dismissViewControllerAnimated:NO completion:nil];
    [((UITabBarController *)self.presentingViewController).selectedViewController pushViewController:chat animated:YES];
}

- (void)addGroupController:(TAddGroupController *)controller didCreateGroupIdFailed:(int)errorCode errorMsg:(NSString *)errorMsg
{
    NSString *text = [NSString stringWithFormat:@"创建群组失败，code：%d, msg：%@",errorCode,errorMsg];
    [self alert:text];
}

- (void)addGroupController:(TAddGroupController *)controller didJoinGroupId:(NSString *)groupId
{
    NSString *text = [NSString stringWithFormat:@"申请加入群组成功，群组ID：%@",groupId];
    [self alert:text];
}

- (void)addGroupController:(TAddGroupController *)controller didJoinGroupIdFailed:(int)errorCode errorMsg:(NSString *)errorMsg
{
    NSString *text = [NSString stringWithFormat:@"申请加入群组失败，code：%d, msg：%@",errorCode,errorMsg];
    [self alert:text];
}

- (void)alert:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
