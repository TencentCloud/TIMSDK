//
//  TContactsController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIContactController.h"
#import "TUIDefine.h"
#import "ReactiveObjC.h"
#import "TUIBlackListController.h"
#import "TUINewFriendViewController.h"
#import "TUIGroupConversationListController.h"
#import "TUIContactActionCell.h"
#import "TUIThemeManager.h"

#define kContactCellReuseId @"ContactCellReuseId"
#define kContactActionCellReuseId @"ContactActionCellReuseId"

@interface TUIContactController () <UITableViewDelegate, UITableViewDataSource, V2TIMFriendshipListener>
@property NSArray<TUIContactActionCellData *> *firstGroupData;
@end

@implementation TUIContactController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
        data.icon = TUIContactDynamicImage(@"contact_new_friend_img", [UIImage imageNamed:TUIContactImagePath(@"new_friend")]);
        data.title = TUIKitLocalizableString(TUIKitContactsNewFriends);
        data.cselector = @selector(onAddNewFriend:);
        data;
    })];
    [list addObject:({
        TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
        data.icon = TUIContactDynamicImage(@"contact_public_group_img", [UIImage imageNamed:TUIContactImagePath(@"public_group")]);
        data.title = TUIKitLocalizableString(TUIKitContactsGroupChats);
        data.cselector = @selector(onGroupConversation:);
        data;
    })];
    [list addObject:({
        TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
        data.icon = TUIContactDynamicImage(@"contact_blacklist_img", [UIImage imageNamed:TUIContactImagePath(@"blacklist")]);
        data.title = TUIKitLocalizableString(TUIKitContactsBlackList);
        data.cselector = @selector(onBlackList:);
        data;
    })];
    self.firstGroupData = [NSArray arrayWithArray:list];


    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    CGRect rect = self.view.bounds;
    if (![UINavigationBar appearance].isTranslucent && [[[UIDevice currentDevice] systemVersion] doubleValue]<15.0) {
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - TabBar_Height - NavBar_Height );
    }
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    
    _tableView.delaysContentTouches = NO;
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:_tableView];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    [_tableView registerClass:[TUICommonContactCell class] forCellReuseIdentifier:kContactCellReuseId];
    [_tableView registerClass:[TUIContactActionCell class] forCellReuseIdentifier:kContactActionCellReuseId];
    
    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
        @strongify(self)
        if ([(NSNumber *)finished boolValue]) {
            [self.tableView reloadData];
        }
    }];
    [RACObserve(self.viewModel, pendencyCnt) subscribeNext:^(NSNumber *x) {
        @strongify(self)
        self.firstGroupData[0].readNum = [x integerValue];
    }];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
}

- (void)onFriendInfoChanged:(NSNotification *)notice
{
    [self.viewModel loadContacts];
}

- (TUIContactViewDataProvider *)viewModel
{
    if (_viewModel == nil) {
        _viewModel = [TUIContactViewDataProvider new];
        [_viewModel loadContacts];
    }
    return _viewModel;
}


- (void)onFriendListChanged {
    [_viewModel loadContacts];
}

- (void)onFriendApplicationListChanged {
    [_viewModel loadFriendApplication];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.viewModel.groupList.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.firstGroupData.count;
    } else {
        NSString *group = self.viewModel.groupList[section-1];
        NSArray *list = self.viewModel.dataDict[group];
        return list.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;

#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont systemFontOfSize:16];
        textLabel.textColor = RGB(0x80, 0x80, 0x80);
        [headerView addSubview:textLabel];
        textLabel.mm_fill().mm_left(12);
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section-1];
    headerView.contentView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;

    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.viewModel.groupList];
    return array;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TUIContactActionCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactActionCellReuseId forIndexPath:indexPath];
        [cell fillWithData:self.firstGroupData[indexPath.row]];
        cell.changeColorWhenTouched = YES;
        return cell;
    } else {
        TUICommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellReuseId forIndexPath:indexPath];
        NSString *group = self.viewModel.groupList[indexPath.section-1];
        NSArray *list = self.viewModel.dataDict[group];
        TUICommonContactCellData *data = list[indexPath.row];
        data.cselector = @selector(onSelectFriend:);
        [cell fillWithData:data];
        cell.changeColorWhenTouched = YES;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark -
- (void)onSelectFriend:(TUICommonContactCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectFriend:)]) {
        [self.delegate onSelectFriend:cell];
    }
}

- (void)onAddNewFriend:(TUICommonTableViewCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onAddNewFriend:)]) {
        [self.delegate onAddNewFriend:cell];
    }
}

- (void)onGroupConversation:(TUICommonTableViewCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGroupConversation:)]) {
        [self.delegate onGroupConversation:cell];
    }
}

- (void)onBlackList:(TUICommonContactCell *)cell
{
    TUIBlackListController *vc = TUIBlackListController.new;
    @weakify(self);
    vc.didSelectCellBlock = ^(TUICommonContactCell * _Nonnull cell) {
        @strongify(self);
        [self onSelectFriend:cell];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)runSelector:(SEL)selector withObject:(id)object{
    if([self respondsToSelector:selector]){
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self, selector, object);
    }

}

@end
