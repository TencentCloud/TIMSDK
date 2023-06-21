//
//  TUIReplyMessageCellData.m
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

/**
    消息的自定义字段 cloudMessageData 的协议格式
    The protocol format of the custom field cloudMessageData of the message

     {
     "messageReply":{
         "messageID": "xxxx0xxx=xx",
         "messageAbstract":"原始消息摘要..."
         "messageSender":"小哥哥/99618",
         "messageType": "1/2/..",
         "version":"1",
       }
     }
 */

#import "TUIReplyMessageCellData.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import "TUIFileMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIVoiceMessageCellData.h"

#import "TUICloudCustomDataTypeCenter.h"
#import "TUIFileReplyQuoteViewData.h"
#import "TUIImageReplyQuoteViewData.h"
#import "TUIMergeReplyQuoteViewData.h"
#import "TUIReplyPreviewData.h"
#import "TUITextReplyQuoteViewData.h"
#import "TUIVideoReplyQuoteViewData.h"
#import "TUIVoiceReplyQuoteViewData.h"

#define kReplyQuoteViewMaxWidth 175
#define kReplyQuoteViewMarginWidth 35

@implementation TUIReplyMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    if (message.cloudCustomData == nil) {
        return nil;
    }

    __block TUIReplyMessageCellData *replyData = nil;
    [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReply
                                            callback:^(BOOL isContains, id obj) {
                                              if (isContains) {
                                                  if (obj && [obj isKindOfClass:NSDictionary.class]) {
                                                      NSDictionary *reply = (NSDictionary *)obj;
                                                      // This message is a "reply message"
                                                      replyData = [[TUIReplyMessageCellData alloc]
                                                          initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                                                      replyData.reuseId = TReplyMessageCell_ReuseId;
                                                      replyData.originMsgID = reply[@"messageID"];
                                                      replyData.msgAbstract = reply[@"messageAbstract"];
                                                      replyData.sender = reply[@"messageSender"];
                                                      replyData.originMsgType = (V2TIMElemType)[reply[@"messageType"] integerValue];
                                                      replyData.content = message.textElem.text;
                                                      replyData.messageRootID = reply[@"messageRootID"];
                                                  }
                                              }
                                            }];

    return replyData;
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            self.cellLayout = [TUIMessageCellLayout incommingTextMessageLayout];
        } else {
            self.cellLayout = [TUIMessageCellLayout outgoingTextMessageLayout];
        }
        _emojiLocations = [NSMutableArray array];
    }
    return self;
}
// Override, the height of whole tableview cell.
- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];

    if (self.bottomContainerSize.height > 0) {
        height += self.bottomContainerSize.height + 6;
    }

    return height;
}

