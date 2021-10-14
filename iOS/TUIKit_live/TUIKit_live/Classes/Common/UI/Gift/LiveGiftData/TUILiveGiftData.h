//
//  TUIGiftData.h
//  Pods
//
//  Created by harvy on 2020/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveGiftData : NSObject

/// 礼物id，唯一标识当前礼物
@property (nonatomic, copy) NSString *giftId;

/// 礼物缩略图URL地址
@property (nonatomic, copy) NSString *giftPicUrl;

/// 礼物名称，eg: 跑车
@property (nonatomic, copy) NSString *title;

/// 礼物的价值，eg: 90金币
@property (nonatomic, assign) NSInteger value;

/// 礼物类型  0:普通礼物  1:全屏播放礼物
@property (nonatomic, assign) NSInteger type;

/// 全屏礼物动画的播放链接
@property (nonatomic, copy) NSString *lottieUrl;

@end

NS_ASSUME_NONNULL_END
