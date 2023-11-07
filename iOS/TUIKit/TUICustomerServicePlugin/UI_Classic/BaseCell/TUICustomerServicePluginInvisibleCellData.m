//
//  TUICustomerServicePluginInvisibleCellData.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginInvisibleCellData.h"
#import "TUICustomerServicePluginPrivateConfig.h"

@implementation TUICustomerServicePluginInvisibleCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUICustomerServicePluginInvisibleCellData *cellData = [[TUICustomerServicePluginInvisibleCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    
    if ([param[@"src"] isEqualToString: BussinessID_Src_CustomerService_EvaluationRule]) {
        NSDictionary *content = param[@"content"];
        NSInteger menuSendRuleFlag = [content[@"menuSendRuleFlag"] integerValue];
        [TUICustomerServicePluginPrivateConfig sharedInstance].canEvaluate = menuSendRuleFlag >> 2;
    }
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    
    if ([param[@"src"] isEqualToString: BussinessID_Src_CustomerService_Timeout]) {
        return TIMCommonLocalizableString(TUICustomerServiceTimeout);
    } else if ([param[@"src"] isEqualToString: BussinessID_Src_CustomerService_End]) {
        return TIMCommonLocalizableString(TUICustomerServiceEnd);
    }
    
    return nil;
}

// Override
- (BOOL)shouldHide {
    return YES;
}

@end
