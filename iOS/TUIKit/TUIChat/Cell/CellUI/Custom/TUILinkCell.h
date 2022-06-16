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
#import "TUILinkCellData.h"
#import "TUIBubbleMessageCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUILinkCell : TUIBubbleMessageCell
@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property TUILinkCellData *customData;
- (void)fillWithData:(TUILinkCellData *)data;

@end

NS_ASSUME_NONNULL_END
