//
//  TUIChatPopContextController.m
//  TUIChat
//
//  Created by wyl on 2022/10/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatPopContextController.h"
#import <TIMCommon/TIMDefine.h>
#import "UIImage+ImageEffects.h"
#import <TUICore/TUICore.h>

@interface TUIChatPopContextController ()<V2TIMAdvancedMsgListener>
@property(nonatomic, strong) UIView *recentView;
@property(nonatomic, strong) UIView *alertContainerView;
@property(nonatomic, strong) TUIMessageCell *alertView;
@property(nonatomic, strong) TUIChatPopContextExtionView *extionView;

@property(nonatomic, strong) UIColor *backgroundColor;  // set backgroundColor
@property(nonatomic, strong) UIView *backgroundView;    // you set coustom view to it
@property(nonatomic, strong) UITapGestureRecognizer *singleTap;
@property(nonatomic, assign) BOOL backgoundTapDismissEnable;  // default NO

@end

@implementation TUIChatPopContextController

- (instancetype)init {
    if (self = [super init]) {
        [self configureController];
    }
    return self;
}

- (void)configureController {
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationCustom;

    _backgroundColor = [UIColor clearColor];
    _backgoundTapDismissEnable = YES;
    _configRecentView = YES; // Default to YES
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    [self addBackgroundView];

    [self addSingleTapGesture];

    [self configureAlertView];

    [self configRecentView];

    [self configExtionView];

    [self.view layoutIfNeeded];

    [self showHapticFeedback];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_viewWillShowHandler) {
        _viewWillShowHandler(_alertView);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_viewDidShowHandler) {
        _viewDidShowHandler(_alertView);
    }

    // 
    // Too far to the top
    CGFloat moveY = 0;
    if (self.recentView.frame.origin.y < NavBar_Height) {
        CGFloat deal = NavBar_Height - self.recentView.frame.origin.y;
        moveY = deal + NavBar_Height + 50;
    }
    // 
    // Too far to the right
    CGFloat moveX = 0;
    if (self.recentView.frame.origin.x + self.recentView.frame.size.width > self.view.frame.size.width) {
        CGFloat deal = self.recentView.frame.origin.x + self.recentView.frame.size.width - self.view.frame.size.width;
        moveX = deal + 5;
    }
    // 
    // too far down
    if (self.extionView.frame.origin.y + self.extionView.frame.size.height > self.view.frame.size.height) {
        CGFloat deal = self.extionView.frame.origin.y + self.extionView.frame.size.height - self.view.frame.size.height;
        moveY = -deal - 50;
    }

    BOOL oneScreenCanFillCheck = NO;
    // Can only one screen fit
    if (self.recentView.frame.size.height + self.originFrame.size.height + self.extionView.frame.size.height + kScale390(100) > self.view.bounds.size.height) {
        oneScreenCanFillCheck = YES;
    }

    if (oneScreenCanFillCheck) {
        // recentView
        CGFloat recentViewMoveY = NavBar_Height + 50;

        self.recentView.frame =
            CGRectMake(self.recentView.frame.origin.x - moveX, recentViewMoveY, self.recentView.frame.size.width, self.recentView.frame.size.height);

        // alertView
        [UIView animateWithDuration:0.3
                         animations:^{
                           self.alertContainerView.frame =
                               CGRectMake(0, self.recentView.frame.origin.y + kScale390(8) + self.recentView.frame.size.height,
                                          self.view.frame.size.width, self.originFrame.size.height);
                         }
                         completion:^(BOOL finished){

                         }];

        // extionView
        CGFloat deal = self.extionView.frame.origin.y + self.extionView.frame.size.height - self.view.frame.size.height;

        CGFloat extionViewMoveY = -deal - 50;

        self.extionView.frame = CGRectMake(self.extionView.frame.origin.x - moveX, self.extionView.frame.origin.y + extionViewMoveY,
                                           self.extionView.frame.size.width, self.extionView.frame.size.height);
        self.extionView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.5
                         animations:^{
                           // Bounces
                           self.extionView.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:^(BOOL finished){

                         }];

        return;
    } else {
        // When the container need a displacement change
        // Or do nothing
        if (moveY != 0) {
            [UIView animateWithDuration:0.3
                             animations:^{
                self.alertContainerView.frame = CGRectMake(0,  self.originFrame.origin.y + moveY, self.view.frame.size.width, self.originFrame.size.height);
                             }
                             completion:^(BOOL finished){

                             }];
        }

        self.recentView.frame = CGRectMake(self.recentView.frame.origin.x - moveX, self.recentView.frame.origin.y, self.recentView.frame.size.width,
                                           self.recentView.frame.size.height);
        [UIView animateWithDuration:0.2
                         animations:^{
                           // When recentView needs to have displacement animation
                           self.recentView.frame = CGRectMake(self.recentView.frame.origin.x, self.recentView.frame.origin.y + moveY,
                                                              self.recentView.frame.size.width, self.recentView.frame.size.height);
                         }
                         completion:^(BOOL finished){

                         }];

        self.extionView.frame = CGRectMake(self.extionView.frame.origin.x - moveX, self.extionView.frame.origin.y + moveY, self.extionView.frame.size.width,
                                           self.extionView.frame.size.height);
        self.extionView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.5
                         animations:^{
                           // Bounces
                           self.extionView.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:^(BOOL finished){

                         }];
    }
}

