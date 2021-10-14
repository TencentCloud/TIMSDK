//
//  TUIMessageDataProvider+Live.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/10.
//

#import "TUIMessageDataProvider.h"
#import "TUIMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProvider (Live)
// msg 获取 celldata
+ (TUIMessageCellData *)getLiveCellData:(V2TIMMessage *)message;

// celldata 获取 cell
+ (TUIMessageCell *)getLiveCellWithCellData:(TUIMessageCellData *)cellData;

// message 获取展示文本，主要用于展示会话最后一条消息
+ (NSString *)getLiveDisplayString:(V2TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
