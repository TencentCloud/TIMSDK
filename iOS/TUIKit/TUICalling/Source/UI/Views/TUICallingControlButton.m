//
//  TUICallingControlButton.m
//  TUICalling
//
//  Created by noah on 2021/9/14.
//

#import "TUICallingControlButton.h"
#import <Masonry/Masonry.h>

@interface TUICallingControlButton()

@property (nonatomic, copy) TUICallingButtonActionBlcok buttonActionBlock;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) CGSize imageSize;

@end

@implementation TUICallingControlButton

+ (instancetype)createViewWithFrame:(CGRect)frame titleText:(NSString *)titleText  buttonAction:(TUICallingButtonActionBlcok)buttonAction imageSize:(CGSize)imageSize {
    TUICallingControlButton *controlView = [[TUICallingControlButton alloc] initWithFrame:frame imageSize:imageSize];
    controlView.buttonActionBlock = buttonAction;
    controlView.titleLabel.text = titleText;
    return controlView;
}

- (instancetype)initWithFrame:(CGRect)frame imageSize:(CGSize)imageSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageSize = imageSize;
        [self addSubview:self.button];
        [self addSubview:self.titleLabel];
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.mas_equalTo(self.imageSize);
        make.bottom.mas_equalTo(self.titleLabel.mas_top).offset(-(CGSizeEqualToSize(CGSizeMake(64, 64), self.imageSize) ? 10.0f : 16.0f));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerX.bottom.equalTo(self);
    }];
}

- (void)configBackgroundImage:(UIImage *)image {
    if (image) {
        [self.button setBackgroundImage:image forState:UIControlStateNormal];
    }
}

- (void)configTitleColor:(UIColor *)titleColor {
    if (titleColor) {
        self.titleLabel.textColor = titleColor;
    }
}

#pragma mark - Event Action

- (void)buttonActionEvent:(UIButton *)sender {
    if (self.buttonActionBlock) {
        self.buttonActionBlock(sender);
    }
}

#pragma mark - Lazy

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button addTarget:self action:@selector(buttonActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

@end
