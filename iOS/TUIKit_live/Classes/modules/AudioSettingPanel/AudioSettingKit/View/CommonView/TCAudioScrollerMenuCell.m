//
//  TCAudioScrollerMenuCell.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCAudioScrollerMenuCell.h"
#import "TCAudioScrollMenuCellModel.h"
#import "TCASKitTheme.h"
#import "ASMasonry.h"

@interface TCAudioScrollerMenuCell (){
    BOOL _isViewReady;
}
@property (nonatomic, strong) TCASKitTheme *theme;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TCAudioScrollMenuCellModel* model;

@property(nonatomic, strong) UIImageView *selectedImageView;

@end

@implementation TCAudioScrollerMenuCell

- (TCASKitTheme *)theme {
    if (!_theme) {
        _theme = [[TCASKitTheme alloc] init];
    }
    return _theme;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.model) {
        self.model.selected = selected;
        self.iconView.image = selected ? self.model.selectedIcon : self.model.icon;
    }
    _selectedImageView.hidden = !selected;
    if (self.model.actionID == 0) {
        _selectedImageView.hidden = YES;
    }
    self.titleLabel.alpha = selected ? 1.0 : 0.5;
}

#pragma mark - 视图属性懒加载
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [self.theme normalFontColor];
        _titleLabel.font = [self.theme themeFontWithSize:10.0];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.hidden = !self.isSelected;
        _selectedImageView.image = [self.theme imageNamed:@"audiosettingkit_select"];
    }
    return _selectedImageView;;
}

-(void)prepareForReuse {
    self.iconView.image = nil;
    self.titleLabel.text = @"";
    self.selected = NO;
    self.model = nil;
}

-(void)dealloc {
    self.model = nil;
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
    [self addSubview:self.iconView];
    [self addSubview:self.selectedImageView];
    [self addSubview:self.titleLabel];
}

- (void)activateConstraints {
    [self.iconView mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.top.right.left.equalTo(self);
        make.height.mas_equalTo(44.0);
    }];
    [self.selectedImageView mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(self.iconView);
    }];
    [self.titleLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.iconView.mas_bottom).offset(8.0);
        make.width.mas_lessThanOrEqualTo(44.0);
    }];
}

/// 绑定视图交互
- (void)bindInteraction {
    
}
/// 设置视图样式
- (void)setupStyle {
    
}

- (void)setupCellWithModel:(TCAudioScrollMenuCellModel *)model {
    self.model = model;
    self.titleLabel.text = model.title;
    self.iconView.image = self.isSelected ? model.selectedIcon : model.icon;
    self.titleLabel.alpha = self.isSelected ? 1.0 : 0.5;
    self.selectedImageView.hidden = !self.isSelected;
}

@end
