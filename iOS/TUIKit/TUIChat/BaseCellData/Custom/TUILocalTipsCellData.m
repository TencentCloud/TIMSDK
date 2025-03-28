//
//  TUILocalTipsCellData.m
//  TUIChat
//
//  Created by yiliangwang on 2025/3/18.
//  Copyright © 2025 Tencent. All rights reserved.
//

#import "TUILocalTipsCellData.h"

@implementation TUILocalTipsCellData
+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUILocalTipsCellData *cellData = [[TUILocalTipsCellData alloc] initWithDirection:MsgDirectionIncoming];
    cellData.innerMessage = message;
    cellData.msgID = message.msgID;
    cellData.content =  param[@"content"];
    cellData.reuseId = TSystemMessageCell_ReuseId;
        
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    return param[@"content"];
}


@end
