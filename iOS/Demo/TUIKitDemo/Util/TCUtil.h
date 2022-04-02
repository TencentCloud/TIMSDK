//
//  TCUtil.h
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016年 tencent. All rights reserved.
//
/** 腾讯云IM Demo数据处理单元
 *
 *  本类为Demo客户端提供数据处理服务，以便客户端更好的工作
 *
 */
#import <Foundation/Foundation.h>
#import "TUIKit.h"

#define IS_NOT_EMPTY_NSSTRING(__X__)            (__X__ && [__X__ isKindOfClass:[NSString class]] && ![__X__ isEqualToString:@""])


@interface TCUtil : NSObject

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict;

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData;

+ (NSString *)getFileCachePath:(NSString *)fileName;

+ (NSUInteger)getContentLength:(NSString*)string;

+ (void)asyncSendHttpRequest:(NSDictionary*)param handler:(void (^)(int resultCode, NSDictionary* resultDict))handler;

+ (void)asyncSendHttpRequest:(NSString*)command params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;

+ (void)asyncSendHttpRequest:(NSString*)command token:(NSString*)token params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;

/// get random string with length
/// @param len length
+ (NSString *) randomStringWithLength: (int) len;

//返回是否第一次安装客户端
BOOL isFirstLaunch(void);

//返回是否是当天首次启动
BOOL isFirstLaunchToday(void);

//通过Safari打开url
+ (void)openLinkWithURL:(NSURL *)url;
@end

