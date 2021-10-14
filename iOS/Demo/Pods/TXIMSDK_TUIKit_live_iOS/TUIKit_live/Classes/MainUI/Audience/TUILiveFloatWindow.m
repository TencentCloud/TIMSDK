//
//  TUILiveFloatWindow.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/10/23.
//

#import "TUILiveFloatWindow.h"
#import "TUILiveAudienceVideoRenderView.h"
#import "Masonry.h"
#import "TUILiveColor.h"

// 屏幕的宽
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define FLOAT_VIEW_WIDTH  120
#define FLOAT_VIEW_HEIGHT FLOAT_VIEW_WIDTH * [[UIScreen mainScreen] bounds].size.height/[[UIScreen mainScreen] bounds].size.width
#define IsIPhoneX (ScreenHeight >= 812 || ScreenWidth >= 812)

@interface TUILiveFloatWindow ()

@property(nonatomic, weak) UIView *origFatherView;
@property(nonatomic, assign) CGRect floatViewRect;
@property(nonatomic, strong) UIImageView *backgroundImageView;
@property(nonatomic, strong) UILabel *noAnchorTips;

@property(nonatomic, strong) UIView *rootView;

@end

@implementation TUILiveFloatWindow{
    UIButton *_closeBtn;
}

+ (instancetype)sharedInstance {
    static TUILiveFloatWindow* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUILiveFloatWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar - 1;
        self.rootViewController = [UIViewController new];
        self.rootViewController.view.backgroundColor = [UIColor clearColor];
        self.rootViewController.view.userInteractionEnabled = NO;
        
        self.rootView = [[UIView alloc] initWithFrame:CGRectZero];
        self.rootView.backgroundColor = [UIColor blackColor];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        [self.rootView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        [self.rootView addGestureRecognizer:tapGesture];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootView addSubview:closeBtn];
        [closeBtn sizeToFit];
        _closeBtn = closeBtn;
        CGRect rect = CGRectMake(ScreenWidth - FLOAT_VIEW_WIDTH - 20, ScreenHeight - FLOAT_VIEW_HEIGHT - 160, FLOAT_VIEW_WIDTH, FLOAT_VIEW_HEIGHT);
        if (IsIPhoneX) {
            rect.origin.y -= 44;
        }
        self.floatViewRect = rect;
        self.hidden = YES; // 初始化默认隐藏
    }
    return self;
}

#pragma mark - getter
- (CGFloat)floatWindowScaling {
    if (self.isShowing) {
        return FLOAT_VIEW_WIDTH / [UIScreen mainScreen].bounds.size.width;
    } else {
        return 1.0;
    }
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        CGRect rect = CGRectMake(0, 0, FLOAT_VIEW_WIDTH, FLOAT_VIEW_HEIGHT);
        CAGradientLayer * gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = rect;
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:19/255.0 green:41/255.0 blue:75/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:5/255.0 green:12/255.0 blue:23/255.0 alpha:1].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.locations = @[@0,@1];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:rect];
        backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        backgroundImageView.backgroundColor = UIColorFromRGB(242424);
        [backgroundImageView.layer addSublayer:gradientLayer];
        _backgroundImageView = backgroundImageView;
    }
    return _backgroundImageView;
}

- (UILabel *)noAnchorTips {
    if (!_noAnchorTips) {
        _noAnchorTips = [[UILabel alloc] init];
        _noAnchorTips.backgroundColor = [UIColor clearColor];
        [_noAnchorTips setTextColor:[UIColor whiteColor]];
        [_noAnchorTips setTextAlignment:NSTextAlignmentCenter];
        [_noAnchorTips setText:@"主播暂时不在线..."];
        _noAnchorTips.adjustsFontSizeToFitWidth = YES;
    }
    return _noAnchorTips;
}

#pragma mark - public function
- (void)show {
    _isShowing = YES; // 一定要最先执行，有些视图依赖改属性进行缩放
    self.rootView.frame = self.floatViewRect;
    [self addSubview:self.rootView];
    [self.rootView addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.rootView);
    }];
    self.hidden = NO;
    
    self.origFatherView = self.renderView.fatherView;
    if (self.origFatherView != self.rootView) {
        // 显示的时候需要将播放视图转移到window上
        self.renderView.fatherView = self.rootView;
    }
    [self.rootView layoutIfNeeded];
    //TODO: - 转移过程中添加动画
    
    [self.rootView bringSubviewToFront:_closeBtn];
    [_closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(42);
        make.top.equalTo(self.rootView.mas_top);
        make.right.equalTo(self.rootView.mas_right);
    }];
    
    
}

