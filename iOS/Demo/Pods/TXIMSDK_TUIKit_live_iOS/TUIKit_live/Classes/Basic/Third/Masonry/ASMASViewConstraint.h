//
//  ASMASViewConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ASMASViewAttribute.h"
#import "ASMASConstraint.h"
#import "ASMASLayoutConstraint.h"
#import "ASMASUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface ASMASViewConstraint : ASMASConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) ASMASViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) ASMASViewAttribute *secondViewAttribute;

/**
 *	initialises the ASMASViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.mas_left, view.mas_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(ASMASViewAttribute *)firstViewAttribute;

/**
 *  Returns all ASMASViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of ASMASViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(ASMAS_VIEW *)view;

@end
