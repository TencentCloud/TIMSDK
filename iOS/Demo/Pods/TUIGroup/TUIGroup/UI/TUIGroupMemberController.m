//
//  GroupMemberController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "TUIDefine.h"
#import "TUIAddCell.h"
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGroupMemberDataProvider.h"

@interface TUIGroupMemberController () <TUIGroupMembersViewDelegate>
@property(nonatomic, strong) TUIGroupMemberDataProvider *dataProvider;
@property (nonatomic, strong) NSMutableArray<TUIGroupMemberCellData *> *members;
@end

@implementation TUIGroupMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
    self.dataProvider = [[TUIGroupMemberDataProvider alloc] initWithGroupID:self.groupId];
    @weakify(self)
    [self.dataProvider loadDatas:^(BOOL success, NSString * _Nonnull err, NSArray * _Nonnull datas) {
        @strongify(self)
        [self.groupMembersView setData:datas];
        NSString *title = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupProfileGroupCountFormat), (long)datas.count];
        self.title = title;
    }];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    //left
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:TUIGroupImagePath(@"back")] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10.0f;
    if (([[TUITool deviceVersion] floatValue] >= 11.0)) {
        leftButton.contentEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
        leftButton.imageEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
    }
    self.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
    self.parentViewController.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];

    //right
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:TUIKitLocalizableString(TUIKitGroupProfileManage) forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;

    _groupMembersView = [[TUIGroupMembersView alloc] initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height, self.view.bounds.size.width, self.view.bounds.size.height - StatusBar_Height - NavBar_Height)];
    _groupMembersView.delegate = self;
    _groupMembersView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_groupMembersView];
}

- (void)leftBarButtonClick{
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInGroupMemberController:)]){
        [_delegate didCancelInGroupMemberController:self];
    }
}

- (void)rightBarButtonClick {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([self.dataProvider.groupInfo canInviteMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileManageAdd) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didAddMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didAddMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    if ([self.dataProvider.groupInfo canRemoveMember]) { // 删除成员
        [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(TUIKitGroupProfileManageDelete) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didDeleteMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didDeleteMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark TUIGroupMembersViewDelegate
- (void)groupMembersView:(TUIGroupMembersView *)groupMembersView didLoadMoreData:(void (^)(NSArray<TUIGroupMemberCellData *> *))completion {
    // 分页加载更多数据
    if (self.dataProvider.isNoMoreData) {
        if (completion) {
            completion(@[]);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.dataProvider loadDatas:^(BOOL success, NSString *err, NSArray *datas) {
        if (datas && datas.count) {
            [weakSelf.members addObjectsFromArray:datas];
        }
        if (completion) {
            completion(datas);
        }
    }];
}

@end


