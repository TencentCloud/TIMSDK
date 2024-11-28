//
//  TUIPhotoPreviewCell.m
//  TUIPhotoPreviewCell
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import "TUIPhotoPreviewCell.h"
#import "TUIMultimediaNavController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <TUICore/UIView+TUILayout.h>
#import <TIMCommon/TIMDefine.h>
#import <TUIMultimediaCore/TUIAssetModel.h>
#import <TUIMultimediaCore/TUIImageManager.h>
#import <TUIMultimediaCore/TUIProgressView.h>

@implementation TUIAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self configSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    }
    return self;
}

- (void)configSubviews {
    // Subclass override
}

#pragma mark - Notification

- (void)photoPreviewCollectionViewDidScroll {
    // Subclass override
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation TUIPhotoPreviewCell

- (void)configSubviews {
    self.previewView = [[TUIPhotoPreviewView alloc] initWithFrame:CGRectZero];
    @weakify(self)
    [self.previewView setSingleTapGestureBlock:^{
        @strongify(self)
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
        }
    }];
    [self.previewView setImageProgressUpdateBlock:^(double progress) {
        @strongify(self)
        if (self.imageProgressUpdateBlock) {
            self.imageProgressUpdateBlock(progress);
        }
    }];
    [self.contentView addSubview:self.previewView];
}

- (void)setModel:(TUIAssetModel *)model {
    [super setModel:model];
    self.previewView.model = model;
}

- (void)recoverSubviews {
    [self.previewView recoverSubviews];
}

- (void)setScaleAspectFillCrop:(BOOL)scaleAspectFillCrop {
    _scaleAspectFillCrop = scaleAspectFillCrop;
    self.previewView.scaleAspectFillCrop = scaleAspectFillCrop;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    self.previewView.cropRect = cropRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

@end


@interface TUIPhotoPreviewView ()<UIScrollViewDelegate>
@property (assign, nonatomic) BOOL isRequestingGIF;
@end

@implementation TUIPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.bouncesZoom = YES;
        self.scrollView.maximumZoomScale = 4;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.multipleTouchEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = YES;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.delaysContentTouches = NO;
        self.scrollView.canCancelContentTouches = YES;
        self.scrollView.alwaysBounceVertical = NO;
        if (@available(iOS 11, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.scrollView];
        
        self.imageContainerView = [[UIView alloc] init];
        self.imageContainerView.clipsToBounds = YES;
        self.imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.imageContainerView];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.imageContainerView addSubview:self.imageView];

        self.iCloudErrorIcon = [[UIImageView alloc] init];
        self.iCloudErrorIcon.image = [UIImage tui_imageNamedFromMyBundle:@"iCloudError"];
        self.iCloudErrorIcon.hidden = YES;
        [self addSubview:self.iCloudErrorIcon];
        
        self.iCloudErrorLabel = [[UILabel alloc] init];
        self.iCloudErrorLabel.font = [UIFont systemFontOfSize:10];
        self.iCloudErrorLabel.textColor = [UIColor whiteColor];
        self.iCloudErrorLabel.text = [NSBundle tui_localizedStringForKey:@"iCloud sync failed"];
        self.iCloudErrorLabel.hidden = YES;
        [self addSubview:self.iCloudErrorLabel];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
        self.progressView = [[TUIProgressView alloc] init];
        self.progressView.hidden = YES;
        [self addSubview:self.progressView];
    }
    return self;
}

- (void)setModel:(TUIAssetModel *)model {
    _model = model;
    self.isRequestingGIF = NO;
    [self.scrollView setZoomScale:1.0 animated:NO];
    if (TUIAssetMediaTypePhotoGif == model.type) {
        // Show thumbnails first
        [[TUIImageManager defaultManager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (photo) {
                self.imageView.image = photo;
            }
            [self resizeSubviews];
            if (self.isRequestingGIF) {
                return;
            }
            // Show gif
            self.isRequestingGIF = YES;
            [[TUIImageManager defaultManager] getOriginalPhotoDataWithAsset:model.asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                progress = progress > 0.02 ? progress : 0.02;
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL iCloudSyncFailed = [TUICommonTools isICloudSyncError:error];
                    self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
                    self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
                    if (self.iCloudSyncFailedHandle) {
                        self.iCloudSyncFailedHandle(model.asset, iCloudSyncFailed);
                    }
                    
                    self.progressView.progress = progress;
                    if (progress >= 1) {
                        self.progressView.hidden = YES;
                    } else {
                        self.progressView.hidden = NO;
                    }
                });
#ifdef DEBUG
                NSLog(@"[TUIMultimediaNavController] getOriginalPhotoDataWithAsset:%f error:%@", progress, error);
#endif
            } completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    self.isRequestingGIF = NO;
                    self.progressView.hidden = YES;
                    self.imageView.image = [UIImage tui_animatedGIFWithData:data];
                    [self resizeSubviews];
                }
            }];
        } progressHandler:nil networkAccessAllowed:NO];
    } else {
        self.asset = model.asset;
    }
}

