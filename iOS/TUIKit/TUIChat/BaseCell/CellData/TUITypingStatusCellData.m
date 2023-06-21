//
//  TUITypingStatusCellData.m
//  TUIChat
//
//  Created by wyl on 2022/7/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITypingStatusCellData.h"

@implementation TUITypingStatusCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUITypingStatusCellData *cellData = [[TUITypingStatusCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.msgID = message.msgID;

    if ([param.allKeys containsObject:@"typingStatus"]) {
        cellData.typingStatus = [param[@"typingStatus"] intValue];
    }

    return cellData;
}

@end
