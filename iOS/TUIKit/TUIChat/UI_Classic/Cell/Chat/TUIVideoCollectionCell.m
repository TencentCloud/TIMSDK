
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIVideoCollectionCell.h"
#import <TIMCommon/TIMDefine.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUICircleLodingView.h"

@import MediaPlayer;
@import AVFoundation;
@import AVKit;

@interface TUIVideoCollectionCellScrollView : UIScrollView <UIScrollViewDelegate>
@property(nonatomic, strong) UIView *videoView;
@property(assign, nonatomic) CGFloat videoViewNormalWidth;
@property(assign, nonatomic) CGFloat videoViewNormalHeight;

- (void)pictureZoomWithScale:(CGFloat)zoomScale;

@end

@implementation TUIVideoCollectionCellScrollView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 2.0f;
        _videoViewNormalHeight = frame.size.height;
        _videoViewNormalWidth = frame.size.width;
        self.videoView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.videoView];
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

#pragma mark-- Help Methods

- (void)pictureZoomWithScale:(CGFloat)zoomScale {
    CGFloat imageScaleWidth = zoomScale * self.videoViewNormalWidth;
    CGFloat imageScaleHeight = zoomScale * self.videoViewNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.videoView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    self.contentSize = CGSizeMake(imageScaleWidth, imageScaleHeight);
}

#pragma mark-- Setter

- (void)setVideoViewNormalWidth:(CGFloat)videoViewNormalWidth {
    _videoViewNormalWidth = videoViewNormalWidth;
    self.videoView.frame = CGRectMake(0, 0, _videoViewNormalWidth, _videoViewNormalHeight);
    self.videoView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void)setVideoViewNormalHeight:(CGFloat)videoViewNormalHeight {
    _videoViewNormalHeight = videoViewNormalHeight;
    self.videoView.frame = CGRectMake(0, 0, _videoViewNormalWidth, _videoViewNormalHeight);
    self.videoView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

#pragma mark-- UIScrollViewDelegate

// Returns the view control that needs to be zoomed. During zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.videoView;
}

// BeginZooming
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    NSLog(@"BeginZooming");
}
// EndZooming
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    NSLog(@"EndZooming");
}

// zoom
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat imageScaleWidth = scrollView.zoomScale * self.videoViewNormalWidth;
    CGFloat imageScaleHeight = scrollView.zoomScale * self.videoViewNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.videoView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
}

@end
@interface TUIVideoCollectionCell ()
@property(nonatomic, strong) TUIVideoCollectionCellScrollView *scrollView;
@property(nonatomic, strong) UILabel *duration;
@property(nonatomic, strong) UILabel *playTime;
@property(nonatomic, strong) UISlider *playProcess;
@property(nonatomic, strong) UIButton *mainPlayBtn;
@property(nonatomic, strong) UIButton *mainDownloadBtn;
@property(nonatomic, strong) UIButton *playBtn;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) TUICircleLodingView *animateCircleView;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) NSString *videoPath;
@property(nonatomic, strong) NSURL *videoUrl;
@property(nonatomic, assign) BOOL isPlay;
@property(nonatomic, assign) BOOL isSaveVideo;
@property(nonatomic, strong) TUIVideoMessageCellData *videoData;
@end

@implementation TUIVideoCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupRotaionNotifications];
    }
    return self;
}

- (void)setupRotaionNotifications {
    if (@available(iOS 16.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange:)
                                                     name:TUIMessageMediaViewDeviceOrientationChangeNotification
                                                   object:nil];
    } else {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}
