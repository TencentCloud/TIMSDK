// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaBeautifySettings.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaBeautifyViewDelegate;

@interface TUIMultimediaBeautifyView : UIView
@property(nonatomic) TUIMultimediaBeautifySettings *settings;
@property(weak, nullable, nonatomic) id<TUIMultimediaBeautifyViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame settings:(nullable TUIMultimediaBeautifySettings *)settings;
@end

@protocol TUIMultimediaBeautifyViewDelegate <NSObject>
- (void)beautifyView:(TUIMultimediaBeautifyView *)beautifyView onSettingsChange:(TUIMultimediaBeautifySettings *)settings;
@end

@interface TUIMultimediaMarker : UIView
@property(nonatomic) NSString *text;
- (void)showForDuration:(CGFloat)showSeconds withHideAnimeDuration:(CGFloat)hideAnimeSeconds;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
