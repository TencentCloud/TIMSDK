//
//  TUICircleLodingView.m
//  TUIChat
//
//  Created by wyl on 2023/4/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICircleLodingView.h"

#define kCircleUnFillColor [[UIColor whiteColor] colorWithAlphaComponent:0.4]

#define kCircleFillColor [UIColor whiteColor]

@interface TUICircleLodingView ()

@end

@implementation TUICircleLodingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self drawProgressCircleWithEndAngle:-M_PI_2 + M_PI * 2 isGrayCircle:YES];
    }
    return self;
}

- (void)setProgress:(double)progress {
    _progress = progress;
    self.labProgress.text = [NSString stringWithFormat:@"%.0f%%", progress];
    [self drawProgress];
}

- (void)drawProgress {
    if (self.progress >= 100) {
        return;
    }
    [self drawProgressCircleWithEndAngle:-M_PI_2 + M_PI * 2 * (self.progress) * 0.01 isGrayCircle:NO];
}

- (void)drawProgressCircleWithEndAngle:(CGFloat)endAngle isGrayCircle:(BOOL)isGrayCircle {
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.width / 2);
    CGFloat radius = self.frame.size.width / 2;
    CGFloat startA = -M_PI_2;
    CGFloat endA = endAngle;

    CAShapeLayer *layer;
    if (isGrayCircle) {
        layer = self.grayProgressLayer;
    } else {
        layer = self.progressLayer;
    }

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    layer.path = [path CGPath];
}

- (UILabel *)labProgress {
    if (!_labProgress) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.center = CGPointMake(self.frame.size.width / 2, self.frame.size.width / 2);
        label.textColor = kCircleFillColor;
        label.font = [UIFont systemFontOfSize:10];
        [self addSubview:label];
        _labProgress = label;
    }
    return _labProgress;
}

- (CAShapeLayer *)grayProgressLayer {
    if (!_grayProgressLayer) {
        _grayProgressLayer = [CAShapeLayer layer];
        _grayProgressLayer.frame = self.bounds;
        _grayProgressLayer.fillColor = [[UIColor clearColor] CGColor];
        _grayProgressLayer.strokeColor = kCircleUnFillColor.CGColor;
        _grayProgressLayer.opacity = 1;
        _grayProgressLayer.lineCap = kCALineCapRound;
        _grayProgressLayer.lineWidth = 3;
        [self.layer addSublayer:_grayProgressLayer];
    }
    return _grayProgressLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor = kCircleFillColor.CGColor;
        _progressLayer.opacity = 1;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = 3;
        [self.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

@end
