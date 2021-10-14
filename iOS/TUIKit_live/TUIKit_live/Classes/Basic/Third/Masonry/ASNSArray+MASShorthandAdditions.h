//
//  ASNSArray+MASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "ASNSArray+MASAdditions.h"

#ifdef ASMAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas_' prefixes,
 *  only enabled if ASMAS_SHORTHAND is defined
 */
@interface NSArray (ASMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(ASMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(ASMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(ASMASConstraintMaker *make))block;

@end

@implementation NSArray (ASMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(ASMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(ASMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(ASMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
