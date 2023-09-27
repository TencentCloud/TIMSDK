//
//  UIImage+TUICallKitRTL.m
//  TUICallKit
//
//  Created by noah on 2023/7/31.
//  Copyright © 2023 Tencent. All rights reserved
//

#import "UIImage+TUICallKitRTL.h"
#import <TUICore/TUIGlobalization.h>

@interface UIImage (TUICallKitRTL)

@end

@implementation UIImage (TUICallKitRTL)

- (UIImage *_Nonnull)checkOverturn {
    if (isRTL()) {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(bitmap, self.size.width / 2, self.size.height / 2);
        CGContextScaleCTM(bitmap, -1.0, -1.0);
        CGContextTranslateCTM(bitmap, -self.size.width / 2, -self.size.height / 2);
        CGContextDrawImage(bitmap, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        return image;
    }
    return self;
}

- (UIImage *)callKitImageFlippedForRightToLeftLayoutDirection {
    if (isRTL()) {
        return [UIImage imageWithCGImage:self.CGImage
                                   scale:self.scale
                             orientation:UIImageOrientationUpMirrored];
    }
    
    return self;
}
@end
