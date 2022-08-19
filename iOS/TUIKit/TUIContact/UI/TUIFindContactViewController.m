//
//  TUIFindContactViewController.m
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import "TUIFindContactViewController.h"
#import "TUIGlobalization.h"
#import "TUICore.h"
#import "TUIFindContactCell.h"
#import "TUIFindContactViewDataProvider.h"
#import "TUIThemeManager.h"

@interface TUIFindContactViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *noDataTipsLabel;
@property (nonatomic, strong) TUIFindContactViewDataProvider *provider;

@end

@implementation TUIFindContactViewController

- (void)dealloc
{
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:TUIKitLocalizableString(Cancel)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    NSString * tipsLabelText = [self.provider getMyUserIDDescription];
    if (self.type == TUIFindContactTypeGroup) {
        tipsLabelText = @"";
    }
    self.tipsLabel.text = tipsLabelText;
}

- (void)setupView
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text =self.type == TUIFindContactTypeC2C ? TUIKitLocalizableString(TUIKitAddFriend) : TUIKitLocalizableString(TUIKitAddGroup);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TUICoreDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = self.searchBar.backgroundColor;
    
    self.searchBar.frame = CGRectMake(10, 0, self.view.bounds.size.width - 20, 60);
    [self.view addSubview:self.searchBar];
    
    self.tableView.frame = CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60);
    [self.view addSubview:self.tableView];
    
    self.tipsLabel.frame = CGRectMake(10, 10, self.view.bounds.size.width - 20, 40);
    [self.tableView addSubview:self.tipsLabel];
    
    self.noDataTipsLabel.frame = CGRectMake(10, 60, self.view.bounds.size.width - 20, 40);
    [self.tableView addSubview:self.noDataTipsLabel];
    
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.type == TUIFindContactTypeC2C ? self.provider.users.count : self.provider.groups.count;
    self.noDataTipsLabel.hidden = !self.tipsLabel.hidden || count || self.searchBar.text.length == 0;
    self.noDataTipsLabel.text = self.type == TUIFindContactTypeC2C ? TUIKitLocalizableString(TUIKitAddUserNoDataTips) : TUIKitLocalizableString(TUIKitAddGroupNoDataTips);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIFindContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *result = self.type == TUIFindContactTypeC2C ? self.provider.users : self.provider.groups;
    TUIFindContactCellModel *cellModel = result[indexPath.row];
    cell.data = cellModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray *result = self.type == TUIFindContactTypeC2C ? self.provider.users : self.provider.groups;
    TUIFindContactCellModel *cellModel = result[indexPath.row];
    [self onSelectCellModel:cellModel];
}

- (void)onSelectCellModel:(TUIFindContactCellModel *)cellModel
{
    if (self.onSelect) {
        self.onSelect(cellModel);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self doSearchWithKeyword:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        [self.provider clear];
        [self.tableView reloadData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    self.tipsLabel.hidden = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self doSearchWithKeyword:searchBar.text];
}

- (void)doSearchWithKeyword:(NSString *)keyword
{
    __weak typeof(self) weakSelf = self;
    if (self.type == TUIFindContactTypeC2C) {
        [self.provider findUser:keyword completion:^{
            [weakSelf.tableView reloadData];
        }];
    } else {
        [self.provider findGroup:keyword completion:^{
            [weakSelf.tableView reloadData];
        }];
    }
}

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"F3F4F5");
        _searchBar.placeholder = self.type == TUIFindContactTypeC2C ? TUIKitLocalizableString(TUIKitSearchUserID) : TUIKitLocalizableString(TUIKitSearchGroupID);
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.delegate = self;
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            searchField.backgroundColor = TUICoreDynamicColor(@"search_textfield_bg_color", @"#FEFEFE");
        }
        
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:TUIKitLocalizableString(Search)];
    }
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"F3F4F5");
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:TUIFindContactCell.class forCellReuseIdentifier:@"cell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = self.type == TUIFindContactTypeC2C ? 72 : 94;
    }
    return _tableView;
}

- (UILabel *)tipsLabel
{
    if (_tipsLabel == nil) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = TUIContactDynamicColor(@"contact_add_contact_tips_text_color", @"#444444");
        _tipsLabel.font = [UIFont systemFontOfSize:12.0];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

- (UILabel *)noDataTipsLabel
{
    if (_noDataTipsLabel == nil) {
        _noDataTipsLabel = [[UILabel alloc] init];
        _noDataTipsLabel.textColor = TUIContactDynamicColor(@"contact_add_contact_nodata_tips_text_color", @"#999999");
        _noDataTipsLabel.font = [UIFont systemFontOfSize:14.0];
        _noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noDataTipsLabel;
}

- (TUIFindContactViewDataProvider *)provider
{
    if (_provider == nil) {
        _provider = [[TUIFindContactViewDataProvider alloc] init];
    }
    return _provider;
}

@end
