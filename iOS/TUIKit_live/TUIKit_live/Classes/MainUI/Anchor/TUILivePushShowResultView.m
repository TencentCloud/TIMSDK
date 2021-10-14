//
//  TUILivePushShowResultView.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/15.
//

#import "TUILivePushShowResultView.h"
#import "TUILiveMsgListCell.h"
#import "UIView+CustomAutoLayout.h"
#import "TUILiveStatisticsTool.h"
#import "Masonry.h"

@implementation TUILivePushShowResultView
{
    UILabel  *_titleLabel;
    UILabel  *_durationLabel;
    UILabel  *_durationTipLabel;
    UILabel  *_viewerCountLabel;
    UILabel  *_viewerCountTipLabel;
    UILabel  *_praiseLabel;
    UILabel  *_praiseTipLabel;
    UIButton *_backBtn;
    UILabel  *_line;
    UILabel  *_backline;
    
    ShowResultComplete _backHomepage;
    TUILiveStatisticsTool *_resultData;
}

- (instancetype)initWithFrame:(CGRect)frame resultData:(TUILiveStatisticsTool *)resultData backHomepage:(ShowResultComplete)backHomepage {
    if (self = [super initWithFrame:frame]) {
        _resultData = resultData;
        _backHomepage = backHomepage;
        
        [self initUI];
        [_backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)initUI {
    int duration = (int)[_resultData getLiveDuration];
    int hour = duration / 3600;
    int min = (duration - hour * 3600) / 60;
    int sec = duration - hour * 3600 - min * 60;

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:21];
    _titleLabel.textColor = [UIColor blackColor];
    [_titleLabel setText:@"直播结束啦!"];
    [self addSubview:_titleLabel];
    
    
    _durationLabel = [[UILabel alloc] init];
    _durationLabel.textAlignment = NSTextAlignmentCenter;
    _durationLabel.font = [UIFont boldSystemFontOfSize:18];
    _durationLabel.textColor = [UIColor colorWithRed:245 / 255.0 green:57 / 255.0 blue:64 / 255.0 alpha:1];
    [_durationLabel setText:[NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec]];
    [self addSubview:_durationLabel];
    
    _durationTipLabel = [[UILabel alloc] init];
    _durationTipLabel.textAlignment = NSTextAlignmentCenter;
    _durationTipLabel.font = [UIFont boldSystemFontOfSize:16];
    _durationTipLabel.textColor = [UIColor blackColor];
    [_durationTipLabel setText:[NSString stringWithFormat:@"直播时长"]];
    [self addSubview:_durationTipLabel];
    
    
    _viewerCountLabel = [[UILabel alloc] init];
    _viewerCountLabel.textAlignment = NSTextAlignmentCenter;
    _viewerCountLabel.font = [UIFont boldSystemFontOfSize:18];
    _viewerCountLabel.textColor = [UIColor colorWithRed:255 / 255.0 green:158 / 255.0 blue:0 / 255.0 alpha:1];
    [_viewerCountLabel setText:[NSString stringWithFormat:@"%ld", [_resultData getTotalViewerCount]]];
    [self addSubview:_viewerCountLabel];
    
    _viewerCountTipLabel = [[UILabel alloc] init];
    _viewerCountTipLabel.textAlignment = NSTextAlignmentCenter;
    _viewerCountTipLabel.font = [UIFont boldSystemFontOfSize:18];
    _viewerCountTipLabel.textColor = [UIColor grayColor];
    [_viewerCountTipLabel setText:[NSString stringWithFormat:@"观看人数"]];
    [self addSubview:_viewerCountTipLabel];
    
    
    _praiseLabel = [[UILabel alloc] init];
    _praiseLabel.textAlignment = NSTextAlignmentCenter;
    _praiseLabel.font = [UIFont boldSystemFontOfSize:18];
    _praiseLabel.textColor = [UIColor colorWithRed:255 / 255.0 green:158 / 255.0 blue:0 / 255.0 alpha:1];
    [_praiseLabel setText:[NSString stringWithFormat:@"%ld\n", [_resultData getLikeCount]]];
    [self addSubview:_praiseLabel];
    
    _praiseTipLabel = [[UILabel alloc] init];
    _praiseTipLabel.textAlignment = NSTextAlignmentCenter;
    _praiseTipLabel.font = [UIFont boldSystemFontOfSize:18];
    _praiseTipLabel.textColor = [UIColor grayColor];
    [_praiseTipLabel setText:[NSString stringWithFormat:@"获赞数量"]];
    [self addSubview:_praiseTipLabel];
    
    _line = [[UILabel alloc] init];
    _line.backgroundColor = [UIColor colorWithRed:215 / 255.0 green:215 / 255.0 blue:215 / 255.0 alpha:1];
    [self addSubview:_line];
    
    _backline = [[UILabel alloc] init];
    _backline.backgroundColor = [UIColor colorWithRed:215 / 255.0 green:215 / 255.0 blue:215 / 255.0 alpha:1];
    [self addSubview:_backline];
    
    _backBtn = [[UIButton alloc] init];
    _backBtn.backgroundColor = [UIColor clearColor];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _backBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:_backBtn];

    [self relayout];
}

- (void)relayout {
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.mas_equalTo(28);
        make.height.mas_equalTo(26);
    }];
    
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(22);
        make.top.equalTo(_titleLabel.mas_bottom).offset(20);
    }];
    [_durationTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.mas_equalTo(_durationLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(16);
    }];
    [_viewerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(0.5);
        make.top.mas_equalTo(_durationTipLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(23);
    }];
    [_viewerCountTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(0.5);
        make.top.mas_equalTo(_viewerCountLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(23);
    }];
    [_praiseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(1.5);
        make.top.mas_equalTo(_durationTipLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(23);
    }];
    [_praiseTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(1.5);
        make.top.mas_equalTo(_praiseLabel.mas_bottom).offset(1);
        make.height.mas_equalTo(23);
    }];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(_viewerCountLabel.mas_bottom);
    }];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(56);
    }];
    [_backline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_backBtn);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    self.layer.cornerRadius = 4;
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)clickBackBtn {
    _backHomepage();
}

@end
