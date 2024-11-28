// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)tui_multimedia_map:(id (^)(id))f {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id x in self) {
        [array addObject:f(x)];
    }
    return array;
}
- (NSArray *)tui_multimedia_mapWithIndex:(id (^)(id, NSUInteger))f {
    const NSUInteger count = self.count;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        [array addObject:f(self[i], i)];
    }
    return array;
}
- (NSArray *)tui_multimedia_filter:(BOOL (^)(id))f {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id x in self) {
        if (f(x)) {
            [array addObject:x];
        }
    }
    return array;
}

+ (NSArray *)tui_multimedia_arrayWithArray:(NSArray *)array append:(NSArray *)append {
    NSMutableArray *res = [NSMutableArray arrayWithArray:array];
    for (id x in append) {
        [res addObject:x];
    }
    return res;
}
@end
