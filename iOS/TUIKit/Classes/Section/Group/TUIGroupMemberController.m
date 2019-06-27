//
//  GroupMemberController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "THeader.h"
#import "TAddCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "Toast/Toast.h"
@import ImSDK;

@interface TUIGroupMemberController ()<TGroupMembersViewDelegate>
@property (nonatomic, strong) NSMutableArray<TGroupMemberCellData *> *members;
@property TIMGroupInfo *groupInfo;
@end

@implementation TUIGroupMemberController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self updateData];
}

- (void)updateData
{
    _members = [NSMutableArray array];
    @weakify(self)
    [[TIMGroupManager sharedInstance] getGroupInfo:@[_groupId] succ:^(NSArray *arr) {
        @strongify(self)
        if(arr.count == 1){
            self.groupInfo = arr[0];
        }
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.view makeToast:msg];
    }];
    
    [[TIMGroupManager sharedInstance] getGroupMembers:_groupId succ:^(NSArray *members) {
        @strongify(self)
        for (TIMGroupMemberInfo *member in members) {
            TGroupMemberCellData *user = [[TGroupMemberCellData alloc] init];
            user.identifier = member.member;
            user.name = member.nameCard;
            [self.members addObject:user];
        }
        [self.groupMembersView setData:self.members];
        NSString *title = [NSString stringWithFormat:@"群成员(%ld人)", (long)self.members.count];
        self.title = title;
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.view makeToast:msg];
    }];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //left
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
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
    
    //right
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"管理" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
    
    _groupMembersView = [[TUIGroupMembersView alloc] initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height, self.view.bounds.size.width, self.view.bounds.size.height - StatusBar_Height - NavBar_Height)];
    _groupMembersView.delegate = self;
    [self.view addSubview:_groupMembersView];
}

- (void)leftBarButtonClick{
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInGroupMemberController:)]){
        [_delegate didCancelInGroupMemberController:self];
    }
}

- (void)rightBarButtonClick {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([self canInviteMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:@"添加成员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didAddMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didAddMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    if ([self canRemoveMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:@"删除成员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didDeleteMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didDeleteMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:ac animated:YES completion:nil];
}


- (BOOL)isMeOwner
{
    return [self.groupInfo.owner isEqualToString:[[TIMManager sharedInstance] getLoginUser]];
}

- (BOOL)isPrivate
{
    return [self.groupInfo.groupType isEqualToString:@"Private"];
}

- (BOOL)canInviteMember
{
    if([self.groupInfo.groupType isEqualToString:@"Private"]){
        return YES;
    }
    else if([self.groupInfo.groupType isEqualToString:@"Public"]){
        return NO;
    }
    else if([self.groupInfo.groupType isEqualToString:@"ChatRoom"]){
        return NO;
    }
    return NO;
}

- (BOOL)canRemoveMember
{
    return [self isMeOwner] && (self.members.count > 1);
}
@end
