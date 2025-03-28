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
- (void)editVideo:(UIViewController *)caller
         url:(NSURL*) url
         complete:(void (^)(NSURL * url)) completion;

- (void)transcodeVideo:(NSURL*) uri
         complete:(void (^)(TranscodeResult* transcodeResult)) completeHandler
         progress:(void (^)(float progress))progressHandler;

- (void)editPicture:(UIViewController *)caller
            picture:(UIImage*) picture
            complete:(void (^)(UIImage *picture)) completion;

@end


NS_ASSUME_NONNULL_END
