
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUICameraView.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUICaptureTimer.h"

static CGFloat gPhotoBtnZoomInRatio = 1.125;
static CGFloat gProgressLayerLineWidth = 5.0;

@interface TUICameraView ()

@property(nonatomic) UIView *contentView;
@property(nonatomic) UIButton *switchCameraButton;
@property(nonatomic) UIButton *closeButton;
@property(nonatomic, strong) UIButton *pictureLibButton;
@property(nonatomic) UIView *focusView;
@property(nonatomic) UISlider *slider;
@property(nonatomic) UIView *photoBtn;
@property(nonatomic) UIView *photoStateView;
@property(nonatomic) UILongPressGestureRecognizer *longPress;
@property(nonatomic) CGRect lastRect;

@property(nonatomic) CAShapeLayer *progressLayer;

@property(nonatomic) TUICaptureTimer *timer;
@property(nonatomic) BOOL isVideoRecording;

@end

@implementation TUICameraView

@synthesize previewView = _previewView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = TUICameraMediaTypePhoto;
        self.aspectRatio = TUICameraViewAspectRatio16x9;
        self.backgroundColor = [UIColor blackColor];
        self.maxVideoCaptureTimeLimit = 15.0;
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.previewView];
    [self.contentView addSubview:self.switchCameraButton];
    [self.contentView addSubview:self.photoBtn];
    [self.contentView addSubview:self.closeButton];
    [self.contentView addSubview:self.pictureLibButton];
    [self.previewView addSubview:self.focusView];
    [self.previewView addSubview:self.slider];

    self.timer = ({
        TUICaptureTimer *timer = [TUICaptureTimer new];
        timer.maxCaptureTime = self.maxVideoCaptureTimeLimit;
        __weak __typeof(self) weakSelf = self;
        timer.progressBlock = ^(CGFloat ratio, CGFloat recordTime) {
          weakSelf.progress = ratio;
        };
        timer.progressFinishBlock = ^(CGFloat ratio, CGFloat recordTime) {
          weakSelf.progress = 1;
          self.longPress.enabled = NO;
          [weakSelf endVideoRecordWithCaptureDuration:recordTime];
          self.longPress.enabled = YES;
        };
        timer.progressCancelBlock = ^{
          weakSelf.progress = 0;
        };
        timer;
    });

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.previewView addGestureRecognizer:tap];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.previewView addGestureRecognizer:pinch];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!CGRectEqualToRect(self.lastRect, self.bounds)) {
        [self setupUI];

        self.lastRect = self.bounds;
        self.contentView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

        CGFloat previewViewWidth = self.contentView.bounds.size.width;
        CGFloat previewViewHeight;
        switch (self.aspectRatio) {
            case TUICameraViewAspectRatio1x1:
                previewViewHeight = previewViewWidth;
                break;
            case TUICameraViewAspectRatio16x9:
                previewViewHeight = previewViewWidth * (16.0 / 9.0);
                break;
            case TUICameraViewAspectRatio5x4:
                previewViewHeight = previewViewWidth * (5.0 / 4.0);
                break;
            default:
                break;
        }
        CGFloat previewViewY = (self.contentView.bounds.size.height - previewViewHeight) / 2.0;
        self.previewView.frame = CGRectMake(0, previewViewY, self.contentView.bounds.size.width, previewViewHeight);

        CGFloat switchCameraButtonWidth = 44.0;
        self.switchCameraButton.frame =
            CGRectMake(self.contentView.bounds.size.width - switchCameraButtonWidth - 16.0, 30.0, switchCameraButtonWidth, switchCameraButtonWidth);

        if (isRTL()) {
            [self.switchCameraButton resetFrameToFitRTL];
        }
        
        CGFloat photoBtnWidth = 100.0;
        self.photoBtn.frame = CGRectMake((self.contentView.bounds.size.width - photoBtnWidth) / 2.0, self.contentView.bounds.size.height - photoBtnWidth - 30,
                                         photoBtnWidth, photoBtnWidth);
        self.photoBtn.layer.cornerRadius = photoBtnWidth / 2.0;

        CGFloat distanceToPhotoBtn = 10.0;
        CGFloat photoStateViewWidth = photoBtnWidth - 2 * distanceToPhotoBtn;
        self.photoStateView.frame = CGRectMake(distanceToPhotoBtn, distanceToPhotoBtn, photoStateViewWidth, photoStateViewWidth);
        self.photoStateView.layer.cornerRadius = photoStateViewWidth / 2.0;

        if (self.type == TUICameraMediaTypeVideo) {
            self.progressLayer.frame = CGRectInset(self.photoBtn.bounds, gProgressLayerLineWidth / 2.0, gProgressLayerLineWidth / 2.0);

            CGFloat radius = self.progressLayer.bounds.size.width / 2;
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                                radius:radius
                                                            startAngle:-M_PI_2
                                                              endAngle:-M_PI_2 + M_PI * 2
                                                             clockwise:YES];
            self.progressLayer.path = path.CGPath;
            [self.photoBtn.layer addSublayer:self.progressLayer];
        }

        CGFloat closeButtonWidth = 30.0;
        CGFloat closeButtonX = (self.photoBtn.frame.origin.x - closeButtonWidth) / 2.0;
        CGFloat closeButtonY = self.photoBtn.center.y - closeButtonWidth / 2.0;
        self.closeButton.frame = CGRectMake(closeButtonX, closeButtonY, closeButtonWidth, closeButtonWidth);
        if (isRTL()) {
            [self.closeButton resetFrameToFitRTL];
        }
        CGFloat pictureButtonWidth = 30.0;

        self.pictureLibButton.frame = CGRectMake(self.contentView.frame.size.width - closeButtonX, closeButtonY, pictureButtonWidth, pictureButtonWidth);
        if (isRTL()) {
            [self.pictureLibButton resetFrameToFitRTL];
        }
        self.slider.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.slider.frame = CGRectMake(self.bounds.size.width - 50, 50, 15, 200);
    }
}

