//
//  TUIGroupManageController.m
//  TUIGroup
//
//  Created by harvy on 2021/12/24.
//

#import "TUIGroupManageController_Minimalist.h"
#import "TUIGlobalization.h"
#import "TUIGroupManageDataProvider.h"
#import "TUIAddCellData.h"
#import "TUIAddCell.h"
#import "TUIMemberInfoCellData.h"
#import "TUIMemberInfoCell.h"
#import "TUISelectGroupMemberViewController_Minimalist.h"
#import "TUISettingAdminController_Minimalist.h"
#import "TUIThemeManager.h"

@interface TUIGroupManageController_Minimalist () <UITableViewDelegate, UITableViewDataSource, TUIGroupManageDataProviderDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TUIGroupManageDataProvider *dataProvider;
@property (nonatomic, strong) UIView *coverView;

@end

@implementation TUIGroupManageController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    self.dataProvider.groupID = self.groupID;
    [self showCoverViewWhenMuteAll:YES];
    [self.dataProvider loadData];
}

- (void)setupViews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TUIKitLocalizableString(TUIKitGroupProfileManage);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TUICoreDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)onSettingAdmin:(TUICommonTextCellData *)textData
{
    if (!self.dataProvider.currentGroupTypeSupportSettingAdmin) {
        [TUITool makeToast:TUIKitLocalizableString(TUIKitGroupSetAdminsForbidden)];
        return;
    }
    TUISettingAdminController_Minimalist *vc = [[TUISettingAdminController_Minimalist alloc] init];
    vc.groupID = self.groupID;
    __weak typeof(self)weakSelf = self;
    vc.settingAdminDissmissCallBack = ^{
        [weakSelf.dataProvider updateMuteMembersFilterAdmins];
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onMutedAll:(TUICommonSwitchCell *)switchCell
{
    __weak typeof(self) weakSelf = self;
    [self.dataProvider mutedAll:switchCell.switcher.isOn completion:^(int code, NSString * error) {
        if (code != 0) {
            switchCell.switcher.on = !switchCell.switcher.isOn;
            [weakSelf.view makeToast:error];
            return;
        }
        [weakSelf showCoverViewWhenMuteAll:switchCell.switcher.isOn];
    }];
}

#pragma mark - TUIGroupManageDataProviderDelegate
- (void)onError:(int)code desc:(NSString *)desc operate:(NSString *)operate
{
    if (code != 0) {
        [TUITool makeToast:[NSString stringWithFormat:@"%d, %@", code, desc]];
    }
}

- (void)showCoverViewWhenMuteAll:(BOOL)show
{
    [self.coverView removeFromSuperview];
    if (show) {
        CGFloat y = 0;
        if (self.dataProvider.datas.count == 0) {
            y = 100;
        } else {
            CGRect rect = [self.tableView rectForSection:0];
            y = CGRectGetMaxY(rect);
        }
        self.coverView.frame = CGRectMake(0, y, self.tableView.mm_w, self.tableView.mm_h);
        [self.tableView addSubview:self.coverView];
    }
}


- (void)reloadData
{
    [self.tableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showCoverViewWhenMuteAll:weakSelf.dataProvider.muteAll];
    });
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView insertSections:sections withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataProvider.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArray = self.dataProvider.datas[section];
    return subArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSArray *subArray = self.dataProvider.datas[indexPath.section];
    TUICommonCellData *data = subArray[indexPath.row];
    
    if ([data isKindOfClass:TUICommonTextCellData.class]) {
        cell = [[TUICommonTextCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(TUICommonTextCell.class)];
        [(TUICommonTextCell *)cell fillWithData:(TUICommonTextCellData *)data];
    } else if ([data isKindOfClass:TUICommonSwitchCellData.class]) {
        cell = [[TUICommonSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(TUICommonSwitchCell.class)];
        [(TUICommonSwitchCell *)cell fillWithData:(TUICommonSwitchCellData *)data];
    } else if ([data isKindOfClass:TUIAddCellData.class]) {
        cell = [[TUIAddCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(TUIAddCell.class)];
        [(TUIAddCell *)cell setData:(TUIAddCellData *)data];
    } else if ([data isKindOfClass:TUIMemberInfoCellData.class]) {
        cell = [[TUIMemberInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(TUIMemberInfoCell.class)];
        [(TUIMemberInfoCell *)cell setData:(TUIMemberInfoCellData *)data];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = @"";
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 0 ? 30 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = TUIKitLocalizableString(TUIKitGroupManageShutupAllTips);
    label.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    label.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:label];
    [label sizeToFit];
    label.mm_x = 20;
    label.mm_y = 10;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (!self.dataProvider.currentGroupTypeSupportAddMemberOfBlocked) {
            [TUITool makeToast:TUIKitLocalizableString(TUIKitGroupAddMemberOfBlockedForbidden)];
            return;
        }

        TUISelectGroupMemberViewController_Minimalist *vc = [[TUISelectGroupMemberViewController_Minimalist alloc] init];
        vc.optionalStyle = TUISelectMemberOptionalStylePublicMan;
        vc.groupId = self.groupID;
        vc.name = TUIKitLocalizableString(TUIKitGroupProfileMember);
        __weak typeof(self) weakSelf = self;
        vc.selectedFinished = ^(NSMutableArray<TUIUserModel *> * _Nonnull modelList) {
            for (TUIUserModel *userModel in modelList) {
                [weakSelf.dataProvider mute:YES user:userModel];
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TUIKitLocalizableString(Delete);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row > 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TUIMemberInfoCellData *cellData = self.dataProvider.datas[indexPath.section][indexPath.row];
        if (![cellData isKindOfClass:TUIMemberInfoCellData.class]) {
            return;
        }
        
        TUIUserModel *userModel = [[TUIUserModel alloc] init];
        userModel.userId = cellData.identifier;
        [self.dataProvider mute:NO user:userModel];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
        _tableView.delaysContentTouches = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (TUIGroupManageDataProvider *)dataProvider
{
    if (_dataProvider == nil) {
        _dataProvider = [[TUIGroupManageDataProvider alloc] init];
        _dataProvider.delegate = self;
    }
    return _dataProvider;
}

- (UIView *)coverView
{
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = self.tableView.backgroundColor;
    }
    return _coverView;
}

@end
