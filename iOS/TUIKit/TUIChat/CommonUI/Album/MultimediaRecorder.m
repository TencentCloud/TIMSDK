//
//  VideoRecorder.m
//  TUIChat
//
//  Created by yiliangwang on 2024/10/30.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "MultimediaRecorder.h"

@interface MultimediaRecorder ()

@end

@implementation MultimediaRecorder

+ (instancetype)sharedInstance {
    static MultimediaRecorder *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)registerAdvancedVideoRecorder:(id<IMultimediaRecorder>)videoRecorder {
    [MultimediaRecorder sharedInstance].advancedVideoRecorder = videoRecorder;
}

- (void)recordVideoWithCaller:(UIViewController *)caller
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock {
    id<IMultimediaRecorder> videoRecorder = nil;
    if ([MultimediaRecorder sharedInstance].advancedVideoRecorder) {
        videoRecorder = [MultimediaRecorder sharedInstance].advancedVideoRecorder;
    }
    
    if (videoRecorder && [videoRecorder respondsToSelector:@selector
                          (recordVideoWithCaller:successBlock:failureBlock:)]) {
        [videoRecorder recordVideoWithCaller:caller successBlock:successBlock failureBlock:failureBlock];
    }
}

@end
