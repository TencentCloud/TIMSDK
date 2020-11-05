//
//  ASMASCompositeConstraint.m
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ASMASCompositeConstraint.h"
#import "ASMASConstraint+Private.h"

@interface ASMASCompositeConstraint () <ASMASConstraintDelegate>

@property (nonatomic, strong) id mas_key;
@property (nonatomic, strong) NSMutableArray *childConstraints;

@end

@implementation ASMASCompositeConstraint

- (id)initWithChildren:(NSArray *)children {
    self = [super init];
    if (!self) return nil;

    _childConstraints = [children mutableCopy];
    for (ASMASConstraint *constraint in _childConstraints) {
        constraint.delegate = self;
    }

    return self;
}

#pragma mark - ASMASConstraintDelegate

- (void)constraint:(ASMASConstraint *)constraint shouldBeReplacedWithConstraint:(ASMASConstraint *)replacementConstraint {
    NSUInteger index = [self.childConstraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.childConstraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (ASMASConstraint *)constraint:(ASMASConstraint __unused *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    id<ASMASConstraintDelegate> strongDelegate = self.delegate;
    ASMASConstraint *newConstraint = [strongDelegate constraint:self addConstraintWithLayoutAttribute:layoutAttribute];
    newConstraint.delegate = self;
    [self.childConstraints addObject:newConstraint];
    return newConstraint;
}

#pragma mark - NSLayoutConstraint multiplier proxies 

- (ASMASConstraint * (^)(CGFloat))multipliedBy {
    return ^id(CGFloat multiplier) {
        for (ASMASConstraint *constraint in self.childConstraints) {
            constraint.multipliedBy(multiplier);
        }
        return self;
    };
}

- (ASMASConstraint * (^)(CGFloat))dividedBy {
    return ^id(CGFloat divider) {
        for (ASMASConstraint *constraint in self.childConstraints) {
            constraint.dividedBy(divider);
        }
        return self;
    };
}

#pragma mark - ASMASLayoutPriority proxy

- (ASMASConstraint * (^)(ASMASLayoutPriority))priority {
    return ^id(ASMASLayoutPriority priority) {
        for (ASMASConstraint *constraint in self.childConstraints) {
            constraint.priority(priority);
        }
        return self;
    };
}

#pragma mark - NSLayoutRelation proxy

- (ASMASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation {
    return ^id(id attr, NSLayoutRelation relation) {
        for (ASMASConstraint *constraint in self.childConstraints.copy) {
            constraint.equalToWithRelation(attr, relation);
        }
        return self;
    };
}

#pragma mark - attribute chaining

- (ASMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    [self constraint:self addConstraintWithLayoutAttribute:layoutAttribute];
    return self;
}

#pragma mark - Animator proxy

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)

- (ASMASConstraint *)animator {
    for (ASMASConstraint *constraint in self.childConstraints) {
        [constraint animator];
    }
    return self;
}

#endif

#pragma mark - debug helpers

- (ASMASConstraint * (^)(id))key {
    return ^id(id key) {
        self.mas_key = key;
        int i = 0;
        for (ASMASConstraint *constraint in self.childConstraints) {
            constraint.key([NSString stringWithFormat:@"%@[%d]", key, i++]);
        }
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant setters

- (void)setInsets:(ASMASEdgeInsets)insets {
    for (ASMASConstraint *constraint in self.childConstraints) {
        constraint.insets = insets;
    }
}

- (void)setInset:(CGFloat)inset {
    for (ASMASConstraint *constraint in self.childConstraints) {
        constraint.inset = inset;
    }
}

- (void)setOffset:(CGFloat)offset {
    for (ASMASConstraint *constraint in self.childConstraints) {
        constraint.offset = offset;
    }
}

- (void)setSizeOffset:(CGSize)sizeOffset {
    for (ASMASConstraint *constraint in self.childConstraints) {
        constraint.sizeOffset = sizeOffset;
    }
}

- (void)setCenterOffset:(CGPoint)centerOffset {
    for (ASMASConstraint *constraint in self.childConstraints) {
        constraint.centerOffset = centerOffset;
    }
}

#pragma mark - ASMASConstraint

- (void)activate {
    for (ASMASConstraint *constraint in self.childConstraints) {
        [constraint activate];
    }
}

- (void)deactivate {
    for (ASMASConstraint *constraint in self.childConstraints) {
        [constraint deactivate];
    }
}

- (void)install {
    for (ASMASConstraint *constraint in self.childConstraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
}

- (void)uninstall {
    for (ASMASConstraint *constraint in self.childConstraints) {
        [constraint uninstall];
    }
}

@end
