//
//  ASMASConstraint+Private.h
//  Masonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "ASMASConstraint.h"

@protocol ASMASConstraintDelegate;


@interface ASMASConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually ASMASConstraintMaker but could be a parent ASMASConstraint
 */
@property (nonatomic, weak) id<ASMASConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with ASMASEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface ASMASConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    ASMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (ASMASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (ASMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol ASMASConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A ASMASViewConstraint may turn into a ASMASCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(ASMASConstraint *)constraint shouldBeReplacedWithConstraint:(ASMASConstraint *)replacementConstraint;

- (ASMASConstraint *)constraint:(ASMASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
