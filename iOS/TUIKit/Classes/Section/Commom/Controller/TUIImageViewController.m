//
//  TUIImageViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/31.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIImageViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TScrollView.h"
#import "MMLayout/UIView+MMLayout.h"
#import "NSBundle+TUIKIT.h"

@interface TUIImageViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *progress;
@property TScrollView *imageScrollView;

@property UIImage *saveBackgroundImage;
@property UIImage *saveShadowImage;

@end

@implementation TUIImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.saveBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.saveShadowImage = self.navigationController.navigationBar.shadowImage;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.imageScrollView = [[TScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.imageScrollView];
    self.imageScrollView.backgroundColor = [UIColor blackColor];
    self.imageScrollView.mm_fill();

    self.imageView = [[UIImageView alloc] initWithImage:nil];
    self.imageScrollView.imageView = self.imageView;
    self.imageScrollView.maximumZoomScale = 4.0;
    self.imageScrollView.delegate = self;



    BOOL isExist = NO;
    [_data getImagePath:TImage_Type_Origin isExist:&isExist];
    if (isExist) {
        if(_data.originImage) {
            _imageView.image = _data.originImage;
        } else {
            [_data decodeImage:TImage_Type_Origin];
            @weakify(self)
            [RACObserve(_data, originImage) subscribeNext:^(UIImage *x) {
                @strongify(self)
                self.imageView.image = x;
                [self.imageScrollView setNeedsLayout];
            }];
        }
    } else {
        _imageView.image = _data.thumbImage;

        _progress = [[UILabel alloc] initWithFrame:self.view.bounds];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:18];
        _progress.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_progress];

        _button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80) * 0.5, self.view.frame.size.height - 60, 80, 30)];
        [_button setTitle:TUILocalizableString(View-the-original) forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:13];
        _button.backgroundColor = [UIColor clearColor];
        _button.layer.borderColor = [UIColor whiteColor].CGColor;
        _button.layer.borderWidth = 0.5;
        _button.layer.cornerRadius = 3;
        [_button.layer setMasksToBounds:YES];
        [_button addTarget:self action:@selector(downloadOrigin:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
    }

}

- (void)downloadOrigin:(id)sender
{
    [_data downloadImage:TImage_Type_Origin];
    @weakify(self)
    [RACObserve(_data, originImage) subscribeNext:^(UIImage *x) {
        @strongify(self)
        if (x) {
            self.imageView.image = x;
            [self.imageScrollView setNeedsLayout];
            self.progress.hidden = YES;
        }
    }];
    [RACObserve(_data, originProgress) subscribeNext:^(NSNumber *x) {
        @strongify(self)
        int progress = [x intValue];
        self.progress.text =  [NSString stringWithFormat:@"%d%%", progress];
        if (progress >= 100)
            self.progress.hidden = YES;
    }];
    self.button.hidden = YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self.navigationController.navigationBar setBackgroundImage:self.saveBackgroundImage
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = self.saveShadowImage;
    }
}
@end
