//
//  TUIFileReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFileReplyQuoteView_Minimalist.h"
#import "TUIFileReplyQuoteViewData_Minimalist.h"

@implementation TUIFileReplyQuoteView_Minimalist

- (void)fillWithData:(TUIReplyQuoteViewData_Minimalist *)data {
    [super fillWithData:data];
    if (![data isKindOfClass:TUIFileReplyQuoteViewData_Minimalist.class]) {
        return;
    }
    self.textLabel.numberOfLines = 1;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}
@end
