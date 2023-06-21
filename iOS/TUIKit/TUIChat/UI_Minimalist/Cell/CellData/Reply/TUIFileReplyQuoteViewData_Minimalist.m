//
//  TUIFileReplyQuoteViewData_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFileReplyQuoteViewData_Minimalist.h"
#import <TUICore/TUIThemeManager.h>
#import "TUIFileMessageCellData_Minimalist.h"

@implementation TUIFileReplyQuoteViewData_Minimalist

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TUIFileMessageCellData_Minimalist.class]) {
        return nil;
    }

    TUIFileReplyQuoteViewData_Minimalist *myData = [[TUIFileReplyQuoteViewData_Minimalist alloc] init];
    myData.text = [(TUIFileMessageCellData_Minimalist *)originCellData fileName];
    myData.icon = TUIChatCommonBundleImage(@"msg_file");
    myData.originCellData = originCellData;
    return myData;
}

@end
