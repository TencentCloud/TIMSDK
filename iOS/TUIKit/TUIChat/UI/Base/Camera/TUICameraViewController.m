
#import "TUICameraViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMMetadata.h>
#import <Photos/Photos.h>

#import "TUICaptureImagePreviewController.h"
#import "TUICaptureVideoPreviewViewController.h"
#import "TUICameraView.h"

#import "TUICameraManager.h"
#import "TUIMotionManager.h"
#import "TUIMovieManager.h"
#import "TUICaptureTimer.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"

@interface TUICameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, TUICameraViewDelegate>
{
    // 会话
    AVCaptureSession          *_session;
    
    // 输入
    AVCaptureDeviceInput      *_deviceInput;
        
    // 输出
    AVCaptureConnection       *_videoConnection;
    AVCaptureConnection       *_audioConnection;
    AVCaptureVideoDataOutput  *_videoOutput;
    AVCaptureStillImageOutput *_imageOutput;

    // 录制
    BOOL                       _recording;
}

@property(nonatomic, strong) TUICameraView   *cameraView;       // 界面布局
@property(nonatomic, strong) TUIMovieManager  *movieManager;     // 视频管理
@property(nonatomic, strong) TUICameraManager *cameraManager;    // 相机管理
@property(nonatomic, strong) TUIMotionManager *motionManager;    // 陀螺仪管理
@property(nonatomic, strong) AVCaptureDevice *activeCamera;     // 当前输入设备
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;   // 不活跃的设备(这里指前摄像头或后摄像头，不包括外接输入设备)

@property (nonatomic) BOOL isFirstShow;
@property (nonatomic) BOOL lastPageBarHidden;
@property (nonatomic) BOOL lastPopGestureEnabled;
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

- (void)dealloc
{
    [self stopCaptureSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isFirstShow) {
        self.isFirstShow = NO;
        
        self.lastPopGestureEnabled = self.navigationController.interactivePopGestureRecognizer.enabled;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        self.lastPageBarHidden = self.navigationController.navigationBarHidden;
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - -输入设备
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

#pragma mark - -相关配置
/// 会话
- (void)setupSession:(NSError **)error {
    _session = [[AVCaptureSession alloc]init];
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

/// 输入
- (void)setupSessionInputs:(NSError **)error {
    // 视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
        }
    }
    _deviceInput = videoInput;
    
    // 音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:error];
    if ([_session canAddInput:audioIn]) {
        [_session addInput:audioIn];
    }
}

/// 输出
- (void)setupSessionOutputs:(NSError **)error {
    dispatch_queue_t captureQueue = dispatch_queue_create("com.tui.captureQueue", DISPATCH_QUEUE_SERIAL);
    
    // 视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:videoOut]){
        [_session addOutput:videoOut];
    }
    _videoOutput = videoOut;
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];

    // 音频输出
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:audioOut]){
        [_session addOutput:audioOut];
    }
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];            
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
    }
    _imageOutput = imageOutput;
}

#pragma mark - -会话控制
// 开启捕捉
- (void)startCaptureSession {
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

// 停止捕捉
- (void)stopCaptureSession {
    if (_session.isRunning) {
        [_session stopRunning];
    }
}

#pragma mark - -操作相机
// 缩放
-(void)zoomAction:(TUICameraView *)cameraView factor:(CGFloat)factor {
    NSError *error = [_cameraManager zoom:[self activeCamera] factor:factor];
    if (error) NSLog(@"%@", error);
}

// 聚焦
-(void)focusAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *))handle {
    NSError *error = [_cameraManager focus:[self activeCamera] point:point];
    handle(error);
    NSLog(@"%f", [self activeCamera].activeFormat.videoMaxZoomFactor);
}

// 曝光
-(void)exposAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *))handle {
    NSError *error = [_cameraManager expose:[self activeCamera] point:point];
    handle(error);
}

// 自动聚焦、曝光
-(void)autoFocusAndExposureAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    NSError *error = [_cameraManager resetFocusAndExposure:[self activeCamera]];
    handle(error);
}

// 闪光灯
-(void)flashLightAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    BOOL on = [_cameraManager flashMode:[self activeCamera]] == AVCaptureFlashModeOn;
    AVCaptureFlashMode mode = on ? AVCaptureFlashModeOff : AVCaptureFlashModeOn;
    NSError *error = [_cameraManager changeFlash:[self activeCamera] mode: mode];
    handle(error);
}

