//
//  TUILiveGiftInfo.h
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveGiftInfo : NSObject

// 礼物面板相关
@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, copy) NSString *giftPicUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger value;

// 礼物播放相关
@property (nonatomic, assign) NSInteger type;           // 礼物类型 0:普通礼物  1:全屏播放礼物
@property (nonatomic, copy) NSString *lottieUrl;        // 全屏播放礼物链接
@property (nonatomic, copy) NSString *sendUser;         // 礼物发送方昵称
@property (nonatomic, copy) NSString *sendUserHeadIcon; // 礼物发送方头像

@property (nonatomic, assign) BOOL selected;

// 上下文信息，用来传值
@property (nonatomic, strong) id context;

/// 初始化方法
/// @param name 礼物名称 eg: "火箭"
/// @param value 礼物价值 eg：“游戏币999”
/// @param iconUrl icon的url路径
/// @param context 上下文信息,例如，可以传网络数据模型
- (instancetype)initWithGiftName:(NSString *)name
                           value:(NSInteger )value
                            icon:(NSString *)iconUrl
                         context:(id)context;

@end

NS_ASSUME_NONNULL_END
