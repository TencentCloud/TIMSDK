//
//  TUIVoiceReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIVoiceReplyQuoteViewData.h"
#import "NSString+emoji.h"
#import "TUIVoiceMessageCellData.h"

@implementation TUIVoiceReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData
{
    if (originCellData == nil) {
        return nil;
    }
    
    if (![originCellData isKindOfClass:TUIVoiceMessageCellData.class]) {
        return nil;
    }
    
    TUIVoiceReplyQuoteViewData *myData = [[TUIVoiceReplyQuoteViewData alloc] init];
    myData.text = [NSString stringWithFormat:@"%ds\"", [(TUIVoiceMessageCellData *)originCellData duration]];
    myData.icon = [UIImage d_imageNamed:@"voice_reply" bundle:TUIChatBundle];
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth
{
    CGFloat marginWidth = 18;
    CGSize size = [@"0" sizeWithAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:10.0]}]; // 单行的高度
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(maxWidth - marginWidth, size.height)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0]}
                                          context:nil];
    return CGSizeMake(rect.size.width + marginWidth, size.height);
}


@end
