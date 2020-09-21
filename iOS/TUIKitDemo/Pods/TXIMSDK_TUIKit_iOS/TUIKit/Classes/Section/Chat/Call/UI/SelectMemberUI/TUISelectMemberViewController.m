//
//  TUISelectMemberViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import "TUISelectMemberViewController.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "TUISelectMemberCell.h"
#import "TUIMemberPanelCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUICallUtils.h"
#import "TUIMemberPanelCell.h"

#define kUserBorder 44.0
#define kUserSpacing 2
#define kUserPanelLeftSpacing 15

@interface TUISelectMemberViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UIButton *cancelBtn;
@property(nonatomic,strong) UIButton *doneBtn;
@property(nonatomic,strong) UICollectionView *userPanel;
@property(nonatomic,strong) UITableView *selectTable;
@property(nonatomic,strong) NSMutableArray <UserModel *>*selectedUsers;

@property(nonatomic,assign) CGFloat topStartPosition;
@property(nonatomic,assign) CGFloat userPanelWidth;
@property(nonatomic,assign) CGFloat userPanelHeight;
@property(nonatomic,assign) CGFloat realSpacing;
@property(nonatomic,assign) NSInteger userPanelColumnCount;
@property(nonatomic,assign) NSInteger userPanelRowCount;

@property(nonatomic,strong) NSMutableArray *memberList;
@end

@implementation TUISelectMemberViewController {
    UICollectionView *_userPanel;
    UITableView *_selectTable;
    UIButton *_cancelBtn;
    UIButton *_doneBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发起呼叫";
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
    self.navigationItem.leftBarButtonItem = item;
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    self.navigationItem.rightBarButtonItem = item2;
    
    CGFloat topPadding = 44.f;
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        topPadding = window.safeAreaInsets.top;
    }
    
    topPadding = MAX(26, topPadding);
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    self.topStartPosition = topPadding + (navBarHeight > 0 ? navBarHeight : 44);
    self.memberList = [NSMutableArray array];
    self.selectedUsers = [NSMutableArray array];
    [self getMembers];
}

#pragma mark UI

