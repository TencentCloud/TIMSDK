
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

@protocol TUIMessageDataProviderDataSource <TUIMessageBaseDataProviderDataSource>

+ (nullable Class)onGetCustomMessageCellDataClass:(NSString *)businessID;

@end

@interface TUIMessageDataProvider : TUIMessageBaseDataProvider

+ (void)setDataSourceClass:(Class<TUIMessageDataProviderDataSource>)dataSourceClass;

#pragma mark - TUIMessageCellData parser
+ (nullable TUIMessageCellData *)getCellData:(V2TIMMessage *)message;

#pragma mark - Last message parser
+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message;

#pragma mark - Data source operate
- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void(^)(void))callback;
- (void)deleteUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail;
- (void)removeUIMsgList:(NSArray<TUIMessageCellData *> *)cellDatas;


//FIXME: 待删除
+ (TUIChatCallingDataProvider *)callingDataProvider;

@end

NS_ASSUME_NONNULL_END
