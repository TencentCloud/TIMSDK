//
//  TUIGroupCreatedCellData_Minimalist.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIGroupCreatedCellData_Minimalist.h"
#import "NSString+TUIUtil.h"

@implementation TUIGroupCreatedCellData_Minimalist

+ (TUIGroupCreatedCellData_Minimalist *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
    TUIGroupCreatedCellData_Minimalist *cellData = [[TUIGroupCreatedCellData_Minimalist alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
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
