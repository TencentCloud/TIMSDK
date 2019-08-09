//
//  MyCustomCellData.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo自定义气泡数据
 *  用于存储聊天气泡中的文本信息数据
 *
 */
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyCustomCellData : TUIMessageCellData

@property NSString *text;
@property NSString *link;

@end

NS_ASSUME_NONNULL_END
