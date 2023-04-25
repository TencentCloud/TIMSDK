//
//  TUISettingAdminController.m
//  TUIGroup
//
//  Created by harvy on 2021/12/28.
//

#import "TUISettingAdminController.h"
#import <TUICore/TUIGlobalization.h>
#import "TUIMemberInfoCell.h"
#import "TUIMemberInfoCellData.h"
#import "TUISettingAdminDataProvider.h"
#import "TUISelectGroupMemberViewController.h"
#import <TUICore/TUIThemeManager.h>

@interface TUISettingAdminController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TUISettingAdminDataProvider *dataProvider;

@end

@implementation TUISettingAdminController

- (void)dealloc {
    if (self.settingAdminDissmissCallBack) {
        self.settingAdminDissmissCallBack();
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    __weak typeof(self) weakSelf = self;
    self.dataProvider.groupID = self.groupID;
    [self.dataProvider loadData:^(int code, NSString *error) {
        [weakSelf.tableView reloadData];
        if (code != 0) {
            [weakSelf.view makeToast:error];
        }
    }];
}

- (void)setupViews
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(TUIKitGroupManageAdminSetting);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
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
    TUIMemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *subArray = self.dataProvider.datas[indexPath.section];
    TUIMemberInfoCellData *cellData = subArray[indexPath.row];
    cell.data = cellData;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        __weak typeof(self) weakSelf = self;
        TUISelectGroupMemberViewController *vc = [[TUISelectGroupMemberViewController alloc] init];
        vc.groupId = self.groupID;
        vc.name = TIMCommonLocalizableString(TUIKitGroupManageAdminSetting);
        vc.selectedFinished = ^(NSMutableArray<TUIUserModel *> * _Nonnull modelList) {
            [weakSelf.dataProvider settingAdmins:modelList callback:^(int code, NSString *errorMsg) {
                if (code != 0) {
                    [weakSelf.view makeToast:errorMsg];
                }
                [weakSelf.tableView reloadData];
            }];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 && indexPath.row > 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TIMCommonLocalizableString(Delete);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *subArray = self.dataProvider.datas[indexPath.section];
        TUIMemberInfoCellData *cellData = subArray[indexPath.row];
        __weak typeof(self) weakSelf = self;
        [self.dataProvider removeAdmin:cellData.identifier callback:^(int code, NSString *err) {
            if (code != 0) {
                [weakSelf.view makeToast:err];
            }
            [weakSelf.tableView reloadData];
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *subArray = self.dataProvider.datas[section];
    NSString *title = TIMCommonLocalizableString(TUIKitGroupOwner);
    if (section == 1) {
        title = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitGroupManagerFormat), subArray.count - 1, 10];
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    label.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:label];
    [label sizeToFit];
    label.mm_x = 20;
    label.mm_y = 10;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
        _tableView.delaysContentTouches = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:TUIMemberInfoCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (TUISettingAdminDataProvider *)dataProvider
{
    if (_dataProvider == nil) {
        _dataProvider = [[TUISettingAdminDataProvider alloc] init];
    }
    return _dataProvider;
}

@end
