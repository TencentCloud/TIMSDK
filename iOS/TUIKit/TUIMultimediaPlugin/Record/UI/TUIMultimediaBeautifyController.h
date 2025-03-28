// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaBeautifySettings.h"
#import "TUIMultimediaPlugin/TUIMultimediaPopupController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaBeautifyControllerDelegate;

@interface TUIMultimediaBeautifyController : TUIMultimediaPopupController
@property(readonly, nonatomic) TUIMultimediaBeautifySettings *settings;
@property(weak, nullable, nonatomic) id<TUIMultimediaBeautifyControllerDelegate> delegate;
@end

@protocol TUIMultimediaBeautifyControllerDelegate <NSObject>
- (void)beautifyControllerOnExit:(TUIMultimediaBeautifyController *)controller;
- (void)beautifyController:(TUIMultimediaBeautifyController *)controller onSettingsChange:(TUIMultimediaBeautifySettings *)settings;
@end

NS_ASSUME_NONNULL_END
