//
//  TUIReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReplyQuoteView_Minimalist.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import "TUIReplyQuoteViewData_Minimalist.h"

@implementation TUIReplyQuoteView_Minimalist

- (void)fillWithData:(TUIReplyQuoteViewData_Minimalist *)data {
    _data = data;
}

- (void)reset {
}

@end
