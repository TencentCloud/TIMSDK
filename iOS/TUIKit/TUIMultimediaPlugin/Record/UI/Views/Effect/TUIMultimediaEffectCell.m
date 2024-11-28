// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaEffectCell.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"

const CGFloat MaskBorderWidth = 2;
const CGFloat EffectCellRadius = 10;
const CGFloat EffectCellWidth = 60;

const CGFloat LabelFontSize = 12;
const CGFloat LabelHeight = 18;
const CGFloat LabelInsectToBottom = 5;

@interface TUIMultimediaEffectCell () {
    UIView *_imgContainerView;
    UIView *_highlightView;
    UIImageView *_imgView;
    UILabel *_label;
    NSString *_text;
}
@end

@implementation TUIMultimediaEffectCell

@dynamic image;
@dynamic text;

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _imgContainerView = [[UIView alloc] init];
    [self.contentView addSubview:_imgContainerView];
    _imgContainerView.layer.cornerRadius = EffectCellRadius;
    _imgContainerView.clipsToBounds = YES;
    _imgView = [[UIImageView alloc] init];
    [_imgContainerView addSubview:_imgView];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.size.mas_equalTo(_iconSize);
      make.center.equalTo(_imgContainerView);
    }];

    _highlightView = [[UIView alloc] init];
    [self.contentView addSubview:_highlightView];
    _highlightView.hidden = YES;
    _highlightView.backgroundColor = [[TUIMultimediaConfig sharedInstance] getThemeColor];

    _label = [[UILabel alloc] init];
    _label.font = [UIFont systemFontOfSize:LabelFontSize];
    _label.textColor = UIColor.whiteColor;
    _label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_label];

    [_highlightView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self.contentView);
    }];
    [_imgContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.top.equalTo(self.contentView).inset(MaskBorderWidth);
      make.height.equalTo(_imgContainerView.mas_width);
    }];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self.contentView);
      make.bottom.equalTo(self.contentView);
      make.top.equalTo(_imgContainerView.mas_bottom);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addMaskToHighlightView];
}

- (void)addMaskToHighlightView {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_highlightView.bounds cornerRadius:EffectCellRadius];
    [maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:_imgContainerView.frame cornerRadius:EffectCellRadius].bezierPathByReversingPath];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = maskPath.CGPath;
    _highlightView.layer.mask = layer;
}

- (void)setIconSize:(CGSize)iconSize {
    _iconSize = iconSize;
    [_imgView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.size.mas_equalTo(_iconSize);
    }];
}

- (UIImage *)image {
    return _imgView.image;
}
- (void)setImage:(UIImage *)image {
    _imgView.image = image;
}
- (NSString *)text {
    return _text;
}
- (void)setText:(NSString *)text {
    _text = text;
    _label.text = text;
}
- (void)setEffectSelected:(BOOL)effectSelected {
    _effectSelected = effectSelected;
    _highlightView.hidden = !effectSelected;
}

@end
