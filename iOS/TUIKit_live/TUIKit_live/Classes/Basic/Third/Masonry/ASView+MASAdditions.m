//
//  UIASView+MASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ASView+MASAdditions.h"
#import <objc/runtime.h>

@implementation ASMAS_VIEW (ASMASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(ASMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ASMASConstraintMaker *constraintMaker = [[ASMASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(ASMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ASMASConstraintMaker *constraintMaker = [[ASMASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(ASMASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ASMASConstraintMaker *constraintMaker = [[ASMASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (ASMASViewAttribute *)mas_left {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (ASMASViewAttribute *)mas_top {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (ASMASViewAttribute *)mas_right {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (ASMASViewAttribute *)mas_bottom {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (ASMASViewAttribute *)mas_leading {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (ASMASViewAttribute *)mas_trailing {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (ASMASViewAttribute *)mas_width {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (ASMASViewAttribute *)mas_height {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (ASMASViewAttribute *)mas_centerX {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (ASMASViewAttribute *)mas_centerY {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (ASMASViewAttribute *)mas_baseline {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (ASMASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (ASMASViewAttribute *)mas_firstBaseline {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (ASMASViewAttribute *)mas_lastBaseline {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (ASMASViewAttribute *)mas_leftMargin {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (ASMASViewAttribute *)mas_rightMargin {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (ASMASViewAttribute *)mas_topMargin {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (ASMASViewAttribute *)mas_bottomMargin {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (ASMASViewAttribute *)mas_leadingMargin {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (ASMASViewAttribute *)mas_trailingMargin {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (ASMASViewAttribute *)mas_centerXWithinMargins {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (ASMASViewAttribute *)mas_centerYWithinMargins {
    return [[ASMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

- (ASMASViewAttribute *)mas_safeAreaLayoutGuide {
    return [[ASMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (ASMASViewAttribute *)mas_safeAreaLayoutGuideTop {
    return [[ASMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ASMASViewAttribute *)mas_safeAreaLayoutGuideBottom {
    return [[ASMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (ASMASViewAttribute *)mas_safeAreaLayoutGuideLeft {
    return [[ASMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}
- (ASMASViewAttribute *)mas_safeAreaLayoutGuideRight {
    return [[ASMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

#endif

#pragma mark - associated properties

- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(ASMAS_VIEW *)view {
    ASMAS_VIEW *closestCommonSuperview = nil;

    ASMAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        ASMAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
