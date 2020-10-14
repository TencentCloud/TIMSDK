//
//  TUILiveRoomManager.m
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveRoomManager.h"
#import "TCUtil.h"
#import "TCConstants.h"

#define kTUILiveRoomBaseUrl @"https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest"

@implementation TUILiveRoomManager

+ (instancetype)sharedManager {
    static TUILiveRoomManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUILiveRoomManager alloc] init];
    });
    return instance;
}

- (void)createRoom:(int)sdkAppID type:(NSString *)type roomID:(NSString *)roomID success:(SuccessCallback)success failed:(FailedCallback)failed {
    NSString *params = [NSString stringWithFormat:@"appId=%d&method=%@&type=%@&roomId=%@", sdkAppID, @"createRoom", type, roomID];
    
    [TUILiveRoomManager asyncSendHttpRequest:params handler:^(int resultCode, NSDictionary *resultDict) {
        if (resultCode == 0) {
            success();
        } else {
            failed(resultCode, resultDict[@"errorMessage"] ?: @"创建失败");
        }
    }];
}

- (void)destroyRoom:(int)sdkAppID type:(NSString *)type roomID:(NSString *)roomID success:(SuccessCallback)success failed:(FailedCallback)failed {
    NSString *params = [NSString stringWithFormat:@"appId=%d&method=%@&type=%@&roomId=%@", sdkAppID, @"destroyRoom", type, roomID];
    [TUILiveRoomManager asyncSendHttpRequest:params handler:^(int resultCode, NSDictionary *resultDict) {
        if (resultCode == 0) {
            success();
        } else {
            failed(resultCode, resultDict[@"errorMessage"] ?: @"销毁失败");
        }
    }];
}

- (void)getRoomList:(int)sdkAppID type:(NSString *)type success:(SuccessRoomListCallback)success failed:(FailedCallback)failed {
    NSString *params = [NSString stringWithFormat:@"appId=%d&method=%@&type=%@", sdkAppID, @"getRoomList" ,type];
    [TUILiveRoomManager asyncSendHttpRequest:params handler:^(int resultCode, NSDictionary *resultDict) {
        if (resultCode == 0) {
            NSMutableArray* temp = [NSMutableArray arrayWithCapacity:2];
            NSArray *array = resultDict[@"data"] ?: @[];
            for (NSDictionary *roomInfo in array) {
                if (roomInfo[@"roomId"]) {
                    [temp addObject:roomInfo[@"roomId"]];
                }
            }
            success(temp);
        } else {
            failed(resultCode, resultDict[@"errorMessage"] ?: @"销毁失败");
        }
    }];
}

// 发送心跳
- (void)updateRoom:(int)sdkAppID type:(NSString *)type roomID:(NSString *)roomID success:(SuccessCallback)success failed:(FailedCallback)failed
{
    NSString *params = [NSString stringWithFormat:@"appId=%d&method=%@&type=%@&roomId=%@", sdkAppID, @"updateRoom" ,type, roomID];
    NSLog(@"[CreateRoom][heart] %s, req:%@", __func__, params);
    [TUILiveRoomManager asyncSendHttpRequest:params handler:^(int resultCode, NSDictionary *resultDict) {
        NSLog(@"[CreateRoom][heart] %s, req:%@, resp:{code:%d, data:%@}", __func__, params, resultCode, resultDict);
        if (resultCode == 0) {
            if (success) {
                success();
            }
        } else {
            if (failed) {
                failed(resultCode, resultDict[@"errorMessage"] ?: @"心跳失败");
            }
        }
    }];
}


+ (void)asyncSendHttpRequest:(NSString*)queryParams handler:(void (^)(int result, NSDictionary* resultDict))handler
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSData* data = [queryParams dataUsingEncoding:kCFStringEncodingUTF8 allowLossyConversion:NO];
        NSMutableString *strUrl = [[NSMutableString alloc] initWithString:kTUILiveRoomBaseUrl];

        NSURL *URL = [NSURL URLWithString:strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
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
                if (resultDict) {
                    errCode = [resultDict[@"errorCode"] intValue];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(errCode, resultDict);
                });
            }
        }];

        [task resume];
    });
}

@end
