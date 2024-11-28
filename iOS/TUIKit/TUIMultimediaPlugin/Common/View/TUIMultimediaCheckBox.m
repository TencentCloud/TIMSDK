// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaCheckBox.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaImageUtil.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"

@interface TUIMultimediaCheckBox () {
    UILabel *_label;
    UIImageView *_imgView;
    UITapGestureRecognizer *_tapRec;
}
@end

@implementation TUIMultimediaCheckBox
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _iconSize = CGSizeMake(18, 18);
    UIImage *imgOff = [TUIMultimediaImageUtil imageFromImage:TUIMultimediaPluginBundleThemeImage(@"checkbox_off_img", @"checkbox_off") withTintColor:[[TUIMultimediaConfig sharedInstance] getThemeColor]];;
    UIImage *imgOn =  [TUIMultimediaImageUtil imageFromImage:TUIMultimediaPluginBundleThemeImage(@"checkbox_on_img", @"checkbox_on") withTintColor:[[TUIMultimediaConfig sharedInstance] getThemeColor]];
    _imgView = [[UIImageView alloc] initWithImage:imgOff highlightedImage:imgOn];
    [self addSubview:_imgView];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;

    _label = [[UILabel alloc] init];
    [self addSubview:_label];
    _label.textColor = UIColor.whiteColor;

    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.top.bottom.equalTo(self);
      make.size.mas_equalTo(self->_iconSize);
    }];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self);
      make.left.equalTo(_imgView.mas_right).inset(5);
      make.centerY.equalTo(_imgView);
    }];

    _tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self addGestureRecognizer:_tapRec];
    return self;
}

- (void)onTap {
    [self setOn:!_on];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Properties
- (void)setOn:(BOOL)on {
    _on = on;
    _imgView.highlighted = on;
}

- (void)setIconSize:(CGSize)iconSize {
    _iconSize = iconSize;
    [_imgView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.size.mas_equalTo(self->_iconSize);
    }];
}

- (NSString *)text {
    return _label.text;
}

- (void)setText:(NSString *)text {
    _label.text = text;
}

- (UIColor *)textColor {
    return _label.textColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _label.textColor = textColor;
}
@end
