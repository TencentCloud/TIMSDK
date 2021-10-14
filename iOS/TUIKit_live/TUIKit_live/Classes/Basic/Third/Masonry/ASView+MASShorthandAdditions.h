//
//  UIView+ASMASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "ASView+MASAdditions.h"

#ifdef ASMAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas_' prefixes,
 *  only enabled if ASMAS_SHORTHAND is defined
 */
@interface ASMAS_VIEW (ASMASShorthandAdditions)

@property (nonatomic, strong, readonly) ASMASViewAttribute *left;
@property (nonatomic, strong, readonly) ASMASViewAttribute *top;
@property (nonatomic, strong, readonly) ASMASViewAttribute *right;
@property (nonatomic, strong, readonly) ASMASViewAttribute *bottom;
@property (nonatomic, strong, readonly) ASMASViewAttribute *leading;
@property (nonatomic, strong, readonly) ASMASViewAttribute *trailing;
@property (nonatomic, strong, readonly) ASMASViewAttribute *width;
@property (nonatomic, strong, readonly) ASMASViewAttribute *height;
@property (nonatomic, strong, readonly) ASMASViewAttribute *centerX;
@property (nonatomic, strong, readonly) ASMASViewAttribute *centerY;
@property (nonatomic, strong, readonly) ASMASViewAttribute *baseline;
@property (nonatomic, strong, readonly) ASMASViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) ASMASViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) ASMASViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) ASMASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) ASMASViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) ASMASViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ASMASViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ASMASViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ASMASViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(ASMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(ASMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(ASMASConstraintMaker *make))block;

@end

#define ASMAS_ATTR_FORWARD(attr)  \
- (ASMASViewAttribute *)attr {    \
    return [self mas_##attr];   \
}

@implementation ASMAS_VIEW (ASMASShorthandAdditions)

ASMAS_ATTR_FORWARD(top);
ASMAS_ATTR_FORWARD(left);
ASMAS_ATTR_FORWARD(bottom);
ASMAS_ATTR_FORWARD(right);
ASMAS_ATTR_FORWARD(leading);
ASMAS_ATTR_FORWARD(trailing);
ASMAS_ATTR_FORWARD(width);
ASMAS_ATTR_FORWARD(height);
ASMAS_ATTR_FORWARD(centerX);
ASMAS_ATTR_FORWARD(centerY);
ASMAS_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

ASMAS_ATTR_FORWARD(firstBaseline);
ASMAS_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

ASMAS_ATTR_FORWARD(leftMargin);
ASMAS_ATTR_FORWARD(rightMargin);
ASMAS_ATTR_FORWARD(topMargin);
ASMAS_ATTR_FORWARD(bottomMargin);
ASMAS_ATTR_FORWARD(leadingMargin);
ASMAS_ATTR_FORWARD(trailingMargin);
ASMAS_ATTR_FORWARD(centerXWithinMargins);
ASMAS_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

ASMAS_ATTR_FORWARD(safeAreaLayoutGuideTop);
ASMAS_ATTR_FORWARD(safeAreaLayoutGuideBottom);
ASMAS_ATTR_FORWARD(safeAreaLayoutGuideLeft);
ASMAS_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (ASMASViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self mas_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(ASMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(ASMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(ASMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
