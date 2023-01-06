//
//  TUIReplyMessageCellData.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//

#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUIBubbleMessageCellData.h"
#import "TUIReplyQuoteViewData.h"
#import "TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIReplyMessageCellData;

@interface TUIReplyMessageCellData : TUIBubbleMessageCellData

/**
 * 原始消息 ID
 * The original message ID
 */
@property (nonatomic, copy) NSString * __nullable originMsgID;

/**
 * 原始消息默认摘要
 * The default abstract of original message
 */
@property (nonatomic, copy) NSString * __nullable msgAbstract;

/**
 * 原始消息的发送者
 * The sender of original message
 */
@property (nonatomic, copy) NSString * __nullable sender;

/**
 * 原始消息的发送者头像
 * The sender of original message
 */
@property (nonatomic, copy) NSString * __nullable faceURL;

/**
 * 原始消息类型
 * The type of original message
 */
@property (nonatomic, assign) V2TIMElemType originMsgType;

/**
 * 原始消息
 * Original message
 */
@property (nonatomic, strong) V2TIMMessage * __nullable originMessage;
@property (nonatomic, strong) TUIMessageCellData *originCellData;
@property (nonatomic, strong) TUIReplyQuoteViewData *quoteData;

/**
 * 回复的内容
 * The content of replying the original message
 */
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong, readonly) NSAttributedString *attributeString;

/**
 * 整个引用视图的尺寸（包括 senderSize 和 quotePlaceholderSize）
 * The size of quote view, including @senderSize and @quotePlaceholderSize
 */
@property (nonatomic, assign) CGSize quoteSize;

/**
 * 发送者的尺寸
 * The size of label which displays the sender displayname
 */
@property (nonatomic, assign) CGSize senderSize;

/**
 * 自定义引用视图的尺寸
 * The size of customize quote view
 */
@property (nonatomic, assign) CGSize quotePlaceholderSize;

/**
 * 回复的内容尺寸
 * The size of label which displays the content of replying the original message.
 */
@property (nonatomic, assign) CGSize replyContentSize;

@property (nonatomic, copy) TUIReplyAsyncLoadFinish onFinish;


/**
 * 消息回复根 RootID 【不一定是上面 originMessage的 msgID ，是最顶上被回复的消息 ID】
 *
 * The message ID of the root message which is replyed at first.
 */
@property (nonatomic, copy) NSString *messageRootID;

@property (nonatomic) UIColor *textColor;

@property (nonatomic, strong) NSString *selectContent;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *emojiLocations;

//Deprecated
//Search `loadOriginMessageFromReplyData` in TUIMessageDataProvider+MessageDeal
//- (void)loadOriginMessage:(void(^)(void))callback;

- (TUIReplyQuoteViewData *)getQuoteData:(TUIMessageCellData *)originCellData;


@end

@interface TUIReferenceMessageCellData : TUIReplyMessageCellData
@property (readonly) CGSize textSize;
@property (readonly) CGPoint textOrigin;
@end
NS_ASSUME_NONNULL_END
