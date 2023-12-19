//
//  TUIChatBotPluginBranchCellData.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginBranchCellData.h"
#import "TUIChatBotPluginDataProvider+CalculateSize.h"

@implementation TUIChatBotPluginBranchCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUIChatBotPluginBranchCellData *cellData = [[TUIChatBotPluginBranchCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;

    NSString *subType = param[@"subtype"];
    if ([subType isEqualToString:@"welcome_msg"]) {
        cellData.subType = BranchMsgSubType_Welcome;
    } else if ([subType isEqualToString:@"clarify_msg"]) {
        cellData.subType = BranchMsgSubType_Clarify;
    }

    NSDictionary *content = param[@"content"];
    cellData.header = content[@"title"];
    NSArray *items = content[@"items"];
    for (NSDictionary *item in items) {
        [cellData.items addObject:item[@"content"]];
    }

    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUIChatBotPluginBranchCellData *cellData = [[TUIChatBotPluginBranchCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    NSDictionary *content = param[@"content"];
    return content[@"title"];
}

// Override
- (BOOL)canForward {
    return NO;
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

@end
