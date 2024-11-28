// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMultimediaSubtitleEditController;

typedef void (^TUIMultimediaSubtitleEditControllerCallback)(TUIMultimediaSubtitleEditController *c, BOOL isOk);

/**
 字幕编辑界面Controller
 */
@interface TUIMultimediaSubtitleEditController : UIViewController
@property(copy, nonatomic) TUIMultimediaSubtitleInfo *subtitleInfo;
@property(nullable, nonatomic) TUIMultimediaSubtitleEditControllerCallback callback;
@end

NS_ASSUME_NONNULL_END
