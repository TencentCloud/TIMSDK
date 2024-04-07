//
//  TUIUtil.h
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016 tencent. All rights reserved.
//
/**
 *
 *  Tencent Cloud Chat Demo data processing unit
 *  - This class provides data processing services for the Demo client, so that the client can work better
 *
 */
#import <Foundation/Foundation.h>

#define IS_NOT_EMPTY_NSSTRING(__X__) (__X__ && [__X__ isKindOfClass:[NSString class]] && ![__X__ isEqualToString:@""])

@interface TUIUtil : NSObject

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict;

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData;

+ (NSString *)getFileCachePath:(NSString *)fileName;

+ (NSUInteger)getContentLength:(NSString *)string;

/// get random string with length
/// @param len length
+ (NSString *)randomStringWithLength:(int)len;

BOOL isFirstLaunch(void);

+ (void)openLinkWithURL:(NSURL *)url;

@end
