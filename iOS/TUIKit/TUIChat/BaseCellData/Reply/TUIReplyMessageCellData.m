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

@end