- (void)setAsset:(PHAsset *)asset {
    if (_asset && self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    
    _asset = asset;
    @weakify(self)
    self.imageRequestID = [[TUIImageManager defaultManager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        @strongify(self)
        BOOL iCloudSyncFailed = !photo && [TUICommonTools isICloudSyncError:info[PHImageErrorKey]];
        self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
        self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
        if (self.iCloudSyncFailedHandle) {
            self.iCloudSyncFailedHandle(asset, iCloudSyncFailed);
        }
        if (![asset isEqual:self->_asset]) return;
        if (photo) {
            self.imageView.image = photo;
        }
        [self resizeSubviews];
        
        self.progressView.hidden = YES;
        if (self.imageProgressUpdateBlock) {
            self.imageProgressUpdateBlock(1);
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        @strongify(self)
        if (![asset isEqual:self->_asset]) return;
        self.progressView.hidden = NO;
        [self bringSubviewToFront:self.progressView];
        progress = progress > 0.02 ? progress : 0.02;
        self.progressView.progress = progress;
        if (self.imageProgressUpdateBlock && progress < 1) {
            self.imageProgressUpdateBlock(progress);
        }
        
        if (progress >= 1) {
            self.progressView.hidden = YES;
            self.imageRequestID = 0;
        }
    } networkAccessAllowed:YES];
    
    [self configMaximumZoomScale];
}

- (void)recoverSubviews {
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    self.imageContainerView.mm_origin = CGPointZero;
    self.imageContainerView.mm_w = self.scrollView.mm_w;
    
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.mm_h / self.scrollView.mm_w) {
        CGFloat width = image.size.width / image.size.height * self.scrollView.mm_h;
        if (width < 1 || isnan(width)) width = self.mm_w;
        width = floor(width);
        
        self.imageContainerView.mm_w = width;
        self.imageContainerView.mm_h = self.mm_h;
        self.imageContainerView.mm_centerX = self.scrollView.mm_w  / 2;
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.mm_w;
        if (height < 1 || isnan(height)) height = self.mm_h;
        height = floor(height);
        self.imageContainerView.mm_h = height;
        self.imageContainerView.mm_centerY = self.mm_h / 2;
    }
    if (self.imageContainerView.mm_h > self.mm_h && self.imageContainerView.mm_h - self.mm_h <= 1) {
        self.imageContainerView.mm_h = self.mm_h;
    }
    CGFloat contentSizeH = MAX(self.imageContainerView.mm_h, self.mm_h);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.mm_w, contentSizeH);
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.imageContainerView.mm_h <= self.mm_h ? NO : YES;
    self.imageView.frame = self.imageContainerView.bounds;
    
    [self refreshScrollViewContentSize];
}

- (void)configMaximumZoomScale {
    self.scrollView.maximumZoomScale = 4.0;
    
    if ([self.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)self.asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        if (aspectRatio > 1.5) {
            self.scrollView.maximumZoomScale *= aspectRatio / 1.5;
        }
    }
}

