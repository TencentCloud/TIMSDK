//
//  TUIRequestOperation.h
//  TUIRequestOperation
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIRequestOperation : NSOperation

typedef void(^TUIRequestCompletedBlock)(UIImage *photo, NSDictionary *info);
typedef void(^TUIRequestProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

- (instancetype)initWithAsset:(PHAsset *)asset completed:(TUIRequestCompletedBlock)completedBlock progress:(TUIRequestProgressBlock)progressBlock;
- (void)done;
@end

NS_ASSUME_NONNULL_END
