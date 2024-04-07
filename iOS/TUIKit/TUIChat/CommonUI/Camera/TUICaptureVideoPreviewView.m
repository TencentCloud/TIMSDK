
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUICaptureVideoPreviewView.h"

@implementation TUICaptureVideoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return self;
}

- (AVCaptureSession *)captureSessionsion {
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setCaptureSessionsion:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

/**
 * Make the layer method of the view return the AVCaptureVideoPreviewLayer class object
 */
+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

@end
