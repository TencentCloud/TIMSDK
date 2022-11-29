//
//  TUITextReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUITextReplyQuoteViewData.h"
#import "NSString+emoji.h"
#import "TUITextMessageCellData.h"

@implementation TUITextReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData
{
    if (originCellData == nil) {
        return nil;
    }
    
    if (![originCellData isKindOfClass:TUITextMessageCellData.class]) {
        return nil;
    }
    
    TUITextReplyQuoteViewData *myData = [[TUITextReplyQuoteViewData alloc] init];
    myData.text = [(TUITextMessageCellData *)originCellData content];
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth
{
    CGSize size = [@"0" sizeWithAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:10.0]}];
    NSAttributedString *attributeString = [self.text getFormatEmojiStringWithFont:[UIFont systemFontOfSize:10.0] emojiLocations:nil];
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(maxWidth, size.height * 2)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];
    return CGSizeMake(rect.size.width, rect.size.height < size.height * 2 ? rect.size.height : size.height * 2);
}

@end
