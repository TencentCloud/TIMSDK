//
//  TUICallKitSelectGroupMemberViewController.m
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/7.
//  Copyright © 2021 Tencent. All rights reserved

#import "TUICallKitSelectGroupMemberViewController.h"
#import "TUICommonModel.h"
#import "TUICore.h"
#import "Masonry.h"
#import "TUICallingCommon.h"
#import "CallingLocalized.h"
#import "TUICallKitSelectGroupMemberCell.h"
#import "TUICallKitGroupMemberInfo.h"
#import "TUICallingStatusManager.h"
#import "TUIDefine.h"
#import "TUICallingAction.h"
#import "TUICallingUserManager.h"
#import "UIImage+TUICallKitRTL.h"

@interface TUICallKitSelectGroupMemberViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *selectTableView;
@property (nonatomic, strong) NSMutableArray<TUICallKitGroupMemberInfo *> *remoteMemberList;
@property (nonatomic, strong) TUICallKitGroupMemberInfo *selfInfo;

@end

@implementation TUICallKitSelectGroupMemberViewController {
    BOOL _isViewReady;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isViewReady = NO;
        _remoteMemberList = [[NSMutableArray alloc] init];
        _selfInfo = [[TUICallKitGroupMemberInfo alloc] init];
        _selfInfo.userId = [TUICallingUserManager getSelfUserId];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self activateConstraints];
    _isViewReady = YES;
    self.navigationItem.title = TUICallingLocalize(@"TUICallKit.Recents.addUser");
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:TUICallingLocalize(@"LoginNetwork.AppUtils.determine")
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(addUsers:)];
    rightBtn.tintColor = TUICallKitDynamicColor(@"callkit_nav_title_text_color", @"#000000");
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UIImage *defaultImage = [TUICallingCommon getBundleImageWithName:@"main_mine_about_back"];
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *leftBtnIcon = TIMCommonDynamicImage(@"nav_back_img", defaultImage);
    leftBtnIcon = [leftBtnIcon callKitImageFlippedForRightToLeftLayoutDirection];
    [leftBtn setImage:leftBtnIcon forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self updateMemberList];
}

- (void)constructViewHierarchy {
    [self.view addSubview:self.selectTableView];
}

- (void)activateConstraints {
    [self.selectTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)updateMemberList {
    NSString *groupId = [[TUICallingStatusManager shareInstance] groupId];
    if (!groupId) {
        [TUITool makeToast:@"groupId unavailable"];
        return;
    }
    
    [[V2TIMManager sharedInstance] getGroupMemberList:groupId
                                               filter:V2TIM_GROUP_MEMBER_FILTER_ALL
                                              nextSeq:0
                                                 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        for (V2TIMGroupMemberFullInfo *userFullInfo in memberList) {
            if ([userFullInfo.userID isEqualToString:self.selfInfo.userId]) {
                self.selfInfo.name = userFullInfo.nickName;
                self.selfInfo.avatar = userFullInfo.faceURL;
                self.selfInfo.isSelect = YES;
                continue;
            }
            
            TUICallKitGroupMemberInfo *userModel = [[TUICallKitGroupMemberInfo alloc] init];
            userModel.userId = userFullInfo.userID;
            userModel.name = userFullInfo.nickName;
            userModel.avatar = userFullInfo.faceURL;
            userModel.isSelect = NO;
            
            for (NSString *userId in [TUICallingUserManager allUserIdList]) {
                if ([userId isEqualToString:userFullInfo.userID]) {
                    userModel.isSelect = YES;
                    break;
                }
            }
            [self.remoteMemberList addObject:userModel];
        }
        
        [self.selectTableView registerClass:[TUICallKitSelectGroupMemberCell classForCoder] forCellReuseIdentifier:@"SelectCell"];
        [self.selectTableView reloadData];
        [self.view layoutIfNeeded];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToast:@"get group members file"];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.remoteMemberList.count == 0) {
        return 0;
    } else {
        return self.remoteMemberList.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICallKitSelectGroupMemberCell *cell = (TUICallKitSelectGroupMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"SelectCell"
                                                                                                               forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        [cell configCell:self.selfInfo isAdded:YES];
    } else {
        for (NSString *userId in [TUICallingUserManager allUserIdList]) {
            if ([userId isEqualToString:self.remoteMemberList[indexPath.row - 1].userId]) {
                [cell configCell:self.remoteMemberList[indexPath.row - 1] isAdded:YES];
                return cell;
            }
        }
        [cell configCell:self.remoteMemberList[indexPath.row - 1] isAdded:NO];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *addedUserLists = [TUICallingUserManager allUserIdList];
    
    if (indexPath.row == 0) {
        return;
    }
    
    for (NSString *userId in addedUserLists) {
        if ([userId isEqualToString:self.remoteMemberList[indexPath.row - 1].userId]) {
            return;
        }
    }
    
    if (!self.remoteMemberList[indexPath.row - 1].isSelect) {
        self.remoteMemberList[indexPath.row - 1].isSelect = YES;
    } else {
        self.remoteMemberList[indexPath.row - 1].isSelect = NO;
    }
    
    [self.selectTableView reloadData];
}

#pragma mark - Lazy

- (UITableView *)selectTableView {
    if (!_selectTableView) {
        _selectTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _selectTableView.delegate = self;
        _selectTableView.dataSource = self;
    }
    return _selectTableView;
}

#pragma mark - EventAction

- (void)addUsers:(UIButton *)sender {
    NSMutableArray<TUIUserModel *> *inviteUsers = [[NSMutableArray alloc] init];
    
    for (TUICallKitGroupMemberInfo *user in self.remoteMemberList) {
        BOOL isExist = NO;
        for (NSString *userId in [TUICallingUserManager allUserIdList]) {
            if ([userId isEqualToString:user.userId]) {
                isExist = YES;
                break;
            }
        }
        
        if (!isExist && user.isSelect) {
            TUIUserModel *addUser = [[TUIUserModel alloc] init];
            addUser.name = user.name;
            addUser.avatar = user.avatar;
            addUser.userId = user.userId;
            [inviteUsers addObject:addUser];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(addNewGroupUser:)]) {
        [self.delegate addNewGroupUser:inviteUsers];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)goBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
