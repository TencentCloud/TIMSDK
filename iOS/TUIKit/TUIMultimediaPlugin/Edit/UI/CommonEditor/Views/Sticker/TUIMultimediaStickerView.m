// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaStickerView.h"
#import <TUICore/TUIThemeManager.h>
#import "Masonry/Masonry.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"
#import "TUIMultimediaPlugin/TUIMultimediaImageUtil.h"

@interface TUIMultimediaStickerView () <UIGestureRecognizerDelegate> {
    UIButton *_btnEdit;
    UIButton *_btnTransform;
    UIButton *_btnDelete;
    UIView *_borderView;
    BOOL _hideEditButton;
    BOOL _active;

    CGFloat _rawRotation;

    UITapGestureRecognizer *_tapRec;
    UITapGestureRecognizer *_doubleTapRec;
    UIPanGestureRecognizer *_panRec;
    UIPinchGestureRecognizer *_pinchRec;
    UIRotationGestureRecognizer *_rotationRec;
    UIPanGestureRecognizer *_btnTransformPanRec;
    UIImpactFeedbackGenerator *_impactGen;
}

@end
@implementation TUIMultimediaStickerView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _contentMargin = 5;
        _rotateAdsorptionLimitAngle = M_PI / 180 * 5;
        _impactGen = [[UIImpactFeedbackGenerator alloc] init];
        [self frv_initUI];
    }
    return self;
}

- (void)frv_initUI {
    _borderView = [[UIView alloc] init];
    _borderView.translatesAutoresizingMaskIntoConstraints = NO;
    _borderView.layer.borderWidth = 1;
    _borderView.layer.borderColor = UIColor.whiteColor.CGColor;
    _borderView.backgroundColor = [UIColor clearColor];
    _borderView.hidden = YES;
    [self addSubview:_borderView];
    [_borderView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    _btnEdit = [self newCornerButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"sticker_edit_img", @"round_edit") left:YES top:YES];
    _btnTransform = [self newCornerButtonWithImage:[TUIMultimediaImageUtil rotateImage:TUIMultimediaPluginBundleThemeImage(@"sticker_transform_img", @"round_transform") angle:90.0f] left:NO top:NO];
    _btnDelete = [self newCornerButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"sticker_delete_img", @"round_close") left:NO top:YES];

    [_btnEdit addTarget:self action:@selector(onBtnEditClicked) forControlEvents:UIControlEventTouchUpInside];
    [_btnDelete addTarget:self action:@selector(onBtnDeleteClicked) forControlEvents:UIControlEventTouchUpInside];

    _tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self addGestureRecognizer:_tapRec];

    _panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    _panRec.delegate = self;
    [self addGestureRecognizer:_panRec];

    _pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    _pinchRec.delegate = self;
    [self addGestureRecognizer:_pinchRec];

    _rotationRec = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotation:)];
    _rotationRec.delegate = self;
    [self addGestureRecognizer:_rotationRec];

    _btnTransformPanRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onBtnTransformPan:)];
    [_btnTransform addGestureRecognizer:_btnTransformPanRec];

    _doubleTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    _doubleTapRec.delaysTouchesEnded = NO;
    _doubleTapRec.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_doubleTapRec];
}

- (UIButton *)newCornerButtonWithImage:(UIImage *)image left:(BOOL)left top:(BOOL)top {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.hidden = YES;
    [self addSubview:btn];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setImage:image forState:UIControlStateNormal];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.width.height.mas_equalTo(24);
      make.centerX.equalTo(left ? self.mas_left : self.mas_right);
      make.centerY.equalTo(top ? self.mas_top : self.mas_bottom);
    }];
    return btn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_delegate onStickerViewSizeChanged:self];
}

