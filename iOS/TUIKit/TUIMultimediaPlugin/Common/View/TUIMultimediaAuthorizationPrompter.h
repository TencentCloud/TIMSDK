// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaAuthorizationPrompter : UIViewController
+ (BOOL) verifyPermissionGranted:(UIViewController*)parentView;
@end

NS_ASSUME_NONNULL_END
