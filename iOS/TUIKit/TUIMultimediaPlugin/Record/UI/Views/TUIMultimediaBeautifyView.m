// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaBeautifyView.h"
#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/RACEXTScope.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaEffectCell.h"
#import "TUIMultimediaPlugin/TUIMultimediaEffectPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaImageUtil.h"
#import "TUIMultimediaPlugin/TUIMultimediaTabPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"

#pragma mark - TUIMultimediaBeautifyView
@interface TUIMultimediaBeautifyView () <TUIMultimediaEffectPanelDelegate, TUIMultimediaTabPanelDelegate> {
    UIView *_topPanel;
    UILabel *_lbStrength;
    UIImageView *_imgViewCompare;
    UISlider *_slider;
    TUIMultimediaTabPanel *_tabPanel;
    TUIMultimediaEffectPanel *_effectPanelBeauty;
    TUIMultimediaEffectPanel *_effectPanelFilter;
    TUIMultimediaEffectItem *_selectedItem;
    TUIMultimediaMarker *_marker;
}
@end

@implementation TUIMultimediaBeautifyView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame settings:nil];
}

- (instancetype)initWithFrame:(CGRect)frame settings:(TUIMultimediaBeautifySettings *)settings {
    self = [super initWithFrame:frame];
    _settings = settings;
    if (_settings == nil) {
        _settings = [[TUIMultimediaBeautifySettings alloc] init];
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.opaque = NO;
    self.backgroundColor = UIColor.clearColor;

    _topPanel = [[UIView alloc] init];
    _topPanel.hidden = YES;
    [self addSubview:_topPanel];
    [_topPanel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.top.equalTo(self);
      make.height.mas_equalTo(52);
    }];

    _marker = [[TUIMultimediaMarker alloc] init];
    [_topPanel addSubview:_marker];

    _lbStrength = [[UILabel alloc] init];
    [_topPanel addSubview:_lbStrength];
    _lbStrength.text = [TUIMultimediaCommon localizedStringForKey:@"strength"];
    _lbStrength.textColor = UIColor.whiteColor;
    _lbStrength.font = [UIFont systemFontOfSize:16];

    _imgViewCompare = [[UIImageView alloc] init];
    [_topPanel addSubview:_imgViewCompare];
    _imgViewCompare.image = TUIMultimediaPluginBundleThemeImage(@"beautify_effect_compare_img", @"effect_compare");

    UIColor* themeColor = [[TUIMultimediaConfig sharedInstance] getThemeColor];
    _slider = [[UISlider alloc] init];
    [_topPanel addSubview:_slider];
    //_slider.thumbTintColor = TUIMultimediaPluginDynamicColor(@"theme_accent_dark_color", @"#006CFF");
    _slider.minimumValue = TUIMultimediaEffectSliderMin;
    _slider.maximumValue = TUIMultimediaEffectSliderMax;
    _slider.minimumTrackTintColor = themeColor;//TUIMultimediaPluginDynamicColor(@"theme_accent_dark_color", @"#006CFF");
    _slider.maximumTrackTintColor = TUIMultimediaPluginDynamicColor(@"beautify_slider_track_bg_color", @"#F4F5F9");
    UIImage *thumbImg = [TUIMultimediaImageUtil createBlueCircleWithWhiteBorder:CGSizeMake(24, 24) withColor:themeColor];
    [_slider setThumbImage:thumbImg forState:UIControlStateNormal];
    [_slider setThumbImage:thumbImg forState:UIControlStateHighlighted];
    [_slider addTarget:self action:@selector(onSliderValueChange) forControlEvents:UIControlEventValueChanged];

    [_lbStrength mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(_topPanel).inset(16);
      make.centerY.equalTo(_topPanel);
    }];
    [_imgViewCompare mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(_topPanel).inset(16);
      make.centerY.equalTo(_topPanel);
      make.width.height.mas_equalTo(30);
    }];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(_lbStrength.mas_right).inset(8);
      make.right.equalTo(_imgViewCompare.mas_left).inset(8);
      make.centerY.equalTo(_topPanel);
      make.height.mas_equalTo(30);
    }];

    _effectPanelBeauty = [[TUIMultimediaEffectPanel alloc] init];
    _effectPanelBeauty.iconSize = CGSizeMake(32, 32);
    _effectPanelBeauty.delegate = self;
    _effectPanelBeauty.items = _settings.beautifyItems;

    _effectPanelFilter = [[TUIMultimediaEffectPanel alloc] init];
    _effectPanelFilter.iconSize = CGSizeMake(56, 56);
    _effectPanelFilter.delegate = self;
    _effectPanelFilter.items = _settings.filterItems;
    _effectPanelFilter.selectedIndex = 0;

    UIView *bottomPanel = [[UIView alloc] init];
    [self addSubview:bottomPanel];
    bottomPanel.backgroundColor = UIColor.blackColor;

    _tabPanel = [[TUIMultimediaTabPanel alloc] initWithFrame:self.bounds];
    _tabPanel.delegate = self;
    _tabPanel.backgroundColor = UIColor.blackColor;
    _tabPanel.tabs = @[
        [[TUIMultimediaTabPanelTab alloc] initWithName:[TUIMultimediaCommon localizedStringForKey:@"beautify"] icon:nil view:_effectPanelBeauty],
        [[TUIMultimediaTabPanelTab alloc] initWithName:[TUIMultimediaCommon localizedStringForKey:@"filter"] icon:nil view:_effectPanelFilter],
    ];
    [bottomPanel addSubview:_tabPanel];

    [bottomPanel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(_topPanel.mas_bottom);
      make.left.right.bottom.equalTo(self);
    }];
    [_tabPanel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.top.equalTo(bottomPanel);
      make.bottom.equalTo(bottomPanel.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)effectPanelSelectionChanged:(TUIMultimediaEffectPanel *)panel {
    [_marker hide];
    if (panel.selectedIndex == -1 || panel.items[panel.selectedIndex].tag == TUIMultimediaEffectItemTagNone) {
        panel.selectedIndex = -1;
        _selectedItem = nil;
        _topPanel.hidden = YES;
        if (panel == _effectPanelFilter) {
            _settings.activeFilterIndex = -1;
        } else {
            for (TUIMultimediaEffectItem *item in _settings.beautifyItems) {
                item.strength = 0;
            }
        }
        [_delegate beautifyView:self onSettingsChange:_settings];
        return;
    }
    _selectedItem = panel.items[panel.selectedIndex];
    if (panel == _effectPanelFilter) {
        _settings.activeFilterIndex = panel.selectedIndex;
        _topPanel.hidden = NO;
        _slider.value = _selectedItem.strength;
        [_delegate beautifyView:self onSettingsChange:_settings];
    } else {
        _topPanel.hidden = NO;
        _slider.value = _selectedItem.strength;
        if ([@[ @(TUIMultimediaEffectItemTagSmooth), @(TUIMultimediaEffectItemTagNatural), @(TUIMultimediaEffectItemTagPitu) ] containsObject:@(_selectedItem.tag)]) {
            _settings.activeBeautifyTag = _selectedItem.tag;
            [_delegate beautifyView:self onSettingsChange:_settings];
        }
    }
}

- (void)tabPanel:(TUIMultimediaTabPanel *)panel selectedIndexChanged:(NSInteger)selectedIndex {
    TUIMultimediaEffectPanel *effectPanel = (TUIMultimediaEffectPanel *)panel.tabs[selectedIndex].view;
    [self effectPanelSelectionChanged:effectPanel];
}

- (void)onSliderValueChange {
    _selectedItem.strength = _slider.value;

    _marker.text = [NSString stringWithFormat:@"%d", (int)_slider.value];
    CGRect trackRect = [_slider trackRectForBounds:_slider.bounds];
    CGRect thumbRect = [_slider thumbRectForBounds:_slider.bounds trackRect:trackRect value:_slider.value];
    CGRect rect = [_topPanel convertRect:thumbRect fromView:_slider];
    [_marker mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.width.height.mas_equalTo(34);
      make.centerX.equalTo(_topPanel.mas_left).offset(CGRectGetMidX(rect));
      make.bottom.equalTo(_topPanel.mas_top).offset(rect.origin.y - 4);
    }];
    [_marker showForDuration:0.5 withHideAnimeDuration:0.5];

    [_delegate beautifyView:self onSettingsChange:_settings];
}