- (void)updateRotation {
    // 规范化到[0,2pi)
    _rawRotation -= floor(_rawRotation / (M_PI * 2)) * M_PI * 2;
    BOOL adsorped = NO;
    // 吸附到 0,90,180,270度
    for (int i = 0; i <= 3; i++) {
        CGFloat diff = fabs(_rawRotation - i * M_PI_2);
        CGFloat diff2 = fabs(_rawRotation - M_PI * 2 - i * M_PI_2);
        if (diff < _rotateAdsorptionLimitAngle || diff2 < _rotateAdsorptionLimitAngle) {
            adsorped = YES;
            if (_rotation != i * M_PI_2) {
                _rotation = i * M_PI_2;
                [_impactGen impactOccurred];
            }
            break;
        }
    }
    if (!adsorped) {
        _rotation = _rawRotation;
    }
    self.transform = CGAffineTransformMakeRotation(_rotation);
}
#pragma mark - Actions
- (void)onTap {
    if (!self.selected) {
        self.selected = YES;
        [_delegate onStickerViewSelected:self];
    }
}
- (void)onDoubleTap:(UITapGestureRecognizer *)rec {
    [_delegate onStickerViewShouldEdit:self];
}
- (void)onPan:(UIPanGestureRecognizer *)rec {
    CGPoint offset = [rec translationInView:self.superview];
    [rec setTranslation:CGPointZero inView:self.superview];
    // 平移
    self.center = Vec2AddVector(self.center, offset);
}
- (void)onPinch:(UIPinchGestureRecognizer *)rec {
    // pow用于加快放大/缩小速度，优化体验
    CGFloat scale = pow(rec.scale, 1.5);
    rec.scale = 1;
    CGSize raw = self.bounds.size;
    self.bounds = CGRectMake(0, 0, raw.width * scale, raw.height * scale);
}
- (void)onRotation:(UIRotationGestureRecognizer *)rec {
    _rawRotation += rec.rotation;
    [self updateRotation];
    rec.rotation = 0;
}
- (void)onBtnTransformPan:(UIPanGestureRecognizer *)rec {
    CGPoint offset = [rec translationInView:self.superview];
    [rec setTranslation:CGPointZero inView:self.superview];

    CGPoint originSize = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    CGPoint originV = Vec2Rotate(Vec2Mul(originSize, 0.5), _rawRotation);
    CGPoint newV = Vec2AddVector(originV, offset);
    // 缩放
    CGPoint newSize = Vec2Mul(originSize, Vec2Len(newV) / Vec2Len(originV));
    self.bounds = CGRectMake(0, 0, newSize.x, newSize.y);
    // 旋转
    _rawRotation += Vec2Degree(originV, newV);
    [self updateRotation];
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)) {
        return YES;
    }
    for (UIView *v in self.subviews) {
        CGPoint localPoint = [v convertPoint:point fromView:self];
        if (CGRectContainsPoint(v.bounds, localPoint)) {
            return YES;
        }
    }
    return NO;
}

- (void)onBtnEditClicked {
    [_delegate onStickerViewShouldEdit:self];
}
- (void)onBtnDeleteClicked {
    [_delegate onStickerViewShouldDelete:self];
}

#pragma mark - Properties
- (BOOL)editButtonHidden {
    return _hideEditButton;
}
- (void)setEditButtonHidden:(BOOL)hideEditButton {
    _hideEditButton = hideEditButton;
}
- (void)setContent:(UIView *)content {
    [_content removeFromSuperview];
    _content = content;
    if (content == nil) {
        return;
    }
    self.bounds = CGRectMake(0, 0, content.bounds.size.width + _contentMargin * 2, content.bounds.size.height + _contentMargin * 2);
    [self addSubview:content];
    [self bringSubviewToFront:_btnEdit];
    [self bringSubviewToFront:_btnTransform];
    [self bringSubviewToFront:_btnDelete];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self).inset(_contentMargin);
    }];
}
- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _borderView.hidden = !selected;
    _btnEdit.hidden = !selected || _hideEditButton;
    _btnTransform.hidden = !selected;
    _btnDelete.hidden = !selected;
}

#pragma mark - UIGestureRecognizerDelegate protocol
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)g1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)g2 {
    NSArray<UIGestureRecognizer *> *recList = @[ _pinchRec, _rotationRec, _panRec ];
    return [recList containsObject:g1] && [recList containsObject:g2];
}
@end