#pragma mark -

- (void)setProgress:(CGFloat)progress {
    if (progress < 0) {
        return;
    } else if (progress < 1.0) {
        self.progressLayer.strokeEnd = progress;
    }

    if (progress >= 1.0) {
        self.progressLayer.strokeEnd = 1.0;
    }
}

#pragma mark - Event Response
- (void)tapAction:(UIGestureRecognizer *)tap {
    if ([_delegate respondsToSelector:@selector(focusAction:point:handle:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.focusView point:point];
        [_delegate focusAction:self
                         point:[self.previewView captureDevicePointForPoint:point]
                        handle:^(NSError *error) {
                          if (error) NSAssert1(NO, @"%@", error);  //[self showError:error];
                        }];
    }
}

- (void)runFocusAnimation:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f
        delay:0.0f
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        }
        completion:^(BOOL complete) {
          double delayInSeconds = 0.5f;
          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
          dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
          });
        }];
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    if ([_delegate respondsToSelector:@selector(zoomAction:factor:)]) {
        if (pinch.state == UIGestureRecognizerStateBegan) {
            [UIView animateWithDuration:0.1
                             animations:^{
                               self->_slider.alpha = 1;
                             }];
        } else if (pinch.state == UIGestureRecognizerStateChanged) {
            if (pinch.velocity > 0) {
                _slider.value += pinch.velocity / 100;
            } else {
                _slider.value += pinch.velocity / 20;
            }
            [_delegate zoomAction:self factor:powf(5, _slider.value)];
        } else {
            [UIView animateWithDuration:0.1
                             animations:^{
                               self->_slider.alpha = 0.0;
                             }];
        }
    }
}

- (void)switchCameraButtonClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(swicthCameraAction:handle:)]) {
        [self.delegate swicthCameraAction:self
                                   handle:^(NSError *_Nonnull error){
                                       //
                                   }];
    }
}

- (void)closeButtonClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(cancelAction:)]) {
        [self.delegate cancelAction:self];
    }
}

