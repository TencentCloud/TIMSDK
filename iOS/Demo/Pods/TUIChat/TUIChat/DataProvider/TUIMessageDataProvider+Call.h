//
//  TUIMessageDataProvider+Live.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/10.
//

#import "TUIMessageDataProvider.h"
#import "TUIMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProvider (Call)
// msg 获取 celldata
+ (TUIMessageCellData *)getCallCellData:(V2TIMMessage *)message;

// message 获取展示文本，主要用于展示会话最后一条消息
+ (NSString *)getCallDisplayString:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
