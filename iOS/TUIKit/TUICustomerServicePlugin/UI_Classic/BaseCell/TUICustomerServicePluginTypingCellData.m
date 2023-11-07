//
//  TUICustomerServicePluginTypingCellData.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/6/16.
//

#import "TUICustomerServicePluginTypingCellData.h"

@implementation TUICustomerServicePluginTypingCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUITypingStatusCellData *cellData = [[TUITypingStatusCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.msgID = message.msgID;

    if ([param[@"src"] isEqualToString: BussinessID_Src_CustomerService_Typing]) {
        cellData.typingStatus = 1;
    }

    return cellData;
}

@end
