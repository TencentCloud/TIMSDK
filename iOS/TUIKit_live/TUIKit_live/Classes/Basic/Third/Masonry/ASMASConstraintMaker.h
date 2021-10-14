//
//  ASMASConstraintMaker.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ASMASConstraint.h"
#import "ASMASUtilities.h"

typedef NS_OPTIONS(NSInteger, ASMASAttribute) {
    ASMASAttributeLeft = 1 << NSLayoutAttributeLeft,
    ASMASAttributeRight = 1 << NSLayoutAttributeRight,
    ASMASAttributeTop = 1 << NSLayoutAttributeTop,
    ASMASAttributeBottom = 1 << NSLayoutAttributeBottom,
    ASMASAttributeLeading = 1 << NSLayoutAttributeLeading,
    ASMASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    ASMASAttributeWidth = 1 << NSLayoutAttributeWidth,
    ASMASAttributeHeight = 1 << NSLayoutAttributeHeight,
    ASMASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    ASMASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    ASMASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    ASMASAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    ASMASAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    ASMASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    ASMASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    ASMASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    ASMASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    ASMASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    ASMASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    ASMASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    ASMASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating ASMASConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface ASMASConstraintMaker : NSObject

/**
 *	The following properties return a new ASMASViewConstraint
 *  with the first item set to the makers associated view and the appropriate ASMASViewAttribute
 */
@property (nonatomic, strong, readonly) ASMASConstraint *left;
@property (nonatomic, strong, readonly) ASMASConstraint *top;
@property (nonatomic, strong, readonly) ASMASConstraint *right;
@property (nonatomic, strong, readonly) ASMASConstraint *bottom;
@property (nonatomic, strong, readonly) ASMASConstraint *leading;
@property (nonatomic, strong, readonly) ASMASConstraint *trailing;
@property (nonatomic, strong, readonly) ASMASConstraint *width;
@property (nonatomic, strong, readonly) ASMASConstraint *height;
@property (nonatomic, strong, readonly) ASMASConstraint *centerX;
@property (nonatomic, strong, readonly) ASMASConstraint *centerY;
@property (nonatomic, strong, readonly) ASMASConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) ASMASConstraint *firstBaseline;
@property (nonatomic, strong, readonly) ASMASConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) ASMASConstraint *leftMargin;
@property (nonatomic, strong, readonly) ASMASConstraint *rightMargin;
@property (nonatomic, strong, readonly) ASMASConstraint *topMargin;
@property (nonatomic, strong, readonly) ASMASConstraint *bottomMargin;
@property (nonatomic, strong, readonly) ASMASConstraint *leadingMargin;
@property (nonatomic, strong, readonly) ASMASConstraint *trailingMargin;
@property (nonatomic, strong, readonly) ASMASConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) ASMASConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new ASMASCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  ASMASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) ASMASConstraint *(^attributes)(ASMASAttribute attrs);

/**
 *	Creates a ASMASCompositeConstraint with type ASMASCompositeConstraintTypeEdges
 *  which generates the appropriate ASMASViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) ASMASConstraint *edges;

/**
 *	Creates a ASMASCompositeConstraint with type ASMASCompositeConstraintTypeSize
 *  which generates the appropriate ASMASViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) ASMASConstraint *size;

/**
 *	Creates a ASMASCompositeConstraint with type ASMASCompositeConstraintTypeCenter
 *  which generates the appropriate ASMASViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) ASMASConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any ASMASConstraint are created with this view as the first item
 *
 *	@return	a new ASMASConstraintMaker
 */
- (id)initWithView:(ASMAS_VIEW *)view;

/**
 *	Calls install method on any ASMASConstraints which have been created by this maker
 *
 *	@return	an array of all the installed ASMASConstraints
 */
- (NSArray *)install;

- (ASMASConstraint * (^)(dispatch_block_t))group;

@end
