//
//  TUIMessageDataProvider+Custom.m
//  TUIChat
//
//  Created by xiangzhang on 2021/9/6.
//

#import "TUIMessageDataProvider+Link.h"
#import "TUILinkCell.h"

@implementation TUIMessageDataProvider (Link)
+ (TUIMessageCellData *)getLinkCellData:(V2TIMMessage *)message {
    if (message.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
        if (!param || ![param isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        NSString *businessID = param[@"businessID"];
        if (![businessID isKindOfClass:[NSString class]]) {
            return nil;
        }
        // 判断是不是自定义跳转消息
        if ([businessID isEqualToString:TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
            TUILinkCellData *cellData = [[TUILinkCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
            cellData.innerMessage = message;
            cellData.msgID = message.msgID;
            cellData.text = param[@"text"];
            cellData.link = param[@"link"];
            cellData.avatarUrl = [NSURL URLWithString:message.faceURL];
            cellData.reuseId = TLinkMessageCell_ReuseId;
            return cellData;
        }
    }
    return nil;
}

+ (TUIMessageCell *)getLinkCellWithCellData:(TUIMessageCellData *)cellData {
    if ([cellData isKindOfClass:[TUILinkCellData class]]) {
        TUILinkCell *linkCell = [[TUILinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TLinkMessageCell_ReuseId];
        [linkCell fillWithData:(TUILinkCellData *)cellData];
        return linkCell;
    }
    return nil;
}

+ (NSString *)getLinkDisplayString:(V2TIMMessage *)message {
    if (message.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
        if (!param || ![param isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        NSString *businessID = param[@"businessID"];
        // 判断是不是自定义跳转消息
        if ([businessID isEqualToString:TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
            return param[@"text"];
        }
    }
    return nil;
}
@end
