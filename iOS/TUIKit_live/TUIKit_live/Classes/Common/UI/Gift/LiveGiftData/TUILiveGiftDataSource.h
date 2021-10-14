//
//  TUILiveGiftAdapterProtocol.h
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import <Foundation/Foundation.h>
@class TUILiveGiftData;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUILiveOnGiftListQueryCallback)(NSArray<TUILiveGiftData *> * __nullable list, NSString * __nullable errMsg);

@protocol TUILiveGiftDataSource <NSObject>

/// 查询礼物信息列表
/// @param callback 回调
- (void)queryGiftInfoList:(TUILiveOnGiftListQueryCallback)callback;

@end

NS_ASSUME_NONNULL_END
