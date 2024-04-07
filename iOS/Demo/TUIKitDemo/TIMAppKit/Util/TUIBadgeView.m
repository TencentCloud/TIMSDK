//
//  TUIBadgeView.m
//  TUIKitDemo
//
//  Created by harvy on 2021/10/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TUIBadgeView.h"
#import <TUICore/UIView+TUILayout.h>

#define TUIBadgeViewColor UIColor.redColor
#define TUIBadgeLabelColor UIColor.whiteColor
#define TUIBadgeLabelFont [UIFont systemFontOfSize:14.0]

#define kAssistCircleDefaultWH 10

@interface TUIBadgeView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UILabel *label;

// Assist circle view for displaying in the origin position
@property(nonatomic, strong) UIView *assistCircleView;
 
// initial postion
@property(nonatomic, assign) CGPoint initialCenterPosition;

@end

@implementation TUIBadgeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    CGPoint point = self.center;
    self.label.text = title;
    self.hidden = (title.length == 0);

    [self sizeToFit];
    self.center = point;
}

- (void)setupUI {
    self.backgroundColor = TUIBadgeViewColor;
    [self addSubview:self.label];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.cancelsTouchesInView = NO;
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.tui_mm_center();
    self.layer.cornerRadius = 0.5 * self.bounds.size.height;
}

- (CGSize)sizeThatFits:(CGSize)size {
    [self.label sizeToFit];
    CGFloat width = self.label.bounds.size.width + 8;
    CGFloat height = self.label.bounds.size.height + 2;
    if (width < height) {
        width = height;
    }
    return CGSizeMake(width, height);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

- (void)pan:(UIPanGestureRecognizer *)gesture {
    if (self.clearCallback == nil) {
        return;
    }

    if (UIGestureRecognizerStateBegan == gesture.state) {
        self.initialCenterPosition = self.center;
    }

    CGPoint point = [gesture locationInView:self.superview];
    CGFloat distance_x = point.x - self.initialCenterPosition.x;
    CGFloat distance_y = point.y - self.initialCenterPosition.y;
    CGFloat distance = sqrtf(distance_x * distance_x + distance_y * distance_y);
    self.center = point;

    if (UIGestureRecognizerStateEnded == gesture.state) {
        // end
        self.hidden = distance >= 60;
        self.center = self.initialCenterPosition;
        if (distance >= 60) {
            [self reset];
            self.clearCallback();
        }
    }
}

- (void)reset {
    self.initialCenterPosition = CGPointZero;
    self.title = @"";
}

- (UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textColor = TUIBadgeLabelColor;
        _label.font = TUIBadgeLabelFont;
    }
    return _label;
}

- (UIView *)assistCircleView {
    if (_assistCircleView == nil) {
        _assistCircleView = [[UIView alloc] init];
        _assistCircleView.backgroundColor = TUIBadgeViewColor;
        _assistCircleView.hidden = YES;
        _assistCircleView.layer.cornerRadius = 0.5 * kAssistCircleDefaultWH;
        _assistCircleView.layer.masksToBounds = YES;
    }
    return _assistCircleView;
}

@end
