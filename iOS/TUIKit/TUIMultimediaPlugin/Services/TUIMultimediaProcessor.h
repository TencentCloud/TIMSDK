// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_Professional/TXVideoEditerListener.h>

NS_ASSUME_NONNULL_BEGIN

@interface TranscodeResult : NSObject
@property(nonatomic, assign) NSInteger errorCode;
@property(nonatomic, strong) NSString *errorString;
@property(nonatomic, strong) NSURL *transcodeUri;
@end

@interface TUIMultimediaProcessor : NSObject
+ (instancetype)shareInstance;
- (void)editMedia:(UIViewController *)caller
         url:(NSURL*) url
         complete:(void (^)(NSURL * url)) completion;

- (void)transcodeMedia:(NSURL*) uri
         complete:(void (^)(TranscodeResult* transcodeResult)) completeHandler
         progress:(void (^)(float progress))progressHandler;

@end


NS_ASSUME_NONNULL_END
