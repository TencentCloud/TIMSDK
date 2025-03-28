// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaStickerView.h"
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaSubtitleView : TUIMultimediaStickerView
@property(nullable, nonatomic) TUIMultimediaSubtitleInfo *subtitleInfo;
@end

NS_ASSUME_NONNULL_END
