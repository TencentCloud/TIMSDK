
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <objc/runtime.h>
#import "UIView+TUILayout.h"

@implementation UIView (TUILayout)

#pragma mark - frame
- (void)setMm_x:(CGFloat)mm_x {
    CGRect frame = self.frame;
    frame.origin.x = mm_x;
    self.frame = frame;
}

- (CGFloat)mm_x {
    return self.frame.origin.x;
}

- (void)setMm_y:(CGFloat)mm_y {
    CGRect frame = self.frame;
    frame.origin.y = mm_y;
    self.frame = frame;
}
- (CGFloat)mm_y {
    return self.frame.origin.y;
}
- (void)setMm_w:(CGFloat)mm_w {
    CGRect frame = self.frame;
    frame.size.width = mm_w;
    self.frame = frame;
}

- (CGFloat)mm_w {
    return self.frame.size.width;
}

- (void)setMm_h:(CGFloat)mm_h {
    CGRect frame = self.frame;
    frame.size.height = mm_h;
    self.frame = frame;
}

- (CGFloat)mm_h {
    return self.frame.size.height;
}

- (CGFloat)mm_centerX {
    return self.center.x;
}

- (CGFloat)mm_centerY {
    return self.center.y;
}

- (void)setMm_centerX:(CGFloat)mm_centerX {
    CGPoint center = self.center;
    center.x = mm_centerX;
    self.center = center;
}

- (void)setMm_centerY:(CGFloat)mm_centerY {
    CGPoint center = self.center;
    center.y = mm_centerY;
    self.center = center;
}

- (CGFloat)mm_r {
    NSCAssert(self.superview, @"must add subview first");
    return self.superview.mm_w - self.mm_maxX;
}

- (void)setMm_r:(CGFloat)mm_r {
    self.mm_x += self.mm_r - mm_r;
}

- (CGFloat)mm_b {
    NSCAssert(self.superview, @"must add subview first");
    return self.superview.mm_h - self.mm_maxY;
}

- (void)setMm_b:(CGFloat)mm_b {
    self.mm_y += self.mm_b - mm_b;
}

- (CGFloat)mm_maxY {
    return CGRectGetMaxY(self.frame);
}
- (CGFloat)mm_minY {
    return CGRectGetMinY(self.frame);
}
- (CGFloat)mm_maxX {
    return CGRectGetMaxX(self.frame);
}
- (CGFloat)mm_minX {
    return CGRectGetMinX(self.frame);
}

#pragma mark - chain call

- (UIView * (^)(CGFloat))mm_top {
    @tui_mm_weakify(self);
    return ^(CGFloat m_top) {
      @tui_mm_strongify(self);
      self.mm_y = m_top;
      return self;
    };
}

- (UIView * (^)(CGFloat))mm_bottom {
    @tui_mm_weakify(self);
    return ^(CGFloat m_bottom) {
      @tui_mm_strongify(self);
      self.mm_b = m_bottom;
      return self;
    };
}
- (UIView * (^)(CGFloat))mm_flexToBottom {
    @tui_mm_weakify(self);
    return ^(CGFloat m_flexToBottom) {
      @tui_mm_strongify(self);
      self.mm_h += self.mm_b - m_flexToBottom;
      return self;
    };
}
- (UIView * (^)(CGFloat))mm_left {
    @tui_mm_weakify(self);
    return ^(CGFloat m_left) {
      @tui_mm_strongify(self);
      self.mm_x = m_left;
      return self;
    };
}

- (UIView * (^)(CGFloat))mm_right {
    @tui_mm_weakify(self);
    return ^(CGFloat m_right) {
      @tui_mm_strongify(self);
      self.mm_r = m_right;
      return self;
    };
}
- (UIView * (^)(CGFloat))mm_flexToRight {
    @tui_mm_weakify(self);
    return ^(CGFloat m_flexToRight) {
      @tui_mm_strongify(self);
      self.mm_w += self.mm_r - m_flexToRight;
      return self;
    };
}

- (UIView * (^)(CGFloat))mm_width {
    @tui_mm_weakify(self);
    return ^(CGFloat m_width) {
      @tui_mm_strongify(self);
      self.mm_w = m_width;
      return self;
    };
}
- (UIView * (^)(CGFloat))mm_height {
    @tui_mm_weakify(self);
    return ^(CGFloat m_height) {
      @tui_mm_strongify(self);
      self.mm_h = m_height;
      return self;
    };
}

- (UIView * (^)(CGFloat))mm__centerX {
    @tui_mm_weakify(self);
    return ^(CGFloat x) {
      @tui_mm_strongify(self);
      NSAssert(self.mm_w, @"must set width first");
      self.mm_centerX = x;
      return self;
    };
}

- (UIView * (^)(CGFloat))mm__centerY {
    @tui_mm_weakify(self);
    return ^(CGFloat y) {
      @tui_mm_strongify(self);
      NSAssert(self.mm_h, @"must set height first");
      self.mm_centerY = y;
      return self;
    };
}

