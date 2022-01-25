//
//  TUIReplyMessageCellData.m
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//

/**
    消息的自定义字段 cloudMessageData 的协议格式
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
#import "TUIMessageDataProvider.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUILinkCellData.h"
#import "NSString+emoji.h"
#import "TUIChatDataProvider.h"

#import "TUITextReplyQuoteViewData.h"
#import "TUIImageReplyQuoteViewData.h"
#import "TUIVideoReplyQuoteViewData.h"
#import "TUIVoiceReplyQuoteViewData.h"
#import "TUIFileReplyQuoteViewData.h"
#import "TUIMergeReplyQuoteViewData.h"
#import "TUIReplyPreviewBar.h"

#define kReplyQuoteViewMaxWidth 175
#define kReplyQuoteViewMarginWidth 35

@implementation TUIReplyMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    if (message.cloudCustomData == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:message.cloudCustomData options:0 error:&error];
    if (error || dict == nil || ![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:@"messageReply"]) {
        return nil;
    }
    
    NSDictionary *reply = [dict valueForKey:@"messageReply"];
    if (reply == nil || ![reply isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    if (![reply.allKeys containsObject:@"version"] ||
        [reply[@"version"] integerValue] > kMessageReplyVersion) {
        NSLog(@"not match the version of message rely");
        return nil;
    }
    
    if (![reply.allKeys containsObject:@"messageID"] ||
        ![reply.allKeys containsObject:@"messageAbstract"] ||
        ![reply.allKeys containsObject:@"messageSender"] ||
        ![reply.allKeys containsObject:@"messageType"]) {
        NSLog(@"invalid message reply data");
        return nil;
    }
    
    // 该消息是「回复消息」
    TUIReplyMessageCellData *replyData = [[TUIReplyMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    replyData.reuseId = TReplyMessageCell_ReuseId;
    replyData.originMsgID = reply[@"messageID"];
    replyData.msgAbstract = reply[@"messageAbstract"];
    replyData.sender = reply[@"messageSender"];
    replyData.originMsgType = (V2TIMElemType)[reply[@"messageType"] integerValue];
    replyData.content = message.textElem.text;  // 目前只支持文本回复
    return replyData;
}

- (CGSize)contentSize
{
    CGFloat height = 0;
    CGFloat quoteHeight = 0;
    CGFloat quoteWidth = 0;
    
    CGFloat quoteMinWidth = 100;
    CGFloat quoteMaxWidth = kReplyQuoteViewMaxWidth;
    CGFloat quotePlaceHolderMarginWidth = 12;
    
    // 动态计算发送者的尺寸
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [self.sender boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]}
                                                  context:nil];
    
    // 动态计算自定义引用占位视图的尺寸
    CGSize placeholderSize = [self quotePlaceholderSizeWithType:self.originMsgType data:self.quoteData];
    
    // 动态计算回复内容的尺寸
    NSAttributedString *attributeString = [self.content getFormatEmojiStringWithFont:[UIFont systemFontOfSize:16.0] emojiLocations:nil];
    CGRect replyContentRect = [attributeString boundingRectWithSize:CGSizeMake(quoteMaxWidth, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil];
    
    
    // 根据内容计算引用视图整体的大小
    quoteWidth = senderRect.size.width;
    if (quoteWidth < placeholderSize.width) {
        quoteWidth = placeholderSize.width;
    }
    if (quoteWidth < replyContentRect.size.width) {
        quoteWidth = replyContentRect.size.width;
    }
    quoteWidth += quotePlaceHolderMarginWidth ;
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
    height = 12 + quoteHeight + 12 + self.replyContentSize.height + 12;
    return CGSizeMake(quoteWidth + kReplyQuoteViewMarginWidth, height);
}

- (CGSize)quotePlaceholderSizeWithType:(V2TIMElemType)type data:(TUIReplyQuoteViewData *)data
{
    if (data == nil) {
        // 根据类型，返回默认数据
        return CGSizeMake(kReplyQuoteViewMaxWidth - 12, 60);
    }
    
    return [data contentSize:kReplyQuoteViewMaxWidth - 12];
}


- (void)loadOriginMessage:(void(^)(void))callback
{
    if (self.originMsgID.length == 0) {
        if (callback) {
            callback();
        }
        return;
    }
    
    @weakify(self)
    [TUIChatDataProvider findMessages:@[self.originMsgID] callback:^(BOOL succ, NSString * _Nonnull error_message, NSArray * _Nonnull msgs) {
        @strongify(self)
        if (!succ) {
            self.quoteData = [self getQuoteData:nil];
            self.originMessage = nil;
            if (callback) {
                callback();
            }
            return;
        }
        V2TIMMessage *originMessage = msgs.firstObject;
        if (originMessage == nil) {
            self.quoteData = [self getQuoteData:nil];
            if (callback) {
                callback();
            }
            return;
        }
        TUIMessageCellData *cellData = [TUIMessageDataProvider getCellData:originMessage];
        self.originCellData = cellData;
        if ([cellData isKindOfClass:TUIImageMessageCellData.class]) {
            // 原始消息是图片
            TUIImageMessageCellData *imageData = (TUIImageMessageCellData *)cellData;
            [imageData downloadImage:TImage_Type_Thumb];
            self.quoteData = [self getQuoteData:imageData];
            self.originMessage = originMessage;
            if (callback) {
                callback();
            }
        } else if ([cellData isKindOfClass:TUIVideoMessageCellData.class]) {
            // 原始消息是视频
            TUIVideoMessageCellData *videoData = (TUIVideoMessageCellData *)cellData;
            [videoData downloadThumb];
            self.quoteData = [self getQuoteData:videoData];
            self.originMessage = originMessage;
            if (callback) {
                callback();
            }
        } else {
            self.quoteData = [self getQuoteData:cellData];
            self.originMessage = originMessage;
            if (callback) {
                callback();
            }
        }
    }];
}

- (TUIReplyQuoteViewData *)getQuoteData:(TUIMessageCellData *)originCellData
{
    
    TUIReplyQuoteViewData *quoteData = nil;
        
    Class class = [originCellData getReplyQuoteViewDataClass];
    if (class && [class respondsToSelector:@selector(getReplyQuoteViewData:)]) {
        quoteData = [class getReplyQuoteViewData:originCellData];
    }
    
    if (quoteData == nil) {
        // 默认创建文本类型
        TUITextReplyQuoteViewData *myData =  [[TUITextReplyQuoteViewData alloc] init];
        myData.text = [TUIReplyPreviewData displayAbstract:self.originMsgType abstract:self.msgAbstract withFileName:NO];
        quoteData = myData;
    }
    
    quoteData.originCellData = originCellData;
    @weakify(self)
    quoteData.onFinish = ^{
        @strongify(self)
        if (self.onFinish) {
            self.onFinish();
        }
    };
    return quoteData;
}

@end
