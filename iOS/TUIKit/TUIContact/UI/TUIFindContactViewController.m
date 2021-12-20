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


@interface TUIFindContactViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
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
}

- (void)setupView
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题
    
    self.navigationItem.title = self.type == TUIFindContactTypeC2C ? TUIKitLocalizableString(TUIKitAddFriend) : TUIKitLocalizableString(TUIKitAddGroup);
    self.view.backgroundColor = self.searchBar.backgroundColor;
    
    self.searchBar.frame = CGRectMake(10, 0, self.view.bounds.size.width - 20, 60);
    [self.view addSubview:self.searchBar];
    
    self.tableView.frame = CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60);
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.type == TUIFindContactTypeC2C ? self.provider.users.count : self.provider.groups.count;
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
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
        _searchBar.backgroundColor = [UIColor d_colorWithColorLight:[UIColor colorWithRed:235/255.0 green:240/255.0 blue:246/255.0 alpha:1/1.0] dark:UIColor.blackColor];
        _searchBar.placeholder = self.type == TUIFindContactTypeC2C ? TUIKitLocalizableString(TUIKitSearchUserID) : TUIKitLocalizableString(TUIKitSearchGroupID);
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.tintColor = [UIColor d_colorWithColorLight:UIColor.darkTextColor dark:UIColor.lightGrayColor];
        _searchBar.delegate = self;
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            searchField.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:UIColor.lightGrayColor];
        }
        
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:TUIKitLocalizableString(Search)];
    }
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor d_colorWithColorLight:[UIColor groupTableViewBackgroundColor] dark:TController_Background_Color_Dark];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:TUIFindContactCell.class forCellReuseIdentifier:@"cell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = self.type == TUIFindContactTypeC2C ? 72 : 94;
    }
    return _tableView;
}

- (TUIFindContactViewDataProvider *)provider
{
    if (_provider == nil) {
        _provider = [[TUIFindContactViewDataProvider alloc] init];
    }
    return _provider;
}

@end
