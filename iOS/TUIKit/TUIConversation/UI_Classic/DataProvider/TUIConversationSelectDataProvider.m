//
//  TUIConversationSelectModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationSelectDataProvider.h"
#import "TUIConversationCellData.h"

@implementation TUIConversationSelectDataProvider

- (Class)getConversationCellClass {
    return [TUIConversationCellData class];
}

@end
