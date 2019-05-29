//
//  GroupMemberController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TGroupMemberController.h"
#import "TGroupMemberCell.h"
#import "THeader.h"
#import "TSelectView.h"
#import "TAddCell.h"
@import ImSDK;

@interface TGroupMemberController ()<TGroupMembersViewDelegate, TSelectViewDelegate>
@property (nonatomic, strong) NSMutableArray<TGroupMemberCellData *> *members;
@end

@implementation TGroupMemberController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self updateData];
}

- (void)updateData
{
    _members = [NSMutableArray array];
    __weak typeof(self) ws = self;
    [[TIMGroupManager sharedInstance] getGroupMembers:_groupId succ:^(NSArray *members) {
        for (TIMGroupMemberInfo *member in members) {
            TGroupMemberCellData *user = [[TGroupMemberCellData alloc] init];
            user.identifier = member.member;
            user.head = TUIKitResource(@"default_head");
            user.name = member.member;
            [ws.members addObject:user];
        }
        [ws.groupMembersView setData:ws.members];
        NSString *title = [NSString stringWithFormat:@"群成员(%ld人)", (long)ws.members.count];
        ws.title = title;
        ws.parentViewController.title = title;
    } fail:^(int code, NSString *msg) {
        
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
    
    _groupMembersView = [[TGroupMembersView alloc] initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height, self.view.bounds.size.width, self.view.bounds.size.height - StatusBar_Height - NavBar_Height)];
    _groupMembersView.delegate = self;
    [self.view addSubview:_groupMembersView];
}

- (void)leftBarButtonClick{
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInGroupMemberController:)]){
        [_delegate didCancelInGroupMemberController:self];
    }
}

- (void)rightBarButtonClick{
    TSelectView *select = [[TSelectView alloc] init];
    select.delegate = self;
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"添加成员", @"删除成员", nil];
    [select setData:array];
    [select showInWindow:self.view.window];
}

- (void)selectView:(TSelectView *)selectView didSelectRowAtIndex:(NSInteger)index
{
    if(index == 0){
        if(_delegate && [_delegate respondsToSelector:@selector(groupMemberController:didAddMembersInGroup:hasMembers:)]){
            [_delegate groupMemberController:self didAddMembersInGroup:_groupId hasMembers:_members];
        }
    }
    else if(index == 1){
        if(_delegate && [_delegate respondsToSelector:@selector(groupMemberController:didDeleteMembersInGroup:hasMembers:)]){
            [_delegate groupMemberController:self didDeleteMembersInGroup:_groupId hasMembers:_members];
        }
    }
}
@end
