//
//  TUIConversationSelectModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//

#import "TUIConversationSelectDataProvider_Minimalist.h"
#import "TUIConversationCellData_Minimalist.h"

@implementation TUIConversationSelectDataProvider_Minimalist

- (Class)getConversationCellClass {
    return [TUIConversationCellData_Minimalist class];
}

@end
