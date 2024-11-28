// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaCircleProgressView.h"

@interface TUIMultimediaCircleProgressView () {
    CAShapeLayer *_backLayer;   // 背景图层
    CAShapeLayer *_frontLayer;  // 用来填充的图层
}

@end

@implementation TUIMultimediaCircleProgressView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _clockwise = YES;
        _width = 5;
        _startAngle = -M_PI / 2;
        _progressBgColor = UIColor.grayColor;
        _progressColor = UIColor.greenColor;
        _lineCap = kCALineCapRound;
        [self initUI];
    }
    return self;
}
- (void)initUI {
    _backLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_backLayer];
    _backLayer.fillColor = nil;
    _backLayer.strokeColor = _progressBgColor.CGColor;

    _frontLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_frontLayer];
    _frontLayer.fillColor = nil;
    _frontLayer.lineCap = _lineCap;
    _frontLayer.strokeColor = _progressColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat len = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    UIBezierPath *backgroundBezierPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                        radius:(len - _width) / 2.0
                                                                    startAngle:0
                                                                      endAngle:M_PI * 2
                                                                     clockwise:_clockwise];
    UIBezierPath *frontFillBezierPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                       radius:(len - _width) / 2.0
                                                                   startAngle:_startAngle
                                                                     endAngle:_startAngle + (_clockwise ? 2 * M_PI : -2 * M_PI)
                                                                    clockwise:_clockwise];
    _backLayer.path = backgroundBezierPath.CGPath;
    _frontLayer.path = frontFillBezierPath.CGPath;
    _frontLayer.lineWidth = _width;
    _backLayer.lineWidth = _width;
    _frontLayer.strokeEnd = 0;
}

#pragma mark - setters
- (void)setProgress:(CGFloat)progress {
    _progress = MAX(0, MIN(1, progress));
}
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    _progress = MAX(0, MIN(1, progress));
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                           self->_frontLayer.strokeEnd = progress;
                         }];
    } else {
        self->_frontLayer.strokeEnd = progress;
    }
}
- (void)setClockwise:(BOOL)clockwise {
    _clockwise = clockwise;
    [self setNeedsLayout];
}
- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
    [self setNeedsLayout];
}
- (void)setWidth:(CGFloat)width {
    _width = width;
    [self setNeedsLayout];
}
- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    _frontLayer.strokeColor = _progressColor.CGColor;
}
- (void)setProgressBgColor:(UIColor *)progressBgColor {
    _progressBgColor = progressBgColor;
    _backLayer.strokeColor = _progressBgColor.CGColor;
}
- (void)setLineCap:(CAShapeLayerLineCap)lineCap {
    _lineCap = lineCap;
    _frontLayer.lineCap = lineCap;
}
@end
