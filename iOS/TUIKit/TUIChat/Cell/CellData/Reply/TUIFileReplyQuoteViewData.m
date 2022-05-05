//
//  TUIFileReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIFileReplyQuoteViewData.h"
#import "TUIFileMessageCellData.h"
#import "TUIThemeManager.h"

@implementation TUIFileReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData
{
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
