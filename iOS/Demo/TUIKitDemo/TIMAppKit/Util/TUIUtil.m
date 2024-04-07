//
//  TUIUtil.m
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016 tencent. All rights reserved.
//
#define ENABLE_SHARE 1

#import "TUIUtil.h"
#import <Accelerate/Accelerate.h>
#import <CommonCrypto/CommonDigest.h>
#import <TUICore/NSString+TUIUtil.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/types.h>

static const NSString *tui_letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation TUIUtil

#define CHECK_STRING_NULL(x) (x == nil) ? @"" : x

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict {
    // Json
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if (error) {
            NSLog(@"[%@] Post Json Error", [self class]);
        }
        return data;
    } else {
        NSLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict {
    return [[NSString alloc] initWithData:[self dictionary2JsonData:dict] encoding:NSUTF8StringEncoding];
    ;
}

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed: %@", jsonString);
        return nil;
    }
    return dic;
}

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed");
        return nil;
    }
    return dic;
}

+ (NSString *)getFileCachePath:(NSString *)fileName {
    if (nil == fileName) {
        return nil;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];

    NSString *fileFullPath = [cacheDirectory stringByAppendingPathComponent:fileName];
    return fileFullPath;
}

// 
+ (NSUInteger)getContentLength:(NSString *)content {
    size_t length = 0;
    for (int i = 0; i < [content length]; i++) {
        unichar ch = [content characterAtIndex:i];
        if (0x4e00 < ch && ch < 0x9fff) {
            length += 2;
        } else {
            length++;
        }
    }

    return length;
}
+ (NSString *)md5Hash:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);

    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3],
                                      result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13],
                                      result[14], result[15]];
}

+ (NSString *)transImageURL2HttpsURL:(NSString *)httpURL {
    if (httpURL.length == 0) {
        return nil;
    }
    if ([NSURL URLWithString:httpURL] == nil) {
        return nil;
    }
    NSString *httpsURL = httpURL;
    if ([httpURL hasPrefix:@"http:"]) {
        httpsURL = [httpURL stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
    } else {
        httpsURL = [NSString stringWithFormat:@"https:%@", httpURL];
    }
    return httpsURL;
}

+ (NSString *)randomStringWithLength:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (int i = 0; i < len; i++) {
        [randomString appendFormat:@"%C", [tui_letters characterAtIndex:arc4random_uniform((uint32_t)[tui_letters length])]];
    }
    return randomString;
}

+ (void)openLinkWithURL:(NSURL *)url {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
                                   if (success) {
                                       NSLog(@"Opened url");
                                   }
                                 }];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}
BOOL isFirstLaunch(void) {
    static NSInteger first = -1;
    if (first != -1) {
        return (first == 0 ? YES : NO);
    }

    first = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kFirstLaunch"] integerValue];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"kFirstLaunch"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[NSUserDefaults standardUserDefaults] synchronize];
    });

    return (first == 0 ? YES : NO);
}

@end
