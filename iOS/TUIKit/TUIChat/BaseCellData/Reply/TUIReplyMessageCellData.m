//
//  TUIReplyMessageCellData.m
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

/**
    The protocol format of the custom field cloudMessageData of the message

     {
     "messageReply":{
         "messageID": "xxxx0xxx=xx",
         "messageAbstract":"origin message abstract..."
         "messageSender":"NickName/99618",
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

@implementation TUIReplyMessageCellData
{
    NSString *_sender;
}

- (void)setSender:(NSString *)sender {
    _sender = sender;
}

- (NSString *__nullable)sender {
    if (self.originMessage) {
        return self.originMessage.nameCard ? : (self.originMessage.friendRemark ? : (self.originMessage.nickName ? : self.originMessage.sender));
    }
    return _sender;
}

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
        return CGSizeMake(20, 20);
    }

    return [data contentSize:TReplyQuoteView_Max_Width - 12];
}

- (TUIReplyQuoteViewData *)getQuoteData:(TUIMessageCellData *)originCellData {
    TUIReplyQuoteViewData *quoteData = nil;
    Class class = [originCellData getReplyQuoteViewDataClass];
    BOOL hasRiskContent = originCellData.innerMessage.hasRiskContent;
    if (hasRiskContent && [TIMConfig isClassicEntrance]){
        // Return text reply data in default
        TUITextReplyQuoteViewData *myData = [[TUITextReplyQuoteViewData alloc] init];
        myData.text = [TUIReplyPreviewData displayAbstract:self.originMsgType abstract:self.msgAbstract withFileName:NO isRisk:hasRiskContent];
        quoteData = myData;
    }
    else  if (class && [class respondsToSelector:@selector(getReplyQuoteViewData:)]) {
        quoteData = [class getReplyQuoteViewData:originCellData];
    }
    else {

    }
    if (quoteData == nil) {
        // 
        // Return text reply data in default
        TUITextReplyQuoteViewData *myData = [[TUITextReplyQuoteViewData alloc] init];
        myData.text = [TUIReplyPreviewData displayAbstract:self.originMsgType abstract:self.msgAbstract withFileName:NO isRisk:hasRiskContent];
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
                                                          // This message is 「quote message」which indicating the original message
                                                          replyData = [[TUIReferenceMessageCellData alloc]
                                                              initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                                                          replyData.reuseId = TUIReferenceMessageCell_ReuseId;
                                                          replyData.originMsgID = reply[@"messageID"];
                                                          replyData.msgAbstract = reply[@"messageAbstract"];
                                                          replyData.sender = reply[@"messageSender"];
                                                          replyData.originMsgType = (V2TIMElemType)[reply[@"messageType"] integerValue];
                                                          replyData.content = message.textElem.text;  // text only
                                                      }
                                                  }
                                              }
                                            }];
    return replyData;
}

@end
