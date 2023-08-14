//
//  TUIMessageDataProvider+MessageDeal.m
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIMessageCellData.h>
#import "TUIChatDataProvider.h"
#import "TUIImageMessageCellData.h"
#import "TUIMessageDataProvider+MessageDeal.h"
#import "TUIMessageDataProvider.h"
@implementation TUIMessageDataProvider (MessageDeal)

- (void)loadOriginMessageFromReplyData:(TUIReplyMessageCellData *)replycellData dealCallback:(void (^)(void))callback {
    if (replycellData.originMsgID.length == 0) {
        if (callback) {
            callback();
        }
        return;
    }

    @weakify(replycellData)[TUIChatDataProvider findMessages:@[ replycellData.originMsgID ]
                                                    callback:^(BOOL succ, NSString *_Nonnull error_message, NSArray *_Nonnull msgs) {
                                                      @strongify(replycellData) if (!succ) {
                                                          replycellData.quoteData = [replycellData getQuoteData:nil];
                                                          replycellData.originMessage = nil;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                          return;
                                                      }
                                                      V2TIMMessage *originMessage = msgs.firstObject;
                                                      if (originMessage == nil) {
                                                          replycellData.quoteData = [replycellData getQuoteData:nil];
                                                          if (callback) {
                                                              callback();
                                                          }
                                                          return;
                                                      }
                                                      TUIMessageCellData *cellData = [TUIMessageDataProvider getCellData:originMessage];
                                                      replycellData.originCellData = cellData;
                                                      if ([cellData isKindOfClass:TUIImageMessageCellData.class]) {
                                                          TUIImageMessageCellData *imageData = (TUIImageMessageCellData *)cellData;
                                                          [imageData downloadImage:TImage_Type_Thumb];
                                                          replycellData.quoteData = [replycellData getQuoteData:imageData];
                                                          replycellData.originMessage = originMessage;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                      } else if ([cellData isKindOfClass:TUIVideoMessageCellData.class]) {
                                                          TUIVideoMessageCellData *videoData = (TUIVideoMessageCellData *)cellData;
                                                          [videoData downloadThumb];
                                                          replycellData.quoteData = [replycellData getQuoteData:videoData];
                                                          replycellData.originMessage = originMessage;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                      } else {
                                                          replycellData.quoteData = [replycellData getQuoteData:cellData];
                                                          replycellData.originMessage = originMessage;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                      }
                                                    }];
}
@end
