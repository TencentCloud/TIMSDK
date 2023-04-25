//
//  TUIBubbleMessageCell_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIBubbleMessageCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIBubbleMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIImageView alloc] initWithFrame:self.container.bounds];
        [self.container addSubview:_bubbleView];
        _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)fillWithData:(TUIBubbleMessageCellData_Minimalist *)data
{
    [super fillWithData:data];
    _bubbleData = data;
    
    if (self.bubbleData.sameToNextMsgSender) {
        self.bubbleView.image = _bubbleData.bubble_SameMsg;
        self.bubbleView.highlightedImage = _bubbleData.highlightedBubble_SameMsg;
    } else {
        self.bubbleView.image = _bubbleData.bubble;
        self.bubbleView.highlightedImage = _bubbleData.highlightedBubble;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bubbleView.mm_top(self.bubbleData.bubbleTop);
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword
{
    /**
     * 父类实现默认高亮效果 - 闪烁
     * The parent class implements the default highlighting effect - flickering
     */
    if (keyword) {
        if (self.highlightAnimating) {
            return;
        }
        [self animate:3];
    }
}

- (void)animate:(int)times
{
    times--;
    if (times < 0) {
        if (self.bubbleData.sameToNextMsgSender) {
            self.bubbleView.image = _bubbleData.bubble_SameMsg;
        } else {
            self.bubbleView.image = _bubbleData.bubble;
        }
        self.bubbleView.layer.cornerRadius = 0;
        self.bubbleView.layer.masksToBounds = YES;
        self.highlightAnimating = NO;
        return;
    }
    
    self.bubbleView.image = self.bubbleData.animateHighlightBubble_alpha50;
    self.bubbleView.layer.cornerRadius = 12;
    self.bubbleView.layer.masksToBounds = YES;
    self.highlightAnimating = YES;
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
