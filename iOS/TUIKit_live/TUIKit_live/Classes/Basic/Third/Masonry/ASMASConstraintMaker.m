//
//  ASMASConstraintMaker.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ASMASConstraintMaker.h"
#import "ASMASViewConstraint.h"
#import "ASMASCompositeConstraint.h"
#import "ASMASConstraint+Private.h"
#import "ASMASViewAttribute.h"
#import "ASView+MASAdditions.h"

@interface ASMASConstraintMaker () <ASMASConstraintDelegate>

@property (nonatomic, weak) ASMAS_VIEW *view;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation ASMASConstraintMaker

- (id)initWithView:(ASMAS_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [ASMASViewConstraint installedConstraintsForView:self.view];
        for (ASMASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (ASMASConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - ASMASConstraintDelegate

- (void)constraint:(ASMASConstraint *)constraint shouldBeReplacedWithConstraint:(ASMASConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (ASMASConstraint *)constraint:(ASMASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    ASMASViewAttribute *viewAttribute = [[ASMASViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    ASMASViewConstraint *newConstraint = [[ASMASViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:ASMASViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        ASMASCompositeConstraint *compositeConstraint = [[ASMASCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

- (ASMASConstraint *)addConstraintWithAttributes:(ASMASAttribute)attrs {
    __unused ASMASAttribute anyAttribute = (ASMASAttributeLeft | ASMASAttributeRight | ASMASAttributeTop | ASMASAttributeBottom | ASMASAttributeLeading
                                          | ASMASAttributeTrailing | ASMASAttributeWidth | ASMASAttributeHeight | ASMASAttributeCenterX
                                          | ASMASAttributeCenterY | ASMASAttributeBaseline
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
                                          | ASMASAttributeFirstBaseline | ASMASAttributeLastBaseline
#endif
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
                                          | ASMASAttributeLeftMargin | ASMASAttributeRightMargin | ASMASAttributeTopMargin | ASMASAttributeBottomMargin
                                          | ASMASAttributeLeadingMargin | ASMASAttributeTrailingMargin | ASMASAttributeCenterXWithinMargins
                                          | ASMASAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    if (attrs & ASMASAttributeLeft) [attributes addObject:self.view.mas_left];
    if (attrs & ASMASAttributeRight) [attributes addObject:self.view.mas_right];
    if (attrs & ASMASAttributeTop) [attributes addObject:self.view.mas_top];
    if (attrs & ASMASAttributeBottom) [attributes addObject:self.view.mas_bottom];
    if (attrs & ASMASAttributeLeading) [attributes addObject:self.view.mas_leading];
    if (attrs & ASMASAttributeTrailing) [attributes addObject:self.view.mas_trailing];
    if (attrs & ASMASAttributeWidth) [attributes addObject:self.view.mas_width];
    if (attrs & ASMASAttributeHeight) [attributes addObject:self.view.mas_height];
    if (attrs & ASMASAttributeCenterX) [attributes addObject:self.view.mas_centerX];
    if (attrs & ASMASAttributeCenterY) [attributes addObject:self.view.mas_centerY];
    if (attrs & ASMASAttributeBaseline) [attributes addObject:self.view.mas_baseline];
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    if (attrs & ASMASAttributeFirstBaseline) [attributes addObject:self.view.mas_firstBaseline];
    if (attrs & ASMASAttributeLastBaseline) [attributes addObject:self.view.mas_lastBaseline];
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    if (attrs & ASMASAttributeLeftMargin) [attributes addObject:self.view.mas_leftMargin];
    if (attrs & ASMASAttributeRightMargin) [attributes addObject:self.view.mas_rightMargin];
    if (attrs & ASMASAttributeTopMargin) [attributes addObject:self.view.mas_topMargin];
    if (attrs & ASMASAttributeBottomMargin) [attributes addObject:self.view.mas_bottomMargin];
    if (attrs & ASMASAttributeLeadingMargin) [attributes addObject:self.view.mas_leadingMargin];
    if (attrs & ASMASAttributeTrailingMargin) [attributes addObject:self.view.mas_trailingMargin];
    if (attrs & ASMASAttributeCenterXWithinMargins) [attributes addObject:self.view.mas_centerXWithinMargins];
    if (attrs & ASMASAttributeCenterYWithinMargins) [attributes addObject:self.view.mas_centerYWithinMargins];
    
#endif
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (ASMASViewAttribute *a in attributes) {
        [children addObject:[[ASMASViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    ASMASCompositeConstraint *constraint = [[ASMASCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

#pragma mark - standard Attributes

- (ASMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
}

- (ASMASConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (ASMASConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (ASMASConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (ASMASConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (ASMASConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (ASMASConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (ASMASConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (ASMASConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (ASMASConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (ASMASConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (ASMASConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (ASMASConstraint *(^)(ASMASAttribute))attributes {
    return ^(ASMASAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (ASMASConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}

- (ASMASConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif


#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (ASMASConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (ASMASConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (ASMASConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (ASMASConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (ASMASConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (ASMASConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (ASMASConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (ASMASConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif


#pragma mark - composite Attributes

- (ASMASConstraint *)edges {
    return [self addConstraintWithAttributes:ASMASAttributeTop | ASMASAttributeLeft | ASMASAttributeRight | ASMASAttributeBottom];
}

- (ASMASConstraint *)size {
    return [self addConstraintWithAttributes:ASMASAttributeWidth | ASMASAttributeHeight];
}

- (ASMASConstraint *)center {
    return [self addConstraintWithAttributes:ASMASAttributeCenterX | ASMASAttributeCenterY];
}

#pragma mark - grouping

- (ASMASConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        ASMASCompositeConstraint *constraint = [[ASMASCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end
