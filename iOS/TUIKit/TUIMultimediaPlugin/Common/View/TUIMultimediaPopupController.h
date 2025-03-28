// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaPopupController : UIViewController
@property(nullable, nonatomic) UIView *mainView;
@property(nonatomic) float animeDuration;

- (BOOL)popupControllerWillCancel;
- (void)popupControllerDidCanceled;
@end

NS_ASSUME_NONNULL_END
