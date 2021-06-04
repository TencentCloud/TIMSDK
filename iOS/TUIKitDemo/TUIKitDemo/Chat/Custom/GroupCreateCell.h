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
#import "TUISystemMessageCell.h"
#import "GroupCreateCellData.h"

@interface GroupCreateCell : TUISystemMessageCell

- (void)fillWithData:(GroupCreateCellData *)data;

@end
