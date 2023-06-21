//
//  TUIChatFlexViewController.m
//  TUIChat
//
//  Created by wyl on 2022/10/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatFlexViewController.h"

typedef enum : NSUInteger {
    FLEX_TOP,
    FLEX_Bottom,
} FLEX_Location;

CGFloat topMargin = NavBar_Height + 30;

@interface TUIChatFlexViewController ()

@property(nonatomic, assign) FLEX_Location currentLoaction;

@property(nonatomic, strong) UIPanGestureRecognizer *panCover;

@property(nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation TUIChatFlexViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];

    self.containerView.backgroundColor = [UIColor whiteColor];

    self.topImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_flex_arrow")]];
    [self.topGestureView addSubview:self.topImgView];

    [self addSingleTapGesture];

    if (!_currentLoaction) {
        self.currentLoaction = FLEX_TOP;
    }

    [self updateSubContainerView];
}

- (void)addSingleTapGesture {
    // When clicking on the shadow, the page disappears
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    CGPoint translation = [tap locationInView:self.containerView];

    if (translation.x < 0 || translation.y < 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (translation.x > self.containerView.frame.size.width || translation.y > self.containerView.frame.size.height) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setnormalTop {
    self.currentLoaction = FLEX_TOP;
}

- (void)setNormalBottom {
    self.currentLoaction = FLEX_Bottom;
}

- (void)setCurrentLoaction:(FLEX_Location)currentLoaction {
    _currentLoaction = currentLoaction;
    if (currentLoaction == FLEX_TOP) {
        self.containerView.frame = CGRectMake(0, topMargin, self.view.frame.size.width, self.view.frame.size.height - topMargin);
    } else if (currentLoaction == FLEX_Bottom) {
        self.containerView.frame = CGRectMake(0, self.view.frame.size.height - kScale390(393), self.view.frame.size.width, kScale390(393));
    }
}

#pragma mark - lazy

- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        _containerView.layer.cornerRadius = kScale390(12);
        [self.view addSubview:_containerView];
    }
    return _containerView;
}

- (UIView *)topGestureView {
    if (_topGestureView == nil) {
        _topGestureView = [[UIView alloc] init];
        [_topGestureView addGestureRecognizer:self.panCover];
        [self.containerView addSubview:_topGestureView];
    }
    return _topGestureView;
}

- (UIPanGestureRecognizer *)panCover {
    if (_panCover == nil) {
        _panCover = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanCover:)];
    }
    return _panCover;
}

- (void)onPanCover:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.topGestureView];
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);

    if (MAX(absX, absY) < 2) return;
    if (absX > absY) {
        if (translation.x < 0) {
            // scroll left
        } else {
            // scroll right
        }
    } else if (absY > absX) {
        if (translation.y < 0) {
            // scroll up
            [self.topGestureView removeGestureRecognizer:self.panCover];
            [UIView animateWithDuration:0.3
                animations:^{
                  self.currentLoaction = FLEX_TOP;
                  [self.topGestureView addGestureRecognizer:self.panCover];
                }
                completion:^(BOOL finished) {
                  if (finished) {
                      [self updateSubContainerView];
                  }
                }];
        } else {
            // scroll down
            if (self.currentLoaction == FLEX_Bottom) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            [self.topGestureView removeGestureRecognizer:self.panCover];
            [UIView animateWithDuration:0.3
                animations:^{
                  self.currentLoaction = FLEX_Bottom;
                  [self.topGestureView addGestureRecognizer:self.panCover];
                }
                completion:^(BOOL finished) {
                  if (finished) {
                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self updateSubContainerView];
                      });
                  }
                }];
        }
    }
}

- (void)updateSubContainerView {
    self.topGestureView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, kScale390(40));
    self.topImgView.frame = CGRectMake((self.topGestureView.frame.size.width - kScale390(24)) * 0.5, kScale390(22), kScale390(24), kScale390(6));
}
@end
