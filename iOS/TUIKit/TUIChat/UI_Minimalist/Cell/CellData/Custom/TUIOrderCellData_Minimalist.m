//
//  TUIOrderCellData_Minimalist.m
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIOrderCellData_Minimalist.h"

@implementation TUIOrderCellData_Minimalist

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUIOrderCellData_Minimalist *cellData =
        [[TUIOrderCellData_Minimalist alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    cellData.msgID = message.msgID;
    cellData.title = param[@"title"];
    cellData.desc = param[@"description"];
    cellData.imageUrl = param[@"imageUrl"];
    cellData.link = param[@"link"];
    cellData.price = param[@"price"];
    cellData.avatarUrl = [NSURL URLWithString:message.faceURL];
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    return param[@"title"];
}

- (CGSize)contentSize {
    CGSize size = CGSizeMake(245, 80);
    return size;
}

@end