- (void)setupViews {
    self.scrollView = [[TUIVideoCollectionCellScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.layer.cornerRadius = 5.0;
    [self.imageView.layer setMasksToBounds:YES];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.scrollView.videoView addSubview:self.imageView];
    self.imageView.mm_fill();
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.mainPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mainPlayBtn.contentMode = UIViewContentModeScaleToFill;
    [self.mainPlayBtn setImage:TUIChatCommonBundleImage(@"video_play_big") forState:UIControlStateNormal];
    [self.mainPlayBtn addTarget:self action:@selector(onPlayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mainPlayBtn];

    self.mainDownloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mainDownloadBtn.contentMode = UIViewContentModeScaleToFill;
    [self.mainDownloadBtn setImage:[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"download")] forState:UIControlStateNormal];
    self.mainDownloadBtn.hidden = YES;
    [self.mainDownloadBtn addTarget:self action:@selector(mainDownloadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mainDownloadBtn];

    self.animateCircleView = [[TUICircleLodingView alloc] initWithFrame:CGRectMake(0, 0, kScale390(40), kScale390(40))];
    self.animateCircleView.progress = 0;
    self.animateCircleView.hidden = YES;
    [self addSubview:_animateCircleView];

    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.contentMode = UIViewContentModeScaleToFill;
    [self.playBtn setImage:TUIChatCommonBundleImage(@"video_play") forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(onPlayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playBtn];

    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.contentMode = UIViewContentModeScaleToFill;
    [self.closeBtn setImage:TUIChatCommonBundleImage(@"video_close") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(onCloseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];

    self.downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadBtn.contentMode = UIViewContentModeScaleToFill;
    [self.downloadBtn setImage:TUIChatCommonBundleImage(@"download") forState:UIControlStateNormal];
    [self.downloadBtn addTarget:self action:@selector(onDownloadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.downloadBtn];

    self.playTime = [[UILabel alloc] init];
    self.playTime.textColor = [UIColor whiteColor];
    self.playTime.font = [UIFont systemFontOfSize:12];
    self.playTime.text = @"00:00";
    [self addSubview:self.playTime];

    self.duration = [[UILabel alloc] init];
    self.duration.textColor = [UIColor whiteColor];
    self.duration.font = [UIFont systemFontOfSize:12];
    self.duration.text = @"00:00";
    [self addSubview:self.duration];

    self.playProcess = [[UISlider alloc] init];
    self.playProcess.minimumValue = 0;
    self.playProcess.maximumValue = 1;
    self.playProcess.minimumTrackTintColor = [UIColor whiteColor];
    [self.playProcess addTarget:self action:@selector(onSliderValueChangedBegin:) forControlEvents:UIControlEventTouchDown];
    [self.playProcess addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playProcess];
}

- (void)fillWithData:(TUIVideoMessageCellData *)data;
{
    [super fillWithData:data];
    self.videoData = data;
    self.isSaveVideo = NO;

    BOOL hasRiskContent = data.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        self.imageView.image = TIMCommonBundleThemeImage(@"", @"icon_security_strike");
        for (UIView *subview in self.subviews) {
            if (subview != self.scrollView && subview != self.closeBtn){
                subview.hidden = YES;
            }
        }
        return;
    }
    
    CGFloat duration = data.videoItem.duration;
    self.duration.text = [NSString stringWithFormat:@"%.2d:%.2d", (int)duration / 60, (int)duration % 60];

    self.imageView.image = nil;
    if (data.thumbImage == nil) {
        [data downloadThumb];
    }
    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
      @strongify(self);
      if (thumbImage) {
          self.imageView.image = thumbImage;
      }
    }];

    if (![self.videoData isVideoExist]) {
        self.mainDownloadBtn.hidden = NO;
        self.mainPlayBtn.hidden = YES;
        self.animateCircleView.hidden = YES;
    } else {
        /**
         * 
         * Downloaded videos can be played directly using local video files
         */
        self.videoPath = self.videoData.videoPath;
        if (self.videoPath) {
            [self addPlayer:[NSURL fileURLWithPath:self.videoPath]];
        }
    }

    [[[RACObserve(self.videoData, videoProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(id _Nullable x) {
      @strongify(self);
      int progress = [x intValue];
      if (progress == 100) {
          self.animateCircleView.progress = 99;
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.animateCircleView.progress = 100;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              self.animateCircleView.progress = 0;
              self.mainDownloadBtn.hidden = YES;
              self.animateCircleView.hidden = YES;
              self.mainPlayBtn.hidden = NO;
            });
          });
      } else if (progress > 1 && progress < 100) {
          self.animateCircleView.progress = progress;
          self.mainDownloadBtn.hidden = YES;
          self.animateCircleView.hidden = NO;
      } else {
          self.animateCircleView.progress = progress;
      }
    }];

    [[[RACObserve(self.videoData, videoPath) filter:^BOOL(NSString *path) {
      return [path length] > 0;
    }] take:1] subscribeNext:^(NSString *path) {
      @strongify(self);
      self.videoPath = path;
      if (self.isSaveVideo) {
          [self saveVideo];
      }
      self.animateCircleView.hidden = YES;
      [self addPlayer:[NSURL fileURLWithPath:self.videoPath]];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.mainDownloadBtn sizeToFit];
    self.mainDownloadBtn.mm_width(65).mm_height(65).mm__centerX(self.mm_w / 2).mm__centerY(self.mm_h / 2);
    self.mainDownloadBtn.layer.cornerRadius = (self.mainDownloadBtn.mm_h * 0.5);
    self.animateCircleView.tui_mm_center();

    self.mainPlayBtn.mm_width(65).mm_height(65).mm__centerX(self.mm_w / 2).mm__centerY(self.mm_h / 2);
    self.closeBtn.mm_width(31).mm_height(31).mm_left(16).mm_bottom(47);
    self.downloadBtn.mm_width(31).mm_height(31).mm_right(16).mm_bottom(48);
    self.playBtn.mm_width(30).mm_height(30).mm_left(32).mm_bottom(108);
    self.playTime.mm_width(40).mm_height(21).mm_left(self.playBtn.mm_maxX + 12).mm__centerY(self.playBtn.mm_centerY);
    self.duration.mm_width(40).mm_height(21).mm_right(15).mm__centerY(self.playBtn.mm_centerY);
    self.playProcess.mm_sizeToFit()
        .mm_left(self.playTime.mm_maxX + 10)
        .mm_flexToRight(self.duration.mm_r + self.duration.mm_w + 10)
        .mm__centerY(self.playBtn.mm_centerY);
    self.scrollView.mm_width(self.mm_w).mm_height(self.mm_h).mm__centerX(self.mm_w / 2).mm__centerY(self.mm_h / 2);
    self.scrollView.videoViewNormalWidth = self.mm_w;
    self.scrollView.videoViewNormalHeight = self.mm_h;
    self.playerLayer.frame = self.scrollView.bounds;
    [self.scrollView.videoView.layer layoutIfNeeded];
}

- (void)addPlayer:(NSURL *)url {
    self.videoUrl = url;
    if (!self.player) {
        self.player = [AVPlayer playerWithURL:self.videoUrl];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.scrollView.videoView.bounds;
        [self.scrollView.videoView.layer insertSublayer:self.playerLayer atIndex:0];

        @weakify(self);
        [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.05, 30)
                                                  queue:NULL
                                             usingBlock:^(CMTime time) {
                                               @strongify(self);
                                               CGFloat curTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
                                               CGFloat duration = CMTimeGetSeconds(self.player.currentItem.duration);
                                               CGFloat progress = curTime / duration;
                                               [self.playProcess setValue:progress];
                                               self.playTime.text = [NSString stringWithFormat:@"%.2d:%.2d", (int)curTime / 60, (int)curTime % 60];
                                             }];
        [self addPlayerItemObserver];
    } else {
        [self removePlayerItemObserver];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.videoUrl];
        [self.player replaceCurrentItemWithPlayerItem:item];
        [self addPlayerItemObserver];
    }
}

