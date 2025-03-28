// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray <__covariant ObjectType>(Functional)

- (NSArray *)tui_multimedia_map:(id (^)(ObjectType))f;
- (NSArray *)tui_multimedia_mapWithIndex:(id (^)(ObjectType, NSUInteger))f;

- (NSArray<ObjectType> *)tui_multimedia_filter:(BOOL (^)(ObjectType))f;

+ (NSArray<ObjectType> *)tui_multimedia_arrayWithArray:(NSArray<ObjectType> *)array append:(NSArray<ObjectType> *)append;
@end

NS_ASSUME_NONNULL_END
