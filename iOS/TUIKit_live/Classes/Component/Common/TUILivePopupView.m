//
//  TUILivePopupView.m
//  Pods
//
//  Created by harvy on 2020/9/18.
//

#import "Masonry.h"
#import "TUILivePopupView.h"

@interface TUILivePopupView () <UIGestureRecognizerDelegate>

@end

@implementation TUILivePopupView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

#pragma mark - UI
- (void)setupViews
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCover)];
    tap.delegate = self;
    [self addGestureRecognizer: tap];
    
    [self addSubview:self.animateView];
    
    [self.animateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(self.animateViewHeight);
        make.height.mas_equalTo(self.animateViewHeight);
    }];
    
    [self layoutAnimateView];
    
    
    [self layoutIfNeeded];
}

- (void)showInView:(UIView *)view animate:(BOOL)animated
{
    [self showInView:view animate:animated completion:nil];
}

- (void)showInView:(UIView *)view animate:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (view == nil) {
        view = UIApplication.sharedApplication.keyWindow;
    }
    
    self.frame = view.bounds;
    [view addSubview:self];
    [view layoutIfNeeded];
    
    [self.animateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self);
    }];
        
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }else {
        [self layoutIfNeeded];
        if (completion) {
            completion();
        }
    }
}

- (void)hide:(BOOL)animated
{
    [self hide:animated completion:nil];
}

- (void)hide:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (!animated) {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
        return;
    }
    
    [self.animateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(self.animateViewHeight);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

- (CGFloat)animateViewHeight
{
    return 290.0;
}


- (void)layoutAnimateView
{
    
}

- (void)tapCover
{
    
}

- (void)updateAnimateViewHeight:(CGFloat)height animated:(BOOL)animated
{
    [self.animateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self layoutIfNeeded];
        }];
    }else {
        [self layoutIfNeeded];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    BOOL flag = !CGRectContainsPoint(self.animateView.frame, point);
    NSLog(@"[hello], flag = %d", flag);
    return flag;
}



- (UIView *)animateView
{
    if (_animateView == nil) {
        _animateView = [[UIView alloc] init];
        _animateView.backgroundColor = [UIColor blackColor];
    }
    return _animateView;
}


@end
