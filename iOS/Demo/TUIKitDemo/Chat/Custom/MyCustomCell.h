//
//  MyCustomCell.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo自定义气泡视图
 *  用于显示聊天气泡中的文本信息数据
 *
 */
#import "TUIMessageCell.h"
#import "MyCustomCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyCustomCell : TUIMessageCell
@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property MyCustomCellData *customData;
- (void)fillWithData:(MyCustomCellData *)data;

@end

NS_ASSUME_NONNULL_END
