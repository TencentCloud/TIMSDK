// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <TXLiteAVSDK_Professional/TXUGCRecord.h>
#import <UIKit/UIKit.h>
#import "TUIMultimediaEncodeConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIMultimediaRecordResultCallback)(NSString *_Nullable videoPath, UIImage *_Nullable image);

@interface TUIMultimediaRecordController : UIViewController
@property(nullable, nonatomic) TUIMultimediaRecordResultCallback resultCallback;
@property(nonatomic) BOOL isOnlySupportTakePhoto;
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
