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
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _titleLabel.textColor = [UIColor whiteColor];
    [_titleLabel setText:@"直播结束啦!"];
    [self addSubview:_titleLabel];
    
    
    _durationLabel = [[UILabel alloc] init];
    _durationLabel.textAlignment = NSTextAlignmentCenter;
    _durationLabel.font = [UIFont boldSystemFontOfSize:15];
    _durationLabel.textColor = [UIColor whiteColor];
    [_durationLabel setText:[NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec]];
    [self addSubview:_durationLabel];
    
    _durationTipLabel = [[UILabel alloc] init];
    _durationTipLabel.textAlignment = NSTextAlignmentCenter;
    _durationTipLabel.font = [UIFont boldSystemFontOfSize:12];
    _durationTipLabel.textColor = [UIColor grayColor];
    [_durationTipLabel setText:[NSString stringWithFormat:@"直播时长"]];
    [self addSubview:_durationTipLabel];
    
    
    _viewerCountLabel = [[UILabel alloc] init];
    _viewerCountLabel.textAlignment = NSTextAlignmentCenter;
    _viewerCountLabel.font = [UIFont boldSystemFontOfSize:12];
    _viewerCountLabel.textColor = [UIColor whiteColor];
    [_viewerCountLabel setText:[NSString stringWithFormat:@"%ld", [_resultData getTotalViewerCount]]];
    [self addSubview:_viewerCountLabel];
    
    _viewerCountTipLabel = [[UILabel alloc] init];
    _viewerCountTipLabel.textAlignment = NSTextAlignmentCenter;
    _viewerCountTipLabel.font = [UIFont boldSystemFontOfSize:12];
    _viewerCountTipLabel.textColor = [UIColor grayColor];
    [_viewerCountTipLabel setText:[NSString stringWithFormat:@"观看人数"]];
    [self addSubview:_viewerCountTipLabel];
    
    
    _praiseLabel = [[UILabel alloc] init];
    _praiseLabel.textAlignment = NSTextAlignmentCenter;
    _praiseLabel.font = [UIFont boldSystemFontOfSize:12];
    _praiseLabel.textColor = [UIColor whiteColor];
    [_praiseLabel setText:[NSString stringWithFormat:@"%ld\n", [_resultData getLikeCount]]];
    [self addSubview:_praiseLabel];
    
    _praiseTipLabel = [[UILabel alloc] init];
    _praiseTipLabel.textAlignment = NSTextAlignmentCenter;
    _praiseTipLabel.font = [UIFont boldSystemFontOfSize:12];
    _praiseTipLabel.textColor = [UIColor grayColor];
    [_praiseTipLabel setText:[NSString stringWithFormat:@"获赞数量"]];
    [self addSubview:_praiseTipLabel];
    
    _line = [[UILabel alloc] init];
    _line.backgroundColor = [UIColor grayColor];
    [self addSubview:_line];
    
    _backBtn = [[UIButton alloc] init];
    _backBtn.backgroundColor = [UIColor clearColor];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self addSubview:_backBtn];

    [self relayout];
}

- (void)relayout {
    CGRect rect = self.bounds;
    
    [_titleLabel sizeWith:CGSizeMake(rect.size.width, 24)];
    [_titleLabel alignParentTopWithMargin:20];
    
    [_durationLabel sizeWith:CGSizeMake(rect.size.width, 15)];
    [_durationLabel layoutBelow:_titleLabel margin:20];
    
    [_durationTipLabel sizeWith:CGSizeMake(rect.size.width, 14)];
    [_durationTipLabel layoutBelow:_durationLabel margin:7];
    
    _viewerCountLabel.frame = CGRectMake(rect.size.width/4.0 - 10, 0, rect.size.width/4.0, 15);
    [_viewerCountLabel layoutBelow:_durationTipLabel margin:20];
    _viewerCountTipLabel.frame = CGRectMake(rect.size.width/5.5, 0, rect.size.width/3.5, 15);
    [_viewerCountTipLabel layoutBelow:_viewerCountLabel margin:7];
    
    _praiseLabel.frame = CGRectMake(rect.size.width/2.0 + 10, 0, rect.size.width/4.0, 15);
    [_praiseLabel layoutBelow:_durationTipLabel margin:20];
    _praiseTipLabel.frame = CGRectMake(rect.size.width/1.88, 0, rect.size.width/3.5, 15);
    [_praiseTipLabel layoutBelow:_praiseLabel margin:7];
    
    
    [_backBtn sizeWith:CGSizeMake(rect.size.width, 35)];
    [_backBtn layoutParentHorizontalCenter];
    [_backBtn layoutBelow:_praiseTipLabel margin:30];
    
    [_line sizeWith:CGSizeMake(rect.size.width, 0.5)];
    [_line layoutBelow:_praiseTipLabel margin:30];
    
    [self setBackgroundColor:[UIColor colorWithRed:19/255.0 green:35/255.0 blue:63/255.0 alpha:1.0]];
}

- (void)clickBackBtn {
    _backHomepage();
}

@end
