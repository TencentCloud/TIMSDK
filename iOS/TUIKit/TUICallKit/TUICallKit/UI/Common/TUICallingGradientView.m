//
//  TUICallingGradientView.m
//  TUICalling
//
//  Created by noah on 2021/8/24.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingGradientView.h"

@interface TUICallingGradientView ()

@property (nonatomic, strong) NSDictionary <NSNumber *, NSArray <NSValue *> *> *pointsDict;
@property (nonatomic, copy) NSArray <UIColor *> *gradientColors;
@property (nonatomic, copy) NSArray <NSNumber *> *gradientLocations;
@property (nonatomic, assign) CGPoint gradientStartPoint;
@property (nonatomic, assign) CGPoint gradientEndPoint;

@end

@implementation TUICallingGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)configWithColors:(NSArray<UIColor *> *)colors direction:(TUIGradientViewDirection)direction {
    NSArray <NSValue *> *pointArray = self.pointsDict[@(direction)];
    [self configWithColors:colors locations:nil startPoint:[[pointArray firstObject] CGPointValue] endPoint:[[pointArray lastObject] CGPointValue]];
}

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

#pragma mark - Private Method

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

- (BOOL)checkCurrentLayerClass {
    return [self.layer isKindOfClass:[CAGradientLayer class]];
}

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