/// 取消按钮
- (UIButton *)cancelBtn {
    if (!_cancelBtn.superview) {
         _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor d_systemBlueColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

/// 完成按钮
- (UIButton *)doneBtn {
    if (!_doneBtn.superview) {
        _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneBtn setAlpha:0.5];
        [_doneBtn setTitleColor:[UIColor d_systemBlueColor] forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

///已选用户面板
- (UICollectionView *)userPanel {
    if (!_userPanel.superview) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userPanel = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _userPanel.backgroundColor = [UIColor clearColor];
        [_userPanel registerClass:[TUIMemberPanelCell class] forCellWithReuseIdentifier:@"TUIMemberPanelCell"];
        if (@available(iOS 10.0, *)) {
            _userPanel.prefetchingEnabled = YES;
        } else {
            // Fallback on earlier versions
        }
        _userPanel.showsVerticalScrollIndicator = NO;
        _userPanel.showsHorizontalScrollIndicator = NO;
        _userPanel.contentMode = UIViewContentModeScaleAspectFit;
        _userPanel.scrollEnabled = NO;
        _userPanel.delegate = self;
        _userPanel.dataSource = self;
        [self.view addSubview:_userPanel];
    }
    return _userPanel;
}

///选择用户列表
- (UITableView *)selectTable {
    if (!_selectTable.superview) {
        _selectTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _selectTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_selectTable registerClass:[TUISelectMemberCell class] forCellReuseIdentifier:@"TUISelectMemberCell"];
        _selectTable.delegate = self;
        _selectTable.dataSource = self;
        [self.view addSubview:_selectTable];
        _selectTable.mm_width(self.view.mm_w).mm_top(self.topStartPosition + 10).mm_flexToBottom(0);
    }
    return _selectTable;
}

///更新 UI
- (void)updateUserPanel {
    self.userPanel.mm_height(self.userPanelHeight).mm_left(kUserPanelLeftSpacing).mm_flexToRight(0).mm_top(self.topStartPosition);
    self.selectTable.mm_width(self.view.mm_w).mm_top(self.userPanel.mm_maxY).mm_flexToBottom(0);
    @weakify(self)
    [self.userPanel performBatchUpdates:^{
        @strongify(self)
        [self.userPanel reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    [self.selectTable reloadData];
    self.doneBtn.alpha = (self.selectedUsers.count == 0 ?  0.5 : 1);
}

#pragma mark action

- (void)onNext {
    if (self.selectedUsers.count == 0) {
        return;
    }
    NSMutableArray *users = [NSMutableArray array];
    for (UserModel *model in self.selectedUsers) {
        [users addObject:[model copy]];
    }
    if (self.selectedFinished) {
        [self.navigationController popViewControllerAnimated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.selectedFinished(users);
        });
    }
}

/// 取消
-(void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TUISelectMemberCell";
    TUISelectMemberCell *cell = (TUISelectMemberCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TUISelectMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row < self.memberList.count) {
        UserModel *model = self.memberList[indexPath.row];
        BOOL isSelect = [self isUserSelected:model];
        [cell fillWithData:model isSelect:isSelect];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.textLabel.textColor = [UIColor d_systemGrayColor];
    footer.textLabel.font = [UIFont systemFontOfSize:14];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"群成员";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSelected = NO;
    UserModel *userSelected = [[UserModel alloc] init];
    if (indexPath.row < self.memberList.count) {
        UserModel *user = self.memberList[indexPath.row];
        isSelected = [self isUserSelected:user];
        userSelected = [user copy];
    }
    
    if (userSelected.userId.length == 0) {
        return;
    }
    
    if (isSelected) {
        for (UserModel *user in self.selectedUsers) {
            if ([user.userId isEqualToString:userSelected.userId]) {
                [self.selectedUsers removeObject:user];
                break;
            }
        }
    } else {
        [self.selectedUsers addObject:userSelected];
    }
    [self updateUserPanel];
}


#pragma mark UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedUsers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TUIMemberPanelCell";
    TUIMemberPanelCell *cell = (TUIMemberPanelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.selectedUsers.count) {
        [cell fillWithData:self.selectedUsers[indexPath.row]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kUserBorder, kUserBorder);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.row < self.selectedUsers.count) {
        // to do
    }
}

#pragma mark data
- (NSInteger)userPanelColumnCount {
    if (self.selectedUsers.count == 0) {
        return 0;
    }
    CGFloat totalWidth = self.view.mm_w - kUserPanelLeftSpacing;
    int columnCount = (int)(totalWidth / (kUserBorder + kUserSpacing));
    return columnCount;
}

- (CGFloat)realSpacing {
    CGFloat totalWidth = self.view.mm_w - kUserPanelLeftSpacing;
    if (self.userPanelColumnCount == 0 || self.userPanelColumnCount == 1) {
        return 0;
    }
    return (totalWidth - (CGFloat)self.userPanelColumnCount * kUserBorder) / ((CGFloat)self.userPanelColumnCount - 1);
}

- (NSInteger)userPanelRowCount {
    NSInteger userCount = self.selectedUsers.count;
    NSInteger columnCount = MAX(self.userPanelColumnCount, 1);
    NSInteger rowCount = userCount / columnCount;
    if (userCount % columnCount != 0) {
        rowCount += 1;
    }
    return rowCount;
}

- (CGFloat)userPanelWidth {
    return (CGFloat)self.userPanelColumnCount * kUserBorder + ((CGFloat)self.userPanelColumnCount - 1) * self.realSpacing;
}

- (CGFloat)userPanelHeight {
    return (CGFloat)self.userPanelRowCount * kUserBorder + ((CGFloat)self.userPanelRowCount - 1) * self.realSpacing;
}

- (void)getMembers {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupId filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        for (V2TIMGroupMemberFullInfo *info in memberList) {
            if ([info.userID isEqualToString:[TUICallUtils loginUser]]) {
                continue;
            }
            UserModel *model = [[UserModel alloc] init];
            model.userId = info.userID;
            if (info.nameCard != nil) {
                model.name = info.nameCard;
            } else if (info.friendRemark != nil) {
                model.name = info.friendRemark;
            } else if (info.nickName != nil) {
                model.name = info.nickName;
            } else {
                model.name = info.userID;
            }
            if (info.faceURL != nil) {
                model.avatar = info.faceURL;
            }
            [self.memberList addObject:model];
        }
        [self.selectTable reloadData];
    } fail:nil];
}

- (BOOL)isUserSelected:(UserModel *)user {
    BOOL isSelected = NO;
    for (UserModel *selectUser in self.selectedUsers) {
        if ([selectUser.userId isEqualToString:user.userId] && ![selectUser.userId isEqualToString:[TUICallUtils loginUser]]) {
            isSelected = YES;
            break;
        }
    }
    return isSelected;
}
@end
