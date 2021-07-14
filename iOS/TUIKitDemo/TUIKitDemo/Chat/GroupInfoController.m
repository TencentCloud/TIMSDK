//
//  GroupInfoController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 群组信息视图
 *  本文件实现了群组信息的展示页面
 *
 *  您可以通过此界面查看特定群组的信息，包括群名称、群成员、群类型等
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "GroupInfoController.h"
#import "TUIGroupInfoController.h"
#import "GroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "TUIContactSelectController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "Toast/Toast.h"
#import "TUIKit.h"

@interface GroupInfoController () <TGroupInfoControllerDelegate>

@end

@implementation GroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    TUIGroupInfoController *info = [[TUIGroupInfoController alloc] init];
    info.groupId = _groupId;
    info.delegate = self;
    info.view.frame = self.view.bounds;
    [self addChildViewController:info];
    [self.view addSubview:info.view];
    self.title = NSLocalizedString(@"ProfileDetails", nil); // @"详细资料";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *点击 群成员 按钮后的响应函数
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectMembersInGroup:(NSString *)groupId
{
    GroupMemberController *membersController = [[GroupMemberController alloc] init];
    membersController.groupId = groupId;
    membersController.title = NSLocalizedString(@"GroupMember", nil); // @"群成员";
    [self.navigationController pushViewController:membersController animated:YES];
}

/**
 *点击添加群成员后的响应函数->进入添加群成员视图
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didAddMembersInGroup:(NSString *)groupId members:(NSArray<TGroupMemberCellData *> *)members
{
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] initWithNibName:nil bundle:nil];
    vc.title = NSLocalizedString(@"GroupAddFirend", nil); // @"添加联系人";
    vc.viewModel.disableFilter = ^BOOL(TCommonContactSelectCellData *data) {
        for (TGroupMemberCellData *cd in members) {
            if ([cd.identifier isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    //添加成功后默认返回群组聊天界面
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

/**
 *点击删除群成员后的响应函数->进入删除群成员视图
 *删除群成员按钮为群成员头像队列后的 "-" 按钮
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteMembersInGroup:(NSString *)groupId members:(NSArray<TGroupMemberCellData *> *)members
{
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] initWithNibName:nil bundle:nil];
    vc.title = NSLocalizedString(@"GroupDeleteFriend", nil); // @"删除联系人";
    NSMutableArray *ids = NSMutableArray.new;
    for (TGroupMemberCellData *cd in members) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
        }
    }
    [vc setSourceIds:ids];

    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    //删除成功后默认返回群组聊天界面
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

/**
 *确认添加群成员后的执行函数，函数内包含请求后的回调
 */
- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupInfoController *)controller
{
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId userList:members succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:NSLocalizedString(@"add_success", nil)];
        [controller updateData];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}

/**
 *确认删除群成员后的执行函数，函数内包含请求后的回调
 */
- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupInfoController *)controller
{
    [[V2TIMManager sharedInstance] kickGroupMember:groupId memberList:members reason:@"" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:NSLocalizedString(@"delete_success", nil)];
        [controller updateData];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}

/**
 *解散群组后执行的函数，默认回到上一界面
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteGroup:(NSString *)groupId
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *退出群组后执行的函数，默认回到上一界面
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didQuitGroup:(NSString *)groupId
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectChangeAvatar:(NSString *)groupId
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"choose_avatar_for_you", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = [THelper randAvatarUrl];
        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupID = groupId;
        info.faceURL = url;
        [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
            [controller updateData];;
        } fail:^(int code, NSString *msg) {
            [THelper makeToastError:code msg:msg];
        }];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}
@end
