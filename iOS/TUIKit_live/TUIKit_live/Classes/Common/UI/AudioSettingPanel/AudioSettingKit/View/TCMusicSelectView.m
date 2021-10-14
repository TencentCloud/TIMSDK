//
//  TCMusicSelectView.m
//  TCAudioSettingKitResources
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCMusicSelectView.h"
#import "AudioEffectSettingViewModel.h"
#import "TCMusicSelectCell.h"
#import "TCMusicSelectedModel.h"
#import "TCASKitTheme.h"
#import "ASMasonry.h"

@interface TCMusicSelectView ()<UITableViewDelegate, UITableViewDataSource>{
    BOOL _isViewReady; // 视图布局是否完成
    BOOL _isShow;
}

@property (nonatomic, strong) TCASKitTheme *theme;

@property (nonatomic, strong) AudioEffectSettingViewModel* viewModel;
// 视图相关属性
@property (nonatomic, strong) UIView *headerContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentSelect;

@end

@implementation TCMusicSelectView

- (instancetype)initWithViewModel:(AudioEffectSettingViewModel *)viewModel {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.viewModel = viewModel;
        [self setupInitStyle];
        [self bindInteraction];
        self.currentSelect = -1;
    }
    return self;
}

- (void)setupInitStyle {
    self.hidden = YES;
}

#pragma mark - 属性方法
- (TCASKitTheme *)theme {
    if (!_theme) {
        _theme = [[TCASKitTheme alloc] init];
    }
    return _theme;
}

- (UIView *)headerContainer {
    if (!_headerContainer) {
        _headerContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _headerContainer.backgroundColor = UIColor.clearColor;
    }
    return _headerContainer;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [self.theme localizedString:@"ASKit.MusicSelectMenu.Title"];
        label.font = [self.theme themeFontWithSize:16.0];
        label.textColor = self.theme.normalFontColor;
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[self.theme imageNamed:@"bgm_back"] forState:UIControlStateNormal];
        _closeButton = button;
    }
    return _closeButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        table.dataSource = self;
        table.delegate = self;
        table.showsVerticalScrollIndicator = NO;
        table.backgroundColor = UIColor.clearColor;
        table.allowsMultipleSelection = NO;
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [table registerClass:[TCMusicSelectCell class] forCellReuseIdentifier:@"TCMusicSelectCell"];
        _tableView = table;
    }
    return _tableView;
}

#pragma mark - public method 实现
- (void)show {
    if (self->_isShow) {
        return;
    }
    self->_isShow = YES;
    self.hidden = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectViewChangeState:)]) {
        [self.delegate selectViewChangeState:self];
    }
}

- (void)hide {
    if (!self->_isShow) {
        return;
    }
    self->_isShow = NO;
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectViewChangeState:)]) {
        [self.delegate selectViewChangeState:self];
    }
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self->_isViewReady) {
        return;
    }
    [self constructViewHierachy];
    [self activateConstraints];
    self->_isViewReady = YES;
    [self setupStyle];
}

- (void)constructViewHierachy {
    [self addSubview:self.headerContainer];
    [self.headerContainer addSubview:self.titleLabel];
    [self.headerContainer addSubview:self.closeButton];
    [self addSubview:self.tableView];
}

- (void)activateConstraints {
    [self activeConstraintsOfTitleContainer];
    [self activateConstraintsOfTableView];
}

- (void)activeConstraintsOfTitleContainer {
    [self.headerContainer mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(56);
    }];
    [self.titleLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerX.equalTo(self.headerContainer.mas_centerX);
        make.centerY.equalTo(self.headerContainer.mas_centerY);
    }];
    [self.titleLabel sizeToFit];
    [self.closeButton mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerY.equalTo(self.headerContainer.mas_centerY);
        make.left.equalTo(self.headerContainer.mas_left).offset(20.0);
    }];
}

- (void)activateConstraintsOfTableView {
    [self.tableView mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.top.equalTo(self.headerContainer.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

- (void)bindInteraction {
    [self.closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupStyle {
    // 切圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

#pragma mark - tabledelegate&&datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCMusicSelectedModel *model = self.viewModel.musicSources[indexPath.row];
    model.action(YES);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMusic:isSelected:)]) {
        [self.delegate didSelectMusic:model isSelected:self.currentSelect != indexPath.row];
    }
    
//    if (self.currentSelect != indexPath.row) {
//        if (model.action) {
//            model.action(YES);
//        }
//        self.currentSelect = indexPath.row;
//    } else {
//        self.currentSelect = -1;
//        if (model.action) {
//            model.action(NO);
//        }
//        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//        [cell setSelected:NO animated:YES];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCMusicSelectCell* cell = (TCMusicSelectCell *)[tableView dequeueReusableCellWithIdentifier:@"TCMusicSelectCell" forIndexPath:indexPath];
    TCMusicSelectedModel *model = self.viewModel.musicSources[indexPath.row];
    [cell setupCellWithModel:model];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewModel.musicSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}


@end
