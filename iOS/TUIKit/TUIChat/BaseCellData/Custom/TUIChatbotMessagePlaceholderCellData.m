//
//  TUIChatbotMessagePlaceholderCellData.m
//  TUIChat
//
//  Created by AI Assistant on 2025/1/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatbotMessagePlaceholderCellData.h"

@implementation TUIChatbotMessagePlaceholderCellData

+ (instancetype)createAIPlaceholderCellData {
    TUIChatbotMessagePlaceholderCellData *cellData = [[TUIChatbotMessagePlaceholderCellData alloc] initWithDirection:MsgDirectionIncoming];
    cellData.content = @""; // Empty content for placeholder
    cellData.isAITyping = YES; // Start in typing state
    cellData.reuseId = @"TUIChatbotMessagePlaceholderCellData";
    return cellData;
}

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    // This placeholder cell data is not created from V2TIMMessage
    // It's created programmatically using createAIPlaceholderCellData
    return nil;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return @""; // No display string for placeholder
}


- (CGSize)contentSize {
    // Small size for placeholder - just enough for loading animation
    return CGSizeMake(40, 20);
}

@end 
