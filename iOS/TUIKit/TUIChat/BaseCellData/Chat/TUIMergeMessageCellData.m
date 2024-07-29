//
//  TUIMergeMessageCellData.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMergeMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import "TUITextMessageCellData.h"
#import <TIMCommon/NSString+TUIEmoji.h>

@implementation TUIMergeMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMMergerElem *elem = message.mergerElem;
    if (elem.layersOverLimit) {
        TUITextMessageCellData *limitCell = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        limitCell.content = TIMCommonLocalizableString(TUIKitRelayLayerLimitTips);
        return limitCell;
    }

    TUIMergeMessageCellData *mergeData = [[TUIMergeMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    mergeData.title = elem.title;
    mergeData.abstractList = [NSArray arrayWithArray:elem.abstractList];
    mergeData.abstractSendDetailList = [self.class formatAbstractSendDetailList:elem.abstractList];
    mergeData.mergerElem = elem;
    mergeData.reuseId = TMergeMessageCell_ReuserId;
    return mergeData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return [NSString stringWithFormat:@"[%@]", TIMCommonLocalizableString(TUIKitRelayChatHistory)];
}

- (Class)getReplyQuoteViewDataClass {
    return NSClassFromString(@"TUIMergeReplyQuoteViewData");
}

- (Class)getReplyQuoteViewClass {
    return NSClassFromString(@"TUIMergeReplyQuoteView");
}

- (NSAttributedString *)abstractAttributedString {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    style.alignment = isRTL()? NSTextAlignmentRight:NSTextAlignmentLeft;
    NSDictionary *attribute = @{
        NSForegroundColorAttributeName : [UIColor colorWithRed:187 / 255.0 green:187 / 255.0 blue:187 / 255.0 alpha:1 / 1.0],
        NSFontAttributeName : [UIFont systemFontOfSize:12.0],
        NSParagraphStyleAttributeName : style
    };

    NSMutableAttributedString *abstr = [[NSMutableAttributedString alloc] initWithString:@""];
    int i = 0;
    for (NSString *ab in self.abstractList) {
        if (i >= 4) {
            break;
        }
        NSString *resultStr = [NSString stringWithFormat:@"%@\n", ab];
        NSString *str = resultStr;
        [abstr appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:attribute]];
        i++;
    }
    return abstr;
}

+ (NSMutableArray *)formatAbstractSendDetailList:(NSArray *)originAbstractList {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = isRTL()? NSTextAlignmentRight:NSTextAlignmentLeft;
    style.lineBreakMode =  NSLineBreakByTruncatingTail;
    NSDictionary *attribute = @{
        NSForegroundColorAttributeName : [UIColor colorWithRed:187 / 255.0 green:187 / 255.0 blue:187 / 255.0 alpha:1 / 1.0],
        NSFontAttributeName : [UIFont systemFontOfSize:12.0],
        NSParagraphStyleAttributeName : style
    };
    int i = 0;
    for (NSString *ab in originAbstractList) {
        if (i >= 4) {
            break;
        }
        NSString *str = ab;
        NSString * splitStr = @":";
        if ([str tui_containsString:@"\u202C:"]) {
            splitStr = @"\u202C:";
        }
        NSArray<NSString *> *result =  [str componentsSeparatedByString:splitStr];
        NSString *sender = result[0];
        NSString *detail = result[1];
        sender =  [NSString stringWithFormat:@"%@",sender];
        detail =  [NSString stringWithFormat:@"%@",detail.getLocalizableStringWithFaceContent];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
        if(sender.length>0 ){
            NSMutableAttributedString *abstr = [[NSMutableAttributedString alloc] initWithString:@""];
            [abstr appendAttributedString:[[NSAttributedString alloc] initWithString:sender attributes:attribute]];
           [dic setObject:abstr forKey:@"sender"];
        }
        if(detail.length>0 ){
           NSMutableAttributedString *abstr = [[NSMutableAttributedString alloc] initWithString:@""];
           [abstr appendAttributedString:[[NSAttributedString alloc] initWithString:detail attributes:attribute]];
           [dic setObject:abstr forKey:@"detail"];
        }
        [array addObject:dic];

        i++;
    }
    return array;
}
- (BOOL)isArString:(NSString *)text {
    NSString *isoLangCode = (__bridge_transfer NSString *)CFStringTokenizerCopyBestStringLanguage((__bridge CFStringRef)text, CFRangeMake(0, text.length));

    if ([isoLangCode isEqualToString:@"ar"]) {
        return YES;
    }
    return NO;
}
@end
