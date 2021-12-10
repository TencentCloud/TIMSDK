//
//  TUIFileReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIFileReplyQuoteView.h"
#import "TUIFileReplyQuoteViewData.h"

@implementation TUIFileReplyQuoteView

- (void)fillWithData:(TUIReplyQuoteViewData *)data
{
    [super fillWithData:data];
    if (![data isKindOfClass:TUIFileReplyQuoteViewData.class]) {
        return;
    }
    self.textLabel.numberOfLines = 1;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}
@end
