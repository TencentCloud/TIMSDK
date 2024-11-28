// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaPopupController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaPasterSelectControllerDelegate;

/**
 贴纸选择界面Controller
 */
@interface TUIMultimediaPasterSelectController : TUIMultimediaPopupController
@property(weak, nullable, nonatomic) id<TUIMultimediaPasterSelectControllerDelegate> delegate;
@end

@protocol TUIMultimediaPasterSelectControllerDelegate <NSObject>
- (void)pasterSelectController:(TUIMultimediaPasterSelectController *)c onPasterSelected:(UIImage *)image;
- (void)onPasterSelectControllerExit:(TUIMultimediaPasterSelectController *)c;
@end

NS_ASSUME_NONNULL_END