- (CGSize)contentSize {
    CGFloat height = 0;
    CGFloat quoteHeight = 0;
    CGFloat quoteWidth = 0;

    CGFloat quoteMinWidth = 100;
    CGFloat quoteMaxWidth = kReplyQuoteViewMaxWidth;
    CGFloat quotePlaceHolderMarginWidth = 12;

    // 动态计算发送者的尺寸
    // Calculate the size of label which displays the sender's displyname
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [self.sender boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                  context:nil];

    // 动态计算自定义引用占位视图的尺寸
    // Calculate the size of customize quote placeholder view
    CGSize placeholderSize = [self quotePlaceholderSizeWithType:self.originMsgType data:self.quoteData];

    // 动态计算回复内容的尺寸
    // Calculate the size of label which displays the content of replying the original message
    NSAttributedString *attributeString = [self.content getFormatEmojiStringWithFont:[UIFont systemFontOfSize:16.0] emojiLocations:nil];
    CGRect replyContentRect = [attributeString boundingRectWithSize:CGSizeMake(quoteMaxWidth, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil];

    // 根据内容计算引用视图整体的大小
    // Calculate the size of quote view base the content
    quoteWidth = senderRect.size.width;
    if (quoteWidth < placeholderSize.width) {
        quoteWidth = placeholderSize.width;
    }
    if (quoteWidth < replyContentRect.size.width) {
        quoteWidth = replyContentRect.size.width;
    }
    quoteWidth += quotePlaceHolderMarginWidth;
    if (quoteWidth > quoteMaxWidth) {
        quoteWidth = quoteMaxWidth;
    }
    if (quoteWidth < quoteMinWidth) {
        quoteWidth = quoteMinWidth;
    }
    quoteHeight = 3 + senderRect.size.height + 4 + placeholderSize.height + 6;

    self.senderSize = CGSizeMake(quoteWidth, senderRect.size.height);
    self.quotePlaceholderSize = placeholderSize;
    self.replyContentSize = CGSizeMake(replyContentRect.size.width, replyContentRect.size.height);
    self.quoteSize = CGSizeMake(quoteWidth, quoteHeight);

    // 计算 cell 的高度
    // Calculate the height of cell
    height = 12 + quoteHeight + 12 + self.replyContentSize.height + 12;
    return CGSizeMake(quoteWidth + kReplyQuoteViewMarginWidth, height);
}

- (CGSize)quotePlaceholderSizeWithType:(V2TIMElemType)type data:(TUIReplyQuoteViewData *)data {
    if (data == nil) {
        return CGSizeMake(kReplyQuoteViewMaxWidth - 12, 60);
    }

    return [data contentSize:kReplyQuoteViewMaxWidth - 12];
}

- (TUIReplyQuoteViewData *)getQuoteData:(TUIMessageCellData *)originCellData {
    TUIReplyQuoteViewData *quoteData = nil;

    Class class = [originCellData getReplyQuoteViewDataClass];
    if (class && [class respondsToSelector:@selector(getReplyQuoteViewData:)]) {
        quoteData = [class getReplyQuoteViewData:originCellData];
    }

    if (quoteData == nil) {
        // 默认创建文本类型
        // Return text reply data in default
        TUITextReplyQuoteViewData *myData = [[TUITextReplyQuoteViewData alloc] init];
        myData.text = [TUIReplyPreviewData displayAbstract:self.originMsgType abstract:self.msgAbstract withFileName:NO];
        quoteData = myData;
    }

    quoteData.originCellData = originCellData;
    @weakify(self);
    quoteData.onFinish = ^{
      @strongify(self);
      if (self.onFinish) {
          self.onFinish();
      }
    };
    return quoteData;
}

@end

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TUIReferenceMessageCellData ()
@property(nonatomic, assign) CGSize textSize;
@property(nonatomic, assign) CGPoint textOrigin;

@end
@implementation TUIReferenceMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    if (message.cloudCustomData == nil) {
        return nil;
    }

    __block TUIReplyMessageCellData *replyData = nil;
    [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReference
                                            callback:^(BOOL isContains, id obj) {
                                              if (isContains) {
                                                  if (obj && [obj isKindOfClass:NSDictionary.class]) {
                                                      NSDictionary *reply = (NSDictionary *)obj;
                                                      if ([reply isKindOfClass:NSDictionary.class]) {
                                                          // 该消息是「引用消息」
                                                          // This message is 「quote message」which indicating the original message
                                                          replyData = [[TUIReferenceMessageCellData alloc]
                                                              initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                                                          replyData.reuseId = TUIReferenceMessageCell_ReuseId;
                                                          replyData.originMsgID = reply[@"messageID"];
                                                          replyData.msgAbstract = reply[@"messageAbstract"];
                                                          replyData.sender = reply[@"messageSender"];
                                                          replyData.originMsgType = (V2TIMElemType)[reply[@"messageType"] integerValue];
                                                          replyData.content = message.textElem.text;  // 目前只支持文本回复
                                                      }
                                                  }
                                              }
                                            }];
    return replyData;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat cellHeight = [super heightOfWidth:width];
    cellHeight += self.quoteSize.height;
    cellHeight += 6;
    return cellHeight;
}

- (CGSize)contentSize {
    CGFloat quoteHeight = 0;
    CGFloat quoteWidth = 0;
    CGFloat quoteMaxWidth = kReplyQuoteViewMaxWidth;
    CGFloat quotePlaceHolderMarginWidth = 12;

    // 动态计算发送者的尺寸
    // Calculate the size of label which displays the sender's displayname
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [self.sender boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                  context:nil];
    // 动态计算自定义引用占位视图的尺寸
    // Calculate the size of customize quote placeholder view
    CGSize placeholderSize = [self quotePlaceholderSizeWithType:self.originMsgType data:self.quoteData];

    // 动态计算回复内容的尺寸
    // Calculate the size of label which displays the content of replying the original message
    NSAttributedString *attributeString = [self.content getFormatEmojiStringWithFont:[UIFont systemFontOfSize:16.0] emojiLocations:nil];

    CGRect replyContentRect = [attributeString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil];
    CGSize size = CGSizeMake(CGFLOAT_CEIL(replyContentRect.size.width), CGFLOAT_CEIL(replyContentRect.size.height));
    self.textSize = size;
    self.textOrigin = CGPointMake(self.cellLayout.bubbleInsets.left, self.cellLayout.bubbleInsets.top + self.bubbleTop);

    size.height += self.cellLayout.bubbleInsets.top + self.cellLayout.bubbleInsets.bottom;
    size.width += self.cellLayout.bubbleInsets.left + self.cellLayout.bubbleInsets.right;

    if (self.direction == MsgDirectionIncoming) {
        size.height = MAX(size.height, [TUIBubbleMessageCellData incommingBubble].size.height);
    } else {
        size.height = MAX(size.height, [TUIBubbleMessageCellData outgoingBubble].size.height);
    }

    quoteWidth = senderRect.size.width;
    quoteWidth += placeholderSize.width;
    quoteWidth += (quotePlaceHolderMarginWidth * 2);

    quoteHeight = MAX(senderRect.size.height, placeholderSize.height);
    quoteHeight += (8 + 8);

    self.senderSize = CGSizeMake(senderRect.size.width, senderRect.size.height);
    self.quotePlaceholderSize = placeholderSize;
    //    self.replyContentSize = CGSizeMake(replyContentRect.size.width, replyContentRect.size.height);
    self.quoteSize = CGSizeMake(quoteWidth, quoteHeight);

    return size;
}
@end
