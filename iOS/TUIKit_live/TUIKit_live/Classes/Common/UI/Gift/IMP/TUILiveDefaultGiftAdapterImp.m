//
//  TUILiveGiftAdapterImp.m
//  TUIKitDemo
//
//  Created by harvy on 2020/9/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveDefaultGiftAdapterImp.h"
#import "TUILiveGiftData.h"

#define kGiftUrl @"https://liteav.sdk.qcloud.com/app/res/picture/live/gift/gift_data.json"

@interface TUILiveDefaultGiftAdapterImp ()

@property (nonatomic, strong) NSArray *caches;

@end

@implementation TUILiveDefaultGiftAdapterImp

- (instancetype)init
{
    if (self = [super init]) {
        [self requestGiftInfoListFromNetwork:nil];
    }
    return self;
}

- (void)requestGiftInfoListFromNetwork:(TUILiveOnGiftListQueryCallback)callback
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kGiftUrl]];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
                return;
            }
            if (![dict.allKeys containsObject:@"giftList"]) {
                if (callback) {
                    callback(nil, @"接口请求格式不正确");
                }
                return;
            }
            
            NSArray *list = [dict objectForKey:@"giftList"];
            if (list == nil) {
                if (callback) {
                    callback(nil, @"接口请求格式不正确");
                }
                return;
            }
            
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *info in list) {
                if (![weakSelf isValidGiftInfo:info]) {
                    continue;
                }
                TUILiveGiftData *gift = [[TUILiveGiftData alloc] init];
                gift.giftId = info[@"giftId"];
                gift.giftPicUrl = info[@"giftImageUrl"];
                gift.title = info[@"title"];
                gift.value = [info[@"price"] integerValue];
                gift.type = [info[@"type"] integerValue];
                gift.lottieUrl = info[@"lottieUrl"];
                [arrayM addObject:gift];
            }
            
            NSArray *array = [NSArray arrayWithArray:arrayM];
            weakSelf.caches = array;
            
            if (callback) {
                callback(array, nil);
            }
        }
    }];
    [dataTask resume];
}

- (void)queryGiftInfoList:(TUILiveOnGiftListQueryCallback)callback
{
    // 有缓存使用缓存
    if (self.caches) {
        if (callback) {
            callback(self.caches, nil);
        }
        [self requestGiftInfoListFromNetwork:nil];
        return;
    }
    
    [self requestGiftInfoListFromNetwork:^(NSArray<TUILiveGiftData *> * _Nullable list, NSString * _Nullable errMsg) {
        if (callback) {
            callback(list, errMsg);
        }
    }];
}

- (BOOL)isValidGiftInfo:(NSDictionary *)info
{
    NSArray *array = info.allKeys;
    if ([array containsObject:@"giftId"] &&
        [array containsObject:@"giftImageUrl"] &&
        [array containsObject:@"lottieUrl"] &&
        [array containsObject:@"price"] &&
        [array containsObject:@"title"] &&
        [array containsObject:@"type"]) {
        return YES;
    }
    return NO;
}


@end
