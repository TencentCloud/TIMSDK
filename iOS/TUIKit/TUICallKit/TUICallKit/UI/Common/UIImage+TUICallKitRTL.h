//
//  UIImage+TUICallKitRTL.h
//  TUICallKit
//
//  Created by noah on 2023/7/31.
//  Copyright © 2023 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TUICallKitRTL)

- (UIImage *_Nonnull)checkOverturn;

- (UIImage *)callKitImageFlippedForRightToLeftLayoutDirection;

@end

NS_ASSUME_NONNULL_END
