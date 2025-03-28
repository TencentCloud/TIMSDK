// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIMultimediaPictureEditorControllerCallback)(UIImage * _Nullable outImage, int resultCode);

@interface TUIMultimediaPictureEditorController : UIViewController
@property(nonatomic) UIImage *srcPicture;
@property(nonatomic) TUIMultimediaPictureEditorControllerCallback completeCallback;
@property(nonatomic)int sourceType;
@end

NS_ASSUME_NONNULL_END
