
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUICameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMMetadata.h>
#import <Photos/Photos.h>

#import "TUICameraView.h"
#import "TUICaptureImagePreviewController.h"
#import "TUICaptureVideoPreviewViewController.h"

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUICameraManager.h"
#import "TUICaptureTimer.h"
#import "TUIMotionManager.h"
#import "TUIMovieManager.h"

@interface TUICameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, TUICameraViewDelegate> {
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_deviceInput;

    AVCaptureConnection *_videoConnection;
    AVCaptureConnection *_audioConnection;
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureStillImageOutput *_imageOutput;

    BOOL _recording;
}

@property(nonatomic, strong) TUICameraView *cameraView;
@property(nonatomic, strong) TUIMovieManager *movieManager;
@property(nonatomic, strong) TUICameraManager *cameraManager;
@property(nonatomic, strong) TUIMotionManager *motionManager;
@property(nonatomic, strong) AVCaptureDevice *activeCamera;
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;

@property(nonatomic) BOOL isFirstShow;
@property(nonatomic) BOOL lastPageBarHidden;
@end

@implementation TUICameraViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _motionManager = [[TUIMotionManager alloc] init];
        _cameraManager = [[TUICameraManager alloc] init];

        _type = TUICameraMediaTypePhoto;
        _aspectRatio = TUICameraViewAspectRatio16x9;
        _videoMaximumDuration = 15.0;
        _videoMinimumDuration = 3.0;
        _isFirstShow = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cameraView = [[TUICameraView alloc] initWithFrame:self.view.bounds];
    self.cameraView.type = self.type;
    self.cameraView.aspectRatio = self.aspectRatio;
    self.cameraView.delegate = self;
    self.cameraView.maxVideoCaptureTimeLimit = self.videoMaximumDuration;
    [self.view addSubview:self.cameraView];

    NSError *error;
    [self setupSession:&error];
    if (!error) {
        [self.cameraView.previewView setCaptureSessionsion:_session];
        [self startCaptureSession];
    } else {
        //        NSAssert1(NO, @"Camera Initialize Failed : %@", error.localizedDescription);
        //        [self showErrorStr:error.localizedDescription];
    }
}

- (void)dealloc {
    [self stopCaptureSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.isFirstShow) {
        self.isFirstShow = NO;
        self.lastPageBarHidden = self.navigationController.navigationBarHidden;
    }
    self.navigationController.navigationBarHidden = YES;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        self.navigationController.navigationBarHidden = self.lastPageBarHidden;
    }
}

#pragma mark - - Input Device
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    return _deviceInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

#pragma mark - - Configuration
- (void)setupSession:(NSError **)error {
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetHigh;

    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

- (void)setupSessionInputs:(NSError **)error {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
        }
    }
    _deviceInput = videoInput;
    if (_type == TUICameraMediaTypeVideo) {
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:error];
        if ([_session canAddInput:audioIn]) {
            [_session addInput:audioIn];
        }
    }
}

- (void)setupSessionOutputs:(NSError **)error {
    dispatch_queue_t captureQueue = dispatch_queue_create("com.tui.captureQueue", DISPATCH_QUEUE_SERIAL);

    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:videoOut]) {
        [_session addOutput:videoOut];
    }
    _videoOutput = videoOut;
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];

    if (_type == TUICameraMediaTypeVideo) {
        AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
        [audioOut setSampleBufferDelegate:self queue:captureQueue];
        if ([_session canAddOutput:audioOut]) {
            [_session addOutput:audioOut];
        }
        _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    }

    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
    }
    _imageOutput = imageOutput;
}

#pragma mark - - Session Control
- (void)startCaptureSession {
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

- (void)stopCaptureSession {
    if (_session.isRunning) {
        [_session stopRunning];
    }
}

#pragma mark - - Camera Operation
- (void)zoomAction:(TUICameraView *)cameraView factor:(CGFloat)factor {
    NSError *error = [_cameraManager zoom:[self activeCamera] factor:factor];
    if (error) NSLog(@"%@", error);
}

- (void)focusAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *))handle {
    NSError *error = [_cameraManager focus:[self activeCamera] point:point];
    handle(error);
    NSLog(@"%f", [self activeCamera].activeFormat.videoMaxZoomFactor);
}

- (void)exposAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *))handle {
    NSError *error = [_cameraManager expose:[self activeCamera] point:point];
    handle(error);
}

- (void)autoFocusAndExposureAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    NSError *error = [_cameraManager resetFocusAndExposure:[self activeCamera]];
    handle(error);
}

- (void)flashLightAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    BOOL on = [_cameraManager flashMode:[self activeCamera]] == AVCaptureFlashModeOn;
    AVCaptureFlashMode mode = on ? AVCaptureFlashModeOff : AVCaptureFlashModeOn;
    NSError *error = [_cameraManager changeFlash:[self activeCamera] mode:mode];
    handle(error);
}

