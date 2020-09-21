#import "TUIAvatarViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIImage+TUIKIT.h"
#import "TScrollView.h"
#import "TUIKit.h"

@interface TUIAvatarViewController ()<UIScrollViewDelegate>
@property UIImageView *avatarView;

@property TScrollView *avatarScrollView;

@property UIImage *saveBackgroundImage;
@property UIImage *saveShadowImage;

@end

@implementation TUIAvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.saveBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.saveShadowImage = self.navigationController.navigationBar.shadowImage;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.avatarScrollView = [[TScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.avatarScrollView];
    self.avatarScrollView.backgroundColor = [UIColor blackColor];
    self.avatarScrollView.mm_fill();

    self.avatarView = [[UIImageView alloc] initWithImage:self.avatarData.avatarImage];
    self.avatarScrollView.imageView = self.avatarView;
    self.avatarScrollView.maximumZoomScale = 4.0;
    self.avatarScrollView.delegate = self;

    self.avatarView.image = self.avatarData.avatarImage;
    TUIProfileCardCellData *data = self.avatarData;
    /*
     @weakify(self)
    [RACObserve(data, avatarUrl) subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatarView sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
    }];
    */
    @weakify(self)
    [RACObserve(data, avatarUrl) subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatarView sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
        [self.avatarScrollView setNeedsLayout];
    }];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.avatarView;
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
