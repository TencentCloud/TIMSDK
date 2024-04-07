//
//  TUIContactSelectController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactSelectController_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICommonContactSelectCell.h"
#import "TUICommonContactSelectCell_Minimalist.h"
#import "TUIContactSelectViewDataProvider_Minimalist.h"
#import "TUIContactUserPanelHeaderView_Minimalist.h"

@interface TUIContactSelectControllerHeaderView_Minimalist : UIView

@property(nonatomic, strong) UIImageView *avatarImageView;

@property(nonatomic, strong) UILabel *nameLabel;

@end

@implementation TUIContactSelectControllerHeaderView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    self.avatarImageView.image = [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_add_icon")];
    self.nameLabel.text = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateUI];
}
- (void)updateUI {
    self.avatarImageView.mm_width(kScale390(20)).mm_height(kScale390(20));
    self.avatarImageView.mm_left(kScale390(18));
    self.nameLabel.font = [UIFont systemFontOfSize:kScale390(16)];
    self.nameLabel.textColor = [UIColor tui_colorWithHex:@"#147AFF"];
    self.avatarImageView.mm_centerY = self.mm_centerY;
    self.nameLabel.mm_height(self.mm_h).mm_left(CGRectGetMaxX(self.avatarImageView.frame) + 14).mm_flexToRight(kScale390(16));
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:kScale390(18)];
    }
    return _nameLabel;
}
@end

@interface TUIContactSelectController_Minimalist () <UITableViewDelegate, UITableViewDataSource>

@property UITableView *tableView;
@property UIView *emptyView;
@property NSMutableArray<TUICommonContactSelectCellData_Minimalist *> *selectArray;
@property(nonatomic, strong) TUIContactSelectControllerHeaderView_Minimalist *addNewGroupHeaderView;
@property(nonatomic, strong) TUIContactUserPanelHeaderView_Minimalist *userPanelHeaderView;
@property(nonatomic, copy) void (^floatDataSourceChanged)(NSArray *arr);

@end

@implementation TUIContactSelectController_Minimalist
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
    self.viewModel = [TUIContactSelectViewDataProvider_Minimalist new];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TIMCommonLocalizableString(Done)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(finishTask)];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];

    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionIndexColor:[UIColor systemBlueColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    [_tableView registerClass:[TUICommonContactSelectCell_Minimalist class] forCellReuseIdentifier:@"TUICommonContactSelectCell_Minimalist"];
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

    _addNewGroupHeaderView = [[TUIContactSelectControllerHeaderView_Minimalist alloc] init];
    _addNewGroupHeaderView.nameLabel.text = TIMCommonLocalizableString(TUIKitRelayTargetCreateNewGroup);
    _addNewGroupHeaderView.nameLabel.font = [UIFont systemFontOfSize:15.0];
    [_addNewGroupHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCreateSessionOrSelectContact)]];
    _tableView.tableHeaderView = _addNewGroupHeaderView;

    [self setupBinds];
    if (self.sourceIds) {
        [self.viewModel setSourceIds:self.sourceIds displayNames:self.displayNames];
    } else {
        [self.viewModel loadContacts];
    }

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
    _tableView.mm_width(self.view.mm_w).mm_flexToBottom(0);
    if (self.maxSelectCount == 1) {
        self.addNewGroupHeaderView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 55);
        self.addNewGroupHeaderView.hidden = NO;
    } else {
        self.addNewGroupHeaderView.frame = CGRectZero;
        self.addNewGroupHeaderView.hidden = YES;
    }
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
        textLabel.font = [UIFont boldSystemFontOfSize:16];
        textLabel.textColor = [UIColor tui_colorWithHex:@"#000000"];
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
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.contentView.backgroundColor = [UIColor whiteColor];

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
    TUICommonContactSelectCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:@"TUICommonContactSelectCell_Minimalist" forIndexPath:indexPath];

    NSString *group = self.viewModel.groupList[indexPath.section];
    NSArray *list = self.viewModel.dataDict[group];
    TUICommonContactSelectCellData *data = list[indexPath.row];
    if (data.enabled) {
        data.cselector = @selector(didSelectContactCell:);
    } else {
        data.cselector = NULL;
    }
    if (self.maxSelectCount == 1) {
        cell.selectButton.hidden = YES;
    }

    [cell fillWithData:data];

    return cell;
}

- (void)contactListNilLabelTapped:(id)label {
    [TUITool makeToast:TIMCommonLocalizableString(TUIKitTipsContactListNil)];
}

- (void)didSelectContactCell:(TUICommonContactSelectCell *)cell {
    TUICommonContactSelectCellData *data = cell.selectData;
    if (!data.isSelected) {
        if (self.maxSelectCount > 0 && self.selectArray.count + 1 > self.maxSelectCount) {
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
    if (self.floatDataSourceChanged) {
        self.floatDataSourceChanged(self.selectArray);
    }

    if (self.maxSelectCount != 1) {
        if (self.selectArray.count > 0) {
            self.userPanelHeaderView.hidden = NO;
            self.userPanelHeaderView.frame = CGRectMake(0, kScale390(22), self.view.bounds.size.width, kScale390(62));
            self.userPanelHeaderView.selectedUsers = self.selectArray;
            @weakify(self);
            self.userPanelHeaderView.clickCallback = ^{
              @strongify(self);
              self.selectArray = self.userPanelHeaderView.selectedUsers;
              if (self.floatDataSourceChanged) {
                  self.floatDataSourceChanged(self.selectArray);
              }
              [self.userPanelHeaderView.userPanel reloadData];
              [self.tableView reloadData];
              if (self.selectArray.count == 0) {
                  [self hidePanelHeaderViewWhenUserSelectCountZero];
              }
            };
            self.tableView.tableHeaderView = self.userPanelHeaderView;
            self.tableView.tableHeaderView.userInteractionEnabled = YES;
            [self.userPanelHeaderView.userPanel reloadData];
        } else {
            [self hidePanelHeaderViewWhenUserSelectCountZero];
        }
    } else {
        [self finishTask];
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                 }];
    }
}
- (void)hidePanelHeaderViewWhenUserSelectCountZero {
    self.userPanelHeaderView.hidden = YES;
    self.userPanelHeaderView.frame = CGRectZero;
    self.tableView.tableHeaderView = self.userPanelHeaderView;
}

- (void)onCreateSessionOrSelectContact {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUIConversationCreatGroupNotification" object:nil];
                             }];
}

- (void)finishTask {
    if (self.finishBlock) {
        self.finishBlock(self.selectArray);
    }
}

- (TUIContactUserPanelHeaderView_Minimalist *)userPanelHeaderView {
    if (!_userPanelHeaderView) {
        _userPanelHeaderView = [[TUIContactUserPanelHeaderView_Minimalist alloc] init];
    }
    return _userPanelHeaderView;
}

#pragma mark - TUIChatFloatSubViewControllerProtocol
- (void)floatControllerLeftButtonClick {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                             }];
}

- (void)floatControllerRightButtonClick {
    [self finishTask];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                             }];
}
@end
