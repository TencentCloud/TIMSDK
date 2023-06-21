
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICameraManager : NSObject

- (AVCaptureDeviceInput *)switchCamera:(AVCaptureSession *)session old:(AVCaptureDeviceInput *)oldinput new:(AVCaptureDeviceInput *)newinput;

- (id)resetFocusAndExposure:(AVCaptureDevice *)device;

- (id)zoom:(AVCaptureDevice *)device factor:(CGFloat)factor;

- (id)focus:(AVCaptureDevice *)device point:(CGPoint)point;

- (id)expose:(AVCaptureDevice *)device point:(CGPoint)point;

- (id)changeFlash:(AVCaptureDevice *)device mode:(AVCaptureFlashMode)mode;

- (id)changeTorch:(AVCaptureDevice *)device model:(AVCaptureTorchMode)mode;

- (AVCaptureFlashMode)flashMode:(AVCaptureDevice *)device;

- (AVCaptureTorchMode)torchMode:(AVCaptureDevice *)device;

@end

NS_ASSUME_NONNULL_END
