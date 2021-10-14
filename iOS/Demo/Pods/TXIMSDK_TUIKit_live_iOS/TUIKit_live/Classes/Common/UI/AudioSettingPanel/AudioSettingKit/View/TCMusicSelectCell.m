//
//  TCMusicSelectCell.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/28.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCMusicSelectCell.h"
#import "TCMusicSelectedModel.h"
#import "TCASKitTheme.h"
#import "ASMasonry.h"

@interface TCMusicSelectCell (){
    BOOL _isViewReady;
}
@property (nonatomic, strong) TCASKitTheme *theme;

@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *singerLabel;
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation TCMusicSelectCell

- (TCASKitTheme *)theme {
    if (!_theme) {
        _theme = [[TCASKitTheme alloc] init];
    }
    return _theme;
}

- (UILabel *)nameLable {
    if (!_nameLable) {
        _nameLable = [[UILabel alloc] init];
        _nameLable.font = [self.theme themeFontWithSize:16.0];
        _nameLable.textColor = self.theme.normalFontColor;
    }
    return _nameLable;
}

- (UILabel *)singerLabel {
    if (!_singerLabel) {
        _singerLabel = [[UILabel alloc] init];
        _singerLabel.font = [self.theme themeFontWithSize:14.0];
        _singerLabel.textColor = self.theme.normalFontColor;
        _singerLabel.alpha = 0.5;
    }
    return _singerLabel;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_playButton setImage:[self.theme imageNamed:@"bgm_pause"] forState:UIControlStateSelected];
        [_playButton setImage:[self.theme imageNamed:@"bgm_play"] forState:UIControlStateNormal];
        _playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _playButton.userInteractionEnabled = NO;
    }
    return _playButton;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    self.playButton.selected = selected;
}


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
    [self addSubview:self.nameLable];
    [self addSubview:self.singerLabel];
    [self addSubview:self.playButton];
}

- (void)activateConstraints {
    [self.nameLable mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.bottom.equalTo(self.mas_centerY);
    }];
    [self.singerLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self.mas_centerY);
    }];
    [self.playButton mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(24);
    }];
}

/// 绑定视图交互
- (void)bindInteraction {
    
}
/// 设置视图样式
- (void)setupStyle {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
}

- (void)setupCellWithModel:(TCMusicSelectedModel *)model {
    self.nameLable.text = model.musicName;
    self.singerLabel.text = model.singerName;
    self.playButton.selected = self.isSelected;
}



@end