- (UIView * (^)(void))tui_mm_center {
    @tui_mm_weakify(self);
    return ^{
      @tui_mm_strongify(self);
      if (self.superview) {
          self.mm_centerX = self.superview.mm_w / 2;
          self.mm_centerY = self.superview.mm_h / 2;
      }
      return self;
    };
}

- (UIView * (^)(void))mm_fill {
    @tui_mm_weakify(self);
    return ^{
      @tui_mm_strongify(self);
      if (self.superview) {
          self.mm_x = self.mm_y = 0;
          self.mm_w = self.superview.mm_w;
          self.mm_h = self.superview.mm_h;
      }
      return self;
    };
}

- (UIView * (^)(void))mm_sizeToFit {
    @tui_mm_weakify(self);
    return ^{
      @tui_mm_strongify(self);
      [self sizeToFit];
      return self;
    };
}
- (UIView * (^)(CGFloat w, CGFloat h))mm_sizeToFitThan {
    @tui_mm_weakify(self);
    return ^(CGFloat w, CGFloat h) {
      @tui_mm_strongify(self);
      [self sizeToFit];
      if (self.mm_w < w) self.mm_w = w;
      if (self.mm_h < h) self.mm_h = h;
      return self;
    };
}

- (UIView * (^)(CGFloat space))mm_hstack {
    @tui_mm_weakify(self);
    return ^(CGFloat space) {
      @tui_mm_strongify(self);
      if (self.mm_sibling) {
          self.mm__centerY(self.mm_sibling.mm_centerY).mm_left(self.mm_sibling.mm_maxX + space);
      }
      return self;
    };
}

- (UIView * (^)(CGFloat space))mm_vstack {
    @tui_mm_weakify(self);
    return ^(CGFloat space) {
      @tui_mm_strongify(self);
      if (self.mm_sibling) {
          self.mm__centerX(self.mm_sibling.mm_centerX).mm_top(self.mm_sibling.mm_maxY + space);
      }
      return self;
    };
}

- (UIView *)mm_sibling {
    NSUInteger idx = [self.superview.subviews indexOfObject:self];
    if (idx == 0 || idx == NSNotFound) return nil;
    return self.superview.subviews[idx - 1];
}

- (UIViewController *)mm_viewController {
    UIView *view = self;
    while (view) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
        view = view.superview;
    }
    return nil;
}

static void *gTUIViewLayoutMethodPropertyBottomGap = &gTUIViewLayoutMethodPropertyBottomGap;
static void *gTUIViewLayoutMethodPropertyTopGap = &gTUIViewLayoutMethodPropertyTopGap;
static void *gTUIViewLayoutMethodPropertyLeftGap = &gTUIViewLayoutMethodPropertyLeftGap;
static void *gTUIViewLayoutMethodPropertyRightGap = &gTUIViewLayoutMethodPropertyRightGap;

- (CGFloat)mm_safeAreaBottomGap {
    NSNumber *gap = objc_getAssociatedObject(self, gTUIViewLayoutMethodPropertyBottomGap);
    if (gap == nil) {
        if (@available(iOS 11, *)) {
            if (self.superview.safeAreaLayoutGuide.layoutFrame.size.height > 0) {
                gap = @((self.superview.mm_h - self.superview.safeAreaLayoutGuide.layoutFrame.origin.y -
                         self.superview.safeAreaLayoutGuide.layoutFrame.size.height));
            } else {
                gap = nil;
            }
        } else {
            gap = @(0);
        }
        objc_setAssociatedObject(self, gTUIViewLayoutMethodPropertyBottomGap, gap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gap.floatValue;
}

- (CGFloat)mm_safeAreaTopGap {
    NSNumber *gap = objc_getAssociatedObject(self, gTUIViewLayoutMethodPropertyTopGap);
    if (gap == nil) {
        if (@available(iOS 11, *)) {
            gap = @(self.superview.safeAreaLayoutGuide.layoutFrame.origin.y);
        } else {
            gap = @(0);
        }
        objc_setAssociatedObject(self, gTUIViewLayoutMethodPropertyTopGap, gap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gap.floatValue;
}

- (CGFloat)mm_safeAreaLeftGap {
    NSNumber *gap = objc_getAssociatedObject(self, gTUIViewLayoutMethodPropertyLeftGap);
    if (gap == nil) {
        if (@available(iOS 11, *)) {
            gap = @(self.superview.safeAreaLayoutGuide.layoutFrame.origin.x);
        } else {
            gap = @(0);
        }
        objc_setAssociatedObject(self, gTUIViewLayoutMethodPropertyLeftGap, gap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gap.floatValue;
}

- (CGFloat)mm_safeAreaRightGap {
    NSNumber *gap = objc_getAssociatedObject(self, gTUIViewLayoutMethodPropertyRightGap);
    if (gap == nil) {
        if (@available(iOS 11, *)) {
            gap =
                @((self.superview.mm_w - self.superview.safeAreaLayoutGuide.layoutFrame.origin.x - self.superview.safeAreaLayoutGuide.layoutFrame.size.width));
        } else {
            gap = @(0);
        }
        objc_setAssociatedObject(self, gTUIViewLayoutMethodPropertyRightGap, gap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gap.floatValue;
}

@end
