//
//  TelephoneAreaCodeSelectorController.m
//  TUIKitDemo
//
//  Created by harvy on 2021/12/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TelephoneAreaCodeSelectorController.h"
#import "TUIDarkModel.h"
#import "TelephoneAreaCodeDataProvider.h"
#import "UIView+TUILayout.h"

@interface TelephoneAreaCodeSelectorController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) TelephoneAreaCodeDataProvider *dataProvider;

@end

@implementation TelephoneAreaCodeSelectorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    __weak typeof(self) weakSelf = self;
    [self.dataProvider searchWithKeyword:@"" callback:^{
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:UIColor.blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:UIColor.blackColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.searchBar.frame = CGRectMake(10, 0, self.view.bounds.size.width - 20, 60);
    self.tableView.frame = CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60);
}

- (void)setupViews
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题
    
    self.view.backgroundColor = self.searchBar.backgroundColor;
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"ChooseNationOrRegion", nil);
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = YES;
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    [self.dataProvider searchWithKeyword:searchBar.text callback:^{
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource. UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataProvider.indexs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *index = self.dataProvider.indexs[section];
    if (![self.dataProvider.datas.allKeys containsObject:index]) {
        return 0;
    }
    NSArray *array = self.dataProvider.datas[index];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    TelephoneAreaCode *code = nil;
    NSString *index = self.dataProvider.indexs[indexPath.section];
    if ([self.dataProvider.datas.allKeys containsObject:index]) {
        NSArray *array = self.dataProvider.datas[index];
        code = array[indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = code.displayName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@", code.code];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TelephoneAreaCode *code = nil;
    NSString *index = self.dataProvider.indexs[indexPath.section];
    if ([self.dataProvider.datas.allKeys containsObject:index]) {
        NSArray *array = self.dataProvider.datas[index];
        code = array[indexPath.row];
    }
    
    if (!code) {
        return;
    }
    
    if (self.onSelect) {
        self.onSelect(code);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.dataProvider.indexs;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = self.dataProvider.indexs[section];
    label.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    label.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:label];
    [label sizeToFit];
    label.mm_x = 20;
    label.mm_y = 10;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:UIColor.blackColor];
        _searchBar.placeholder = NSLocalizedString(@"Search", nil);
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.tintColor = [UIColor d_colorWithColorLight:UIColor.darkTextColor dark:UIColor.lightGrayColor];
        _searchBar.delegate = self;
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            searchField.backgroundColor = [UIColor d_colorWithColorLight:[UIColor groupTableViewBackgroundColor] dark:UIColor.lightGrayColor];
        }
    }
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.sectionIndexColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    }
    return _tableView;
}

- (TelephoneAreaCodeDataProvider *)dataProvider
{
    if (_dataProvider == nil) {
        _dataProvider = [[TelephoneAreaCodeDataProvider alloc] init];
    }
    return _dataProvider;
}

@end
