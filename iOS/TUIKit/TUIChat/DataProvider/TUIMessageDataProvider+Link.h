//
//  TUIMessageDataProvider+Custom.h
//  TUIChat
//
//  Created by xiangzhang on 2021/9/6.
//

#import "TUIMessageDataProvider.h"
#import "TUIMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProvider (Link)
// msg 获取 celldata
+ (TUIMessageCellData *)getLinkCellData:(V2TIMMessage *)message;

// celldata 获取 cell
+ (TUIMessageCell *)getLinkCellWithCellData:(TUIMessageCellData *)cellData;

// message 获取展示文本，主要用于展示会话最后一条消息
+ (NSString *)getLinkDisplayString:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
