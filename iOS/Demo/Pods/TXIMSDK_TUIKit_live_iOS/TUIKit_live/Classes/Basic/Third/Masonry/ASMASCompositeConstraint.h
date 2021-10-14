//
//  ASMASCompositeConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ASMASConstraint.h"
#import "ASMASUtilities.h"

/**
 *	A group of ASMASConstraint objects
 */
@interface ASMASCompositeConstraint : ASMASConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child ASMASConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
