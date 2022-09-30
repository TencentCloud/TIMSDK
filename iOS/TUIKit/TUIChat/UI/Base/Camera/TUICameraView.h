
#import <UIKit/UIKit.h>
#import "TUICaptureVideoPreviewView.h"
#import "TUICameraMacro.h"

NS_ASSUME_NONNULL_BEGIN



@class TUICameraView;
@protocol TUICameraViewDelegate <NSObject>
@optional;

/**
 * 闪光灯
 * Flash
 */
- (void)flashLightAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;

/**
 * 补光
 * Fill light
 */
- (void)torchLightAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;

/**
 * 转换摄像头
 * Switch camera
 */
- (void)swicthCameraAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;

/**
 * 自动聚焦曝光
 * Auto focus and exposure
 */
- (void)autoFocusAndExposureAction:(TUICameraView *)cameraView handle:(void(^)(NSError *error))handle;

/**
 * 聚焦
 * Foucus
 */
- (void)focusAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void(^)(NSError *error))handle;

/**
 * 曝光
 * Expose
 */
- (void)exposAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void(^)(NSError *error))handle;

/**
 * 缩放
 * Zoom
 */
- (void)zoomAction:(TUICameraView *)cameraView factor:(CGFloat)factor;


- (void)cancelAction:(TUICameraView *)cameraView;

- (void)pictureLibAction:(TUICameraView *)cameraView;

- (void)takePhotoAction:(TUICameraView *)cameraView;

- (void)stopRecordVideoAction:(TUICameraView *)cameraView RecordDuration:(CGFloat)duration;

- (void)startRecordVideoAction:(TUICameraView *)cameraView;

- (void)didChangeTypeAction:(TUICameraView *)cameraView type:(TUICameraMediaType)type;

@end

@interface TUICameraView : UIView

@property(nonatomic, weak) id <TUICameraViewDelegate> delegate;

@property(nonatomic, readonly) TUICaptureVideoPreviewView *previewView;

/// default TUICameraMediaTypePhoto
@property(nonatomic) TUICameraMediaType type;

/// default TUICameraViewAspectRatio16x9
@property (nonatomic) TUICameraViewAspectRatio aspectRatio;

/// default 15s
@property (nonatomic, assign) CGFloat maxVideoCaptureTimeLimit;

@end

NS_ASSUME_NONNULL_END
