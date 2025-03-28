// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaSubtitleEditViewDelegate;

@interface TUIMultimediaSubtitleEditView : UIView
@property(nonatomic) TUIMultimediaSubtitleInfo *subtitleInfo;
@property(weak, nullable, nonatomic) id<TUIMultimediaSubtitleEditViewDelegate> delegate;
- (void)activate;
@end

@protocol TUIMultimediaSubtitleEditViewDelegate <NSObject>
- (void)subtitleEditViewOnOk:(TUIMultimediaSubtitleEditView *)view;
- (void)subtitleEditViewOnCancel:(TUIMultimediaSubtitleEditView *)view;
@end

NS_ASSUME_NONNULL_END
