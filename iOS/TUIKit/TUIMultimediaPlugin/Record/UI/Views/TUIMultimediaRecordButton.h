// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaRecordButtonDelegate;

/**
 视频录制按钮
 */
@interface TUIMultimediaRecordButton : UIView
@property(nonatomic) float progress;
@property(nonatomic) float dotSizeNormal;
@property(nonatomic) float progressSizeNormal;
@property(nonatomic) float dotSizePressed;
@property(nonatomic) float progressSizePressed;
@property(weak, nullable, nonatomic) id<TUIMultimediaRecordButtonDelegate> delegate;
@property(nonatomic) BOOL isOnlySupportTakePhoto;

- (instancetype)initWithFrame:(CGRect)frame;
@end

@protocol TUIMultimediaRecordButtonDelegate <NSObject>
- (void)onRecordButtonTap:(TUIMultimediaRecordButton *)btn;
- (void)onRecordButtonLongPressBegan:(TUIMultimediaRecordButton *)btn;
- (void)onRecordButtonLongPressEnded:(TUIMultimediaRecordButton *)btn;
- (void)onRecordButtonLongPressCancelled:(TUIMultimediaRecordButton *)btn;
@end

NS_ASSUME_NONNULL_END