- (void)refreshScrollViewContentSize {
    // to do
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(10, 0, self.mm_w - 20, self.mm_h);
    static CGFloat progressWH = 40;
    CGFloat progressX = (self.mm_w - progressWH) / 2;
    CGFloat progressY = (self.mm_h - progressWH) / 2;
    self.progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    [self recoverSubviews];
    self.iCloudErrorIcon.frame = CGRectMake(20, [TUICommonTools tui_statusBarHeight] + 44 + 10, 28, 28);
    self.iCloudErrorLabel.frame = CGRectMake(53, [TUICommonTools tui_statusBarHeight] + 44 + 10, self.mm_w - 63, 28);
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = MIN(self.scrollView.maximumZoomScale, 2.5);
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentSize];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (self.scrollView.mm_w > self.scrollView.contentSize.width) ? ((self.scrollView.mm_w - self.scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (self.scrollView.mm_h > self.scrollView.contentSize.height) ? ((self.scrollView.mm_h - self.scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);
}

@end


@implementation TUIVideoPreviewCell

- (void)configSubviews {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    self.iCloudErrorIcon = [[UIImageView alloc] init];
    self.iCloudErrorIcon.image = [UIImage tui_imageNamedFromMyBundle:@"iCloudError"];
    self.iCloudErrorIcon.hidden = YES;
    self.iCloudErrorLabel = [[UILabel alloc] init];
    self.iCloudErrorLabel.font = [UIFont systemFontOfSize:10];
    self.iCloudErrorLabel.textColor = [UIColor whiteColor];
    self.iCloudErrorLabel.text = [NSBundle tui_localizedStringForKey:@"iCloud sync failed"];
    self.iCloudErrorLabel.hidden = YES;
}

- (void)configPlayButton {
    if (self.playButton) {
        [self.playButton removeFromSuperview];
    }
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage tui_imageNamedFromMyBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage tui_imageNamedFromMyBundle:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
    [self.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.frame = CGRectMake(0, 64, self.mm_w, self.mm_h - 64 - 44);
    [self.contentView addSubview:self.playButton];
    [self.contentView addSubview:self.iCloudErrorIcon];
    [self.contentView addSubview:self.iCloudErrorLabel];
}

- (void)setModel:(TUIAssetModel *)model {
    [super setModel:model];
    [self configMoviePlayer];
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    if (self.player) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        [self.player pause];
        self.player = nil;
    }
    //有编辑时,优先使用编辑的url 和 Image
    if (self.model.editurl) {
        if (self.model.editImage) {
            self.cover = self.model.editImage;
        }
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.model.editurl];
        [self configPlayerWithItem:playerItem];
    }
    else {
        if (self.model && self.model.asset) {
            [[TUIImageManager defaultManager] getPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                BOOL iCloudSyncFailed = !photo && [TUICommonTools isICloudSyncError:info[PHImageErrorKey]];
                self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
                self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
                if (self.iCloudSyncFailedHandle) {
                    self.iCloudSyncFailedHandle(self.model.asset, iCloudSyncFailed);
                }
                if (photo) {
                    self.cover = photo;
                }
            }];
            [[TUIImageManager defaultManager] getVideoWithAsset:self.model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL iCloudSyncFailed = !playerItem && [TUICommonTools isICloudSyncError:info[PHImageErrorKey]];
                    self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
                    self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
                    if (self.iCloudSyncFailedHandle) {
                        self.iCloudSyncFailedHandle(self.model.asset, iCloudSyncFailed);
                    }
                    [self configPlayerWithItem:playerItem];
                });
            }];
        } else {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
            [self configPlayerWithItem:playerItem];
        }
    }
    
}

- (void)configPlayerWithItem:(AVPlayerItem *)playerItem {
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.frame = self.bounds;
    [self.contentView.layer addSublayer:self.playerLayer];
    [self configPlayButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.playButton.frame = CGRectMake(0, 64, self.mm_w, self.mm_h - 64 - 44);
    self.iCloudErrorIcon.frame = CGRectMake(20, [TUICommonTools tui_statusBarHeight] + 44 + 10, 28, 28);
    self.iCloudErrorLabel.frame = CGRectMake(53, [TUICommonTools tui_statusBarHeight] + 44 + 10, self.mm_w - 63, 28);
}

- (void)photoPreviewCollectionViewDidScroll {
    if (self.player && self.player.rate != 0.0) {
        [self pausePlayerAndShowNaviBar];
    }
}

#pragma mark - Notification

- (void)appWillResignActiveNotification {
    if (self.player && self.player.rate != 0.0) {
        [self pausePlayerAndShowNaviBar];
    }
}

#pragma mark - Click Event

- (void)playButtonClick {
    CMTime currentTime = self.player.currentItem.currentTime;
    CMTime durationTime = self.player.currentItem.duration;
    if (self.player.rate == 0.0f) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TZ_VIDEO_PLAY_NOTIFICATION" object:self.player];
        if (currentTime.value == durationTime.value) [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
        [self.player play];
        [self.playButton setImage:nil forState:UIControlStateNormal];
        [UIApplication sharedApplication].statusBarHidden = YES;
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
        }
    } else {
        [self pausePlayerAndShowNaviBar];
    }
}

- (void)pausePlayerAndShowNaviBar {
    [self.player pause];
    [self.playButton setImage:[UIImage tui_imageNamedFromMyBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

@end


@implementation TUIGifPreviewCell

- (void)configSubviews {
    [self configPreviewView];
}

- (void)configPreviewView {
    _previewView = [[TUIPhotoPreviewView alloc] initWithFrame:CGRectZero];
    @weakify(self)
    [_previewView setSingleTapGestureBlock:^{
        @strongify(self)
        [self signleTapAction];
    }];
    [self.contentView addSubview:_previewView];
}

- (void)setModel:(TUIAssetModel *)model {
    [super setModel:model];
    _previewView.model = self.model;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _previewView.frame = self.bounds;
}

#pragma mark - Click Event

- (void)signleTapAction {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

@end
