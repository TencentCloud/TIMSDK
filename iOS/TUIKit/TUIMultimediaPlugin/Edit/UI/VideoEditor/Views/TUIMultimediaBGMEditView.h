// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaBGM.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaBGMEditViewDelegate;

@interface TUIMultimediaBGMEditView : UIView
@property(nonatomic) NSArray<TUIMultimediaBGMGroup *> *bgmConfig;
@property(nonatomic) float clipDuration;
@property(nonatomic) TUIMultimediaBGM *selectedBgm;
@property(nonatomic) BOOL originAudioEnabled;
@property(nonatomic) BOOL bgmEnabled;
@property(weak, nullable, nonatomic) id<TUIMultimediaBGMEditViewDelegate> delegate;
@end

@protocol TUIMultimediaBGMEditViewDelegate <NSObject>
- (void)bgmEditViewValueChanged:(TUIMultimediaBGMEditView *)v;
@end

NS_ASSUME_NONNULL_END
