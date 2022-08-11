//
//  TUICallingVideoRenderView.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>
#import "TUICallEngineHeader.h"

@class CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TUICallingVideoRenderViewDelegate <NSObject>

@optional
- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture;

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture;

@end

/**
 Video RenderView
 */
@interface TUICallingVideoRenderView : TUIVideoView

@property (nonatomic, weak) id<TUICallingVideoRenderViewDelegate> delegate;

- (void)configViewWithUserModel:(CallingUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END
