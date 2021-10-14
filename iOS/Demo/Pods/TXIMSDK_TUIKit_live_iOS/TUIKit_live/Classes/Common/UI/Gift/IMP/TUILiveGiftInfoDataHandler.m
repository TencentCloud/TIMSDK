//
//  TUILiveGiftInfoManager.m
//  Pods
//
//  Created by harvy on 2020/9/23.
//

#import "TUILiveGiftInfoDataHandler.h"
#import "TUILiveGiftInfo.h"
#import "TUILiveGiftData.h"
#import "TUILiveGiftDataSource.h"

@interface TUILiveGiftInfoDataHandler ()

@property (nonatomic, strong) NSDictionary<NSString *, TUILiveGiftInfo *> *caches;
@property (nonatomic, copy) TUILiveGiftInfoDataProviderCallback callback;

@end

@implementation TUILiveGiftInfoDataHandler

- (void)setGiftDataSource:(id<TUILiveGiftDataSource>)giftDataSource
{
    _giftDataSource = giftDataSource;
    
    [self queryGiftInfoList:nil];
}

- (void)queryGiftInfoList:(TUILiveGiftInfoDataProviderCallback)callback
{
    __weak typeof(self) weakSelf = self;
    if ([self.giftDataSource respondsToSelector:@selector(queryGiftInfoList:)]) {
        [self.giftDataSource queryGiftInfoList:^(NSArray<TUILiveGiftData *> * _Nullable list, NSString * _Nullable errMsg) {
            if (errMsg && errMsg.length) {
                if (callback) {
                    callback(@[], errMsg);
                }
                return;
            }
            
            NSMutableArray *arrayM = [NSMutableArray array];
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            for (TUILiveGiftData *data in list) {
                TUILiveGiftInfo *giftInfo = [weakSelf giftInfoWithData:data];
                [dictM setObject:giftInfo forKey:giftInfo.giftId];
                [arrayM addObject:giftInfo];
            }
            
            NSArray *array = [NSArray arrayWithArray:arrayM];
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:dictM];
            
            if ([NSThread isMainThread]) {
                self.caches = dict;
                if (callback) {
                    callback(array, nil);
                }
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.caches = dict;
                    if (callback) {
                        callback(array, nil);
                    }
                });
            }
        }];
    }
}

- (TUILiveGiftInfo *)giftInfoWithData:(TUILiveGiftData *)data
{
    TUILiveGiftInfo *giftInfo = [[TUILiveGiftInfo alloc] init];
    giftInfo.giftId           = data.giftId;
    giftInfo.giftPicUrl       = data.giftPicUrl;
    giftInfo.title            = data.title;
    giftInfo.value            = data.value;
    giftInfo.type             = data.type;
    giftInfo.lottieUrl        = data.lottieUrl;
    return giftInfo;
}

- (TUILiveGiftInfo *)getGiftInfo:(NSString *)giftId
{
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        __block TUILiveGiftInfo *giftInfo = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            giftInfo = [weakSelf getGiftInfo:giftId];
        });
        return giftInfo;
    }
    
    if (giftId == nil || ![giftId isKindOfClass:NSString.class] || giftId.length == 0) {
        return nil;
    }
    
    TUILiveGiftInfo *giftInfo = [self.caches objectForKey:giftId];
    return giftInfo;
}

/// 礼物面板，每行的列数，默认4个
- (int)getColumnNum
{
    return 4;
}

- (NSDictionary *)caches
{
    if (_caches == nil) {
        _caches = [NSDictionary dictionary];
    }
    return _caches;
}

@end
