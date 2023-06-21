//
//  TUIFileReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFileReplyQuoteViewData.h"
#import <TUICore/TUIThemeManager.h>
#import "TUIFileMessageCellData.h"

@implementation TUIFileReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TUIFileMessageCellData.class]) {
        return nil;
    }

    TUIFileReplyQuoteViewData *myData = [[TUIFileReplyQuoteViewData alloc] init];
    myData.text = [(TUIFileMessageCellData *)originCellData fileName];
    myData.icon = TUIChatCommonBundleImage(@"msg_file");
    myData.originCellData = originCellData;
    return myData;
}

@end
