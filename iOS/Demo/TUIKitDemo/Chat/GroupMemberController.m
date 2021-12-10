//
//  GroupMemberController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 群成员管理视图
 *  本文件实现了群成员管理视图，在管理员进行群内人员管理时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import "GroupMemberController.h"
#import "TUIGroupMemberController.h"
#import "TUIContactSelectController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIView+TUIToast.h"
#import "TUIKit.h"

@interface GroupMemberController () <TGroupMemberControllerDelegagte>

@property (nonatomic, weak) TUIGroupMemberController *memberVc;

@end

@implementation GroupMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    TUIGroupMemberController *members = [[TUIGroupMemberController alloc] init];
    members.groupId = _groupId;
    members.groupInfo = _groupInfo;
    members.delegate = self;
    [self addChildViewController:members];
    [self.view addSubview:members.view];
    self.memberVc = members;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didCancelInGroupMemberController:(TUIGroupMemberController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)groupMemberController:(TUIGroupMemberController *)controller didAddMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members
{
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] initWithNibName:nil bundle:nil];
    vc.title = NSLocalizedString(@"GroupAddFirend", nil); // @"添加联系人";
    vc.viewModel.disableFilter = ^BOOL(TUICommonContactSelectCellData *data) {
        for (TUIGroupMemberCellData *cd in members) {
            if ([cd.identifier isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    vc.finishBlock = ^(NSArray<TUICommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (TUICommonContactSelectCellData *data in selectArray) {
            [list addObject:data.identifier];
        }
        [self.navigationController popToViewController:self animated:YES];
        [self addGroupId:groupId memebers:list controller:controller];
    };
}

- (void)groupMemberController:(TUIGroupMemberController *)controller didDeleteMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members
{
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] initWithNibName:nil bundle:nil];
    vc.title = NSLocalizedString(@"GroupDeleteFriend", nil); // @"删除联系人";
    NSMutableArray *ids = NSMutableArray.new;
    for (TUIGroupMemberCellData *cd in members) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
        }
    }
    [vc setSourceIds:ids];
    vc.viewModel.avaliableFilter = ^BOOL(TUICommonContactSelectCellData *data) {
        for (TUIGroupMemberCellData *cd in members) {
            if ([cd.identifier isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    vc.finishBlock = ^(NSArray<TUICommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (TUICommonContactSelectCellData *data in selectArray) {
            [list addObject:data.identifier];
        }
        [self.navigationController popToViewController:self animated:YES];
        [self deleteGroupId:groupId memebers:list controller:controller];
    };
}

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupMemberController *)controller
{
    @weakify(self)
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId userList:members succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        @strongify(self)
        [TUITool makeToast:NSLocalizedString(@"add_success", nil)];
        [self.memberVc refreshData];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupMemberController *)controller
{
    @weakify(self)
    [[V2TIMManager sharedInstance] kickGroupMember:groupId memberList:members reason:@"" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        @strongify(self)
        [TUITool makeToast:NSLocalizedString(@"delete_success", nil)];
        [self.memberVc refreshData];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}
@end
