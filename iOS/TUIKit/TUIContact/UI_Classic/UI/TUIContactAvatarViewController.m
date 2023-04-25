#import "TUIContactAvatarViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <TUICore/UIView+TUILayout.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@interface TUIContactAvatarViewController ()<UIScrollViewDelegate>
@property UIImageView *avatarView;

@property TUIScrollView *avatarScrollView;

@property UIImage *saveBackgroundImage;
@property UIImage *saveShadowImage;

@end

@implementation TUIContactAvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.saveBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.saveShadowImage = self.navigationController.navigationBar.shadowImage;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    CGRect rect = self.view.bounds;
    self.avatarScrollView = [[TUIScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.avatarScrollView];
    self.avatarScrollView.backgroundColor = [UIColor blackColor];
    self.avatarScrollView.frame = rect;

    self.avatarView = [[UIImageView alloc] initWithImage:self.avatarData.avatarImage];
    self.avatarScrollView.imageView = self.avatarView;
    self.avatarScrollView.maximumZoomScale = 4.0;
    self.avatarScrollView.delegate = self;

    self.avatarView.image = self.avatarData.avatarImage;
    TUICommonContactProfileCardCellData *data = self.avatarData;
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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
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
