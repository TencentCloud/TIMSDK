//
//  TBubbleMessageCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIBubbleMessageCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIBubbleMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIImageView alloc] initWithFrame:self.container.bounds];
        [self.container addSubview:_bubbleView];
        _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self prepareReactTagUI:self.container];
    }
    return self;
}

- (void)fillWithData:(TUIBubbleMessageCellData *)data {
    [super fillWithData:data];
    self.bubbleData = data;
    self.bubbleView.image = data.bubble;
    self.bubbleView.highlightedImage = data.highlightedBubble;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.bubbleView.frame;
    frame.origin.x = self.bubbleData.bubbleTop;
    self.bubbleView.frame = frame;

    CGPoint center = self.retryView.center;
    center.y = self.bubbleView.center.y;
    self.retryView.center = center;
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword {
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

- (void)animate:(int)times {
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
