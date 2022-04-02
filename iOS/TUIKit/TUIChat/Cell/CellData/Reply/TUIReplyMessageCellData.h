//
//  TUIReplyMessageCellData.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//

#import "TUIBubbleMessageCellData.h"
#import <ImSDK_Plus/ImSDK_Plus.h>

#import "TUIReplyQuoteViewData.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIReplyAsyncLoadFinish)(void);

@class TUIReplyMessageCellData;
typedef void(^YUReplyMessageAsyncLoadFinsh)(TUIReplyMessageCellData *replyData);

@interface TUIReplyMessageCellData : TUIBubbleMessageCellData

// 原始消息 ID
@property (nonatomic, copy) NSString * __nullable originMsgID;
// 原始消息默认摘要
@property (nonatomic, copy) NSString * __nullable msgAbstract;
// 原始消息的发送者
@property (nonatomic, copy) NSString * __nullable sender;
// 原始消息类型
@property (nonatomic, assign) V2TIMElemType originMsgType;

// 原始消息
@property (nonatomic, strong) V2TIMMessage * __nullable originMessage;
@property (nonatomic, strong) TUIMessageCellData *originCellData;
@property (nonatomic, strong) TUIReplyQuoteViewData *quoteData;

// 回复的内容
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong, readonly) NSAttributedString *attributeString;

// 整个引用视图的尺寸（包括 senderSize 和 quotePlaceholderSize）
@property (nonatomic, assign) CGSize quoteSize;
// 发送者的尺寸
@property (nonatomic, assign) CGSize senderSize;
// 自定义引用视图的尺寸
@property (nonatomic, assign) CGSize quotePlaceholderSize;
// 回复的内容尺寸
@property (nonatomic, assign) CGSize replyContentSize;

@property (nonatomic, copy) TUIReplyAsyncLoadFinish onFinish;

//Deprecated
//Search `loadOriginMessageFromReplyData` in TUIMessageDataProvider+MessageDeal
//- (void)loadOriginMessage:(void(^)(void))callback;

- (TUIReplyQuoteViewData *)getQuoteData:(TUIMessageCellData *)originCellData;

@end

NS_ASSUME_NONNULL_END
