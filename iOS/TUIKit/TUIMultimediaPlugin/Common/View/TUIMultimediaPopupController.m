// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaPopupController.h"
#import <Masonry/Masonry.h>

@interface TUIMultimediaPopupController () {
    UIView *_popupView;
}
@end

@implementation TUIMultimediaPopupController

- (instancetype)init {
    self = [super init];
    _animeDuration = 0.15;
    return self;
}

- (void)viewDidLoad {
    _popupView = [[UIView alloc] init];
    [self.view addSubview:_popupView];

    UIView *cancelView = [[UIView alloc] init];
    [self.view addSubview:cancelView];

    [_popupView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self.view);
      make.top.equalTo(self.view.mas_bottom);
    }];
    [cancelView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.left.right.equalTo(self.view);
      make.bottom.equalTo(_popupView.mas_top);
    }];

    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancelViewTap:)];
    rec.cancelsTouchesInView = NO;
    [cancelView addGestureRecognizer:rec];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:_animeDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                       [self->_popupView mas_remakeConstraints:^(MASConstraintMaker *make) {
                         make.left.right.equalTo(self.view);
                         make.bottom.equalTo(self.view.mas_bottom);
                       }];
                       [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (BOOL)popupControllerWillCancel {
    return YES;
}

- (void)popupControllerDidCanceled {
    // do nothing
}

- (void)onCancelViewTap:(UITapGestureRecognizer *)rec {
    BOOL b = [self popupControllerWillCancel];
    if (b) {
        [UIView animateWithDuration:_animeDuration
            delay:0
            options:UIViewAnimationOptionCurveLinear
            animations:^{
              [self->_popupView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view);
                make.top.equalTo(self.view.mas_bottom);
              }];
              [self.view layoutIfNeeded];
            }
            completion:^(BOOL finished) {
              [self popupControllerDidCanceled];
            }];
    }
}

- (void)setMainView:(UIView *)mainView {
    if (_mainView != nil) {
        [_mainView removeFromSuperview];
    }
    _mainView = mainView;
    [_popupView addSubview:_mainView];
    [mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self->_popupView);
    }];
}
@end
