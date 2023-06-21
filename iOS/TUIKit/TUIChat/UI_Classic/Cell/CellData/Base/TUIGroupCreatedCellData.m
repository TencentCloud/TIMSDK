//
//  TUIGroupCreatedCellData.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIGroupCreatedCellData.h"
#import <TUICore/NSString+TUIUtil.h>

@implementation TUIGroupCreatedCellData

+ (TUIGroupCreatedCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUIGroupCreatedCellData *cellData = [[TUIGroupCreatedCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    cellData.innerMessage = message;
    cellData.msgID = message.msgID;
    cellData.content = param[@"content"];
    cellData.opUser = param[@"opUser"];
    cellData.cmd = param[@"cmd"];
    return cellData;
}

- (NSMutableAttributedString *)attributedString {
    NSString *localizableContent = self.content;
    if (self.cmd && [self.cmd isKindOfClass:NSNumber.class]) {
        NSInteger command = [self.cmd integerValue];
        if (command == 1) {
            localizableContent = TIMCommonLocalizableString(TUICommunityCreateTipsMessage);
        } else {
            localizableContent = TIMCommonLocalizableString(TUIGroupCreateTipsMessage);
        }
    }
    NSString *str = [NSString stringWithFormat:@"\"%@\" %@", self.opUser, localizableContent];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName : [UIColor d_systemGrayColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    return attributeString;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)msg {
    if (msg.customElem == nil || msg.customElem.data == nil) {
        return nil;
    }

    NSDictionary *param = [TUITool jsonData2Dictionary:msg.customElem.data];
    if (param == nil || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSString *businessID = param[@"businessID"];
    if (![businessID isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (![businessID isEqualToString:BussinessID_GroupCreate] && ![param.allKeys containsObject:BussinessID_GroupCreate]) {
        return nil;
    }

    NSString *localizableContent = param[@"content"];
    NSNumber *cmd = param[@"cmd"];
    if (cmd && [cmd isKindOfClass:NSNumber.class]) {
        NSInteger command = [cmd integerValue];
        if (command == 1) {
            localizableContent = TIMCommonLocalizableString(TUICommunityCreateTipsMessage);
        } else {
            localizableContent = TIMCommonLocalizableString(TUIGroupCreateTipsMessage);
        }
    }
    return [NSString stringWithFormat:@"\"%@\" %@", param[@"opUser"], localizableContent];
}

@end