// 手电筒
-(void)torchLightAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    BOOL on = [_cameraManager torchMode:[self activeCamera]] == AVCaptureTorchModeOn;
    AVCaptureTorchMode mode = on ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    NSError *error = [_cameraManager changeTorch:[self activeCamera] model:mode];
    handle(error);
}

// 转换摄像头
- (void)swicthCameraAction:(TUICameraView *)cameraView handle:(void (^)(NSError *))handle {
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        // 动画效果
        CATransition *animation = [CATransition animation];
        animation.type = @"oglFlip";
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.5;
        [self.cameraView.previewView.layer addAnimation:animation forKey:@"flip"];

        // 当前闪光灯状态
        AVCaptureFlashMode mode = [_cameraManager flashMode:[self activeCamera]];

        // 转换摄像头
        _deviceInput = [_cameraManager switchCamera:_session old:_deviceInput new:videoInput];

        // 重新设置视频输出链接
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];

//         如果后置转前置，系统会自动关闭手电筒(如果之前打开的，需要更新UI)
//        if (videoDevice.position == AVCaptureDevicePositionFront) {
//            [self.cameraView changeTorch:NO];
//        }

        // 前后摄像头的闪光灯不是同步的，所以在转换摄像头后需要重新设置闪光灯
        [_cameraManager changeFlash:[self activeCamera] mode:mode];
    }
    handle(error);
}

#pragma mark - -拍摄照片
// 拍照
- (void)takePhotoAction:(TUICameraView *)cameraView {
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error) {
            [self showErrorStr:error.localizedDescription];
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc]initWithData:imageData];
        TUICaptureImagePreviewController *vc = [[TUICaptureImagePreviewController alloc]initWithImage:image];
        [self.navigationController pushViewController:vc animated:YES];
        __weak __typeof(self) weakSelf = self;
        vc.commitBlock = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            UIImage *convertToUpImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [strongSelf.delegate cameraViewController:strongSelf didFinishPickingMediaWithImage:convertToUpImage];
            
            [strongSelf popViewControllerAnimated:YES];
        };
        vc.cancelBlock = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.navigationController popViewControllerAnimated:YES];
        };
    }];
}

// 取消拍照
- (void)cancelAction:(TUICameraView *)cameraView {
    [self.delegate cameraViewControllerDidCancel:self];
    
    [self popViewControllerAnimated:YES];
}

#pragma mark - -录制视频
// 开始录像
-(void)startRecordVideoAction:(TUICameraView *)cameraView {
   
    // 每次重新创建，避免之前的信息未释放导致的 Crash
    _movieManager  = [[TUIMovieManager alloc]  init];
    _recording = YES;
    _movieManager.currentDevice = [self activeCamera];
    _movieManager.currentOrientation = [self currentVideoOrientation];
    @weakify(self)
    [_movieManager start:^(NSError * _Nonnull error) {
        @strongify(self)
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (error) [self showErrorStr:error.localizedDescription];
        });
    }];
}

// 停止录像
-(void)stopRecordVideoAction:(TUICameraView *)cameraView RecordDuration:(CGFloat)duration {
    
    _recording = NO;
    @weakify(self)
    [_movieManager stop:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
        @strongify(self)
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (duration < self.videoMinimumDuration) {
                [self showErrorStr:TUIKitLocalizableString(TUIKitMoreVideoCaptureDurationTip)];
            }
            else if (error) {
                [self showErrorStr:error.localizedDescription];
            }
            else {
                TUICaptureVideoPreviewViewController *videoPreviewController = [[TUICaptureVideoPreviewViewController alloc] initWithVideoURL:url];
                [self.navigationController pushViewController:videoPreviewController animated:YES];
                @weakify(self)
                videoPreviewController.commitBlock = ^{
                    @strongify(self)
                    [self.delegate cameraViewController:self didFinishPickingMediaWithVideoURL:url];
                    [self popViewControllerAnimated:YES];
                };
                videoPreviewController.cancelBlock = ^{
                    @strongify(self)
                    [self.navigationController popViewControllerAnimated:YES];
                };
            }
        });
    }];
}

#pragma mark - - AVCaptureVideoDataOutputSampleBufferDelegate 输出代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (_recording) {
        [_movieManager writeData:connection video:_videoConnection audio:_audioConnection buffer:sampleBuffer];
    }
}

#pragma mark - -其它方法
// 当前设备取向
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
    index --;
    UIViewController *lastVC = nil;
    if (index > 0 && index < self.navigationController.viewControllers.count) {
        lastVC = self.navigationController.viewControllers[index];
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = self.lastPopGestureEnabled;
    
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
