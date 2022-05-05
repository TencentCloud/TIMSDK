//
//  TUIGroupCreatedCellData.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIGroupCreatedCellData.h"
#import "NSString+TUIUtil.h"

@implementation TUIGroupCreatedCellData

+ (TUIGroupCreatedCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
    TUIGroupCreatedCellData *cellData = [[TUIGroupCreatedCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    cellData.innerMessage = message;
    cellData.msgID = message.msgID;
    cellData.content = param[@"content"];
    cellData.opUser = param[@"opUser"];
    return cellData;
}

- (NSMutableAttributedString *)attributedString {
    NSString *str = [NSString stringWithFormat:@"\"%@\"%@", self.opUser, self.content];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemGrayColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    return attributeString;
}

@end
