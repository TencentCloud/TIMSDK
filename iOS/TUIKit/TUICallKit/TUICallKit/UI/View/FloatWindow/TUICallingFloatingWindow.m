//
//  TUICallingFloatingWindow.m
//  TUICalling
//
//  Created by noah on 2022/1/12.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingFloatingWindow.h"
#import "TUICallingVideoRenderView.h"
#import "Masonry.h"
#import "TUICallingCommon.h"
#import "UIColor+TUICallingHex.h"
#import "UIView+TUIUtil.h"
#import "TUIDefine.h"

static CGFloat const kMicroWindowCornerRatio = 15.0f;
static CGFloat const kMicroContainerViewOffset = 8;

@interface TUICallingFloatingWindow()

@property (nonatomic, assign) CGPoint beganPoint;
@property (nonatomic, assign) CGPoint beganOrigin;

@property (nonatomic, strong) TUICallingVideoRenderView *renderView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *describeLabel;

@end

@implementation TUICallingFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<TUICallingFloatingWindowDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self initSubviews];
        [self activateConstraints];
        [self bindInteraction];
    }
    return self;
}

- (void)initSubviews {
    [self addSubview:self.bgView];
    [self addSubview:self.containerView];
    [self addSubview:self.imageView];
    [self addSubview:self.describeLabel];
}

- (void)activateConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bgView);
        make.top.left.mas_equalTo(self.bgView).offset(kMicroContainerViewOffset);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(5);
        make.centerX.mas_equalTo(self.containerView);
        make.width.height.mas_equalTo(30);
    }];
    [self.describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.mas_equalTo(self.containerView);
        make.bottom.mas_equalTo(self.containerView).offset(-5);
    }];
}

- (void)bindInteraction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:tap];
    [pan requireGestureRecognizerToFail:tap];
    [self addGestureRecognizer:pan];
}

- (void)updateMicroWindowWithText:(NSString *)textStr {
    self.describeLabel.hidden = NO;
    [self.describeLabel setText:textStr];
}

- (void)floatingWindowRoundedRect {
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    
    if (self.frame.origin.x < Screen_Width / 2.0f) {
        corner = UIRectCornerTopRight | UIRectCornerBottomRight;
    }
    
    [self.bgView roundedRect:corner withCornerRatio:kMicroWindowCornerRatio];
}

- (void)updateMicroWindowWithRenderView:(TUICallingVideoRenderView *)renderView {
    if (renderView) {
        self.imageView.hidden = YES;
        self.describeLabel.hidden = YES;
        renderView.frame = CGRectMake(0, 0, kMicroVideoViewWidth - kMicroContainerViewOffset * 2, kMicroVideoViewHeight - kMicroContainerViewOffset * 2);
        [self.renderView removeFromSuperview];
        [self.containerView addSubview:renderView];
        self.renderView = renderView;
    } else {
        self.imageView.hidden = NO;
        self.describeLabel.hidden = NO;
    }
}

#pragma mark - TUICallingVideoRenderViewDelegate

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingWindowDidClickView)]) {
        [self.delegate floatingWindowDidClickView];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    if (!panGesture || !panGesture.view) {
        return;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            self.beganPoint = [panGesture translationInView:panGesture.view];
            self.beganOrigin = self.frame.origin;
            [self.bgView roundedRect:UIRectCornerAllCorners withCornerRatio:kMicroWindowCornerRatio];
        } break;
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [panGesture translationInView:panGesture.view];
            CGFloat offsetX = (point.x - _beganPoint.x);
            CGFloat offsetY = (point.y - _beganPoint.y);
            self.frame = CGRectMake(_beganOrigin.x + offsetX, _beganOrigin.y + offsetY, self.frame.size.width, self.frame.size.height);
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGFloat leftDefine = 0;
            CGRect screenRect = [UIScreen mainScreen].bounds;
            CGFloat currentCenterX = self.frame.origin.x + self.frame.size.width / 2.0;
            CGFloat finalOriginX = (currentCenterX <= screenRect.size.width / 2.0) ? leftDefine : (screenRect.size.width - self.frame.size.width);
            CGFloat finalOriginY = self.frame.origin.y;
            
            if (self.frame.origin.y <= StatusBar_Height) {
                finalOriginY = StatusBar_Height;
            }
            
            if ((self.frame.origin.y + self.frame.size.height) >= screenRect.size.height) {
                finalOriginY = screenRect.size.height - self.frame.size.height - Bottom_SafeHeight;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                if (self) {
                    self.frame = CGRectMake(finalOriginX , finalOriginY, self.frame.size.width, self.frame.size.height);
                }
            } completion:^(BOOL finished) {
                [self floatingWindowRoundedRect];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(floatingWindowChangedFrame)]) {
                    [self.delegate floatingWindowChangedFrame];
                }
            }];
        } break;
        default:
            break;
    }
}

#pragma mark - Getter And Setter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor t_colorWithHexString:@"#CCCCCC"];
        _bgView.alpha = 0.2;
        _bgView.layer.borderWidth = 1;
        _bgView.layer.borderColor = [UIColor t_colorWithHexString:@"#999999"].CGColor;
        _bgView.layer.masksToBounds = YES;
        _bgView.alpha = 0.8;
    }
    return _bgView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
        _containerView.layer.cornerRadius = 10.0f;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setImage:[TUICallingCommon getBundleImageWithName:@"trtccalling_ic_dialing"]];
    }
    return _imageView;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        [_describeLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_describeLabel setTextColor:[UIColor t_colorWithHexString:@"#000000"]];
        _describeLabel.textAlignment = NSTextAlignmentCenter;
        _describeLabel.hidden = YES;
    }
    return _describeLabel;
}

@end