- (void)addPlayerItemObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)removePlayerItemObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)stopVideoPlayAndSave {
    [self stopPlay];
    self.isSaveVideo = NO;
    [TUITool hideToast];
}

#pragma player event

- (void)onPlayBtnClick {
    if (![self.videoData isVideoExist]) {
        [self.videoData downloadVideo];
    } else {
        if (self.isPlay) {
            [self stopPlay];
        } else {
            [self play];
        }
    }
}

- (void)onCloseBtnClick {
    [self stopPlay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseMedia:)]) {
        [self.delegate onCloseMedia:self];
    }
}

- (void)onVideoPlayEnd {
    if (1 == self.playProcess.value) {
        [self.player seekToTime:CMTimeMakeWithSeconds(0, 30)];
        [self stopPlay];
    }
}

- (void)onSliderValueChangedBegin:(id)sender {
    [self.player pause];
}

- (void)onSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    CGFloat curTime = CMTimeGetSeconds(self.player.currentItem.duration) * slider.value;
    [self.player seekToTime:CMTimeMakeWithSeconds(curTime, 30)];
    [self play];
}

- (void)play {
    self.isPlay = YES;
    [self.player play];
    self.imageView.hidden = YES;
    self.mainPlayBtn.hidden = YES;
    [self.playBtn setImage:TUIChatCommonBundleImage(@"video_pause") forState:UIControlStateNormal];
}

