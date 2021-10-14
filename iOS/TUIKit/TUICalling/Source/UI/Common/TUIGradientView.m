//
//  TUIGradientView.m
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import "TUIGradientView.h"

@interface TUIGradientView ()

/// 常用渐变方向集合
@property (nonatomic, strong) NSDictionary <NSNumber *, NSArray <NSValue *> *> *pointsDict;

/// 渐变颜色
@property (nonatomic, copy) NSArray <UIColor *> *gradientColors;

/// 渐变颜色区间
@property (nonatomic, copy) NSArray <NSNumber *> *gradientLocations;

/// 起始点
@property (nonatomic, assign) CGPoint gradientStartPoint;

/// 结束点
@property (nonatomic, assign) CGPoint gradientEndPoint;

@end

@implementation TUIGradientView

#pragma mark - override

+ (Class)layerClass {
    return [CAGradientLayer class];
}

#pragma mark - 设置渐变参数，提供常用渐变方向

- (void)configWithColors:(NSArray<UIColor *> *)colors direction:(TUIGradientViewDirection)direction {
    NSArray <NSValue *> *pointArray = self.pointsDict[@(direction)];
    [self configWithColors:colors locations:nil startPoint:[[pointArray firstObject] CGPointValue] endPoint:[[pointArray lastObject] CGPointValue]];
}

#pragma mark - 设置渐变参数

- (void)configWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    NSMutableArray *colorsTemp = [NSMutableArray array];
    for (UIColor *color in colors) {
        if ((__bridge id)color.CGColor) {
            [colorsTemp addObject:(__bridge id)color.CGColor];
        }
    }
    self.gradientColors = [colorsTemp copy];
    self.gradientLocations = locations;
    self.gradientStartPoint = startPoint;
    self.gradientEndPoint = endPoint;
}

#pragma mark- 私有方法

- (void)setGradientColors:(NSArray<UIColor *> *)gradientColors {
    if ([self checkCurrentLayerClass]) {
        [((CAGradientLayer *)self.layer) setColors:gradientColors];
    }
}

- (void)setGradientLocations:(NSArray<NSNumber *> *)gradientLocations {
    if ([self checkCurrentLayerClass]) {
        [((CAGradientLayer *)self.layer) setLocations:gradientLocations];
    }
}

- (void)setGradientStartPoint:(CGPoint)gradientStartPoint {
    if ([self checkCurrentLayerClass]) {
        [((CAGradientLayer *)self.layer) setStartPoint:gradientStartPoint];
    }
}

- (void)setGradientEndPoint:(CGPoint)gradientEndPoint {
    if ([self checkCurrentLayerClass]) {
        [((CAGradientLayer *)self.layer) setEndPoint:gradientEndPoint];
    }
}

#pragma mark - 检查当前layer类

- (BOOL)checkCurrentLayerClass {
    return [self.layer isKindOfClass:[CAGradientLayer class]];
}

#pragma mark - 常用渐变方向集合

- (NSDictionary <NSNumber *, NSArray <NSValue *> *> *)pointsDict {
    return @{
        @(TUIGradientViewDirectionLeftToRight) : @[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(1, 0)]],
        @(TUIGradientViewDirectionRightToLeft) : @[[NSValue valueWithCGPoint:CGPointMake(1, 0)], [NSValue valueWithCGPoint:CGPointMake(0, 0)]],
        @(TUIGradientViewDirectionBottomToTop) : @[[NSValue valueWithCGPoint:CGPointMake(0, 1)], [NSValue valueWithCGPoint:CGPointMake(0, 0)]],
        @(TUIGradientViewDirectionTopToBottom) : @[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(0, 1)]],
        @(TUIGradientViewDirectionLeftBottomToRightTop) : @[[NSValue valueWithCGPoint:CGPointMake(0, 1)], [NSValue valueWithCGPoint:CGPointMake(1, 0)]],
        @(TUIGradientViewDirectionLeftTopToRightBottom) : @[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(1, 1)]],
        @(TUIGradientViewDirectionRightBottomToLeftTop) : @[[NSValue valueWithCGPoint:CGPointMake(1, 1)], [NSValue valueWithCGPoint:CGPointMake(0, 0)]],
        @(TUIGradientViewDirectionRightTopToLeftBottom) : @[[NSValue valueWithCGPoint:CGPointMake(1, 0)], [NSValue valueWithCGPoint:CGPointMake(0, 1)]]
    };
}

@end