- (void)pictureLibClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(pictureLibAction:)]) {
        [self.delegate pictureLibAction:self];
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self beginVideoRecord];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self endVideoRecordWithCaptureDuration:self.timer.captureDuration];
            break;
        }
        default:
            break;
    }
}

- (void)beginVideoRecord {
    if (self.isVideoRecording) {
        return;
    }

    self.closeButton.hidden = YES;

    self.isVideoRecording = YES;

    self.pictureLibButton.hidden = YES;

    [self.timer startTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
      self.progressLayer.strokeEnd = 0.0;
      [UIView animateWithDuration:0.2
                       animations:^{
                         self.photoStateView.transform = CGAffineTransformMakeScale(.5, .5);
                         self.photoBtn.transform = CGAffineTransformMakeScale(gPhotoBtnZoomInRatio, gPhotoBtnZoomInRatio);
                       }];

      if ([self.delegate respondsToSelector:@selector(startRecordVideoAction:)]) {
          [self.delegate startRecordVideoAction:self];
      }
    });
}

- (void)endVideoRecordWithCaptureDuration:(CGFloat)duration {
    if (self.isVideoRecording == NO) {
        return;
    }

    self.closeButton.hidden = NO;

    self.isVideoRecording = NO;

    self.pictureLibButton.hidden = NO;

    [self.timer stopTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
      [UIView animateWithDuration:0.2
                       animations:^{
                         self.photoStateView.transform = CGAffineTransformIdentity;
                         self.photoBtn.transform = CGAffineTransformIdentity;
                       }];

      if ([self.delegate respondsToSelector:@selector(stopRecordVideoAction:RecordDuration:)]) {
          [self.delegate stopRecordVideoAction:self RecordDuration:duration];
      }

      self.progressLayer.strokeEnd = 0.0;
    });
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture {
    if ([_delegate respondsToSelector:@selector(takePhotoAction:)]) {
        [_delegate takePhotoAction:self];
    }
}

#pragma mark - Getters & Setters
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
    }
    return _contentView;
}

- (TUICaptureVideoPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[TUICaptureVideoPreviewView alloc] init];
        _previewView.userInteractionEnabled = YES;
    }
    return _previewView;
}

- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *switchCameraButtonImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camera_switchCamera")];
        [_switchCameraButton setImage:switchCameraButtonImage forState:UIControlStateNormal];
        [_switchCameraButton addTarget:self action:@selector(switchCameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *closeButtonImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camera_back")];
        [_closeButton setBackgroundImage:[closeButtonImage rtl_imageFlippedForRightToLeftLayoutDirection] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)pictureLibButton {
    if (!_pictureLibButton) {
        _pictureLibButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *pictureImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"more_picture")];
        [_pictureLibButton setBackgroundImage:pictureImage forState:UIControlStateNormal];
        [_pictureLibButton addTarget:self action:@selector(pictureLibClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pictureLibButton;
}

- (UIView *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [UIView new];
        [_photoBtn setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
        if (self.type == TUICameraMediaTypeVideo) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
            [_photoBtn addGestureRecognizer:longPress];
            _longPress = longPress;
        }
        if (self.type == TUICameraMediaTypePhoto) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            [_photoBtn addGestureRecognizer:tapGesture];
        }
        _photoBtn.userInteractionEnabled = YES;

        _photoStateView = [UIView new];
        _photoStateView.backgroundColor = [UIColor whiteColor];
        [_photoBtn addSubview:_photoStateView];
    }
    return _photoBtn;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineWidth = gProgressLayerLineWidth;
        _progressLayer.strokeColor = [UIColor colorWithRed:0 green:204.0 / 255 blue:0 alpha:1].CGColor;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        _progressLayer.lineCap = kCALineCapButt;
    }
    return _progressLayer;
}

- (UIView *)focusView {
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor colorWithRed:0 green:204.0 / 255 blue:0 alpha:1].CGColor;
        _focusView.layer.borderWidth = 3.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (UISlider *)slider {
    if (_slider == nil) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        _slider.maximumTrackTintColor = [UIColor whiteColor];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        _slider.alpha = 0.0;
        _slider.hidden = YES;
    }
    return _slider;
}

@end
