// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaBGMEditView.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCheckBox.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaMusicCell.h"
#import "TUIMultimediaPlugin/TUIMultimediaTabPanel.h"

static const CGFloat ItemInset = 10;
static const CGFloat ItemWidthFactor = 0.7;

static const CGFloat CollectionViewHeight = 100;

@interface TUIMultimediaBGMEditView () <UITableViewDataSource, UITableViewDelegate> {
    NSArray<UITableView *> *_tableViews;
    TUIMultimediaTabPanel *_tabPanel;
    NSInteger _selectedIndex;
    TUIMultimediaCheckBox *_switchOriginAudio;
    TUIMultimediaCheckBox *_switchBgm;
}

@end

@implementation TUIMultimediaBGMEditView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _bgmConfig = @[];
        _selectedIndex = -1;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = TUIMultimediaPluginDynamicColor(@"editor_popup_view_bg_color", @"#000000BF");

    _tabPanel = [[TUIMultimediaTabPanel alloc] initWithFrame:self.bounds];
    [self addSubview:_tabPanel];

    _switchOriginAudio = [[TUIMultimediaCheckBox alloc] init];
    [self addSubview:_switchOriginAudio];
    _switchOriginAudio.text = [TUIMultimediaCommon localizedStringForKey:@"editor_origin_audio"];
    [_switchOriginAudio addTarget:self action:@selector(onSwitchOriginAudioChanged) forControlEvents:UIControlEventValueChanged];

    _switchBgm = [[TUIMultimediaCheckBox alloc] init];
    [self addSubview:_switchBgm];
    _switchBgm.text = [TUIMultimediaCommon localizedStringForKey:@"editor_bgm"];
    [_switchBgm addTarget:self action:@selector(onSwitchBGMChanged) forControlEvents:UIControlEventValueChanged];

    [_tabPanel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.top.equalTo(self);
      make.bottom.equalTo(_switchBgm.mas_top).inset(10);
      make.height.mas_equalTo(400);
    }];
    [_switchBgm mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
      make.height.mas_equalTo(24);
      make.left.equalTo(self).inset(20);
    }];
    [_switchOriginAudio mas_makeConstraints:^(MASConstraintMaker *make) {
      make.height.mas_equalTo(24);
      make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
      make.right.equalTo(self).inset(20);
    }];

    [self reloadConfig];
}

- (void)reloadConfig {
    _tableViews = [_bgmConfig tui_multimedia_mapWithIndex:^UITableView *(TUIMultimediaBGMGroup *group, NSUInteger idx) {
      UITableView *v = [[UITableView alloc] init];
      v.tag = idx;
      v.backgroundColor = UIColor.clearColor;
      v.dataSource = self;
      v.delegate = self;
      [v registerClass:TUIMultimediaMusicCell.class forCellReuseIdentifier:TUIMultimediaMusicCell.reuseIdentifier];
      return v;
    }];
    _tabPanel.tabs = [_tableViews tui_multimedia_map:^TUIMultimediaTabPanelTab *(UITableView *v) {
      return [[TUIMultimediaTabPanelTab alloc] initWithName:[TUIMultimediaCommon localizedStringForKey:self->_bgmConfig[v.tag].name] icon:nil view:v];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (NSArray<TUIMultimediaBGM *> *)getBgmListByTableView:(UITableView *)v {
    return _bgmConfig[v.tag].bgmList;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getBgmListByTableView:tableView].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMultimediaMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:TUIMultimediaMusicCell.reuseIdentifier forIndexPath:indexPath];
    cell.music = [self getBgmListByTableView:tableView][indexPath.item];
    if (cell.music == _selectedBgm) {
        if (_switchBgm.on) {
            cell.state = TUIMultimediaMusicCellStateEnabled;
        } else {
            cell.state = TUIMultimediaMusicCellStateSelected;
        }
    } else {
        cell.state = TUIMultimediaMusicCellStateNormal;
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _selectedBgm = [self getBgmListByTableView:tableView][indexPath.item];
    if (!_switchBgm.on) {
        _switchBgm.on = YES;
    }
    [_delegate bgmEditViewValueChanged:self];
    for (UITableView *v in _tableViews) {
        [v reloadData];
    }
}

#pragma mark - Actions
- (void)onSwitchOriginAudioChanged {
    [_delegate bgmEditViewValueChanged:self];
}

- (void)onSwitchBGMChanged {
    [_delegate bgmEditViewValueChanged:self];
    for (UITableView *v in _tableViews) {
        [v reloadData];
    }
}

#pragma mark - Properties
- (void)setBgmConfig:(NSArray<TUIMultimediaBGMGroup *> *)bgmConfig {
    _bgmConfig = bgmConfig;
    [self reloadConfig];
}
- (BOOL)originAudioEnabled {
    return _switchOriginAudio.on;
}
- (void)setOriginAudioEnabled:(BOOL)originAudioEnabled {
    _switchOriginAudio.on = originAudioEnabled;
}

- (BOOL)bgmEnabled {
    return _switchBgm.on;
}
- (void)setBgmEnabled:(BOOL)bgmEnabled {
    _switchBgm.on = bgmEnabled;
}

- (void)setClipDuration:(float)videoDuration {
    _clipDuration = videoDuration;
}

@end
