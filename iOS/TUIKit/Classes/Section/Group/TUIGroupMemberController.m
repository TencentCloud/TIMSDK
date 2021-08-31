//
//  GroupMemberController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "TUIKit.h"
#import "TAddCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMGroupInfo+DataProvider.h"
#import "TIMUserProfile+DataProvider.h"
#import "UIColor+TUIDarkMode.h"

@interface TUIGroupMemberController ()<TGroupMembersViewDelegate>
@property (nonatomic, strong) NSMutableArray<TGroupMemberCellData *> *members;
@property V2TIMGroupInfo *groupInfo;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL isNoMoreData;
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
    [[V2TIMManager sharedInstance] getGroupsInfo:@[_groupId] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        @strongify(self)
        if(groupResultList.count == 1){
            self.groupInfo = groupResultList[0].info;
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToast:msg];
    }];
    
    [self loadDatas:^(BOOL success, NSString *err, NSArray *datas) {
        @strongify(self)
        if (!success) {
            [THelper makeToast:err];
            return;
        }
        [self.members addObjectsFromArray:datas];
        [self.groupMembersView setData:self.members];
        NSString *title = [NSString stringWithFormat:TUILocalizableString(TUIKitGroupProfileGroupCountFormat), (long)self.members.count];
        self.title = title;;
    }];
}

- (void)loadDatas:(void(^)(BOOL success, NSString *err, NSArray *datas))completion
{
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:_groupId filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:self.index succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        self.index = nextSeq;
        self.isNoMoreData = (nextSeq == 0);
        NSMutableArray *arrayM = [NSMutableArray array];
        NSMutableArray *ids = [NSMutableArray array];
        NSMutableDictionary *map = [NSMutableDictionary dictionary];
        for (V2TIMGroupMemberFullInfo *member in memberList) {
            TGroupMemberCellData *user = [[TGroupMemberCellData alloc] init];
            user.identifier = member.userID;
            if (member.nameCard.length > 0) {
                user.name = member.nameCard;
            } else if (member.friendRemark.length > 0) {
                user.name = member.friendRemark;
            } else if (member.nickName.length > 0) {
                user.name = member.nickName;
            } else {
                user.name = member.userID;
            }
            [arrayM addObject:user];
            [ids addObject:user.identifier];
            if (user.identifier && user) {
                map[user.identifier] = user;
            }
        }
        // 批量获取头像 faceURL
        [[V2TIMManager sharedInstance] getUsersInfo:ids succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            NSArray *userIDs =  map.allKeys;
            for (V2TIMUserFullInfo *info in infoList) {
                if (![userIDs containsObject:info.userID]) {
                    continue;
                }
                TGroupMemberCellData *user = map[info.userID];
                user.avatarUrl = info.faceURL;
            }
            if (completion) {
                completion(YES, @"", arrayM);
            }
        } fail:^(int code, NSString *desc) {
            if (completion) {
                completion(NO, desc, @[]);
            }
        }];
        
    } fail:^(int code, NSString *msg) {
        if (completion) {
            completion(NO, msg, @[]);
        }
    }];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

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
    [rightButton setTitle:TUILocalizableString(TUIKitGroupProfileManage) forState:UIControlStateNormal];
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

    if ([self.groupInfo canInviteMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileManageAdd) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didAddMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didAddMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    if ([self.groupInfo canRemoveMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitGroupProfileManageDelete) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didDeleteMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didDeleteMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    [ac addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)groupMembersView:(TUIGroupMembersView *)groupMembersView didLoadMoreData:(void (^)(NSArray<TGroupMemberCellData *> *))completion
{
    // 分页加载更多数据
    if (self.isNoMoreData) {
        if (completion) {
            completion(@[]);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self loadDatas:^(BOOL success, NSString *err, NSArray *datas) {
        if (datas && datas.count) {
            [weakSelf.members addObjectsFromArray:datas];
        }
        if (completion) {
            completion(datas);
        }
    }];
}


/*
- (BOOL)isMeOwner
{
    return [self.groupInfo.owner isEqualToString:[[TIMManager sharedInstance] getLoginUser]];
}
 */
/*
- (BOOL)isPrivate
{
    return [self.groupInfo.groupType isEqualToString:@"Private"];
}
 */
/*
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
 */
/**
- (BOOL)canRemoveMember
{
    return [self isMeOwner] && (self.members.count > 1);
}
 **/
@end
