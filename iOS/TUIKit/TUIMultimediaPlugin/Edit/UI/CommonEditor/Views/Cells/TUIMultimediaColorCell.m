// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaColorCell.h"

const CGFloat ContentMarginSelected = 0;
const CGFloat ContentMarginDeselected = 5;

const CGFloat FrontMargin = 4;

@interface TUIMultimediaColorCell () {
    UIView *_front;
    UIView *_back;
    CGFloat _contentMargin;
}
@end

@implementation TUIMultimediaColorCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _contentMargin = ContentMarginDeselected;
        _color = UIColor.blackColor;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _back = [[UIView alloc] init];
    _back.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:_back];

    _front = [[UIView alloc] init];
    _front.backgroundColor = _color;
    [self.contentView addSubview:_front];

    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat len = MIN(self.contentView.bounds.size.width, self.contentView.bounds.size.height) - _contentMargin;
    CGPoint center = CGPointMake(self.contentView.bounds.size.width / 2, self.contentView.bounds.size.height / 2);

    _back.bounds = CGRectMake(0, 0, len, len);
    _back.center = center;
    _back.layer.cornerRadius = len / 2;
    _back.clipsToBounds = YES;

    _front.bounds = CGRectMake(0, 0, len - FrontMargin, len - FrontMargin);
    _front.center = center;
    _front.layer.cornerRadius = (len - FrontMargin) / 2;
    _front.clipsToBounds = YES;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _front.backgroundColor = _color;
}

- (void)setColorSelected:(BOOL)colorSelected {
    _colorSelected = colorSelected;
    _contentMargin = colorSelected ? ContentMarginSelected : ContentMarginDeselected;
    [self setNeedsLayout];
}

@end
