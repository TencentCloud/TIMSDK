
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TUICaptureVideoPreviewView : UIView

@property (strong, nonatomic) AVCaptureSession *captureSessionsion;

- (CGPoint)captureDevicePointForPoint:(CGPoint)point;

@end
