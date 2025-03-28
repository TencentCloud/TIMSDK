// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaPersistence.h"
#import <TUICore/NSString+TUIUtil.h>

#define PASS_ERROR_WITH_LOG(errsrc, errdst, retval)                                 \
    do {                                                                            \
        if (errsrc != nil) {                                                        \
            NSLog(@"[TUIMultimedia] %s error: %@", __func__, errsrc.localizedDescription); \
            if (errdst != nil) {                                                    \
                *errdst = errsrc;                                                   \
            }                                                                       \
            return retval;                                                          \
        }                                                                           \
    } while (0)

static NSString *const BasePath = @"TUIMultimediaPlugin";

@implementation TUIMultimediaPersistence
+ (NSString *)basePath {
    NSString *res = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [res stringByAppendingPathComponent:BasePath];
}

+ (BOOL)saveData:(NSData *)data toFile:(NSString *)file error:(NSError **)error {
    NSAssert([file startsWith:self.basePath], @"Assert that file path should based on BasePath");
    NSError *err = nil;
    [NSFileManager.defaultManager createDirectoryAtPath:[file stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err];
    PASS_ERROR_WITH_LOG(err, error, NO);
    [data writeToFile:file options:NSDataWritingAtomic error:&err];
    PASS_ERROR_WITH_LOG(err, error, NO);
    return file;
}

+ (nullable NSData *)loadDataFromFile:(NSString *)file error:(NSError **)error {
    NSAssert([file startsWith:self.basePath], @"Assert that file path should based on BasePath");
    NSError *err = nil;
    NSData *res = [NSData dataWithContentsOfFile:file options:0 error:&err];
    PASS_ERROR_WITH_LOG(err, error, nil);
    return res;
}

+ (BOOL)removeFile:(NSString *)file error:(NSError **_Nullable)error {
    NSAssert([file startsWith:self.basePath], @"Assert that file path should based on BasePath");
    NSError *err = nil;
    BOOL res = [NSFileManager.defaultManager removeItemAtPath:file error:&err];
    PASS_ERROR_WITH_LOG(err, error, nil);
    return res;
}
@end