- (void)addBackgroundView {
    if (_backgroundView == nil) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = _backgroundColor;
        _backgroundView = backgroundView;
    }
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:_backgroundView atIndex:0];
    [self addConstraintToView:_backgroundView edgeInset:UIEdgeInsetsZero];
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = backgroundView;
    } else if (_backgroundView != backgroundView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:backgroundView aboveSubview:_backgroundView];
        [self addConstraintToView:backgroundView edgeInset:UIEdgeInsetsZero];
        backgroundView.alpha = 0;
        [UIView animateWithDuration:0.3
            animations:^{
              backgroundView.alpha = 1;
            }
            completion:^(BOOL finished) {
              [_backgroundView removeFromSuperview];
              _backgroundView = backgroundView;
              [self addSingleTapGesture];
            }];
    }
}

- (void)addSingleTapGesture {
    self.view.userInteractionEnabled = YES;
    _backgroundView.userInteractionEnabled = YES;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.enabled = _backgoundTapDismissEnable;

    [_backgroundView addGestureRecognizer:singleTap];
    _singleTap = singleTap;
}

- (void)configureAlertView {
    self.alertContainerView = [[UIView alloc] init];
    [self.view addSubview:self.alertContainerView];
    _alertView = [[self.alertCellClass alloc] init];
    [self.alertContainerView addSubview:_alertView];
    _alertView.userInteractionEnabled = YES;
    if ([self.alertView isKindOfClass:NSClassFromString(@"TUIMergeMessageCell_Minimalist")]) {
        _alertView.userInteractionEnabled = NO;
    }
    [_alertView fillWithData:self.alertViewCellData];
    [_alertView layoutIfNeeded];
    
    self.alertContainerView.frame = CGRectMake(0, _originFrame.origin.y, self.view.frame.size.width, _originFrame.size.height);
    _alertView.frame = CGRectMake(0, 0, self.alertContainerView.frame.size.width, self.alertContainerView.frame.size.height);
    for (UIView *view in _alertView.contentView.subviews) {
        if(view != _alertView.container) {
            view.hidden = YES;
        }
    }
    [_alertView.container mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_originFrame.origin.x);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(_originFrame.size);
    }];
}

- (void)configRecentView {
    _recentView = [[UIView alloc] init];
    _recentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_recentView];
    _recentView.frame = CGRectMake(_originFrame.origin.x,
                                   _originFrame.origin.y - kScale390(8 + 40),
                                   MAX(kTIMDefaultEmojiSize.width *8,kScale390(208)),
                                   kScale390(40));
    
    // Set alpha to 0 if configRecentView is NO
    if (!_configRecentView) {
        _recentView.alpha = 0;
    }
    
    NSDictionary *param = @{TUICore_TUIChatExtension_ChatPopMenuReactRecentView_Delegate : self};
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_MinimalistExtensionID parentView:self.recentView param:param];
}

- (void)configExtionView {
    _extionView = [[TUIChatPopContextExtionView alloc] init];
    _extionView.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
    _extionView.layer.cornerRadius = kScale390(16);
    [self.view addSubview:_extionView];

    CGFloat height = [self configAndCaculateExtionHeight];
    _extionView.frame = CGRectMake(_originFrame.origin.x, _originFrame.origin.y + _originFrame.size.height + kScale390(8), kScale390(180), height);
}

- (CGFloat)configAndCaculateExtionHeight {
    NSMutableArray *items = self.items;
    CGFloat height = 0;
    for (int i = 0; i < items.count; i++) {
        height += kScale390(40);
    }

    CGFloat topMargin = kScale390(6);
    CGFloat bottomMargin = kScale390(6);
    height += topMargin;
    height += bottomMargin;

    [_extionView configUIWithItems:items topBottomMargin:topMargin];
    return height;
}

- (void)updateExtionView {
    CGFloat height = [self configAndCaculateExtionHeight];
    _extionView.frame = CGRectMake(_extionView.frame.origin.x, _extionView.frame.origin.y, _extionView.frame.size.width, height);
}

