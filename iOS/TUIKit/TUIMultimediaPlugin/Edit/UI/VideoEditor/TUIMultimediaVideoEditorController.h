// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaEncodeConfig.h"


NS_ASSUME_NONNULL_BEGIN

/**
 视频编辑界面Controller
 */
@interface TUIMultimediaVideoEditorController : UIViewController
@property(nullable, nonatomic) NSString *sourceVideoPath;
@property(nullable, nonatomic) NSString *resultVideoPath;
@property(nonatomic)int sourceType;
@property(nonatomic, nullable) void (^completeCallback)(NSString *resultVideoPath, int resultCode);
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
