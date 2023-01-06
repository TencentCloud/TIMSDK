//
//  TUIVoiceReplyQuoteViewData_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIVoiceReplyQuoteViewData_Minimalist.h"
#import "TUIVoiceMessageCellData_Minimalist.h"
#import "TUIThemeManager.h"
#import "NSString+TUIEmoji.h"

@implementation TUIVoiceReplyQuoteViewData_Minimalist

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData
{
    if (originCellData == nil) {
        return nil;
    }
    
    if (![originCellData isKindOfClass:TUIVoiceMessageCellData_Minimalist.class]) {
        return nil;
    }
    
    TUIVoiceReplyQuoteViewData_Minimalist *myData = [[TUIVoiceReplyQuoteViewData_Minimalist alloc] init];
    myData.text = [NSString stringWithFormat:@"%ds\"", [(TUIVoiceMessageCellData_Minimalist *)originCellData duration]];
    myData.icon = TUIChatCommonBundleImage(@"voice_reply");
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth
{
    CGFloat marginWidth = 18;
    CGSize size = [@"0" sizeWithAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:10.0]}];
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(maxWidth - marginWidth, size.height)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0]}
                                          context:nil];
    return CGSizeMake(rect.size.width + marginWidth, size.height);
}


@end
