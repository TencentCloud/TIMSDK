
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TUICameraMacro.h"
#import "TUICaptureVideoPreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@class TUICameraView;
@protocol TUICameraViewDelegate <NSObject>
@optional

/**
 * Flash
 */
- (void)flashLightAction:(TUICameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * Fill light
 */
- (void)torchLightAction:(TUICameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * 
 * Switch camera
 */
- (void)swicthCameraAction:(TUICameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * 
 * Auto focus and exposure
 */
- (void)autoFocusAndExposureAction:(TUICameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * 
 * Foucus
 */
- (void)focusAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *error))handle;

/**
 * 
 * Expose
 */
- (void)exposAction:(TUICameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *error))handle;

/**
 * 
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

@property(nonatomic, weak) id<TUICameraViewDelegate> delegate;

@property(nonatomic, readonly) TUICaptureVideoPreviewView *previewView;

/// default TUICameraMediaTypePhoto
@property(nonatomic) TUICameraMediaType type;

/// default TUICameraViewAspectRatio16x9
@property(nonatomic) TUICameraViewAspectRatio aspectRatio;

/// default 15s
@property(nonatomic, assign) CGFloat maxVideoCaptureTimeLimit;

@end

NS_ASSUME_NONNULL_END
