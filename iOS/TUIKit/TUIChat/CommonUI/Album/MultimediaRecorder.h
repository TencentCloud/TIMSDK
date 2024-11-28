//
//  VideoRecorder.h
//  TUIChat
//
//  Created by yiliangwang on 2024/10/30.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^VideoRecorderSuccessBlock)(NSURL *uri);
typedef void (^VideoRecorderFailureBlock)(NSInteger errorCode, NSString *errorMessage);

@protocol IMultimediaRecorder <NSObject>
- (void)recordVideoWithCaller:(UIViewController *)caller
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock;

-(void)takePhoneWithCaller:(UIViewController *)caller
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock;

@end

@interface MultimediaRecorder : NSObject
@property (nonatomic, strong) id<IMultimediaRecorder> advancedVideoRecorder;

+ (instancetype)sharedInstance;

+ (void)registerAdvancedVideoRecorder:(id<IMultimediaRecorder>)videoRecorder;

- (void)recordVideoWithCaller:(UIViewController *)caller
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock;

-(void)takePhoneWithCaller:(UIViewController *)caller
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock;
@end

NS_ASSUME_NONNULL_END
