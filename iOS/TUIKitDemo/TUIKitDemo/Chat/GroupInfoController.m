//
//  GroupInfoController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "GroupInfoController.h"
#import "TUIGroupInfoController.h"
#import "GroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "TUIContactSelectController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "Toast/Toast.h"
@import ImSDK;

@interface GroupInfoController () <TGroupInfoControllerDelegate>

@end

@implementation GroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    TUIGroupInfoController *info = [[TUIGroupInfoController alloc] init];
    info.groupId = _groupId;
    info.delegate = self;
    [self addChildViewController:info];
    [self.view addSubview:info.view];
    self.title = @"详细资料";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectMembersInGroup:(NSString *)groupId
{
    GroupMemberController *membersController = [[GroupMemberController alloc] init];
    membersController.groupId = groupId;
    [self.navigationController pushViewController:membersController animated:YES];
}

- (void)groupInfoController:(TUIGroupInfoController *)controller didAddMembersInGroup:(NSString *)groupId members:(NSArray *)members
{
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] initWithNibName:nil bundle:nil];
    vc.title = @"添加联系人";
    vc.viewModel.disableFilter = ^BOOL(TCommonContactSelectCellData *data) {
        for (TGroupMemberCellData *cd in members) {
            if ([cd.identifier isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (TCommonContactSelectCellData *data in selectArray) {
            [list addObject:data.identifier];
        }
        [self.navigationController popToViewController:self animated:YES];
        [self addGroupId:groupId memebers:list controller:controller];
    };
}

- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteMembersInGroup:(NSString *)groupId members:(NSArray *)members
{
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] initWithNibName:nil bundle:nil];
    vc.title = @"删除联系人";
    vc.viewModel.avaliableFilter = ^BOOL(TCommonContactSelectCellData *data) {
        for (TGroupMemberCellData *cd in members) {
            if ([cd.identifier isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (TCommonContactSelectCellData *data in selectArray) {
            [list addObject:data.identifier];
        }
        [self.navigationController popToViewController:self animated:YES];
        [self deleteGroupId:groupId memebers:list controller:controller];
    };
}

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupInfoController *)controller
{
    [[TIMGroupManager sharedInstance] inviteGroupMember:_groupId members:members succ:^(NSArray *members) {
        [self.view makeToast:@"添加成功"];
        [controller updateData];
    } fail:^(int code, NSString *msg) {
        [self.view makeToast:msg];
    }];
}

- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupInfoController *)controller
{
    [[TIMGroupManager sharedInstance] deleteGroupMemberWithReason:groupId reason:@"" members:members succ:^(NSArray *members) {
        [self.view makeToast:@"删除成功"];
        [controller updateData];
    } fail:^(int code, NSString *msg) {
        [self.view makeToast:msg];
    }];
}

- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteGroup:(NSString *)groupId
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject] animated:YES];
}

- (void)groupInfoController:(TUIGroupInfoController *)controller didQuitGroup:(NSString *)groupId
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject] animated:YES];
}
@end
