
#import "TUIMovieManager.h"

@interface TUIMovieManager()
{
    BOOL                _readyToRecordVideo;
    BOOL                _readyToRecordAudio;
    dispatch_queue_t    _movieWritingQueue;

    NSURL              *_movieURL;
    AVAssetWriter      *_movieWriter;
    AVAssetWriterInput *_movieAudioInput;
    AVAssetWriterInput *_movieVideoInput;
}

@end

@implementation TUIMovieManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _movieWritingQueue = dispatch_queue_create("com.tui.Movie.Writing.Queue", DISPATCH_QUEUE_SERIAL);
        _movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), @"TUICaptureTempMovie.mov"]];
        _referenceOrientation = AVCaptureVideoOrientationPortrait;
    }
    return self;
}

- (void)start:(void(^)(NSError *error))handle {

    [self removeFile:self->_movieURL];
        
    NSError *error;
    if (!self->_movieWriter) {
        self->_movieWriter = [[AVAssetWriter alloc] initWithURL:self->_movieURL fileType:AVFileTypeQuickTimeMovie error:&error];
    }
    handle(error);
}

- (void)stop:(void(^)(NSURL *url, NSError *error))handle{
    _readyToRecordVideo = NO;
    _readyToRecordAudio = NO;
    
    if (self->_movieWriter && self->_movieWriter.status == AVAssetWriterStatusWriting) {
        
        [self->_movieWriter finishWritingWithCompletionHandler:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self->_movieWriter.status == AVAssetWriterStatusCompleted) {
                    handle(self->_movieURL, nil);
                } else {
                    handle(nil, self->_movieWriter.error);
                }
                self->_movieWriter = nil;
            });
        }];
    } else {
        [self->_movieWriter cancelWriting];
        self->_movieWriter = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handle(nil, [NSError errorWithDomain:@"com.tui.Movie.Writing" code:0 userInfo:@{NSLocalizedDescriptionKey:@"AVAssetWriter状态错误"}]);
        });
    }
}

- (void)writeData:(AVCaptureConnection *)connection video:(AVCaptureConnection*)video audio:(AVCaptureConnection *)audio buffer:(CMSampleBufferRef)buffer {
    
    CFRetain(buffer);
    if (connection == video){
        if (!self->_readyToRecordVideo){
            self->_readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(buffer)] == nil;
        }
        if ([self inputsReadyToRecord]){
            [self writeSampleBuffer:buffer ofType:AVMediaTypeVideo];
        }
    } else if (connection == audio){
        if (!self->_readyToRecordAudio) {
            self->_readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(buffer)] == nil;
        }
        if ([self inputsReadyToRecord]){
            [self writeSampleBuffer:buffer ofType:AVMediaTypeAudio];
        }
    }
    CFRelease(buffer);
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType{
    if (_movieWriter.status == AVAssetWriterStatusUnknown){
        if ([_movieWriter startWriting]){
            [_movieWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            NSLog(@"%@", _movieWriter.error);
        }
    }
    if (_movieWriter.status == AVAssetWriterStatusWriting){
        if (mediaType == AVMediaTypeVideo){
            if (!_movieVideoInput.readyForMoreMediaData){
                return;
            }
            if (![_movieVideoInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"%@", _movieWriter.error);
            }
        } else if (mediaType == AVMediaTypeAudio) {
            if (!_movieAudioInput.readyForMoreMediaData) {
                return;
            }
            if (![_movieAudioInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"%@", _movieWriter.error);
            }
        }
    }
}

- (BOOL)inputsReadyToRecord{
    return _readyToRecordVideo && _readyToRecordAudio;
}

/// 音频源数据写入配置
- (NSError *)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *channelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription,&aclSize);
    NSData *dataLayout = aclSize > 0 ? [NSData dataWithBytes:channelLayout length:aclSize] : [NSData data];
    NSDictionary *settings = @{AVFormatIDKey: [NSNumber numberWithInteger: kAudioFormatMPEG4AAC],
                             AVSampleRateKey: [NSNumber numberWithFloat: currentASBD->mSampleRate],
                          AVChannelLayoutKey: dataLayout,
                       AVNumberOfChannelsKey: [NSNumber numberWithInteger: currentASBD->mChannelsPerFrame],
               AVEncoderBitRatePerChannelKey: [NSNumber numberWithInt: 64000]};

    if ([_movieWriter canApplyOutputSettings:settings forMediaType: AVMediaTypeAudio]){
        _movieAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings:settings];
        _movieAudioInput.expectsMediaDataInRealTime = YES;
        if ([_movieWriter canAddInput:_movieAudioInput]){
            [_movieWriter addInput:_movieAudioInput];
        } else {
            return _movieWriter.error;
        }
    } else {
        return _movieWriter.error;
    }
    return nil;
}

/// 视频源数据写入配置
- (NSError *)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    CGFloat bitsPerPixel = numPixels < (640 * 480) ? 4.05 : 11.0;
    NSDictionary *compression = @{AVVideoAverageBitRateKey: [NSNumber numberWithInteger: numPixels * bitsPerPixel],
                                  AVVideoMaxKeyFrameIntervalKey: [NSNumber numberWithInteger:30]};
    NSDictionary *settings = @{AVVideoCodecKey: AVVideoCodecH264,
                               AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
                              AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
               AVVideoCompressionPropertiesKey: compression};

    if ([_movieWriter canApplyOutputSettings:settings forMediaType:AVMediaTypeVideo]){
        _movieVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        _movieVideoInput.expectsMediaDataInRealTime = YES;
        _movieVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_movieWriter canAddInput:_movieVideoInput]){
            [_movieWriter addInput:_movieVideoInput];
        } else {
            return _movieWriter.error;
        }
    } else {
        return _movieWriter.error;
    }
    return nil;
}

// 获取视频旋转矩阵
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.currentOrientation];
    CGFloat angleOffset;
    if (self.currentDevice.position == AVCaptureDevicePositionBack) {
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    } else {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

// 获取视频旋转角度
- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat angle = 0.0;
    switch (orientation){
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
    }
    return angle;
}

// 移除文件
- (void)removeFile:(NSURL *)fileURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = fileURL.path;
    if ([fileManager fileExistsAtPath:filePath]){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success) {
            NSAssert(NO, error.localizedDescription);
            NSLog(@"删除视频文件失败：%@", error);
        } else {
            NSLog(@"删除视频文件成功");
        }
    }
}

@end
