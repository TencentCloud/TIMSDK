//
//  TUIMessageDataProvider+MessageDeal.m
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatDataProvider_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist+MessageDeal.h"
#import "TUIMessageDataProvider_Minimalist.h"

@implementation TUIMessageDataProvider_Minimalist (MessageDeal)

- (void)loadOriginMessageFromReplyData:(TUIReplyMessageCellData_Minimalist *)replycellData dealCallback:(void (^)(void))callback {
    if (replycellData.originMsgID.length == 0) {
        if (callback) {
            callback();
        }
        return;
    }

    @weakify(replycellData)[TUIChatDataProvider_Minimalist findMessages:@[ replycellData.originMsgID ]
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
                                                                 TUIMessageCellData *cellData = [TUIMessageDataProvider_Minimalist getCellData:originMessage];
                                                                 replycellData.originCellData = cellData;
                                                                 if ([cellData isKindOfClass:TUIImageMessageCellData_Minimalist.class]) {
                                                                     TUIImageMessageCellData_Minimalist *imageData =
                                                                         (TUIImageMessageCellData_Minimalist *)cellData;
                                                                     [imageData downloadImage:TImage_Type_Thumb];
                                                                     replycellData.quoteData = [replycellData getQuoteData:imageData];
                                                                     replycellData.originMessage = originMessage;
                                                                     if (callback) {
                                                                         callback();
                                                                     }
                                                                 } else if ([cellData isKindOfClass:TUIVideoMessageCellData_Minimalist.class]) {
                                                                     TUIVideoMessageCellData_Minimalist *videoData =
                                                                         (TUIVideoMessageCellData_Minimalist *)cellData;
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
