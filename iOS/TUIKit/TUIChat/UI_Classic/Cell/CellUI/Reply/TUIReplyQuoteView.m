//
//  TUIReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReplyQuoteView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import "TUIReplyQuoteViewData.h"

@implementation TUIReplyQuoteView

- (void)fillWithData:(TUIReplyQuoteViewData *)data {
    _data = data;
}

- (void)reset {
}

@end
