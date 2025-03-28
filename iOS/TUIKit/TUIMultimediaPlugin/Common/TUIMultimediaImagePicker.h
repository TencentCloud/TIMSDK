// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIMultimediaImagePickerCallback)(UIImage *_Nullable image);

@interface TUIMultimediaImagePicker : NSObject
@property(nullable, nonatomic) TUIMultimediaImagePickerCallback callback;
- (instancetype)init;
- (void)presentOn:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
