//
//  TUILiveGiftAdapterImp.h
//  TUIKitDemo
//
//  Created by harvy on 2020/9/16.
//  Copyright © 2020 Tencent. All rights reserved.
/**
 礼物面板数据源，demo自行实现对应的接口即可
 */


#import <Foundation/Foundation.h>
#import "TUILiveGiftDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveDefaultGiftAdapterImp : NSObject <TUILiveGiftDataSource>

/// 查询礼物信息列表
/// @param callback 回调
- (void)queryGiftInfoList:(TUILiveOnGiftListQueryCallback)callback;

@end

NS_ASSUME_NONNULL_END
