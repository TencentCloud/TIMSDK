//
//  VideoViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/11/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *progress;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL isVideoExist = NO;
    NSString *videoPath = [_data getVideoPath:&isVideoExist];
    if(isVideoExist){
        [self addPlayer:videoPath];
    }
    else{
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.frame = self.view.bounds;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];
        
        BOOL isSnapshotExist = NO;
        NSString *snapshotPath = [_data getSnapshotPath:&isSnapshotExist];
        if(isSnapshotExist){
            _imageView.image = [UIImage imageNamed:snapshotPath];
        }
        else{
            __weak typeof(self) ws = self;
            [_data downloadSnapshot:^(NSInteger curSize, NSInteger totalSize) {
            } response:^(int code, NSString *desc, NSString *path) {
                if(code == 0){
                    ws.imageView.image = [UIImage imageNamed:path];
                }
            }];
        }
        
        _progress = [[UILabel alloc] initWithFrame:self.view.bounds];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:18];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.userInteractionEnabled = YES;
        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [_progress addGestureRecognizer:tap];
        [self.view addSubview:_progress];
        
        
        __weak typeof(self) ws = self;
        [_data downloadVideo:^(NSInteger curSize, NSInteger totalSize) {
            ws.progress.text = [NSString stringWithFormat:@"%ld%%", curSize * 100 / totalSize];
        } response:^(int code, NSString *desc, NSString *path) {
            if(code == 0){
                [ws addPlayer:path];
            }
        }];
    }
}

- (void)addPlayer:(NSString *)path
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    player.view.frame = self.view.bounds;
    [self addChildViewController:player];
    [self.view addSubview:player.view];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
