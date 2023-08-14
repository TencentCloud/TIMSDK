//
//  TUIImageMessageCell_Minimalist.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIImageMessageCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIImageMessageCell_Minimalist ()

@property(nonatomic, strong) UIView *animateHighlightView;

@end

@implementation TUIImageMessageCell_Minimalist

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

        self.msgTimeLabel.textColor = RGB(255, 255, 255);
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

    if (data.direction == MsgDirectionIncoming) {
        [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
          @strongify(self);
          int progress = [x intValue];
          self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
          self.progress.hidden = (progress >= 100 || progress == 0);
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat topMargin = 0;
    CGFloat height = self.container.mm_h;

    if (self.messageData.messageModifyReactsSize.height > 0) {
        topMargin = 10;
        height = (self.container.mm_h - self.messageData.messageModifyReactsSize.height - topMargin);
    }

    _thumb.mm_height(height).mm_left(0).mm_top(topMargin).mm_width(self.container.mm_w);

    _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _progress.mm_fill();
    _progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.msgStatusView.frame = CGRectOffset(self.msgStatusView.frame, kScale390(8), 0);
    self.msgTimeLabel.frame = CGRectOffset(self.msgTimeLabel.frame, kScale390(8), 0);
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

#pragma mark - TUIMessageCellProtocol
+ (CGFloat)getEstimatedHeight:(TUIMessageCellData *)data {
    return 139.f;
}

+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIImageMessageCellData.class], @"data must be kind of TUIImageMessageCellData");
    TUIImageMessageCellData *imageCellData = (TUIImageMessageCellData *)data;
    
    CGSize size = CGSizeZero;
    BOOL isDir = NO;
    if (![imageCellData.path isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:imageCellData.path isDirectory:&isDir]) {
        if (!isDir) {
            size = [UIImage imageWithContentsOfFile:imageCellData.path].size;
        }
    }

    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in imageCellData.items) {
            if (item.type == TImage_Type_Origin) {
                size = item.size;
            }
        }
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in imageCellData.items) {
            if (item.type == TImage_Type_Large) {
                size = item.size;
            }
        }
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in imageCellData.items) {
            if (item.type == TImage_Type_Thumb) {
                size = item.size;
            }
        }
    }

    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return size;
    }
    CGFloat widthMax = kScale390(250);
    CGFloat heightMax = kScale390(250);
    if (size.height > size.width) {
        size.width = size.width / size.height * heightMax;
        size.height = heightMax;
    } else {
        size.height = size.height / size.width * widthMax;
        size.width = widthMax;
    }
    return size;
}

@end
