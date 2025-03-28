// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaSplitter.h"

@interface TUIMultimediaSplitter () {
    CAShapeLayer *_shapeLayer;
}

@end

@implementation TUIMultimediaSplitter
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _color = UIColor.lightGrayColor;
    _lineWidth = 1;
    _lineCap = kCGLineCapRound;
    self.backgroundColor = UIColor.clearColor;

    _shapeLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_shapeLayer];

    [self updateShapeLayer];
    return self;
}
- (void)updateShapeLayer {
    _shapeLayer.frame = self.bounds;
    CGPoint startPoint, endPoint;
    CGSize size = self.bounds.size;
    CGFloat inset = 0;
    if (_axis == UILayoutConstraintAxisVertical) {
        startPoint = CGPointMake(size.width / 2, inset);
        endPoint = CGPointMake(size.width / 2, size.height - inset);
    } else {
        startPoint = CGPointMake(inset, size.height / 2);
        endPoint = CGPointMake(size.width - inset, size.height / 2);
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    _shapeLayer.path = path.CGPath;
    _shapeLayer.strokeColor = _color.CGColor;
    _shapeLayer.lineWidth = _lineWidth;
    switch (_lineCap) {
        default:
        case kCGLineCapButt:
            _shapeLayer.lineCap = kCALineCapButt;
            break;
        case kCGLineCapRound:
            _shapeLayer.lineCap = kCALineCapRound;
            break;
        case kCGLineCapSquare:
            _shapeLayer.lineCap = kCALineCapSquare;
            break;
    }
}
- (void)layoutSubviews {
    [self updateShapeLayer];
}
- (void)setAxis:(UILayoutConstraintAxis)axis {
    _axis = axis;
    [self updateShapeLayer];
}
- (void)setColor:(UIColor *)color {
    _color = color;
    [self updateShapeLayer];
}
- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self updateShapeLayer];
}
- (void)setLineCap:(CGLineCap)lineCap {
    _lineCap = lineCap;
    [self updateShapeLayer];
}
@end
