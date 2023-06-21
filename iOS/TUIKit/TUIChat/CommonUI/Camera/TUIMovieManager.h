
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMovieManager : NSObject

@property(nonatomic, assign) AVCaptureVideoOrientation referenceOrientation;

@property(nonatomic, assign) AVCaptureVideoOrientation currentOrientation;

@property(nonatomic, strong) AVCaptureDevice *currentDevice;

- (void)start:(void (^)(NSError *error))handle;

- (void)stop:(void (^)(NSURL *url, NSError *error))handle;

- (void)writeData:(AVCaptureConnection *)connection video:(AVCaptureConnection *)video audio:(AVCaptureConnection *)audio buffer:(CMSampleBufferRef)buffer;

@end

NS_ASSUME_NONNULL_END
