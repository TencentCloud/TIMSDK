//
//  GroupMemberController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "GroupMemberController.h"
#import "TGroupMemberController.h"
#import "AddMemberController.h"
#import "DeleteMemberController.h"

@interface GroupMemberController () <TGroupMemberControllerDelegagte>

@end

@implementation GroupMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    TGroupMemberController *members = [[TGroupMemberController alloc] init];
    members.groupId = _groupId;
    members.delegate = self;
    [self addChildViewController:members];
    [self.view addSubview:members.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didCancelInGroupMemberController:(TGroupMemberController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)groupMemberController:(TGroupMemberController *)controller didAddMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members
{
    AddMemberController *member = [[AddMemberController alloc] init];
    member.groupId = groupId;
    member.presenter = self;
    UINavigationController *memberNavi = [[UINavigationController alloc] initWithRootViewController:member];
    [self presentViewController:memberNavi animated:YES completion:nil];
}

- (void)groupMemberController:(TGroupMemberController *)controller didDeleteMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members
{
    DeleteMemberController *member = [[DeleteMemberController alloc] init];
    member.groupId = groupId;
    member.presenter = self;
    UINavigationController *memberNavi = [[UINavigationController alloc] initWithRootViewController:member];
    [self presentViewController:memberNavi animated:YES completion:nil];
}

@end
