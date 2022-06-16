//
//  TBubbleMessageCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIBubbleMessageCell.h"
#import "TUIFaceView.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"

@implementation TUIBubbleMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.container addSubview:_bubbleView];
        _bubbleView.mm_fill();
        _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self prepareReactTagUI:self.container];
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

- (void)highlightWhenMatchKeyword:(NSString *)keyword
{
    // 默认高亮效果，闪烁
    if (keyword) {
        // 显示高亮动画
        if (self.highlightAnimating) {
            return;
        }
        [self animate:3];
    }
}

// 默认高亮动画
- (void)animate:(int)times
{
    times--;
    if (times < 0) {
        self.bubbleView.image = self.bubbleData.bubble;
        self.highlightAnimating = NO;
        return;
    }
    self.highlightAnimating = YES;
    self.bubbleView.image = self.bubbleData.animateHighlightBubble_alpha50;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bubbleView.image = self.bubbleData.animateHighlightBubble_alpha20;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.bubbleData.highlightKeyword) {
                [self animate:0];
                return;
            }
            [self animate:times];
        });
    });
}

@end
