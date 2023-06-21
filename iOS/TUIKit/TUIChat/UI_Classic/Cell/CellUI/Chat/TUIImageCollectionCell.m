
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIImageCollectionCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUITool.h>
#import "TUICircleLodingView.h"

@interface TUIImageCollectionCellScrollView : UIScrollView <UIScrollViewDelegate>
@property(nonatomic, strong) UIView *containerView;
@property(assign, nonatomic) CGFloat imageNormalWidth;
@property(assign, nonatomic) CGFloat imageNormalHeight;
- (void)pictureZoomWithScale:(CGFloat)zoomScale;

@end

@implementation TUIImageCollectionCellScrollView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 2.0f;
        _imageNormalHeight = frame.size.height;
        _imageNormalWidth = frame.size.width;
        self.containerView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.containerView];
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
    CGFloat imageScaleWidth = zoomScale * self.imageNormalWidth;
    CGFloat imageScaleHeight = zoomScale * self.imageNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.containerView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    self.contentSize = CGSizeMake(imageScaleWidth, imageScaleHeight);
}

#pragma mark-- Setter

- (void)setImageNormalWidth:(CGFloat)imageNormalWidth {
    _imageNormalWidth = imageNormalWidth;
    self.containerView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
    self.containerView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void)setImageNormalHeight:(CGFloat)imageNormalHeight {
    _imageNormalHeight = imageNormalHeight;
    self.containerView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
    self.containerView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

#pragma mark-- UIScrollViewDelegate

// Returns the view control that needs to be zoomed. During zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
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
    CGFloat imageScaleWidth = scrollView.zoomScale * self.imageNormalWidth;
    CGFloat imageScaleHeight = scrollView.zoomScale * self.imageNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.containerView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
}

@end

@interface TUIImageCollectionCell ()
@property(nonatomic, strong) TUIImageCollectionCellScrollView *scrollView;
@property(nonatomic, strong) TUIImageMessageCellData *imgCellData;
@property(nonatomic, strong) UIButton *mainDownloadBtn;
@property(nonatomic, strong) TUICircleLodingView *animateCircleView;

@end

@implementation TUIImageCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupRotaionNotifications];
    }
    return self;
}

- (void)setupViews {
    self.scrollView = [[TUIImageCollectionCellScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.layer.cornerRadius = 5.0;
    [self.imageView.layer setMasksToBounds:YES];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.scrollView.containerView addSubview:self.imageView];
    self.imageView.mm_fill();
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.mainDownloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mainDownloadBtn.contentMode = UIViewContentModeScaleToFill;
    [self.mainDownloadBtn setTitle:TIMCommonLocalizableString(TUIKitImageViewOrigin) forState:UIControlStateNormal];
    self.mainDownloadBtn.backgroundColor = [UIColor grayColor];
    [self.mainDownloadBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    self.mainDownloadBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mainDownloadBtn.layer.cornerRadius = .16;
    self.mainDownloadBtn.hidden = YES;
    [self.mainDownloadBtn addTarget:self action:@selector(mainDownloadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mainDownloadBtn];

    self.downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadBtn.contentMode = UIViewContentModeScaleToFill;
    [self.downloadBtn setImage:TUIChatCommonBundleImage(@"download") forState:UIControlStateNormal];
    [self.downloadBtn addTarget:self action:@selector(onSaveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.downloadBtn];

    self.animateCircleView = [[TUICircleLodingView alloc] initWithFrame:CGRectMake(0, 0, kScale390(40), kScale390(40))];
    self.animateCircleView.hidden = YES;
    self.animateCircleView.progress = 0;
    [self addSubview:_animateCircleView];

    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMedia)];
    [self addGestureRecognizer:tap];
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
- (void)mainDownloadBtnClick {
    if (self.imgCellData.originImage == nil) {
        [self.imgCellData downloadImage:TImage_Type_Origin];
    }
}
- (void)onSaveBtnClick {
    UIImage *image = self.imageView.image;
    [[PHPhotoLibrary sharedPhotoLibrary]
        performChanges:^{
          [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        }
        completionHandler:^(BOOL success, NSError *_Nullable error) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitPictureSavedSuccess)];
            } else {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitPictureSavedFailed)];
            }
          });
        }];
}

- (void)onSelectMedia {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseMedia:)]) {
        [self.delegate onCloseMedia:self];
    }
}

- (void)fillWithData:(TUIImageMessageCellData *)data;
{
    [super fillWithData:data];
    self.imgCellData = data;
    self.imageView.image = nil;
    if (data.thumbImage == nil) {
        [data downloadImage:TImage_Type_Thumb];
    }
    if (data.thumbImage && data.largeImage == nil) {
        self.animateCircleView.hidden = NO;
        [data downloadImage:TImage_Type_Large];
    }

    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
      @strongify(self);
      if (thumbImage) {
          self.imageView.image = thumbImage;
      }
    }];

    // largeImage
    [[RACObserve(data, largeImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *largeImage) {
      @strongify(self);
      if (largeImage) {
          self.imageView.image = largeImage;
      }
    }];
    [[[RACObserve(data, largeProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      int progress = [x intValue];
      if (progress == 100) {
          self.animateCircleView.progress = 99;
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.animateCircleView.progress = 100;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              self.animateCircleView.progress = 0;
              self.mainDownloadBtn.hidden = NO;
              self.animateCircleView.hidden = YES;
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

    // originImage
    [[RACObserve(data, originImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *originImage) {
      @strongify(self);
      if (originImage) {
          self.imageView.image = originImage;
      }
    }];
    [[[RACObserve(data, originProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
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
              [self.mainDownloadBtn setTitle:TIMCommonLocalizableString(TUIKitImageViewOrigin) forState:UIControlStateNormal];
            });
          });
      } else if (progress > 1 && progress < 100) {
          self.animateCircleView.progress = progress;
          [self.mainDownloadBtn setTitle:[NSString stringWithFormat:@"%d%%", progress] forState:UIControlStateNormal];
          self.animateCircleView.hidden = YES;
      } else {
          self.animateCircleView.progress = progress;
      }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.mainDownloadBtn sizeToFit];
    self.mainDownloadBtn.mm_width(self.mainDownloadBtn.mm_w + 10).mm_height(self.mainDownloadBtn.mm_h).mm__centerX(self.mm_w / 2).mm_bottom(48);
    self.mainDownloadBtn.layer.cornerRadius = (self.mainDownloadBtn.mm_h * 0.5);
    self.animateCircleView.tui_mm_center();
    self.downloadBtn.mm_width(31).mm_height(31).mm_right(16).mm_bottom(48);
    self.scrollView.mm_width(self.mm_w).mm_height(self.mm_h).mm__centerX(self.mm_w / 2).mm__centerY(self.mm_h / 2);
    self.scrollView.imageNormalWidth = self.mm_w;
    self.scrollView.imageNormalHeight = self.mm_h;
    self.imageView.frame = self.scrollView.bounds;
    [self.imageView layoutIfNeeded];
}

- (void)onDeviceOrientationChange:(NSNotification *)noti {
    for (UIView *subview in self.subviews) {
        if (subview) {
            [subview removeFromSuperview];
        }
    }
    [self setupViews];
    [self fillWithData:self.imgCellData];
}

@end
