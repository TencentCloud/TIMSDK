
#import <UIKit/UIKit.h>
#import "TUICaptureVideoPreviewView.h"
#import "TUICameraMacro.h"

NS_ASSUME_NONNULL_BEGIN



@class TUICameraView;
@protocol TUICameraViewDelegate <NSObject>
@optional;

/// 闪光灯
-(void)flashLightAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;
/// 补光
-(void)torchLightAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;
/// 转换摄像头
-(void)swicthCameraAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;
/// 自动聚焦曝光
-(void)autoFocusAndExposureAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;
/// 聚焦
-(void)focusAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void(^)(NSError *error))handle;
/// 曝光
-(void)exposAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void(^)(NSError *error))handle;
/// 缩放
-(void)zoomAction:(TUICameraView *)cameraView factor:(CGFloat)factor;

/// 取消
-(void)cancelAction:(TUICameraView *)cameraView;
/// 拍照
-(void)takePhotoAction:(TUICameraView *)cameraView;
/// 停止录制视频
-(void)stopRecordVideoAction:(TUICameraView *)cameraView RecordDuration:(CGFloat)duration;
/// 开始录制视频
-(void)startRecordVideoAction:(TUICameraView *)cameraView;
/// 改变拍摄类型 1：拍照 2：视频
-(void)didChangeTypeAction:(TUICameraView *)cameraView type:(TUICameraMediaType)type;

@end

@interface TUICameraView : UIView

@property(nonatomic, weak) id <TUICameraViewDelegate> delegate;

@property(nonatomic, readonly) TUICaptureVideoPreviewView *previewView;

/// default TUICameraMediaTypePhoto
@property(nonatomic) TUICameraMediaType type;

/// previewView的宽高比, 默认TUICameraViewAspectRatio16x9
@property (nonatomic) TUICameraViewAspectRatio aspectRatio;

/// 最大录制时长, default 15s
@property (nonatomic, assign) CGFloat maxVideoCaptureTimeLimit;

@end

NS_ASSUME_NONNULL_END
