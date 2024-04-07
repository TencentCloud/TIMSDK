
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIVideoCollectionCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import "ReactiveObjC/ReactiveObjC.h"

@import MediaPlayer;
@import AVFoundation;
@import AVKit;

@interface TUIVideoCollectionCell_Minimalist ()
@property(nonatomic, strong) UILabel *duration;
@property(nonatomic, strong) UILabel *playTime;
@property(nonatomic, strong) UISlider *playProcess;
@property(nonatomic, strong) UIButton *mainPlayBtn;
@property(nonatomic, strong) UIButton *playBtn;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) NSString *videoPath;
@property(nonatomic, strong) NSURL *videoUrl;
@property(nonatomic, assign) BOOL isPlay;
@property(nonatomic, assign) BOOL isSaveVideo;
@property(nonatomic, strong) TUIVideoMessageCellData *videoData;
@end

@implementation TUIVideoCollectionCell_Minimalist
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.layer.cornerRadius = 5.0;
    [self.imageView.layer setMasksToBounds:YES];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
    self.imageView.mm_fill();
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.mainPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mainPlayBtn.contentMode = UIViewContentModeScaleToFill;
    [self.mainPlayBtn setImage:TUIChatCommonBundleImage(@"video_play_big") forState:UIControlStateNormal];
    [self.mainPlayBtn addTarget:self action:@selector(onPlayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mainPlayBtn];

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
        /**
         * Undownloaded videos play using online url
         */
        [self.videoData getVideoUrl:^(NSString *_Nonnull url) {
          @strongify(self);
          if (url) {
              [self addPlayer:[NSURL URLWithString:url]];
          }
        }];
        /**
         * Download video asynchronously
         */
        [self.videoData downloadVideo];
    } else {
        /**
         * Downloaded videos can be played directly using local video files
         */
        self.videoPath = self.videoData.videoPath;
        if (self.videoPath) {
            [self addPlayer:[NSURL fileURLWithPath:self.videoPath]];
        }
    }

    [[[RACObserve(self.videoData, videoPath) filter:^BOOL(NSString *path) {
      return [path length] > 0;
    }] take:1] subscribeNext:^(NSString *path) {
      @strongify(self);
      self.videoPath = path;
      if (self.isSaveVideo) {
          [self saveVideo];
      }

      /**
       * If it has not been played, or the playback is wrong, switch from online playback to local playback
       */
      if (self.player.status == AVPlayerStatusFailed || self.player.status == AVPlayerStatusReadyToPlay) {
          [self addPlayer:[NSURL fileURLWithPath:self.videoPath]];
      }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
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
}

- (void)addPlayer:(NSURL *)url {
    self.videoUrl = url;
    if (!self.player) {
        self.player = [AVPlayer playerWithURL:self.videoUrl];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = self.bounds;
        [self.layer insertSublayer:playerLayer atIndex:0];

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
    if (self.isPlay) {
        [self stopPlay];
    } else {
        [self play];
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
    self.isPlay = NO;
    [self.player pause];
    self.mainPlayBtn.hidden = NO;
    [self.playBtn setImage:TUIChatCommonBundleImage(@"video_play") forState:UIControlStateNormal];
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
@end
