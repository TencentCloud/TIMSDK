//
//  TUICustomerServicePluginEvaluationCellData.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginEvaluationCellData.h"
#import <TIMCommon/TUIMessageCellLayout.h>
#import "TUICustomerServicePluginDataProvider+CalculateSize.h"

@implementation TUICustomerServicePluginEvaluationCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }

    TUICustomerServicePluginEvaluationCellData *cellData = [[TUICustomerServicePluginEvaluationCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    
    NSDictionary *content = param[@"menuContent"];
    cellData.type = [content[@"type"] integerValue];
    cellData.header = content[@"head"];
    cellData.tail = content[@"tail"];
    
    if ([content.allKeys containsObject:@"selected"]) {
        NSDictionary *selected = content[@"selected"];
        cellData.isSelected = selected.count > 0;
        NSInteger selectedID = [selected[@"id"] integerValue];
        cellData.score = selectedID < 100 ? selectedID : selectedID - 100;
    } else {
        cellData.isSelected = NO;
    }
    
    cellData.sessionID = content[@"sessionId"];
    cellData.expireTime = [content[@"expireTime"] unsignedIntegerValue];

    NSArray *items = content[@"menu"];
    cellData.totalScore = items.count;
    cellData.items = items;
    for (NSDictionary *item in items) {
        [cellData.itemDict setValue:item[@"content"] forKey:item[@"id"]];
    }
    
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TIMCommonLocalizableString(TUICustomerServiceSatisfactionEvaluation);
}

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        self.showAvatar = NO;
    }
    return self;
}

// Override
- (BOOL)canForward {
    return NO;
}

- (BOOL)canLongPress {
    return NO;
}

- (NSMutableDictionary *)itemDict {
    if (!_itemDict) {
        _itemDict = [[NSMutableDictionary alloc] init];
    }
    return _itemDict;
}

- (BOOL)isExpired {
    NSTimeInterval cur = [[NSDate date] timeIntervalSince1970];
    return cur > self.expireTime;
}

@end
