//
//  TCUtil.h
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface TCUtil : NSObject

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData;

+ (NSString *)getFileCachePath:(NSString *)fileName;

+ (NSUInteger)getContentLength:(NSString*)string;

+ (void)asyncSendHttpRequest:(NSDictionary*)param handler:(void (^)(int resultCode, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command token:(NSString*)token params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;



@end

