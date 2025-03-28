// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>
#import "TUIMultimediaProcessor.h"
#import "TUIMultimediaPlugin/TUIMultimediaEncodeConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaVideoEditorController.h"
#import "TUIMultimediaPlugin/TUIMultimediaPictureEditorController.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaConstant.h"

@interface TUIMediaTranscode : NSObject
-(instancetype) initWithParameter:(NSURL*) url
                complete:(void (^)(TranscodeResult* transcodeResult)) completionHandler
                progress:(void (^)(float progress))progressHandler;
-(void) startTranscoding;
@end

@interface TUIMultimediaProcessor () {
    NSOperationQueue *_operationQueue;
    TUIMultimediaEncodeConfig *_encodeConfig;
}

@end

@implementation TranscodeResult

@end

@implementation TUIMultimediaProcessor

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init {
    self = [super init];
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 2;
    return self;
}

- (void)editVideo:(UIViewController *)caller
         url:(NSURL*) url
         complete:(void (^)(NSURL * url)) completion {
    NSLog(@"TUIMultimediaMediaProcessor editVideo url = %@", url.path);
    UINavigationController *callerNavigation = caller.navigationController;
    if (callerNavigation == nil) {
        callerNavigation = [[UINavigationController alloc] initWithRootViewController:caller];
    }
    
    __auto_type videoEditorCallback = ^(NSString *resultVideoPath, int resultCode) {
      NSLog(@"editVideo callback videoPath = %@, resultCode = %d", resultVideoPath, resultCode);
      [callerNavigation popViewControllerAnimated:YES];
      NSURL* transcodeUrl = nil;
      if (resultCode == VIDEO_EDIT_RESULT_CODE_GENERATE_SUCCESS && resultVideoPath != nil) {
          transcodeUrl = [NSURL fileURLWithPath:resultVideoPath];
      }
      completion(transcodeUrl);
    };
    
    TUIMultimediaVideoEditorController *editorController = [[TUIMultimediaVideoEditorController alloc] init];
    editorController.sourceVideoPath = url.path;
    editorController.completeCallback = videoEditorCallback;
    editorController.sourceType = SOURCE_TYPE_ALBUM;
    [callerNavigation pushViewController:editorController animated:YES];
}

- (void)editPicture:(UIViewController *)caller
            picture:(UIImage*) picture
            complete:(void (^)(UIImage * picture)) completion {
    NSLog(@"edit picture. picture:%@", picture);
    UINavigationController *callerNavigation = caller.navigationController;
    if (callerNavigation == nil) {
        callerNavigation = [[UINavigationController alloc] initWithRootViewController:caller];
    }
    
    __auto_type pictureEditorCallback = ^(UIImage *outImage, int resultCode) {
        NSLog(@"edit picture. call back output picture:%@, result code:%d", outImage, resultCode);
      [callerNavigation popViewControllerAnimated:YES];
      completion(outImage);
    };
    
    TUIMultimediaPictureEditorController *editorController = [[TUIMultimediaPictureEditorController alloc] init];
    editorController.srcPicture = picture;
    editorController.completeCallback = pictureEditorCallback;
    editorController.sourceType = SOURCE_TYPE_ALBUM;
    [callerNavigation pushViewController:editorController animated:YES];
}

- (void)transcodeVideo:(NSURL *)url
               complete:(void (^)(TranscodeResult *transcodeResult))completeHandler
               progress:(void (^)(float progress))progressHandler {
    NSLog(@"TUIMultimediaMediaProcessor transcodeVideo uri is %@", url.path);
    if (!url) {
        completeHandler(nil);
        return;
    }
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        TUIMediaTranscode *mediaTranscode = [[TUIMediaTranscode alloc] initWithParameter:url
                                                                       complete:completeHandler
                                                                       progress:progressHandler];
        [mediaTranscode startTranscoding];
    }];
    
    [_operationQueue addOperation:operation];
}
@end


@interface TUIMediaTranscode() <TXVideoGenerateListener> {
    TXVideoEditer* _editer;
    NSURL* _url;
    NSString* _resultVideoPath;
    TUIMultimediaEncodeConfig *_encodeConfig;
    void (^_completionHandler)(TranscodeResult* transcodeResult);
    void (^_progressHandler)(float progress);
    NSCondition *_condition;
}

@end

@implementation TUIMediaTranscode
-(instancetype) initWithParameter:(NSURL*) url
                complete:(void (^)(TranscodeResult* transcodeResult)) completionHandler
                progress:(void (^)(float progress))progressHandler {
    self = [super init];
    _editer = [[TXVideoEditer alloc] initWithPreview:nil];
    _editer.generateDelegate = self;
    _url = url;
    _completionHandler = completionHandler;
    _progressHandler = progressHandler;
    _condition = [[NSCondition alloc] init];
    return self;
}

- (void)startTranscoding{
    NSLog(@"TUIMultimediaMediaProcessor startTranscoding url is %@", _url.path);
    TUIMultimediaEncodeConfig* encodeConfig = [[TUIMultimediaEncodeConfig alloc] initWithVideoQuality:[[TUIMultimediaConfig sharedInstance] getVideoQuality]];
    [_editer setVideoPath:_url.path];
    [_editer setVideoBitrate:encodeConfig.bitrate];
    _resultVideoPath = [self getOutFilePath];
    [_condition lock];
    [_editer generateVideo:[encodeConfig getVideoEditCompressed] videoOutputPath:_resultVideoPath];
    [_condition wait];
    [_condition unlock];
    _condition = nil;
    _editer = nil;
}

- (void)stopTranscode{
    [_editer cancelGenerate];
}

- (void)onGenerateComplete:(TXGenerateResult *)result {
    NSLog(@"TUIMultimediaMediaProcessor onGenerateComplete transcodeUri is %@",[NSURL fileURLWithPath:_resultVideoPath]);
    [_condition lock];
    [_condition signal];
    [_condition unlock];
    
    TranscodeResult* transcodeResult = [TranscodeResult alloc];
    transcodeResult.errorCode = result.retCode;
    transcodeResult.transcodeUri =  [NSURL fileURLWithPath:_resultVideoPath];
    transcodeResult.errorString = result.descMsg;
    if (_completionHandler) {
        _completionHandler(transcodeResult);
    }
}

- (void)onGenerateProgress:(float)progress {
    if (_progressHandler) {
        _progressHandler(progress);
    }
}

-(NSString*) getOutFilePath{
    NSDate* currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString* currentDateString = [dateFormatter stringFromDate:currentDate];
    NSString* outFileName = [NSString stringWithFormat:@"%@-%u-temp.mp4", currentDateString, arc4random()];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:outFileName];
}
@end
