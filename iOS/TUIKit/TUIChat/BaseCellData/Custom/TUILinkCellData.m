//
//  MyCustomCellData.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TUILinkCellData.h"

@implementation TUILinkCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUILinkCellData *cellData = [[TUILinkCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.msgID = message.msgID;
    cellData.text = param[@"text"];
    cellData.link = param[@"link"];
    cellData.avatarUrl = [NSURL URLWithString:message.faceURL];
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    return param[@"text"];
}

- (CGSize)contentSize {
    CGFloat textMaxWidth = 245.f;
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(textMaxWidth, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                          context:nil];
    CGSize size = CGSizeMake(textMaxWidth + 15, rect.size.height + 56);
    return size;
}

@end
