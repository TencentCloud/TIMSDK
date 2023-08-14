//
//  TUIChatPopActionsView.m
//  TUIChat
//
//  Created by wyl on 2022/6/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatPopActionsView.h"

@implementation TUIChatPopActionsView

- (void)layoutSubviews {
    [super layoutSubviews];

    [self updateCorner];
}
- (void)updateCorner {
    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    CGRect containerBounds = self.bounds;
    CGRect bounds = CGRectMake(containerBounds.origin.x, containerBounds.origin.y - 1, containerBounds.size.width, containerBounds.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corner cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
@end
