//
//  TCUtil.m
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
#define ENABLE_SHARE 1

#import "TCUtil.h"
#import "NSString+TUICommon.h"
#import <mach/mach.h>
#import <Accelerate/Accelerate.h>
#import <mach/mach.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "TCLoginParam.h"
#import "TCConstants.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TCUtil

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict
{
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
        }
        return data;
    }
    else
    {
        NSLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString
{
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

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData
{
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

+ (NSString *)getFileCachePath:(NSString *)fileName
{
    if (nil == fileName)
    {
        return nil;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];

    NSString *fileFullPath = [cacheDirectory stringByAppendingPathComponent:fileName];
    return fileFullPath;
}


//通过分别计算中文和其他字符来计算长度
+ (NSUInteger)getContentLength:(NSString*)content
{
    size_t length = 0;
    for (int i = 0; i < [content length]; i++)
    {
        unichar ch = [content characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff)
        {
            length += 2;
        }
        else
        {
            length++;
        }
    }

    return length;
}
+ (NSString *)md5Hash:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);

    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14],
            result[15]
            ];
}

+ (void)asyncSendHttpRequest:(NSString*)command token:(NSString*)token params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData* data = [TCUtil dictionary2JsonData:params];
        if (data == nil)
        {
            NSLog(@"sendHttpRequest failed，参数转成json格式失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(kError_ConvertJsonFailed, @"参数错误", nil);
            });
            return;
        }

        NSString* urlString = [kHttpServerAddr stringByAppendingPathComponent:command];
        NSMutableString *strUrl = [[NSMutableString alloc] initWithString:urlString];

        NSURL *URL = [NSURL URLWithString:strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            if (token.length > 0) {

                NSString* sig = [[NSString stringWithFormat:@"%@%@", token, [self md5Hash:data]] md5];
                [request setValue:sig forHTTPHeaderField:@"Liteav-Sig"];
            }
            [request setHTTPBody:data];
        }

        [request setTimeoutInterval:kHttpTimeout];


        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil)
            {
                NSLog(@"internalSendRequest failed，NSURLSessionDataTask return error code:%d, des:%@", [error code], [error description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(kError_HttpError, @"服务请求失败", nil);
                });
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary* resultDict = [TCUtil jsonSring2Dictionary:responseString];
                int errCode = -1;
                NSString* message = @"";
                NSDictionary* dataDict = nil;
                if (resultDict)
                {
                    if (resultDict[@"code"]) {
                        errCode = [resultDict[@"code"] intValue];
                    }

                    if (resultDict[@"message"]) {
                        message = resultDict[@"message"];
                    }

                    if (200 == errCode && resultDict[@"data"])
                    {
                        dataDict = resultDict[@"data"];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(errCode, message, dataDict);
                });
            }
        }];

        [task resume];
    });
}

+ (void)asyncSendHttpRequest:(NSString*)command params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler
{
    [self asyncSendHttpRequest:command token:nil params:params handler:handler];
}


+ (void)asyncSendHttpRequest:(NSDictionary*)param handler:(void (^)(int result, NSDictionary* resultDict))handler
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData* data = [TCUtil dictionary2JsonData:param];
        if (data == nil)
        {
            NSLog(@"sendHttpRequest failed，参数转成json格式失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(kError_ConvertJsonFailed, nil);
            });
            return;
        }

        NSMutableString *strUrl = [[NSMutableString alloc] initWithString:kHttpServerAddr];

        NSURL *URL = [NSURL URLWithString:strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

            [request setHTTPBody:data];
        }

        [request setTimeoutInterval:kHttpTimeout];


        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil)
            {
                NSLog(@"internalSendRequest failed，NSURLSessionDataTask return error code:%d, des:%@", [error code], [error description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(kError_HttpError, nil);
                });
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary* resultDict = [TCUtil jsonSring2Dictionary:responseString];
                int errCode = -1;
                NSDictionary* dataDict = nil;
                if (resultDict)
                {
                    if (resultDict[@"returnValue"])
                        errCode = [resultDict[@"returnValue"] intValue];

                    if (0 == errCode && resultDict[@"returnData"])
                    {
                        dataDict = resultDict[@"returnData"];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(errCode, dataDict);
                });
            }
        }];

        [task resume];
    });
}


+ (NSString *)transImageURL2HttpsURL:(NSString *)httpURL
{
    if (httpURL.length == 0) {
        return nil;
    }
    if ([NSURL URLWithString:httpURL] == nil) {
        return nil;
    }
    NSString * httpsURL = httpURL;
    if ([httpURL hasPrefix:@"http:"]) {
        httpsURL = [httpURL stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
    }else{
        httpsURL = [NSString stringWithFormat:@"https:%@",httpURL];
    }
    return httpsURL;
}


@end
