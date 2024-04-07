//
//  TUIReplyMessageCellData.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TIMCommon/TUIBubbleMessageCellData.h>
#import "TUIChatDefine.h"
#import "TUIReplyQuoteViewData.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIReplyMessageCellData;

@interface TUIReplyMessageCellData : TUIBubbleMessageCellData

/**
 * The original message ID
 */
@property(nonatomic, copy) NSString *__nullable originMsgID;

/**
 * The default abstract of original message
 */
@property(nonatomic, copy) NSString *__nullable msgAbstract;

/**
 * The sender of original message
 */
@property(nonatomic, copy) NSString *__nullable sender;

/**
 * The sender of original message
 */
@property(nonatomic, copy) NSString *__nullable faceURL;

/**
 * The type of original message
 */
@property(nonatomic, assign) V2TIMElemType originMsgType;

/**
 * 
 * Original message
 */
@property(nonatomic, strong) V2TIMMessage *__nullable originMessage;
@property(nonatomic, strong) TUIMessageCellData *originCellData;
@property(nonatomic, strong) TUIReplyQuoteViewData *quoteData;

/**
 * The content of replying the original message
 */
@property(nonatomic, copy) NSString *content;
@property(nonatomic, strong, readonly) NSAttributedString *attributeString;

/**
 * The size of quote view, including @senderSize and @quotePlaceholderSize
 */
@property(nonatomic, assign) CGSize quoteSize;

/**
 * The size of label which displays the sender displayname
 */
@property(nonatomic, assign) CGSize senderSize;

/**
 * The size of customize quote view
 */
@property(nonatomic, assign) CGSize quotePlaceholderSize;

/**
 * The size of label which displays the content of replying the original message.
 */
@property(nonatomic, assign) CGSize replyContentSize;

@property(nonatomic, copy) TUIReplyAsyncLoadFinish onFinish;

/**
 * The message ID of the root message which is replyed at first.
 */
@property(nonatomic, copy) NSString *messageRootID;

@property(nonatomic) UIColor *textColor;

@property(nonatomic, strong) NSString *selectContent;
@property(nonatomic, strong) NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *emojiLocations;

// Deprecated
// Search `loadOriginMessageFromReplyData` in TUIMessageDataProvider+MessageDeal
//- (void)loadOriginMessage:(void(^)(void))callback;

- (TUIReplyQuoteViewData *)getQuoteData:(TUIMessageCellData *)originCellData;
- (CGSize)quotePlaceholderSizeWithType:(V2TIMElemType)type data:(TUIReplyQuoteViewData *)data;

@end

@interface TUIReferenceMessageCellData : TUIReplyMessageCellData

@property(nonatomic, assign) CGSize textSize;
@property(nonatomic, assign) CGPoint textOrigin;

@end
NS_ASSUME_NONNULL_END
