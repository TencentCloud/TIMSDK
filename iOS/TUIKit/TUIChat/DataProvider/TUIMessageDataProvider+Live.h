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
// 判断是否为 "群直播" 自定义消息
+ (BOOL)isLiveMessage:(V2TIMMessage *)message;

// 获取 TUIMessageCellData
+ (TUIMessageCellData *)getLiveCellData:(V2TIMMessage *)message;

// 获取会话最后一条消息的展示文本
+ (NSString *)getLiveMessageDisplayString:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
