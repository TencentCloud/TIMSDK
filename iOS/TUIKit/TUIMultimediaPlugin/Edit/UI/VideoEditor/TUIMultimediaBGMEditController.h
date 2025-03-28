// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaPopupController.h"
#import "TUIMultimediaPlugin/TUIMultimediaVideoBgmEditInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaBGMEditControllerDelegate;

/**
 背景音乐选择界面Controller
 */
@interface TUIMultimediaBGMEditController : TUIMultimediaPopupController
@property(nonatomic) float clipDuration;
@property(readonly, nonatomic) TUIMultimediaVideoBgmEditInfo *bgmEditInfo;
@property(weak, nullable, nonatomic) id<TUIMultimediaBGMEditControllerDelegate> delegate;
@end

@protocol TUIMultimediaBGMEditControllerDelegate <NSObject>
- (void)onBGMEditController:(TUIMultimediaBGMEditController *)c bgmInfoChanged:(TUIMultimediaVideoBgmEditInfo *)bgmInfo;
- (void)onBGMEditControllerExit:(TUIMultimediaBGMEditController *)c;
@end
NS_ASSUME_NONNULL_END