- (void)setBackgoundTapDismissEnable:(BOOL)backgoundTapDismissEnable {
    _backgoundTapDismissEnable = backgoundTapDismissEnable;
    _singleTap.enabled = backgoundTapDismissEnable;
}

- (void)addConstraintToView:(UIView *)view edgeInset:(UIEdgeInsets)edgeInset {
    [self addConstraintWithView:view topView:self.view leftView:self.view bottomView:self.view rightView:self.view edgeInset:edgeInset];
}

- (void)addConstraintWithView:(UIView *)view
                      topView:(UIView *)topView
                     leftView:(UIView *)leftView
                   bottomView:(UIView *)bottomView
                    rightView:(UIView *)rightView
                    edgeInset:(UIEdgeInsets)edgeInset {
    if (topView) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:topView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:edgeInset.top]];
    }

    if (leftView) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:leftView
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1
                                                               constant:edgeInset.left]];
    }

    if (rightView) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:rightView
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1
                                                               constant:edgeInset.right]];
    }

    if (bottomView) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:bottomView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:edgeInset.bottom]];
    }
}

#pragma mark -  public

- (void)setBlurEffectWithView:(UIView *)view {
    [self setBlurEffectWithView:view style:BlurEffectStyleDarkEffect];
}

- (void)setBlurEffectWithView:(UIView *)view style:(BlurEffectStyle)blurStyle {
    UIImage *snapshotImage = [UIImage snapshotImageWithView:view];
    UIImage *blurImage = [self blurImageWithSnapshotImage:snapshotImage style:blurStyle];
    dispatch_async(dispatch_get_main_queue(), ^{
      UIImageView *blurImageView = [[UIImageView alloc] initWithImage:blurImage];
      self.backgroundView = blurImageView;
    });
}

- (void)setBlurEffectWithView:(UIView *)view effectTintColor:(UIColor *)effectTintColor {
    UIImage *snapshotImage = [UIImage snapshotImageWithView:view];
    UIImage *blurImage = [snapshotImage applyTintEffectWithColor:effectTintColor];
    UIImageView *blurImageView = [[UIImageView alloc] initWithImage:blurImage];
    self.backgroundView = blurImageView;
}

#pragma mark - private
- (void)showHapticFeedback {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
          UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
          [generator prepare];
          [generator impactOccurred];
        });

    } else {
        // Fallback on earlier versions
    }
}
- (UIImage *)blurImageWithSnapshotImage:(UIImage *)snapshotImage style:(BlurEffectStyle)blurStyle {
    switch (blurStyle) {
        case BlurEffectStyleLight:
            return [snapshotImage applyLightEffect];
        case BlurEffectStyleDarkEffect:
            return [snapshotImage applyDarkEffect];
        case BlurEffectStyleExtraLight:
            return [snapshotImage applyExtraLightEffect];
        default:
            return nil;
    }
}

- (void)blurDismissViewControllerAnimated:(BOOL)animated completion:(void (^__nullable)(BOOL finished))completion {
    [self dismissViewControllerAnimated:animated];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (completion) {
          completion(YES);
      }
    });
}
- (void)dismissViewControllerAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.3
                     animations:^{
                       self.recentView.frame = CGRectMake(self.recentView.frame.origin.x, self.originFrame.origin.y - self.recentView.frame.size.height,
                                                          self.recentView.frame.size.width, self.recentView.frame.size.height);
                     }
                     completion:^(BOOL finished){

                     }];

    [UIView animateWithDuration:0.3
        animations:^{
        self.alertContainerView.frame = CGRectMake(0,  self.originFrame.origin.y , self.view.frame.size.width, self.originFrame.size.height);
        }
        completion:^(BOOL finished) {
          if (finished) {
              [self dismissViewControllerAnimated:animated completion:self.dismissComplete];
          }
        }];

    self.extionView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.2
        animations:^{
          self.extionView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        }
        completion:^(BOOL finished) {
          if (finished) {
              self.extionView.transform = CGAffineTransformMakeScale(0, 0);
          }
        }];
}

#pragma mark - action

- (void)singleTap:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:NO];
}

// MARK: V2TIMAdvancedMsgListener
- (void)onRecvMessageRevoked:(NSString *)msgID operateUser:(V2TIMUserFullInfo *)operateUser reason:(NSString *)reason {
    
    if ([msgID isEqualToString:self.alertViewCellData.msgID]) {
        UIViewController *controller = self;
        while(controller.presentingViewController != nil){
            controller = controller.presentingViewController;
        }
        [controller dismissViewControllerAnimated:YES completion:^{
            [self blurDismissViewControllerAnimated:NO completion:nil];
        }];
    }

}


@end
