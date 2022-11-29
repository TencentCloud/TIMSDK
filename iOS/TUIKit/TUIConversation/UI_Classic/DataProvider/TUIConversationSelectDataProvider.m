//
//  TUIConversationSelectModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//

#import "TUIConversationSelectDataProvider.h"
#import "TUIConversationCellData.h"

@implementation TUIConversationSelectDataProvider

- (Class)getConversationCellClass {
    return [TUIConversationCellData class];
}

@end
