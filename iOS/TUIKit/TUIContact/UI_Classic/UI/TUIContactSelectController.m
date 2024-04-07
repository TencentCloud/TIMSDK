//
//  TUIContactSelectController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactSelectController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICommonContactSelectCell.h"
#import "TUIContactSelectViewDataProvider.h"

static NSString *gReuseIdentifier = @"ContactSelectCell";

@interface TUIContactSelectController () <UITableViewDelegate, UITableViewDataSource>

@property UITableView *tableView;
@property UIView *emptyView;
@property TUIContactListPicker *pickerView;
@property NSMutableArray<TUICommonContactSelectCellData *> *selectArray;

@end

@implementation TUIContactSelectController
@synthesize finishBlock;
@synthesize maxSelectCount;
@synthesize sourceIds;
@synthesize viewModel;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData {
    self.maxSelectCount = 0;
    self.selectArray = @[].mutableCopy;
    self.viewModel = [TUIContactSelectViewDataProvider new];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F3F5F9");
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    [_tableView registerClass:[TUICommonContactSelectCell class] forCellReuseIdentifier:gReuseIdentifier];
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_emptyView];
    _emptyView.mm_fill();
    _emptyView.hidden = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contactListNilLabelTapped:)];
    [_emptyView addGestureRecognizer:tapGesture];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_emptyView addSubview:tipsLabel];
    tipsLabel.text = TIMCommonLocalizableString(TUIKitTipsContactListNil);
    tipsLabel.mm_sizeToFit().tui_mm_center();

    _pickerView = [[TUIContactListPicker alloc] initWithFrame:CGRectZero];
    [_pickerView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.view addSubview:_pickerView];
    [_pickerView.accessoryBtn addTarget:self action:@selector(finishTask) forControlEvents:UIControlEventTouchUpInside];

    [self setupBinds];
    if (self.sourceIds) {
        [self.viewModel setSourceIds:self.sourceIds displayNames:self.displayNames];
    } else {
        [self.viewModel loadContacts];
    }

    self.view.backgroundColor = RGB(42, 42, 40);
    self.navigationItem.title = self.title;
}

- (void)setupBinds {
    @weakify(self);
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(NSNumber *finished) {
      @strongify(self);
      if ([finished boolValue]) {
          [self.tableView reloadData];
      }
    }];
    [RACObserve(self.viewModel, groupList) subscribeNext:^(NSArray *group) {
      @strongify(self);
      self.emptyView.hidden = (group.count > 0);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pickerView.mm_width(self.view.mm_w).mm_height(60 + _pickerView.mm_safeAreaBottomGap).mm_bottom(0);
    _tableView.mm_width(self.view.mm_w).mm_flexToBottom(_pickerView.mm_h);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{ return self.viewModel.groupList.count; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *group = self.viewModel.groupList[section];
    NSArray *list = self.viewModel.dataDict[group];
    return list.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont systemFontOfSize:16];
        textLabel.textColor = RGB(0x80, 0x80, 0x80);
        [textLabel setRtlAlignment:TUITextRTLAlignmentLeading];
        [headerView addSubview:textLabel];
        [textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(headerView.mas_leading).mas_offset(12);
            make.top.bottom.trailing.mas_equalTo(headerView);
        }];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.viewModel.groupList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonContactSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:gReuseIdentifier forIndexPath:indexPath];

    NSString *group = self.viewModel.groupList[indexPath.section];
    NSArray *list = self.viewModel.dataDict[group];
    TUICommonContactSelectCellData *data = list[indexPath.row];
    if (data.enabled) {
        data.cselector = @selector(didSelectContactCell:);
    } else {
        data.cselector = NULL;
    }
    [cell fillWithData:data];
    return cell;
}

- (void)didSelectContactCell:(TUICommonContactSelectCell *)cell {
    TUICommonContactSelectCellData *data = cell.selectData;
    if (!data.isSelected) {
        if (maxSelectCount > 0 && self.selectArray.count + 1 > self.maxSelectCount) {
            [TUITool makeToast:[NSString stringWithFormat:TIMCommonLocalizableString(TUIKitTipsMostSelectTextFormat), (long)self.maxSelectCount]];
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

- (void)contactListNilLabelTapped:(id)label {
    [TUITool makeToast:TIMCommonLocalizableString(TUIKitTipsContactListNil)];
}

- (void)finishTask {
    if (self.finishBlock) {
        self.finishBlock(self.selectArray);
    }
}

@end
