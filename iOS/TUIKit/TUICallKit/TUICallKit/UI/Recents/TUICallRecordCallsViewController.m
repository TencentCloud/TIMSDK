//
//  TUICallRecordCallsViewController.m
//  TUICallKit
//
//  Created by noah on 2023/2/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICallRecordCallsViewController.h"
#import "Masonry.h"
#import "TUICore.h"
#import "TUICallingCommon.h"
#import "TUICallRecordCallsViewModel.h"
#import "TUICallRecordCallsCell.h"
#import "CallingLocalized.h"
#import "TUIThemeManager.h"

static NSString *const gRecordCallsViewModelKVOKeyPath = @"dataSource";

@interface TUICallRecordCallsViewController ()<UITableViewDelegate, UITableViewDataSource>

/// 头部导航容器视图
@property (nonatomic, strong) UIView *containerView;
/// 开始编辑按钮
@property (nonatomic, strong) UIButton *editButton;
/// 清除所有记录按钮
@property (nonatomic, strong) UIButton *clearButton;
/// 编辑完成按钮
@property (nonatomic, strong) UIButton *doneButton;
/// 分段控制视图
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
/// 无最近通话提示文本
@property (nonatomic, strong) UILabel *notRecordCallsLabel;
/// 列表表头视图
@property (nonatomic, strong) UIView *tableHeaderView;
/// 通话记录列表
@property (nonatomic, strong) UITableView *recordCallsList;

@property (nonatomic, readwrite, strong) TUICallRecordCallsViewModel *recordCallsViewModel;

@end

@implementation TUICallRecordCallsViewController

- (instancetype)initWithRecordCallsUIStyle:(TUICallKitRecordCallsUIStyle)recordCallsUIStyle {
    self = [super init];
    if (self) {
        _recordCallsViewModel = [[TUICallRecordCallsViewModel alloc] init];
        _recordCallsViewModel.recordCallsUIStyle = recordCallsUIStyle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TUICallKitDynamicColor(@"callkit_recents_bg_color", @"#FFFFFF");
    [self constructViewHierarchy];
    [self activateConstraints];
    [self bindInteraction];
    [self bindViewModel];
    [self.recordCallsViewModel queryRecentCalls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.recordCallsViewModel queryRecentCalls];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidChange)
                                                 name:UIWindowDidBecomeKeyNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
}

- (void)dealloc {
    [self removeBindViewModel];
}

- (void)constructViewHierarchy {
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.segmentedControl];
    [self.containerView addSubview:self.editButton];
    [self.containerView addSubview:self.clearButton];
    [self.containerView addSubview:self.doneButton];
    [self.view addSubview:self.notRecordCallsLabel];
    [self.view addSubview:self.recordCallsList];
}

- (void)activateConstraints {
    CGFloat statusBarHeight = [TUICallingCommon getStatusBarHeight];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.width.equalTo(self.view);
        make.height.equalTo(@(statusBarHeight + 44));
    }];
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(statusBarHeight + 6.0);
        make.centerX.equalTo(self.containerView);
        make.width.equalTo(@(180));
        make.height.equalTo(@(32));
    }];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.segmentedControl);
        make.trailing.equalTo(self.containerView).offset(-20);
        make.width.height.equalTo(@(32));
    }];
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.segmentedControl);
        make.leading.equalTo(self.containerView).offset(20);
        make.height.equalTo(@(32));
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.segmentedControl);
        make.trailing.equalTo(self.containerView).offset(-20);
        make.height.equalTo(@(32));
    }];
    [self.recordCallsList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(statusBarHeight + 44);
        make.centerX.width.bottom.equalTo(self.view);
    }];
    [self.notRecordCallsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.equalTo(self.view);
    }];
}