- (void)stopPlay {
    BOOL hasRiskContent = self.videoData.innerMessage.hasRiskContent;
    self.isPlay = NO;
    [self.player pause];
    self.imageView.hidden = NO;
    if (!hasRiskContent) {
        self.mainPlayBtn.hidden = NO;
    }
    [self.playBtn setImage:TUIChatCommonBundleImage(@"video_play") forState:UIControlStateNormal];
}

- (void)mainDownloadBtnClick {
    if (![self.videoData isVideoExist]) {
        [self.videoData downloadVideo];
    }
}
#pragma video save
- (void)onDownloadBtnClick {
    if (![self.videoData isVideoExist]) {
        self.isSaveVideo = YES;
        [TUITool makeToast:TIMCommonLocalizableString(TUIKitVideoDownloading) duration:CGFLOAT_MAX];
    } else {
        [self saveVideo];
    }
}

- (void)saveVideo {
    [TUITool hideToast];
    [[PHPhotoLibrary sharedPhotoLibrary]
        performChanges:^{
          PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:self.videoPath]];
          request.creationDate = [NSDate date];
        }
        completionHandler:^(BOOL success, NSError *_Nullable error) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitVideoSavedSuccess) duration:1];
            } else {
                [TUITool makeToastError:-1 msg:TIMCommonLocalizableString(TUIKitVideoSavedFailed)];
            }
          });
        }];
}

- (void)onDeviceOrientationChange:(NSNotification *)noti {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self reloadAllView];
}

- (void)reloadAllView {
    if (self.player) {
        [self stopPlay];
        self.player = nil;
    }
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    for (UIView *subview in self.scrollView.subviews) {
        if (subview) {
            [subview removeFromSuperview];
        }
    }
    for (UIView *subview in self.subviews) {
        if (subview) {
            [subview removeFromSuperview];
        }
    }
    [self setupViews];
    if (self.videoData) {
        [self fillWithData:self.videoData];
    }
}
#pragma mark - TUIMessageProgressManagerDelegate
- (void)onUploadProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![msgID isEqualToString:self.videoData.msgID]) {
        return;
    }
    if (self.videoData.direction == MsgDirectionOutgoing) {
        self.videoData.uploadProgress = progress;
    }
}
#pragma mark - V2TIMAdvancedMsgListener
- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    V2TIMMessage *imMsg = msg;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }
    if ([self.videoData.innerMessage.msgID isEqualToString:imMsg.msgID]) {
        BOOL hasRiskContent = msg.hasRiskContent;
        if (hasRiskContent) {
            self.videoData.innerMessage = imMsg;
            [self showRiskAlert];
        }
    }
}

- (void)showRiskAlert {
    if (self.player) {
        [self stopPlay];
    }
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                message:TIMCommonLocalizableString(TUIKitVideoCheckRisk)
                                                         preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitVideoCheckRiskCancel)
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    [strongSelf reloadAllView];
                                                  }]];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}
@end
