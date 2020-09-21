//
//  TBubbleMessageCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIBubbleMessageCell.h"
#import "TUIFaceView.h"
#import "TUIFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "MMLayout/UIView+MMLayout.h"

@implementation TUIBubbleMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.container addSubview:_bubbleView];
        _bubbleView.mm_fill();
        _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)fillWithData:(TUIBubbleMessageCellData *)data
{
    [super fillWithData:data];
    self.bubbleData = data;
    self.bubbleView.image = data.bubble;
    self.bubbleView.highlightedImage = data.highlightedBubble;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bubbleView.mm_top(self.bubbleData.bubbleTop);
    self.retryView.mm__centerY(self.bubbleView.mm_centerY);
}
@end
