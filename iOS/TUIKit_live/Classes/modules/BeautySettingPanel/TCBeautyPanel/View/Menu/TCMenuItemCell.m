// Copyright (c) 2019 Tencent. All rights reserved.

#import "TCMenuItemCell.h"

@implementation TCMenuItemCell {
    UIImageView *_backgroundImageView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupView];
    }
    return self;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _imageView.highlighted = NO;
    _label.highlighted = NO;
    _imageView.image = nil;
    _label.text = nil;
}

- (void)layoutSubviews
{
    if (_imageView && _imageView.image) {
        CGSize imageSize = CGSizeMake(45, 45); // _imageView.image.size
        CGRect labelFrame = CGRectIntegral((CGRect){CGPointZero, [_label sizeThatFits:self.bounds.size]});
        labelFrame.size.width = CGRectGetWidth(self.bounds);
        const CGFloat spacing = 5;
        CGFloat totalHeight = CGRectGetHeight(labelFrame) + imageSize.height;
        CGFloat y = (CGRectGetHeight(self.bounds) - totalHeight) / 2;
        CGRect imageFrame = CGRectMake(0, y, CGRectGetWidth(self.bounds), imageSize.height);
        labelFrame.origin.y = CGRectGetMaxY(imageFrame) + spacing;
        _label.frame = labelFrame;
        _imageView.frame = imageFrame;
    } else {
        _label.frame = self.bounds;
    }
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        _backgroundImageView.image = self.selectedBackgroundImage;
    }
    _label.highlighted = selected;
    _imageView.highlighted = selected;
    _backgroundImageView.hidden = !selected;
}

- (void)setupView
{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.font = [UIFont systemFontOfSize:12];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    _backgroundImageView = [[UIImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(8, 0, 8, 0))];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:_backgroundImageView atIndex:0];
}

- (UIImageView *)imageView {
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return _imageView;
}


@end