- (void)hide {
    _isShowing = NO; // 一定要最先执行，有些视图依赖改属性进行缩放
    [self.rootView removeFromSuperview];
    self.hidden = YES;
    // 隐藏的时候需要将绘制视图放回原视图(原始图需要自己管理视图层级)
    self.renderView.fatherView = self.origFatherView;
}

- (void)switchPKStatus:(BOOL)isPKStatus {
    if (isPKStatus) {
        CGRect targetFrame = self.rootView.frame;
        if (targetFrame.size.width != self.floatViewRect.size.width) {
            return;
        }
        targetFrame.origin.x -= targetFrame.size.width;
        if (targetFrame.origin.x < 0) {
            targetFrame.origin.x = 0;
        }
        targetFrame.size.width += targetFrame.size.width;
        [UIView animateWithDuration:0.1 animations:^{
            self.rootView.frame = targetFrame;
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.rootView.frame = self.floatViewRect;
        }];
    }
}

- (void)switchNoAnchorStatus:(BOOL)isNoAnchor {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isNoAnchor) {
            [self.backgroundImageView addSubview:self.noAnchorTips];
            [self.noAnchorTips mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.backgroundImageView);
                make.height.mas_equalTo(20);
                make.width.equalTo(self.backgroundImageView).multipliedBy(0.8);
            }];
        } else {
            [self.noAnchorTips removeFromSuperview];
        }
    });
}

#pragma mark - private function
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (CGRectContainsPoint(self.rootView.bounds,
                            [self.rootView convertPoint:point fromView:self])) {
        return [super pointInside:point withEvent:event];
    }
    
    return NO;
}

- (void)closeBtnClick:(id)sender
{
    if (self.closeHandler) {
        self.closeHandler();
    } else {
        [self hide];
        // 持有的视图做退房处理
        self.backController = nil;
    }
}

#pragma mark - GestureRecognizer
// 手势处理
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    if (UIGestureRecognizerStateBegan == panGesture.state) {
    } else if (UIGestureRecognizerStateChanged == panGesture.state) {
        CGPoint translation = [panGesture translationInView:self];
        
        CGPoint center = self.rootView.center;
        center.x += translation.x;
        center.y += translation.y;
        self.rootView.center = center;
        
        UIEdgeInsets effectiveEdgeInsets = UIEdgeInsetsZero; // 边距可以自己调
        
        CGFloat   leftMinX = 0.0f + effectiveEdgeInsets.left;
        CGFloat    topMinY = 0.0f + effectiveEdgeInsets.top;
        CGFloat  rightMaxX = self.bounds.size.width - self.rootView.bounds.size.width + effectiveEdgeInsets.right;
        CGFloat bottomMaxY = self.bounds.size.height - self.rootView.bounds.size.height + effectiveEdgeInsets.bottom;
        
        CGRect frame = self.rootView.frame;
        frame.origin.x = frame.origin.x > rightMaxX ? rightMaxX : frame.origin.x;
        frame.origin.x = frame.origin.x < leftMinX ? leftMinX : frame.origin.x;
        frame.origin.y = frame.origin.y > bottomMaxY ? bottomMaxY : frame.origin.y;
        frame.origin.y = frame.origin.y < topMinY ? topMinY : frame.origin.y;
        self.rootView.frame = frame;
        
        // zero
        [panGesture setTranslation:CGPointZero inView:self];
    } else if (UIGestureRecognizerStateEnded == panGesture.state) {
    }
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if (self.backHandler) {
            self.backHandler();
        } else {
            [self hide];
            if (self.backController) {
                //TODO: 这里未必是push的，需要进一步思考怎么处理
                [[self topNavigationController] pushViewController:self.backController animated:YES];
                self.backgroundColor = nil;
            }
        }
    }
}

- (UINavigationController *)topNavigationController {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController.navigationController;
}

@end
