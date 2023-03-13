//
//  TUIChatFloatTitleView.m
//  TUIChat
//
//  Created by wyl on 2023/1/16.
//

#import "TUIChatFloatController.h"
#import "TUIDefine.h"

typedef enum : NSUInteger {
    FLEX_TOP,
    FLEX_Bottom,
} FLEX_Location;


@interface TUIChatFloatTitleView ()

@end

@implementation TUIChatFloatTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:kScale390(20)];
    [self addSubview:self.titleLabel];
    
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.text = @"";
    self.subTitleLabel.font = [UIFont systemFontOfSize:kScale390(12)];
    self.subTitleLabel.tintColor = [UIColor grayColor];
    [self addSubview:self.subTitleLabel];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.leftButton];
    [self.leftButton setTitle:TUIKitLocalizableString(TUIKitCreateCancel) forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(16)];
    [self.leftButton addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setTitleColor:[UIColor tui_colorWithHex:@"#0365F9"] forState:UIControlStateNormal];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.rightButton];
    [self.rightButton setTitle:TUIKitLocalizableString(TUIKitCreateNext) forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(16)];
    [self.rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setTitleColor:[UIColor tui_colorWithHex:@"#0365F9"] forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.titleLabel sizeToFit];
    [self.subTitleLabel sizeToFit];

    if (self.subTitleLabel.isHidden ||self.subTitleLabel.text.length == 0) {
        self.titleLabel.frame = CGRectMake((self.frame.size.width - self.titleLabel.frame.size.width) *0.5, kScale390(23.5), self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    }
    else {
        self.titleLabel.frame = CGRectMake((self.frame.size.width - self.titleLabel.frame.size.width) *0.5, kScale390(17.5), self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);

        self.subTitleLabel.frame = CGRectMake((self.frame.size.width - self.subTitleLabel.frame.size.width) *0.5, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kScale390(1), self.subTitleLabel.frame.size.width, self.subTitleLabel.frame.size.height);
    }

    
    [self.leftButton sizeToFit];
    self.leftButton.frame = CGRectMake(kScale390(15), kScale390(23.5), self.leftButton.frame.size.width, self.leftButton.frame.size.height);

    
    [self.rightButton sizeToFit];
    self.rightButton.frame = CGRectMake(self.frame.size.width - self.rightButton.frame.size.width - kScale390(14), kScale390(23.5), self.rightButton.frame.size.width, self.rightButton.frame.size.height);

    
}
- (void)leftButtonClick {
    if(self.leftButtonClickCallback){
        self.leftButtonClickCallback();
    }
}

- (void)rightButtonClick {
    if(self.rightButtonClickCallback){
        self.rightButtonClickCallback();
    }
}

- (void)setTitleText:(NSString *)mainText
        subTitleText:(NSString *)secondText
         leftBtnText:(NSString *)leftBtnText
        rightBtnText:(NSString *)rightBtnText {
    self.titleLabel.text = mainText;
    self.subTitleLabel.text = secondText;
    [self.leftButton setTitle:leftBtnText forState:UIControlStateNormal];
    [self.rightButton setTitle:rightBtnText forState:UIControlStateNormal];
}
@end

@interface TUIChatFloatController ()

@property (nonatomic, assign) CGFloat topMargin;

@property (nonatomic, strong) UIViewController<TUIChatFloatSubViewControllerProtocol> * childVC;

@property (nonatomic,assign)  FLEX_Location currentLoaction;

@property (nonatomic, strong) UIPanGestureRecognizer *panCover;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation TUIChatFloatController

- (void)appendChildViewController:(UIViewController <TUIChatFloatSubViewControllerProtocol>*)vc topMargin:(CGFloat)topMargin {
    self.childVC = vc;
    self.topMargin = topMargin;
    
    [self addChildViewController:vc];
    [self.containerView addSubview:vc.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor tui_colorWithHex:@"#000000" alpha:0.6];
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    self.containerView.backgroundColor = [UIColor whiteColor];
        
    self.topImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_flex_arrow")]];
    [self.topGestureView addSubview:self.topImgView];
    self.topImgView.hidden = YES;

    @weakify(self)
    self.topGestureView.leftButtonClickCallback = ^{
        @strongify(self)
        if ([self.childVC respondsToSelector:@selector(floatControllerLeftButtonClick)] ) {
            [self.childVC performSelector:@selector(floatControllerLeftButtonClick)];
        }
    };
    self.topGestureView.rightButtonClickCallback = ^{
        @strongify(self)
        if ([self.childVC respondsToSelector:@selector(floatControllerRightButtonClick)] ) {
            [self.childVC performSelector:@selector(floatControllerRightButtonClick)];
        }
    };
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
    CGPoint  translation = [tap locationInView:self.containerView];
    
    if (translation.x <0 || translation.y <0 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (translation.x > self.containerView.frame.size.width  || translation.y > self.containerView.frame.size.height) {
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
        self.containerView.frame = CGRectMake(0, self.topMargin, self.view.frame.size.width, self.view.frame.size.height - self.topMargin);
    }
    else if (currentLoaction == FLEX_Bottom) {
        self.containerView.frame = CGRectMake(0, self.view.frame.size.height - kScale390(393), self.view.frame.size.width,kScale390(393));
    }
}

- (void)floatDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self dismissViewControllerAnimated:flag completion:completion];
}
#pragma mark - lazy

- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        _containerView.layer.cornerRadius = kScale390(12);
        [self.view addSubview: _containerView];
    }
    return _containerView;
}

- (UIView *)topGestureView {
    if (_topGestureView == nil) {
        _topGestureView = [[TUIChatFloatTitleView alloc] init];
//        [_topGestureView addGestureRecognizer:self.panCover];
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

- (void)onPanCover:(UIPanGestureRecognizer *)pan  {
    
    CGPoint  translation = [pan translationInView:self.topGestureView];
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    if (MAX(absX, absY) < 2)
        return;
    if (absX > absY ) {
        if (translation.x<0) {
            //scroll left
        }else{
            //scroll right
        }
    } else if (absY > absX) {
        if (translation.y<0) {
            //scroll up
            [self.topGestureView removeGestureRecognizer:self.panCover];
            [UIView animateWithDuration:0.3 animations:^{
                self.currentLoaction = FLEX_TOP;
                [self.topGestureView addGestureRecognizer:self.panCover];
            }completion:^(BOOL finished) {
                if (finished) {
                    [self updateSubContainerView];
                }
            }];
        }else{
            //scroll down
            if (self.currentLoaction == FLEX_Bottom) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            [self.topGestureView removeGestureRecognizer:self.panCover];
            [UIView animateWithDuration:0.3 animations:^{
                self.currentLoaction = FLEX_Bottom;
                [self.topGestureView addGestureRecognizer:self.panCover];
            }completion:^(BOOL finished) {
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
    self.topGestureView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, kScale390(68.5));
    self.topImgView.frame = CGRectMake((self.topGestureView.frame.size.width -kScale390(24)) *0.5, kScale390(22), kScale390(24) , kScale390(6));
    
    self.childVC.view.frame = CGRectMake(0,
                                         self.topGestureView.frame.origin.y +
                                         self.topGestureView.frame.size.height,
                                         self.containerView.frame.size.width,
                                         self.containerView.frame.size.height -
                                         self.topGestureView.frame.size.height);
    
}
@end
