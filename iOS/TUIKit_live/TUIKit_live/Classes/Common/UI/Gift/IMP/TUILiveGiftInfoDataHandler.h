//
//  TUILiveGiftInfoManager.h
//  Pods
//
//  Created by harvy on 2020/9/23.
//

#import <Foundation/Foundation.h>
#import "TUILiveGiftInfo.h"
@protocol TUILiveGiftDataSource;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUILiveGiftInfoDataProviderCallback)(NSArray<TUILiveGiftInfo *> *list, NSString * __nullable errMsg);

@interface TUILiveGiftInfoDataHandler : NSObject

@property (nonatomic, weak) id<TUILiveGiftDataSource> giftDataSource;

- (void)queryGiftInfoList:(TUILiveGiftInfoDataProviderCallback __nullable)callback;
- (TUILiveGiftInfo *)getGiftInfo:(NSString *)giftId;
- (int)getColumnNum;

@end

NS_ASSUME_NONNULL_END
