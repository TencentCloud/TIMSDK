// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 持久化工具类
 所有路径参数均使用相对路径
 */
@interface TUIMultimediaPersistence : NSObject
+ (NSString *)basePath;
+ (BOOL)saveData:(NSData *)data toFile:(NSString *)file error:(NSError **_Nullable)error;
+ (nullable NSData *)loadDataFromFile:(NSString *)file error:(NSError **_Nullable)error;
+ (BOOL)removeFile:(NSString *)file error:(NSError **_Nullable)error;
@end

NS_ASSUME_NONNULL_END
