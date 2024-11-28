// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaMusicCell.h"
#import <TUICore/TUIThemeManager.h>
#import "Masonry/Masonry.h"
#import "TUIMultimediaPlugin/TUIMultimediaAutoScrollLabel.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaFakeAudioWaveView.h"

static const CGFloat TitleFontSize = 14;
static const CGFloat SubtitleFontSize = 12;

@interface TUIMultimediaMusicCell () {
    TUIMultimediaAutoScrollLabel *_lbTitle;
    UILabel *_lbSubTitle;
    UILabel *_lbDuration;
    TUIMultimediaFakeAudioWaveView *_waveView;
}
@end

@implementation TUIMultimediaMusicCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.contentView.backgroundColor = UIColor.clearColor;
    self.backgroundColor = UIColor.clearColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _lbTitle = [[TUIMultimediaAutoScrollLabel alloc] init];
    [self.contentView addSubview:_lbTitle];

    _lbSubTitle = [[UILabel alloc] init];
    [self.contentView addSubview:_lbSubTitle];
    _lbSubTitle.font = [UIFont systemFontOfSize:SubtitleFontSize];
    _lbSubTitle.textColor = TUIMultimediaPluginDynamicColor(@"editor_bgm_text_color", @"#FFFFFF99");

    _lbDuration = [[UILabel alloc] init];
    [self.contentView addSubview:_lbDuration];
    _lbDuration.font = [UIFont monospacedSystemFontOfSize:SubtitleFontSize weight:UIFontWeightMedium];
    _lbDuration.textColor = TUIMultimediaPluginDynamicColor(@"editor_bgm_text_color", @"#FFFFFF99");

    _waveView = [[TUIMultimediaFakeAudioWaveView alloc] init];
    [self addSubview:_waveView];
    _waveView.hidden = YES;

    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.top.equalTo(self.contentView).inset(10);
      make.width.mas_equalTo(120);
    }];
    [_lbSubTitle mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(_lbTitle.mas_bottom).inset(5);
      make.left.equalTo(self.contentView).inset(14);
      make.bottom.equalTo(self.contentView).inset(10);
    }];
    [_lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(self.contentView);
      make.right.equalTo(self.contentView).inset(10);
    }];
    [_waveView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(_lbDuration.mas_left).inset(50);
      make.centerY.equalTo(self);
      make.height.mas_equalTo(12);
      make.width.mas_equalTo(48);
    }];
}
- (void)updateTitle {
    UIColor *color = UIColor.whiteColor;
    BOOL active = NO;
    if (_state == TUIMultimediaMusicCellStateEnabled) {
        color = [[TUIMultimediaConfig sharedInstance] getThemeColor];
        if (_music.lyric != nil && _music.lyric.length > 0) {
            active = YES;
        }
    }
    NSString *title = _music.lyric != nil && _music.lyric.length > 0 ? _music.lyric : _music.name;
    _lbTitle.text = [[NSAttributedString alloc] initWithString:title
                                                    attributes:@{
                                                        NSFontAttributeName : [UIFont systemFontOfSize:TitleFontSize],
                                                        NSForegroundColorAttributeName : color,
                                                    }];
    _lbTitle.active = active;
}
- (void)updateWave {
    switch (_state) {
        case TUIMultimediaMusicCellStateNormal:
            _waveView.hidden = YES;
            _waveView.enabled = NO;
            break;
        case TUIMultimediaMusicCellStateSelected:
            _waveView.color = TUIMultimediaPluginDynamicColor(@"editor_bgm_text_color", @"#FFFFFF99");
            _waveView.hidden = NO;
            _waveView.enabled = NO;
            break;
        case TUIMultimediaMusicCellStateEnabled:
            _waveView.color = [[TUIMultimediaConfig sharedInstance] getThemeColor];
            _waveView.hidden = NO;
            _waveView.enabled = YES;
            break;
    }
}
#pragma mark - Properties
- (void)setState:(TUIMultimediaMusicCellState)state {
    _state = state;
    [self updateTitle];
    [self updateWave];
}
- (void)setMusic:(TUIMultimediaBGM *)music {
    _music = music;
    [self updateTitle];
    _lbSubTitle.text = music.source;
    float duration = music.asset == nil ? 0 : music.asset.duration.value / music.asset.duration.timescale;
    int min = (int)(duration / 60);
    _lbDuration.text = [NSString stringWithFormat:@"%02d:%02d", min, (int)(duration - min * 60)];
}

@end
