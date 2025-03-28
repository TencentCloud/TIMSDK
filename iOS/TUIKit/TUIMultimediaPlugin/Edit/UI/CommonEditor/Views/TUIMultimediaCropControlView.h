// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#import "TUIMultimediaCropView.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMultimediaCommonEditorControlView;
@protocol TUIMultimediaCropControlDelegate;

@interface TUIMultimediaCropControlView : UIView
@property(weak, nullable, nonatomic) id<TUIMultimediaCropControlDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame editorControl:(TUIMultimediaCommonEditorControlView*)editorControl;
- (void)show;
- (void)changeResetButtonStatus;
@end

@protocol TUIMultimediaCropControlDelegate <NSObject>
- (void)onCancelCrop;
- (void)onConfirmCrop:(CGRect)cropRect;
@end

NS_ASSUME_NONNULL_END
