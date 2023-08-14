//
//  TUIFileReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFileReplyQuoteView_Minimalist.h"
#import "TUIFileReplyQuoteViewData.h"

@implementation TUIFileReplyQuoteView_Minimalist

- (void)fillWithData:(TUIReplyQuoteViewData *)data {
    [super fillWithData:data];
    if (![data isKindOfClass:TUIFileReplyQuoteViewData.class]) {
        return;
    }
    self.textLabel.numberOfLines = 1;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}
@end
