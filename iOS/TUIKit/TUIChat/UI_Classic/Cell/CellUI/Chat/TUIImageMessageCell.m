//
//  TUIImageMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIImageMessageCell.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIImageMessageCell ()

@property(nonatomic, strong) UIView *animateHighlightView;

@end

@implementation TUIImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFit;
        _thumb.backgroundColor = [UIColor clearColor];
        [self.container addSubview:_thumb];

        _progress = [[UILabel alloc] init];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:15];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.layer.cornerRadius = 5.0;
        _progress.hidden = YES;
        _progress.backgroundColor = TImageMessageCell_Progress_Color;
        [_progress.layer setMasksToBounds:YES];
        [self.container addSubview:_progress];
    }
    return self;
}

- (void)fillWithData:(TUIImageMessageCellData *)data;
{
    // set data
    [super fillWithData:data];
    self.imageData = data;
    _thumb.image = nil;
    if (data.thumbImage == nil) {
        [data downloadImage:TImage_Type_Thumb];
    }

    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
      @strongify(self);
      if (thumbImage) {
          self.thumb.image = thumbImage;
      }
    }];

    [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      int progress = [x intValue];
      self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
      self.progress.hidden = (progress >= 100 || progress == 0);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.messageData.messageModifyReactsSize.height > 0) {
        if (self.tagView) {
            CGFloat topMargin = 10;
            CGFloat tagViewTopMargin = 6;
            CGFloat thumbHeight = self.container.mm_h - topMargin - self.messageData.messageModifyReactsSize.height - tagViewTopMargin;
            _thumb.mm_height(thumbHeight).mm_left(0).mm_top(topMargin).mm_width(self.container.mm_w);
            self.tagView.frame = CGRectMake(0, self.container.mm_h - self.messageData.messageModifyReactsSize.height - tagViewTopMargin,
                                            self.container.frame.size.width, self.messageData.messageModifyReactsSize.height);
        }
        self.bubbleView.hidden = NO;
    } else {
        CGFloat topMargin = 0;
        CGFloat height = self.container.mm_h;
        _thumb.mm_height(height).mm_left(0).mm_top(topMargin).mm_width(self.container.mm_w);
        self.bubbleView.hidden = YES;
    }

    _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _progress.mm_fill();
    _progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}
- (void)highlightWhenMatchKeyword:(NSString *)keyword {
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
        [self.animateHighlightView removeFromSuperview];
        self.highlightAnimating = NO;
        return;
    }
    self.highlightAnimating = YES;
    self.animateHighlightView.frame = self.container.bounds;
    self.animateHighlightView.alpha = 0.1;
    [self.container addSubview:self.animateHighlightView];
    [UIView animateWithDuration:0.25
        animations:^{
          self.animateHighlightView.alpha = 0.5;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.25
              animations:^{
                self.animateHighlightView.alpha = 0.1;
              }
              completion:^(BOOL finished) {
                if (!self.imageData.highlightKeyword) {
                    [self animate:0];
                    return;
                }
                [self animate:times];
              }];
        }];
}

- (UIView *)animateHighlightView {
    if (_animateHighlightView == nil) {
        _animateHighlightView = [[UIView alloc] init];
        _animateHighlightView.backgroundColor = [UIColor orangeColor];
    }
    return _animateHighlightView;
}

@end
