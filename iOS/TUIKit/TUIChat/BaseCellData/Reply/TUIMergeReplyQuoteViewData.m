//
//  TUIMergeReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMergeReplyQuoteViewData.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import "TUIMergeMessageCellData.h"

@implementation TUIMergeReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TUIMergeMessageCellData.class]) {
        return nil;
    }

    TUIMergeReplyQuoteViewData *myData = [[TUIMergeReplyQuoteViewData alloc] init];
    myData.title = [(TUIMergeMessageCellData *)originCellData title];
    NSAttributedString *abstract = [(TUIMergeMessageCellData *)originCellData abstractAttributedString];
    myData.abstract = abstract.string;
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth {
    CGFloat singleHeight = [UIFont systemFontOfSize:10.0].lineHeight;
    NSAttributedString *titleAttributeString = [self.title getFormatEmojiStringWithFont:[UIFont systemFontOfSize:10.0] emojiLocations:nil];
    CGRect titleRect = [titleAttributeString boundingRectWithSize:CGSizeMake(maxWidth, singleHeight)
                                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                          context:nil];
    CGFloat width = titleRect.size.width;
    CGFloat height = titleRect.size.height;
    return CGSizeMake(MIN(width, maxWidth), height);
}

@end
