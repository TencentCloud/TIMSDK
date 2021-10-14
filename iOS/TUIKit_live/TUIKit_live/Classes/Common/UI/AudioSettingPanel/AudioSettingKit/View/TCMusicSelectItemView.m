//
//  TCMusicSelectItemView.m
//  TCAudioSettingKitResources
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCMusicSelectItemView.h"
#import "TCASKitTheme.h"
#import "ASMasonry.h"

@interface TCMusicSelectItemView () {
    BOOL _isViewReady;
    BOOL _isPlayingStatus;
}

@property (nonatomic, strong) TCASKitTheme *theme;

@property (nonatomic, strong) UIView *selectStatusContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *rightIcon;

@property (nonatomic, strong) UIView *playingStatusContainer;
@property (nonatomic, strong) UILabel *musicNameLabel;
@property (nonatomic, strong) UILabel *musicProgressLabel;
@property (nonatomic, strong) UIButton *pausButton;

@end

@implementation TCMusicSelectItemView

#pragma mark - 视图属性懒加载
- (TCASKitTheme *)theme {
    if (!_theme) {
        _theme = [[TCASKitTheme alloc] init];
    }
    return _theme;
}

-(UIView *)selectStatusContainer {
    if (!_selectStatusContainer) {
        _selectStatusContainer = [[UIView alloc] init];
    }
    return _selectStatusContainer;;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.text = [self.theme localizedString:@"ASKit.MainMenu.BGM"];
        label.font = [self.theme themeFontWithSize:16.0];
        label.textColor = self.theme.normalFontColor;
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.text = [self.theme localizedString:@"ASKit.MainMenu.SelectMusic"];
        label.font = [self.theme themeFontWithSize:14.0];
        label.textColor = self.theme.normalFontColor;
        label.alpha = 0.5;
        _subTitleLabel = label;
    }
    return _subTitleLabel;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.alpha = 0.7;
        imageView.image = [self.theme imageNamed:@"VoiceSetting_SelectMusic"];
        _rightIcon = imageView;
    }
    return _rightIcon;
}

- (UIView *)playingStatusContainer {
    if (!_playingStatusContainer) {
        _playingStatusContainer = [[UIView alloc] init];
        _playingStatusContainer.hidden = YES;
    }
    return _playingStatusContainer;
}

- (UILabel *)musicNameLabel {
    if (!_musicNameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = self.theme.normalFontColor;
        label.font = [self.theme themeFontWithSize:16.0];
        _musicNameLabel = label;
    }
    return _musicNameLabel;
}

- (UILabel *)musicProgressLabel {
    if (!_musicProgressLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = self.theme.normalFontColor;
        label.font = [self.theme themeFontWithSize:16.0];
        label.textAlignment = NSTextAlignmentRight;
        _musicProgressLabel = label;
    }
    return _musicProgressLabel;
}

- (UIButton *)pausButton{
    if (!_pausButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[self.theme imageNamed:@"bgm_pause"] forState:UIControlStateNormal];
        [button setImage:[self.theme imageNamed:@"bgm_play"] forState:UIControlStateSelected];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
        _pausButton = button;
    }
    return _pausButton;
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
    [self bindInteraction];
}


#pragma mark - 构造视图层级,初始化布局
/// 构造视图层级
- (void)constructViewHierachy {
    [self addSubview:self.selectStatusContainer];
    [self.selectStatusContainer addSubview:self.titleLabel];
    [self.selectStatusContainer addSubview:self.subTitleLabel];
    [self.selectStatusContainer addSubview:self.rightIcon];
    
    [self addSubview:self.playingStatusContainer];
    [self.playingStatusContainer addSubview:self.musicNameLabel];
    [self.playingStatusContainer addSubview:self.musicProgressLabel];
    [self.playingStatusContainer addSubview:self.pausButton];
}

/// 构造视图约束
- (void)activateConstraints {
    [self activateConstraintsSelectStatus];
    [self activateConstraintsPlayingConotainer];
}

- (void)activateConstraintsSelectStatus {
    [self.selectStatusContainer mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.titleLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerY.equalTo(self.selectStatusContainer.mas_centerY);
        make.left.equalTo(self.selectStatusContainer.mas_left).offset(20);
    }];
    [self.titleLabel sizeToFit];
    [self.rightIcon mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerY.equalTo(self.selectStatusContainer.mas_centerY);
        make.right.equalTo(self.selectStatusContainer.mas_right).offset(-20);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(10);
    }];
    [self.subTitleLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerY.equalTo(self.selectStatusContainer.mas_centerY);
        make.right.equalTo(self.rightIcon.mas_left).offset(-8);
    }];
    [self.subTitleLabel sizeToFit];
}

- (void)activateConstraintsPlayingConotainer {
    [self.playingStatusContainer mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.musicNameLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerY.equalTo(self.playingStatusContainer.mas_centerY);
        make.left.equalTo(self.playingStatusContainer.mas_left).offset(20);
        make.width.mas_equalTo(128);
    }];
    [self.pausButton mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerY.equalTo(self.playingStatusContainer.mas_centerY);
        make.right.equalTo(self.playingStatusContainer.mas_right).offset(-20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    [self.musicProgressLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.centerY.equalTo(self.playingStatusContainer.mas_centerY);
        make.right.equalTo(self.pausButton.mas_left).offset(-8);
        make.left.equalTo(self.musicNameLabel.mas_right);
    }];
}

/// 绑定视图交互
- (void)bindInteraction {
    UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}
/// 设置视图样式
- (void)setupStyle {
    self.musicNameLabel.numberOfLines = 1;
}
 
- (void)panAction:(UIPanGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickItem)]) {
        [self.delegate didClickItem];
    }
}

- (void)pauseAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPausButton:)]) {
        [self.delegate didClickPausButton:!sender.isSelected];
    }
    sender.selected = !sender.isSelected;
}

/// 选中音乐后传入名称
/// @param musicName 音乐名（空字符串代表没有选中）
- (void)selectMusic:(NSString *)musicName {
    NSString *sufix = @"";
    if ([musicName isEqualToString:@""]) {
        [self changePlayingStatus:NO];
        self.pausButton.selected = YES;
    } else {
        self.pausButton.selected = NO;
        [self changePlayingStatus:YES];
        sufix = @"...";
    }
//    self.musicNameLabel.text = [NSString stringWithFormat:@"%@%@",musicName, sufix];
    self.musicNameLabel.text = musicName;
}

- (void)refreshMusicPlayingProgress:(NSString *)progressString {
    self.musicProgressLabel.text = progressString;
}

- (void)completeStatus {
    self.pausButton.selected = YES;
}

#pragma mark - 私有方法
- (void)changePlayingStatus:(BOOL)isPlayingStatus {
    if (_isPlayingStatus == isPlayingStatus) {
        return;
    }
    _isPlayingStatus = isPlayingStatus;
    if (isPlayingStatus) {
        self.playingStatusContainer.hidden = NO;
        self.selectStatusContainer.hidden = YES;
    } else {
        self.selectStatusContainer.hidden = NO;
        self.playingStatusContainer.hidden = YES;
    }
}

@end
