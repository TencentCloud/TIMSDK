
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUICaptureVideoPreviewViewController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@import AVFoundation;

@interface TUICaptureVideoPreviewViewController ()

@property(nonatomic) NSURL *fileURL;

@property(nonatomic) AVPlayer *player;
@property(nonatomic) AVPlayerItem *item;
@property(nonatomic) AVPlayerLayer *playerLayer;
@property(nonatomic) UIButton *commitButton;
@property(nonatomic) UIButton *cancelButton;

@property(nonatomic) CGRect lastRect;
@property(nonatomic) BOOL onShow;
@property(nonatomic) BOOL onReadyToPlay;

@end

@implementation TUICaptureVideoPreviewViewController

- (instancetype)initWithVideoURL:(NSURL *)url {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _fileURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];

    self.item = [[AVPlayerItem alloc] initWithURL:self.fileURL];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.view.layer addSublayer:self.playerLayer];

    self.commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *commitImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camer_commit")];
    [self.commitButton setImage:commitImage forState:UIControlStateNormal];
    UIImage *commitBGImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camer_commitBg")];
    [self.commitButton setBackgroundImage:commitBGImage forState:UIControlStateNormal];
    [self.commitButton addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commitButton];

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *cancelButtonBGImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camera_cancel")];
    [self.cancelButton setBackgroundImage:[cancelButtonBGImage rtl_imageFlippedForRightToLeftLayoutDirection] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];

    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.item];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            self.onReadyToPlay = YES;
            [self playVideo];
        }
    }
}

- (void)playVideo {
    [TUITool dispatchMainAsync:^{
      if (self.onShow && self.onReadyToPlay) {
          [self.player play];
      }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.onShow = YES;

    [self playVideo];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if (!CGRectEqualToRect(self.lastRect, self.view.bounds)) {
        self.lastRect = self.view.bounds;

        self.playerLayer.frame = self.view.bounds;

        CGFloat commitButtonWidth = 80.0;
        CGFloat buttonDistance = (self.view.bounds.size.width - 2 * commitButtonWidth) / 3.0;
        CGFloat commitButtonY = self.view.bounds.size.height - commitButtonWidth - 50.0;
        CGFloat commitButtonX = 2 * buttonDistance + commitButtonWidth;
        self.commitButton.frame = CGRectMake(commitButtonX, commitButtonY, commitButtonWidth, commitButtonWidth);
        
        CGFloat cancelButtonX = commitButtonWidth;
        self.cancelButton.frame = CGRectMake(cancelButtonX, commitButtonY, commitButtonWidth, commitButtonWidth);
        if (isRTL()) {
            [self.commitButton resetFrameToFitRTL];
            [self.cancelButton resetFrameToFitRTL];
        }
    }
}

- (void)commitButtonClick:(UIButton *)btn {
    if (self.commitBlock) {
        [self removeObserver];
        self.commitBlock();
    }
}

- (void)cancelButtonClick:(UIButton *)btn {
    if (self.cancelBlock) {
        [self removeObserver];
        self.cancelBlock();
    }
}

- (void)playFinished:(NSNotification *)noti {
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

- (void)removeObserver {
    [self.item removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
