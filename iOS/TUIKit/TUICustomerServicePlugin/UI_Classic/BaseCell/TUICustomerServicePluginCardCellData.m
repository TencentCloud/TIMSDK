//
//  TUICustomerServicePluginCardCellData.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginCardCellData.h"
#import "TUICustomerServicePluginDataProvider+CalculateSize.h"

@implementation TUICustomerServicePluginCardCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUICustomerServicePluginCardCellData *cellData = [[TUICustomerServicePluginCardCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    NSDictionary *content = param[@"content"];
    cellData.header = content[@"header"];
    cellData.desc = content[@"desc"];
    cellData.picURL = content[@"pic"];
    cellData.jumpURL = content[@"url"];
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TIMCommonLocalizableString(TUICustomerServiceCardMessage);
}

// Override
- (BOOL)canForward {
    return NO;
}

@end
