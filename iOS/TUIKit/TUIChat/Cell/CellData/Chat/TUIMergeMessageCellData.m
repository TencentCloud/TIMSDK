//
//  TUIMergeMessageCellData.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import "TUIMergeMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIDefine.h"

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@implementation TUIMergeMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMMergerElem *elem = message.mergerElem;
    if (elem.layersOverLimit) {
        TUITextMessageCellData *limitCell = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        limitCell.content = TUIKitLocalizableString(TUIKitRelayLayerLimitTips);
        return limitCell;
    }
    
    TUIMergeMessageCellData *relayData = [[TUIMergeMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    relayData.title = elem.title;
    relayData.abstractList = [NSArray arrayWithArray:elem.abstractList];
    relayData.mergerElem = elem;
    relayData.reuseId = TRelayMessageCell_ReuserId;
    return relayData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return [NSString stringWithFormat:@"[%@]", TUIKitLocalizableString(TUIKitRelayChatHistory)];
}

- (Class)getReplyQuoteViewDataClass
{
    return NSClassFromString(@"TUIMergeReplyQuoteViewData");
}

- (Class)getReplyQuoteViewClass
{
    return NSClassFromString(@"TUIMergeReplyQuoteView");
}


- (CGSize)contentSize
{
    CGRect rect = [[self abstractAttributedString] boundingRectWithSize:CGSizeMake(200 - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGSize size = CGSizeMake(CGFLOAT_CEIL(rect.size.width), CGFLOAT_CEIL(rect.size.height) - 10);
    self.abstractSize = size;
    CGFloat height = size.height;
    if (height > TRelayMessageCell_Text_Height_Max) {
        self.abstractSize = CGSizeMake(size.width, size.height - (height - TRelayMessageCell_Text_Height_Max));
        height = TRelayMessageCell_Text_Height_Max;
    }
    UIFont *titleFont = [UIFont systemFontOfSize:16];
    height = (10 + titleFont.lineHeight + 3) + height + 1 + 5 + 20 + 5;
    return CGSizeMake(200, height);
}

- (NSAttributedString *)abstractAttributedString
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    NSDictionary *attribute = @{
        NSForegroundColorAttributeName : [UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1/1.0],
        NSFontAttributeName : [UIFont systemFontOfSize:12.0],
        NSParagraphStyleAttributeName : style
    };
    
    NSMutableAttributedString *abstr = [[NSMutableAttributedString alloc] initWithString:@""];
    int i = 0;
    for (NSString *ab in self.abstractList) {
        if (i >= 4) {
            break;
        }
        NSString *str = [NSString stringWithFormat:@"%@\n", ab];
        [abstr appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:attribute]];
        i++;
    }
    return abstr;
}


@end
