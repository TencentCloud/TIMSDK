//
//  TUIVideoViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/24.
//

#import "TUIVideoViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
@import MediaPlayer;
@import AVFoundation;
@import AVKit;

@interface TUIVideoViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *progress;
@property AVPlayerViewController *playerVc;
@end

@implementation TUIVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self)
    if (![_data isVideoExist])
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.frame = self.view.bounds;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];
        
        if (_data.thumbImage == nil) {
            [_data downloadThumb];
        }
        
        _progress = [[UILabel alloc] initWithFrame:self.view.bounds];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:18];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.userInteractionEnabled = YES;
        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [_progress addGestureRecognizer:tap];
        [self.view addSubview:_progress];
        
        
        [RACObserve(_data, thumbImage) subscribeNext:^(UIImage *x) {
            @strongify(self)
            self.imageView.image = x;
        }];
        [RACObserve(_data, videoProgress) subscribeNext:^(NSNumber *x) {
            @strongify(self)
            int p = [x intValue];
            self.progress.text = [NSString stringWithFormat:@"%d%%", p];
        }];
        
        [_data downloadVideo];
    }
    
    [[[RACObserve(_data, videoPath) filter:^BOOL(NSString *path) {
        return [path length] > 0;
    }] take:1] subscribeNext:^(NSString *path) {
        @strongify(self)
        [self addPlayer:path];
    }];
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

- (void)addPlayer:(NSString *)path
{
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
    vc.player = ({
        AVPlayer *p = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
        p;
    });
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc.player play];
    vc.view.frame = self.view.frame;
    self.progress.hidden = YES;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
