//
//  TUICustomerServicePluginCollectionCellData.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginCollectionCellData.h"
#import "TUICustomerServicePluginDataProvider+CalculateSize.h"

@implementation TUICustomerServicePluginCollectionCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUICustomerServicePluginCollectionCellData *cellData = [[TUICustomerServicePluginCollectionCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    NSDictionary *content = param[@"content"];
    cellData.header = content[@"header"];
    NSArray *items = content[@"items"];
    for (NSDictionary *item in items) {
        [cellData.items addObject:item[@"content"]];
    }
    cellData.type = [content[@"type"] integerValue];
    NSDictionary *selected = content[@"selected"];
    cellData.selectedContent = selected[@"content"];
    
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TIMCommonLocalizableString(TUICustomerServiceCollectInfomation);
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
