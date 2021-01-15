//
//  TUIContactSelectController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//

#import "TUIContactSelectController.h"
#import "TCommonContactSelectCell.h"
#import "TContactSelectViewModel.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIContactListPicker.h"
#import "UIImage+TUIKIT.h"
#import "THeader.h"
#import "Toast/Toast.h"
#import "THelper.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"

static NSString *kReuseIdentifier = @"ContactSelectCell";

@interface TUIContactSelectController ()<UITableViewDelegate,UITableViewDataSource>

@property UITableView *tableView;
@property UIView *emptyView;
@property TUIContactListPicker *pickerView;
@property NSMutableArray *selectArray;

@end

@implementation TUIContactSelectController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData
{
    self.maxSelectCount = INT_MAX;
    self.selectArray = @[].mutableCopy;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    //cell无数据时，不显示间隔线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    [_tableView registerClass:[TCommonContactSelectCell class] forCellReuseIdentifier:kReuseIdentifier];

    _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_emptyView];
    _emptyView.mm_fill();
    _emptyView.hidden = YES;

    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_emptyView addSubview:tipsLabel];
    tipsLabel.text = TUILocalizableString(TUIKitTipsContactListNil);
    tipsLabel.mm_sizeToFit().mm_center();


    _pickerView = [[TUIContactListPicker alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_pickerView];
    [_pickerView.accessoryBtn addTarget:self action:@selector(finishTask) forControlEvents:UIControlEventTouchUpInside];

    [self setupBinds];

    if (self.sourceIds) {
        [self.viewModel setSourceIds:self.sourceIds];
    } else {
        [self.viewModel loadContacts];
    }

    self.view.backgroundColor = RGB(42,42,40);
}

- (void)setupBinds
{
    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(NSNumber *finished) {
        @strongify(self)
        if ([finished boolValue]) {
            [self.tableView reloadData];
        }
    }];
    [RACObserve(self.viewModel, groupList) subscribeNext:^(NSArray *group) {
        @strongify(self)
        self.emptyView.hidden = (group.count > 0);
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _pickerView.mm_width(self.view.mm_w).mm_height(60+_pickerView.mm_safeAreaBottomGap).mm_bottom(0);
    _tableView.mm_width(self.view.mm_w).mm_flexToBottom(_pickerView.mm_h);
}

- (TContactSelectViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [TContactSelectViewModel new];
    }
    return _viewModel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.viewModel.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *group = self.viewModel.groupList[section];
    NSArray *list = self.viewModel.dataDict[group];
    return list.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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
    label.text = self.viewModel.groupList[section];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{   
    return 33;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.viewModel.groupList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCommonContactSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];

    NSString *group = self.viewModel.groupList[indexPath.section];
    NSArray *list = self.viewModel.dataDict[group];
    TCommonContactSelectCellData *data = list[indexPath.row];
    if (data.enabled) {
        data.cselector = @selector(didSelectContactCell:);
    } else {
        data.cselector = NULL;
    }
    [cell fillWithData:data];
    return cell;
}

- (void)didSelectContactCell:(TCommonContactSelectCell *)cell
{
    TCommonContactSelectCellData *data = cell.selectData;
    if (!data.isSelected) {
        if (self.selectArray.count + 1 > self.maxSelectCount) {
            [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitTipsMostSelectTextFormat),(long)self.maxSelectCount]];
            return;
        }
    }
    data.selected = !data.isSelected;
    [cell fillWithData:data];
    if (data.isSelected) {
        [self.selectArray addObject:data];
    } else {
        [self.selectArray removeObject:data];
    }
    self.pickerView.selectArray = [self.selectArray copy];
}

- (void)finishTask
{
    if (self.finishBlock) {
        self.finishBlock(self.selectArray);
    }
}

@end
