
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TUIMessageBaseDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class TUITextMessageCellData;
@class TUIFaceMessageCellData;
@class TUIImageMessageCellData;
@class TUIVoiceMessageCellData;
@class TUIVideoMessageCellData;
@class TUIFileMessageCellData;
@class TUISystemMessageCellData;
@class TUIChatCallingDataProvider;

@interface TUIMessageDataProvider : TUIMessageBaseDataProvider
- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void (^)(void))callback;

+ (NSMutableArray *)getCustomMessageInfo;

+ (NSMutableArray *)getPluginCustomMessageInfo;

+ (BOOL)judgeCurrentDataPluginMsg:(TUIMessageCellData *)data;

+ (TUIChatCallingDataProvider *)callingDataProvider;

+ (TUIMessageCellData *__nullable)getCellData:(V2TIMMessage *)message;

+ (nullable TUIMessageCellData *)getSystemMsgFromDate:(NSDate *)date;

+ (TUIMessageCellData *)getRevokeCellData:(V2TIMMessage *)message;

+ (NSString *)getDisplayString:(V2TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
