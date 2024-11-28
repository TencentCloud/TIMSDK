// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaBeautifySettings.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMultimediaRecordControlView;

typedef NS_ENUM(NSInteger, TUIMultimediaRecordAspectRatio) {
    TUIMultimediaRecordAspectRatio1_1,
    TUIMultimediaRecordAspectRatio3_4,
    TUIMultimediaRecordAspectRatio4_3,
    TUIMultimediaRecordAspectRatio9_16,
    TUIMultimediaRecordAspectRatio16_9,
};
typedef void (^TUIMultimediaRecordControlCallback)(TUIMultimediaRecordControlView *);

@protocol TUIMultimediaRecordControlViewDelegate <NSObject>
- (void)recordControlViewOnRecordStart;
- (void)recordControlViewOnRecordFinish;
- (void)recordControlViewPhoto;
- (void)recordControlViewOnFlashStateChange:(BOOL)flashState;
- (void)recordControlViewOnAspectChange:(TUIMultimediaRecordAspectRatio)aspect;
- (void)recordControlViewOnExit;
- (void)recordControlViewOnCameraSwicth:(BOOL)isUsingFrontCamera;
- (void)recordControlViewOnBeautify;
@end

/**
 包含视频录制页面的各种控制按钮
 */
@interface TUIMultimediaRecordControlView : UIView
@property(nonatomic) BOOL flashState;
@property(nonatomic) TUIMultimediaRecordAspectRatio aspectRatio;
@property(nonatomic) BOOL isUsingFrontCamera;
@property(readonly, nonatomic) UIView *previewView;
@property(nonatomic) TUIMultimediaBeautifySettings *beautifySettings;
@property(nonatomic) BOOL recordTipHidden;

@property(weak, nullable, nonatomic) id<TUIMultimediaRecordControlViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame isOnlySupportTakePhoto:(BOOL)isOnlySupportTakePhoto;
- (instancetype)initWithFrame:(CGRect)frame isOnlySupportTakePhoto:(BOOL)isOnlySupportTakePhoto beautifySettings:(TUIMultimediaBeautifySettings *)beautifySettings;

- (void)setProgress:(float)progress duration:(float)duration;
@end

NS_ASSUME_NONNULL_END
