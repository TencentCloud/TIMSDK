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

@implementation TUIMergeMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMMergerElem *elem = message.mergerElem;
    if (elem.layersOverLimit) {
        TUITextMessageCellData *limitCell = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        limitCell.content = TIMCommonLocalizableString(TUIKitRelayLayerLimitTips);
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
        NSString *str = [NSString stringWithFormat:@"%@\n", ab];
        [abstr appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:attribute]];
        i++;
    }
    return abstr;
}

@end
