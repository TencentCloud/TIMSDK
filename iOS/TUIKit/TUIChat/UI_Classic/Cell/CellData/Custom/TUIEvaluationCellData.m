//
//  TUIEvaluationCellData.m
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIEvaluationCellData.h"

@implementation TUIEvaluationCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUIEvaluationCellData *cellData = [[TUIEvaluationCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    cellData.desc = message.customElem.desc;
    cellData.score = [param[@"score"] integerValue];
    cellData.comment = param[@"comment"];
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return message.customElem.desc;
}

- (CGSize)contentSize {
    CGRect rect = [self.comment boundingRectWithSize:CGSizeMake(215, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                             context:nil];
    CGSize size = CGSizeMake(245, ceilf(rect.size.height));
    size.height += self.comment.length > 0 ? 88 : 50;
    return size;
}

@end