- (void)torchLightAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    BOOL on = [_cameraManager torchMode:[self activeCamera]] == AVCaptureTorchModeOn;
    AVCaptureTorchMode mode = on ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    NSError *error = [_cameraManager changeTorch:[self activeCamera] model:mode];
    handle(error);
}

- (void)swicthCameraAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        CATransition *animation = [CATransition animation];
        animation.type = @"oglFlip";
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.5;
        [self.cameraView.previewView.layer addAnimation:animation forKey:@"flip"];

        AVCaptureFlashMode mode = [_cameraManager flashMode:[self activeCamera]];

        _deviceInput = [_cameraManager switchCamera:_session old:_deviceInput new:videoInput];

        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];

        [_cameraManager changeFlash:[self activeCamera] mode:mode];
    }
    handle(error);
}

#pragma mark - - Taking Photo
- (void)takePhotoAction:(TUICameraView *)cameraView {
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                              completionHandler:^(CMSampleBufferRef _Nullable imageDataSampleBuffer, NSError *_Nullable error) {
                                                if (error) {
                                                    [self showErrorStr:error.localizedDescription];
                                                    return;
                                                }
                                                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                TUICaptureImagePreviewController *vc = [[TUICaptureImagePreviewController alloc] initWithImage:image];
                                                [self.navigationController pushViewController:vc animated:YES];
                                                __weak __typeof(self) weakSelf = self;
                                                vc.commitBlock = ^{
                                                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                  UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
                                                  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                                                  UIImage *convertToUpImage = UIGraphicsGetImageFromCurrentImageContext();
                                                  UIGraphicsEndImageContext();
                                                  NSData *data = UIImageJPEGRepresentation(convertToUpImage, 0.75);
                                                  [strongSelf.delegate cameraViewController:strongSelf didFinishPickingMediaWithImageData:data];
                                                  [strongSelf popViewControllerAnimated:YES];
                                                };
                                                vc.cancelBlock = ^{
                                                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                  [strongSelf.navigationController popViewControllerAnimated:YES];
                                                };
                                              }];
}

- (void)cancelAction:(TUICameraView *)cameraView {
    [self.delegate cameraViewControllerDidCancel:self];

    [self popViewControllerAnimated:YES];
}

- (void)pictureLibAction:(TUICameraView *)cameraView {
    @weakify(self);
    [self.delegate cameraViewControllerDidPictureLib:self
                                      finishCallback:^{
                                        @strongify(self);
                                        [self popViewControllerAnimated:NO];
                                      }];
}

#pragma mark - - Record
- (void)startRecordVideoAction:(TUICameraView *)cameraView {
    /**
     * Recreate each time to avoid Crash caused by unreleased previous information
     */
    _movieManager = [[TUIMovieManager alloc] init];
    _recording = YES;
    _movieManager.currentDevice = [self activeCamera];
    _movieManager.currentOrientation = [self currentVideoOrientation];
    @weakify(self);
    [_movieManager start:^(NSError *_Nonnull error) {
      @strongify(self);
      @weakify(self);
      dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (error) [self showErrorStr:error.localizedDescription];
      });
    }];
}

- (void)stopRecordVideoAction:(TUICameraView *)cameraView RecordDuration:(CGFloat)duration {
    _recording = NO;
    @weakify(self);
    [_movieManager stop:^(NSURL *_Nonnull url, NSError *_Nonnull error) {
      @strongify(self);
      @weakify(self);
      dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (duration < self.videoMinimumDuration) {
            [self showErrorStr:TIMCommonLocalizableString(TUIKitMoreVideoCaptureDurationTip)];
        } else if (error) {
            [self showErrorStr:error.localizedDescription];
        } else {
            TUICaptureVideoPreviewViewController *videoPreviewController = [[TUICaptureVideoPreviewViewController alloc] initWithVideoURL:url];
            [self.navigationController pushViewController:videoPreviewController animated:YES];
            @weakify(self);
            videoPreviewController.commitBlock = ^{
              @strongify(self);
              [self.delegate cameraViewController:self didFinishPickingMediaWithVideoURL:url];
              [self popViewControllerAnimated:YES];
            };
            videoPreviewController.cancelBlock = ^{
              @strongify(self);
              [self.navigationController popViewControllerAnimated:YES];
            };
        }
      });
    }];
}

#pragma mark - - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_recording) {
        [_movieManager writeData:connection video:_videoConnection audio:_audioConnection buffer:sampleBuffer];
    }
}

#pragma mark - - Others
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewControllerAnimated:(BOOL)animated {
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    index--;
    UIViewController *lastVC = nil;
    if (index > 0 && index < self.navigationController.viewControllers.count) {
        lastVC = self.navigationController.viewControllers[index];
    }

    self.navigationController.navigationBarHidden = self.lastPageBarHidden;

    if (lastVC) {
        [self.navigationController popToViewController:lastVC animated:animated];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

- (void)showErrorStr:(NSString *)errStr {
    [TUITool makeToast:errStr duration:1 position:CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0)];
}

@end
