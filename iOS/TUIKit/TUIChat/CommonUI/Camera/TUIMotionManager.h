
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
@import UIKit;
@interface TUIMotionManager : NSObject

@property(nonatomic, assign) UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

@end
