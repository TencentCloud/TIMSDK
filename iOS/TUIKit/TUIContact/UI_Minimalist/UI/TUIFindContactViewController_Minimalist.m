//
//  TUIFindContactViewController.m
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFindContactViewController_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIContactEmptyView_Minimalist.h"
#import "TUIFindContactCell_Minimalist.h"
#import "TUIFindContactViewDataProvider_Minimalist.h"

@interface TUIFindContactViewController_Minimalist () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UILabel *tipsLabel;
@property(nonatomic, strong) TUIContactEmptyView_Minimalist *noDataEmptyView;

@property(nonatomic, strong) TUIFindContactViewDataProvider_Minimalist *provider;

@end

@implementation TUIFindContactViewController_Minimalist

- (void)dealloc {
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[ [UISearchBar class] ]] setTitle:TIMCommonLocalizableString(Cancel)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    NSString *tipsLabelText = [self.provider getMyUserIDDescription];
    if (self.type == TUIFindContactTypeGroup_Minimalist) {
        tipsLabelText = @"";
    }
    self.tipsLabel.text = tipsLabelText;
}

- (void)setupView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;  // Not setting it will cause some problems such as position confusion and no animation.

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.type == TUIFindContactTypeC2C_Minimalist ? TIMCommonLocalizableString(TUIKitAddFriend) : TIMCommonLocalizableString(TUIKitAddGroup);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = [UIColor whiteColor];

    self.searchBar.frame = CGRectMake(10, 0, self.view.bounds.size.width - 20, kScale390(38));
    self.searchBar.layer.cornerRadius = kScale390(10);
    self.searchBar.layer.masksToBounds = YES;
    [self.view addSubview:self.searchBar];

    self.tableView.frame = CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60);
    [self.view addSubview:self.tableView];

    self.tipsLabel.frame = CGRectMake(10, 10, self.view.bounds.size.width - 20, 40);
    [self.tableView addSubview:self.tipsLabel];

    self.noDataEmptyView.frame = CGRectMake(0, kScale390(42), self.view.bounds.size.width - 20, 200);
    [self.tableView addSubview:self.noDataEmptyView];
}
- (TUIContactEmptyView_Minimalist *)noDataEmptyView {
    if (_noDataEmptyView == nil) {
        _noDataEmptyView = [[TUIContactEmptyView_Minimalist alloc]
            initWithImage:[UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_not_found_icon")]
                     Text:(self.type == TUIFindContactTypeC2C_Minimalist ? TIMCommonLocalizableString(TUIKitAddUserNoDataTips)
                                                                         : TIMCommonLocalizableString(TUIKitAddGroupNoDataTips))];
        _noDataEmptyView.hidden = YES;
    }
    return _noDataEmptyView;
}
#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.type == TUIFindContactTypeC2C_Minimalist ? self.provider.users.count : self.provider.groups.count;
    self.noDataEmptyView.hidden = !self.tipsLabel.hidden || count || self.searchBar.text.length == 0;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIFindContactCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *result = self.type == TUIFindContactTypeC2C_Minimalist ? self.provider.users : self.provider.groups;
    TUIFindContactCellModel_Minimalist *cellModel = result[indexPath.row];
    cell.data = cellModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSArray *result = self.type == TUIFindContactTypeC2C_Minimalist ? self.provider.users : self.provider.groups;
    TUIFindContactCellModel_Minimalist *cellModel = result[indexPath.row];
    [self onSelectCellModel:cellModel];
}

- (void)onSelectCellModel:(TUIFindContactCellModel_Minimalist *)cellModel {
    if (self.onSelect) {
        self.onSelect(cellModel);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self doSearchWithKeyword:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.provider clear];
        [self.tableView reloadData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.tipsLabel.hidden = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self doSearchWithKeyword:searchBar.text];
}

- (void)doSearchWithKeyword:(NSString *)keyword {
    __weak typeof(self) weakSelf = self;
    if (self.type == TUIFindContactTypeC2C_Minimalist) {
        [self.provider findUser:keyword
                     completion:^{
                       [weakSelf.tableView reloadData];
                     }];
    } else {
        [self.provider findGroup:keyword
                      completion:^{
                        [weakSelf.tableView reloadData];
                      }];
    }
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
        _searchBar.placeholder =
            self.type == TUIFindContactTypeC2C_Minimalist ? TIMCommonLocalizableString(TUIKitSearchUserID) : TIMCommonLocalizableString(TUIKitSearchGroupID);
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.delegate = self;
        _searchBar.searchTextField.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            searchField.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
        }

        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[ [UISearchBar class] ]] setTitle:TIMCommonLocalizableString(Search)];
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:TUIFindContactCell_Minimalist.class forCellReuseIdentifier:@"cell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = self.type == TUIFindContactTypeC2C_Minimalist ? kScale390(63) : kScale390(93);
    }
    return _tableView;
}

- (UILabel *)tipsLabel {
    if (_tipsLabel == nil) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = TUIContactDynamicColor(@"contact_add_contact_tips_text_color", @"#444444");
        _tipsLabel.font = [UIFont systemFontOfSize:12.0];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

- (TUIFindContactViewDataProvider_Minimalist *)provider {
    if (_provider == nil) {
        _provider = [[TUIFindContactViewDataProvider_Minimalist alloc] init];
    }
    return _provider;
}

@end
