//
//  TUIMergeReplyQuoteViewData_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMergeReplyQuoteViewData_Minimalist.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import "TUIMergeMessageCellData_Minimalist.h"

@implementation TUIMergeReplyQuoteViewData_Minimalist

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TUIMergeMessageCellData_Minimalist.class]) {
        return nil;
    }

    TUIMergeReplyQuoteViewData_Minimalist *myData = [[TUIMergeReplyQuoteViewData_Minimalist alloc] init];
    myData.title = [(TUIMergeMessageCellData_Minimalist *)originCellData title];
    NSAttributedString *abstract = [(TUIMergeMessageCellData_Minimalist *)originCellData abstractAttributedString];
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

    NSAttributedString *abstractAttributeString = [self.abstract getFormatEmojiStringWithFont:[UIFont systemFontOfSize:10.0] emojiLocations:nil];
    CGRect abstractRect = [abstractAttributeString boundingRectWithSize:CGSizeMake(maxWidth, singleHeight * 2)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                context:nil];
    CGFloat abstractHeight = abstractRect.size.height;
    if (abstractHeight > singleHeight * 2) {
        abstractHeight = singleHeight * 2;
    }

    CGFloat width = titleRect.size.width;
    if (width < abstractRect.size.width) {
        width = abstractRect.size.width;
    }

    CGFloat height = titleRect.size.height + 3;
    height += abstractHeight + 3;

    if (width > maxWidth) {
        width = maxWidth;
    }

    return CGSizeMake(width, height);
}

@end
