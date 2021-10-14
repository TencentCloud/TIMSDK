//
//  UIASView+MASAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ASMASUtilities.h"
#import "ASMASConstraintMaker.h"
#import "ASMASViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating ASMASViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface ASMAS_VIEW (ASMASAdditions)

/**
 *	following properties return a new ASMASViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_left;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_top;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_right;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_bottom;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_leading;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_trailing;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_width;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_height;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_centerX;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_centerY;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_baseline;
@property (nonatomic, strong, readonly) ASMASViewAttribute *(^mas_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_firstBaseline;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_leftMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_rightMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_topMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_bottomMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_leadingMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_trailingMargin;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_centerXWithinMargins;
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ASMASViewAttribute *mas_safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id mas_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)mas_closestCommonSuperview:(ASMAS_VIEW *)view;

/**
 *  Creates a ASMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created ASMASConstraints
 */
- (NSArray *)mas_makeConstraints:(void(NS_NOESCAPE ^)(ASMASConstraintMaker *make))block;

/**
 *  Creates a ASMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated ASMASConstraints
 */
- (NSArray *)mas_updateConstraints:(void(NS_NOESCAPE ^)(ASMASConstraintMaker *make))block;

/**
 *  Creates a ASMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated ASMASConstraints
 */
- (NSArray *)mas_remakeConstraints:(void(NS_NOESCAPE ^)(ASMASConstraintMaker *make))block;

@end
