//
//  GroupInfoController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "GroupInfoController.h"
#import "TGroupInfoController.h"
#import "GroupMemberController.h"
#import "AddMemberController.h"
#import "DeleteMemberController.h"
@interface GroupInfoController () <TGroupInfoControllerDelegate>

@end

@implementation GroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    TGroupInfoController *info = [[TGroupInfoController alloc] init];
    info.groupId = _groupId;
    info.delegate = self;
    [self addChildViewController:info];
    [self.view addSubview:info.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)groupInfoController:(TGroupInfoController *)controller didSelectMembersInGroup:(NSString *)groupId
{
    GroupMemberController *membersController = [[GroupMemberController alloc] init];
    membersController.groupId = groupId;
    [self.navigationController pushViewController:membersController animated:YES];
}

- (void)groupInfoController:(TGroupInfoController *)controller didAddMembersInGroup:(NSString *)groupId
{
    AddMemberController *member = [[AddMemberController alloc] init];
    member.presenter = self;
    member.groupId = groupId;
    UINavigationController *memberNavi = [[UINavigationController alloc] initWithRootViewController:member];
    [self presentViewController:memberNavi animated:YES completion:nil];
}

- (void)groupInfoController:(TGroupInfoController *)controller didDeleteMembersInGroup:(NSString *)groupId
{
    DeleteMemberController *member = [[DeleteMemberController alloc] init];
    member.presenter = self;
    member.groupId = groupId;
    UINavigationController *memberNavi = [[UINavigationController alloc] initWithRootViewController:member];
    [self presentViewController:memberNavi animated:YES completion:nil];
}

- (void)groupInfoController:(TGroupInfoController *)controller didDeleteGroup:(NSString *)groupId
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject] animated:YES];
}

- (void)groupInfoController:(TGroupInfoController *)controller didQuitGroup:(NSString *)groupId
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject] animated:YES];
}
@end
