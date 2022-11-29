
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@import UIKit;
@interface TUIMotionManager : NSObject

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign)AVCaptureVideoOrientation videoOrientation;

@end
