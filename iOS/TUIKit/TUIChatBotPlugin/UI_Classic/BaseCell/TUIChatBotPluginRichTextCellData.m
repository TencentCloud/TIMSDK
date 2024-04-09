//
//  TUIChatBotPluginRichTextCellData.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2024/3/1.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "TUIChatBotPluginRichTextCellData.h"
#import <TIMCommon/TIMDefine.h>

@implementation TUIChatBotPluginRichTextCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                            options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUIChatBotPluginRichTextCellData *cellData = [[TUIChatBotPluginRichTextCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    cellData.content = param[@"content"];
    cellData.reuseId = TRichTextMessageCell_ReuserId;
    cellData.status = Msg_Status_Init;
    cellData.cellHeight = TRichTextMessageCell_Height_Default;
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return @"Rich Text";
}

@end