- (void)setSettings:(TUIMultimediaBeautifySettings *)settings {
    _effectPanelBeauty.items = _settings.beautifyItems;
    _effectPanelFilter.items = _settings.filterItems;
    _effectPanelFilter.selectedIndex = 0;
}
@end

#pragma mark - TUIMultimediaMarker
@interface TUIMultimediaMarker () {
    UIImageView *_imgView;
    UILabel *_label;
    dispatch_block_t hideBlock;
}
@end
@implementation TUIMultimediaMarker
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initUI];
    return self;
}
- (void)initUI {
    _imgView = [[UIImageView alloc] init];
    [self addSubview:_imgView];
    _imgView.image = TUIMultimediaPluginBundleThemeImage(@"beautify_marker_img", @"marker");
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    _label = [[UILabel alloc] init];
    [self addSubview:_label];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = UIColor.blackColor;
    _label.font = [UIFont systemFontOfSize:12];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self);
      make.centerY.equalTo(self);
    }];
}
- (NSString *)text {
    return _label.text;
}
- (void)setText:(NSString *)text {
    _label.text = text;
}
- (void)showForDuration:(CGFloat)showSeconds withHideAnimeDuration:(CGFloat)hideAnimeSeconds {
    self.alpha = 1;
    self.hidden = NO;
    if (hideBlock != nil) {
        dispatch_block_cancel(hideBlock);
    }
    @weakify(self);
    hideBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
      @strongify(self);
      [UIView animateWithDuration:hideAnimeSeconds
          animations:^{
            self.alpha = 0;
          }
          completion:^(BOOL finished) {
            self.alpha = 1;
            self.hidden = YES;
          }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(showSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), hideBlock);
}
- (void)hide {
    if (hideBlock != nil) {
        dispatch_block_cancel(hideBlock);
    }
    self.alpha = 1;
    self.hidden = YES;
}
@end
