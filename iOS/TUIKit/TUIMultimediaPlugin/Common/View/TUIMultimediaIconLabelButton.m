// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaIconLabelButton.h"
#import <Masonry/Masonry.h>

@interface TUIMultimediaIconLabelButton () {
}

@end

@implementation TUIMultimediaIconLabelButton
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat midX = CGRectGetMidX(contentRect);
    CGFloat minY = CGRectGetMinY(contentRect);
    return CGRectMake(midX - _iconSize.width / 2, minY, _iconSize.width, _iconSize.height);
}
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [self imageRectForContentRect:contentRect];
    CGSize size = self.currentAttributedTitle.size;
    CGFloat midX = CGRectGetMidX(contentRect);
    return CGRectMake(midX - size.width / 2, CGRectGetMaxY(imageRect) + _iconLabelGap, size.width, size.height);
}
- (CGSize)intrinsicContentSize {
    CGSize titleSize = [self titleRectForContentRect:CGRectZero].size;
    return CGSizeMake(MAX(_iconSize.width, titleSize.width), _iconSize.height + _iconLabelGap + titleSize.height);
}
- (void)setIconSize:(CGSize)iconSize {
    _iconSize = iconSize;
    [self setNeedsLayout];
}
- (void)setIconLabelGap:(CGFloat)iconLabelGap {
    _iconLabelGap = iconLabelGap;
    [self setNeedsLayout];
}
@end
