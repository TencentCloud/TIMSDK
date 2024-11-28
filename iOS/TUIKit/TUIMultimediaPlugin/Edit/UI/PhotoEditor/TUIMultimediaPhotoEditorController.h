// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIMultimediaPhotoEditorControllerCallback)(NSURL * _Nullable url, int resultCode);

@interface TUIMultimediaPhotoEditorController : UIViewController
@property(nonatomic) UIImage *photo;
@property(nonatomic) TUIMultimediaPhotoEditorControllerCallback completeCallback;
@end

NS_ASSUME_NONNULL_END
