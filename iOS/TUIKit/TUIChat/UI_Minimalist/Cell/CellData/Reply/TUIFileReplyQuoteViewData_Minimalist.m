//
//  TUIFileReplyQuoteViewData_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIFileReplyQuoteViewData_Minimalist.h"
#import "TUIFileMessageCellData_Minimalist.h"
#import "TUIThemeManager.h"

@implementation TUIFileReplyQuoteViewData_Minimalist

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData
{
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
