//
//  TUICallingFloatingWindow.h
//  TUICalling
//
//  Created by noah on 2022/1/12.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>
#import "TUICallingVideoRenderView.h"
@class TUICallingVideoRenderView;

NS_ASSUME_NONNULL_BEGIN

static CGFloat const kMicroAudioViewWidth = 80.0f;
static CGFloat const kMicroAudioViewHeight = 80.0f;
static CGFloat const kMicroVideoViewWidth = 100.0f;
static CGFloat const kMicroVideoViewHeight = 100.0f * 16 / 9.0;
#define kMicroAudioViewRect (CGRectMake(Screen_Width - kMicroAudioViewWidth, 150, kMicroAudioViewWidth, kMicroAudioViewHeight))
#define kMicroVideoViewRect (CGRectMake(Screen_Width - kMicroVideoViewWidth, 150, kMicroVideoViewWidth, kMicroVideoViewHeight))

@protocol TUICallingFloatingWindowDelegate <NSObject>

- (void)floatingWindowDidClickView;
- (void)floatingWindowChangedFrame;

@end

@interface TUICallingFloatingWindow : UIWindow <TUICallingVideoRenderViewDelegate>

@property (nonatomic, weak) id<TUICallingFloatingWindowDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<TUICallingFloatingWindowDelegate>)delegate;

- (void)updateMicroWindowWithText:(NSString *)textStr;

- (void)updateMicroWindowWithRenderView:(TUICallingVideoRenderView * _Nullable)renderView;

- (void)updateMicroWindowBackgroundAvatar:(NSString *)avatar;

- (void)floatingWindowRoundedRect;

@end

NS_ASSUME_NONNULL_END
