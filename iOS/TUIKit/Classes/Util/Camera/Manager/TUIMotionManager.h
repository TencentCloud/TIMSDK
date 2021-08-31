
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TUIMotionManager : NSObject

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign)AVCaptureVideoOrientation videoOrientation;

@end