- (void)bindInteraction {
    [self.clearButton addTarget:self action:@selector(clearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton addTarget:self action:@selector(doneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.segmentedControl addTarget:self action:@selector(segmentSelectItem:) forControlEvents:UIControlEventValueChanged];
}

- (void)bindViewModel {
    [self.recordCallsViewModel addObserver:self forKeyPath:gRecordCallsViewModelKVOKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeBindViewModel {
    @try {
        [self.recordCallsViewModel removeObserver:self forKeyPath:gRecordCallsViewModelKVOKeyPath context:nil];
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - event action

- (void)windowDidChange {
    [self.recordCallsViewModel queryRecentCalls];
}

- (void)clearButtonClick:(UIButton *)button {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self)weakSelf = self;
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:TUICallingLocalize(@"TUICallKit.Recents.clear.all")
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.recordCallsList setEditing:NO animated:YES];
        [strongSelf showButtonStatus:NO];
        [strongSelf.recordCallsViewModel clearAllRecordCalls];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TUICallingLocalize(@"TUICallKit.Recents.clear.cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:clearAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editButtonClick:(UIButton *)button {
    [self.recordCallsList setEditing:YES animated:YES];
    [self showButtonStatus:YES];
}

- (void)doneButtonClick:(UIButton *)button {
    [self.recordCallsList setEditing:NO animated:YES];
    [self showButtonStatus:NO];
}

- (void)callButtonClick:(UIButton *)button {
    
}

- (void)segmentSelectItem:(UISegmentedControl *)sender {
    [self showButtonStatus:NO];
    [self.recordCallsList setEditing:NO animated:YES];
    TUICallRecordCallsType recordCallsType = TUICallRecordCallsTypeAll;
    
    if (sender.selectedSegmentIndex == 1) {
        recordCallsType = TUICallRecordCallsTypeMissed;
    }
    
    [self.recordCallsViewModel switchRecordCallsType:recordCallsType];
}

- (void)showButtonStatus:(BOOL)isEdit {
    self.editButton.hidden = isEdit;
    self.clearButton.hidden = !isEdit;
    self.doneButton.hidden = !isEdit;
}

#pragma mark - observeValueForKeyPath

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:gRecordCallsViewModelKVOKeyPath]) {
        dispatch_callkit_main_async_safe(^{
            [self.recordCallsList reloadData];
            
            if (self.recordCallsViewModel.dataSource <= 0) {
                [self.recordCallsList setEditing:NO animated:YES];
                [self showButtonStatus:NO];
            }
        });
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.recordCallsViewModel deleteRecordCall:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TUICallingLocalize(@"TUICallKit.Recents.delete");
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                      title:TUICallingLocalize(@"TUICallKit.Recents.delete")
                                                                    handler:^(UITableViewRowAction * _Nonnull action,
                                                                              NSIndexPath * _Nonnull indexPath) {
        [self.recordCallsViewModel deleteRecordCall:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    delete.backgroundColor = [UIColor redColor];
    return @[delete];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.0, *)) {
        UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                      title:TUICallingLocalize(@"TUICallKit.Recents.delete")
                                                                                    handler:^(UIContextualAction * _Nonnull action,
                                                                                              __kindof UIView * _Nonnull sourceView,
                                                                                              void (^ _Nonnull completionHandler)(BOOL)) {
            [self.recordCallsViewModel deleteRecordCall:indexPath];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        deleteRowAction.backgroundColor = [UIColor redColor];
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
        config.performsFirstActionWithFullSwipe = false;
        [self showButtonStatus:YES];
        return config;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordCallsViewModel.dataSource ? self.recordCallsViewModel.dataSource.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICallRecordCallsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TUICallRecordCallsCell class])
                                                                   forIndexPath:indexPath];
    __weak typeof(self)weakSelf = self;
    cell.moreBtnClickedHandler = ^(TUICallRecordCallsCell *recordCallsCell) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.recordCallsViewModel jumpUserInfoController:indexPath navigationController:strongSelf.navigationController];
    };
    
    TUICallRecordCallsCellViewModel *viewModel = self.recordCallsViewModel.dataSource[indexPath.row];
    [cell bindViewModel:viewModel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.recordCallsViewModel repeatCall:indexPath];
}

#pragma mark - getter and setter

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        if (TUICallKitRecordCallsUIStyleClassic == self.recordCallsViewModel.recordCallsUIStyle) {
            _containerView.backgroundColor = TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
        } else {
            _containerView.backgroundColor = TUICallKitDynamicColor(@"callkit_recents_bg_color", @"#FFFFFF");
        }
    }
    return _containerView;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setTitle:TUICallingLocalize(@"TUICallKit.Recents.clear") forState:UIControlStateNormal];
        clearButton.titleLabel.textAlignment = isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft;
        clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [clearButton setTitleColor:TUICallKitDynamicColor(@"callkit_nav_title_text_color", @"#000000") forState:UIControlStateNormal];
        clearButton.hidden = YES;
        [clearButton.titleLabel sizeToFit];
        clearButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _clearButton = clearButton;
    }
    return _clearButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setImage:[TUICallingCommon getBundleImageWithName:@"ic_calls_edit"] forState:UIControlStateNormal];
        editButton.titleLabel.textAlignment = isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft;
        editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _editButton = editButton;
    }
    return _editButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:TUICallingLocalize(@"TUICallKit.Recents.done") forState:UIControlStateNormal];
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [doneButton setTitleColor:TUICallKitDynamicColor(@"callkit_nav_title_text_color", @"#000000") forState:UIControlStateNormal];
        [doneButton.titleLabel sizeToFit];
        doneButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        doneButton.hidden = YES;
        _doneButton = doneButton;
    }
    return _doneButton;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        NSArray *array = [NSArray arrayWithObjects:TUICallingLocalize(@"TUICallKit.Recents.all"),
                          TUICallingLocalize(@"TUICallKit.Recents.missed"), nil];
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:array];
        segment.selectedSegmentIndex = 0;
        _segmentedControl = segment;
    }
    return _segmentedControl;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 80)];
        UILabel *label = [[UILabel alloc] init];
        label.textColor = TUICallKitDynamicColor(@"callkit_recents_tableHeader_title_text_color", @"#000000");
        label.text = TUICallingLocalize(@"TUICallKit.Recents.calls");
        label.font = [UIFont fontWithName:@"PingFangHK-Semibold" size:34];
        label.textAlignment = isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft;
        [tableHeaderView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(tableHeaderView);
            make.leading.equalTo(tableHeaderView).offset(20);
        }];
        _tableHeaderView = tableHeaderView;
    }
    return _tableHeaderView;
}

- (UITableView *)recordCallsList {
    if (!_recordCallsList) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.tableHeaderView = self.tableHeaderView;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = self.view.backgroundColor;
        [tableView registerClass:[TUICallRecordCallsCell class] forCellReuseIdentifier:NSStringFromClass([TUICallRecordCallsCell class])];
        _recordCallsList = tableView;
    }
    return _recordCallsList;
}

- (UILabel *)notRecordCallsLabel {
    if (!_notRecordCallsLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = UIColor.grayColor;
        label.font = [UIFont systemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        label.hidden = YES;
        _notRecordCallsLabel = label;
    }
    return _notRecordCallsLabel;
}

@end
