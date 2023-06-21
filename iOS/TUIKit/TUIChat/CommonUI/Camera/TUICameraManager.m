
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUICameraManager.h"

@implementation TUICameraManager

#pragma mark - - Switch Camera
- (AVCaptureDeviceInput *)switchCamera:(AVCaptureSession *)session old:(AVCaptureDeviceInput *)oldinput new:(AVCaptureDeviceInput *)newinput {
    [session beginConfiguration];
    [session removeInput:oldinput];
    if ([session canAddInput:newinput]) {
        [session addInput:newinput];
        [session commitConfiguration];
        return newinput;
    } else {
        [session addInput:oldinput];
        [session commitConfiguration];
        return oldinput;
    }
}

#pragma mark - - Zoom
- (id)zoom:(AVCaptureDevice *)device factor:(CGFloat)factor {
    if (device.activeFormat.videoMaxZoomFactor > factor && factor >= 1.0) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device rampToVideoZoomFactor:factor withRate:4.0];
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self error:@"Unsupported zoom factor" code:2000];
}

#pragma mark - - Focus
- (id)focus:(AVCaptureDevice *)device point:(CGPoint)point {
    BOOL supported = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus];
    if (supported) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self error:@"Device does not support focus" code:2001];
}

#pragma mark - - Expose
static const NSString *CameraAdjustingExposureContext;
- (id)expose:(AVCaptureDevice *)device point:(CGPoint)point {
    BOOL supported = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
    if (supported) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self error:@"Device does not support exposure" code:2002];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &CameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&CameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{
              NSError *error;
              if ([device lockForConfiguration:&error]) {
                  device.exposureMode = AVCaptureExposureModeLocked;
                  [device unlockForConfiguration];
              } else {
                  NSLog(@"%@", error);
              }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - - Auto focus, exposure
- (id)resetFocusAndExposure:(AVCaptureDevice *)device {
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
    }
    return error;
}

#pragma mark - - Flash
- (AVCaptureFlashMode)flashMode:(AVCaptureDevice *)device {
    return [device flashMode];
}

- (id)changeFlash:(AVCaptureDevice *)device mode:(AVCaptureFlashMode)mode {
    if (![device hasFlash]) {
        return [self error:@"Flash is not supported" code:2003];
    }
    if ([self torchMode:device] == AVCaptureTorchModeOn) {
        [self setTorch:device model:AVCaptureTorchModeOff];
    }
    return [self setFlash:device mode:mode];
}

- (id)setFlash:(AVCaptureDevice *)device mode:(AVCaptureFlashMode)mode {
    if ([device isFlashModeSupported:mode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = mode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self error:@"Flash is not supported" code:2003];
}

#pragma mark - - Flashlight
- (AVCaptureTorchMode)torchMode:(AVCaptureDevice *)device {
    return [device torchMode];
}

- (id)changeTorch:(AVCaptureDevice *)device model:(AVCaptureTorchMode)mode {
    if (![device hasTorch]) {
        return [self error:@"Flashlight not supported" code:2004];
    }
    if ([self flashMode:device] == AVCaptureFlashModeOn) {
        [self setFlash:device mode:AVCaptureFlashModeOff];
    }
    return [self setTorch:device model:mode];
}

- (id)setTorch:(AVCaptureDevice *)device model:(AVCaptureTorchMode)mode {
    if ([device isTorchModeSupported:mode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = mode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self error:@"Flashlight not supported" code:2004];
}

#pragma mark -
- (NSError *)error:(NSString *)text code:(NSInteger)code {
    NSDictionary *desc = @{NSLocalizedDescriptionKey : text};
    NSError *error = [NSError errorWithDomain:@"com.tui.camera" code:code userInfo:desc];
    return error;
}

@end
