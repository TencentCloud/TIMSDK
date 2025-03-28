// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaAutoScrollLabel.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"

static NSString *const ScrollAnimeKey = @"ScrollAnimeKey";

@interface TUIMultimediaAutoScrollLabel () <CAAnimationDelegate> {
    UIScrollView *_scrollView;
    UILabel *_label;
    UILabel *_label2;
    CAGradientLayer *_fadeLayer;
}

@end

@implementation TUIMultimediaAutoScrollLabel
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _scrollSpeed = 20;
        _pauseInterval = 2;
        _text = [[NSAttributedString alloc] initWithString:@""];
        _fadeInOutRate = 0.1;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.scrollEnabled = NO;
    _scrollView.userInteractionEnabled = NO;
    [self addSubview:_scrollView];

    _label = [[UILabel alloc] init];
    _label.numberOfLines = 1;
    [_scrollView addSubview:_label];

    _label2 = [[UILabel alloc] init];
    _label2.numberOfLines = 1;
    [_scrollView addSubview:_label2];

    NSArray *fadeColorList = @[
        (__bridge id)[UIColor.blackColor colorWithAlphaComponent:0].CGColor,
        (__bridge id)UIColor.blackColor.CGColor,
        (__bridge id)UIColor.blackColor.CGColor,
        (__bridge id)[UIColor.blackColor colorWithAlphaComponent:0].CGColor,
    ];
    _fadeLayer = [[CAGradientLayer alloc] init];
    _fadeLayer.backgroundColor = UIColor.clearColor.CGColor;
    _fadeLayer.colors = fadeColorList;
    _fadeLayer.locations = @[ @0, @(_fadeInOutRate), @(1 - _fadeInOutRate), @1 ];
    _fadeLayer.startPoint = CGPointMake(0, 0.5);
    _fadeLayer.endPoint = CGPointMake(1, 0.5);

    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.height.equalTo(_label.mas_height);
      make.edges.equalTo(self);
    }];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.top.bottom.equalTo(_scrollView);
    }];
    [_label2 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.bottom.equalTo(_scrollView);
      make.left.equalTo(_label.mas_right).offset(self.bounds.size.width);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _fadeLayer.frame = self.bounds;
    if (_active) {
        [self startScroll];
    }
    [_label2 mas_updateConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(_label.mas_right).offset(self.bounds.size.width);
    }];
}

- (void)startScroll {
    CGFloat scrollWidth = _scrollView.bounds.size.width;
    CGFloat labelWidth = _label.bounds.size.width;

    [_scrollView.layer removeAnimationForKey:ScrollAnimeKey];

    _scrollView.bounds = CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);

    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"bounds.origin.x"];
    anime.fromValue = @(0);
    anime.toValue = @(labelWidth + scrollWidth);
    anime.duration = (labelWidth + scrollWidth) / _scrollSpeed;
    anime.removedOnCompletion = NO;
    anime.delegate = self;
    [_scrollView.layer addAnimation:anime forKey:ScrollAnimeKey];
}

- (void)stopScroll {
    [_scrollView.layer removeAnimationForKey:ScrollAnimeKey];
    _scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)animationDidStop:(CAAnimation *)anime finished:(BOOL)finished {
    if (anime == [_scrollView.layer animationForKey:ScrollAnimeKey] && finished && _active) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_pauseInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          if (self->_active) {
              [self startScroll];
          }
        });
    }
}
#pragma mark - Properties
- (void)setActive:(BOOL)active {
    if (!_active && active) {
        [self startScroll];
        self.layer.mask = _fadeLayer;
    } else if (_active && !active) {
        [self stopScroll];
        self.layer.mask = nil;
    }
    _active = active;
}
- (void)setText:(NSAttributedString *)text {
    _label.attributedText = text;
    [_label sizeToFit];

    _label2.attributedText = text;
    [_label2 sizeToFit];

    _scrollView.contentSize = _label.bounds.size;
    _scrollView.contentOffset = CGPointMake(0, 0);
    if (_active) {
        [self startScroll];
    }
}
- (void)setFadeInOutRate:(CGFloat)fadeInOutRate {
    _fadeInOutRate = MAX(0, MIN(1, fadeInOutRate));
    _fadeLayer.locations = @[ @0, @(_fadeInOutRate), @(1 - _fadeInOutRate), @1 ];
}
@end
