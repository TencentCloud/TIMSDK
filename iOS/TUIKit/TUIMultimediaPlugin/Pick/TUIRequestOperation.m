//
//  TUIRequestOperation.m
//  TUIRequestOperation
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import "TUIRequestOperation.h"
#import <TUIMultimediaCore/TUIImageManager.h>

@interface TUIRequestOperation()
@property (nonatomic, copy, nullable) TUIRequestCompletedBlock completedBlock;
@property (nonatomic, copy, nullable) TUIRequestProgressBlock progressBlock;
@property (nonatomic, strong, nullable) PHAsset *asset;
@end

@implementation TUIRequestOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithAsset:(PHAsset *)asset completed:(TUIRequestCompletedBlock)completedBlock progress:(TUIRequestProgressBlock)progressBlock {
    self = [super init];
    self.asset = asset;
    self.completedBlock = completedBlock;
    self.progressBlock = progressBlock;
    _executing = NO;
    _finished = NO;
    return self;
}

- (void)start {
    self.executing = YES;
    [[TUIImageManager defaultManager] getPhotoWithAsset:self.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (isDegraded) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completedBlock) {
                self.completedBlock(photo, info);
            }
            [self done];
        });
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) {
                self.progressBlock(progress, error, stop, info);
            }
        });
    } networkAccessAllowed:YES];
}

- (void)done {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.finished = YES;
        self.executing = NO;
        [self reset];
    });
}

- (void)reset {
    self.asset = nil;
    self.completedBlock = nil;
    self.progressBlock = nil;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isAsynchronous {
    return YES;
}

@end
