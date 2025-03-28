// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaRecorder.h"
#import <TUIChat/MultimediaRecorder.h>

#import "TUIMultimediaSignatureChecker.h"
#import "TUIMultimediaEncodeConfig.h"
#import "TUIMultimediaVideoEditorController.h"
#import "TUIMultimediaConfig.h"
#import "TUIMultimediaRecordController.h"
#import "TUIMultimediaPictureEditorController.h"
#import "TUIMultimediaPlugin/TUIMultimediaConstant.h"

@interface TUIMultimediaRecorder () <IMultimediaRecorder> {
}

@end

@implementation TUIMultimediaRecorder

- (void)recordVideoWithCaller:(UIViewController *)caller
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock {
    [self openRecodeWithCaller:caller isOnlySupportTakePhone:NO successBlock:successBlock failureBlock:failureBlock];
}

-(void)takePhoneWithCaller:(UIViewController *)caller
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock {
    [self openRecodeWithCaller:caller isOnlySupportTakePhone:YES successBlock:successBlock failureBlock:failureBlock];
}


- (void)openRecodeWithCaller:(UIViewController *)caller
              isOnlySupportTakePhone:(BOOL)isOnlySupportTakePhone
              successBlock:(VideoRecorderSuccessBlock)successBlock
              failureBlock:(VideoRecorderFailureBlock)failureBlock {
    UINavigationController *navigation = caller.navigationController;
    if (navigation == nil) {
        navigation = [[UINavigationController alloc] initWithRootViewController:caller];
    }
    
    __auto_type videoEditorVCCallback = ^(NSString *resultVideoPath, int resultCode) {
        if (VIDEO_EDIT_RESULT_CODE_CANCEL == resultCode || VIDEO_EDIT_RESULT_CODE_GENERATE_FAIL == resultCode || resultVideoPath == nil) {
            [navigation popViewControllerAnimated:YES];
        } else {
            successBlock([NSURL fileURLWithPath:resultVideoPath]);
            [navigation popViewControllerAnimated:NO];
            [navigation popViewControllerAnimated:YES];
        }
    };
    
    __auto_type photoEditorVCCallback = ^(UIImage *outImage, int resultCode) {
        if (PHOTO_EDIT_RESULT_CODE_CANCEL == resultCode || PHOTO_EDIT_RESULT_CODE_GENERATE_FAIL == resultCode || outImage == nil) {
            [navigation popViewControllerAnimated:YES];
        } else {
            NSString *outFilePath = [self getPictureOutFilePath];
            BOOL isSaveImageSuccess = [self saveImageAsJPEG:outImage filePath:outFilePath];
            if (!isSaveImageSuccess) {
                [navigation popViewControllerAnimated:YES];
                return;
            }
            successBlock([NSURL fileURLWithPath:outFilePath]);
            [navigation popViewControllerAnimated:NO];
            [navigation popViewControllerAnimated:YES];
        }
    };
    
    __auto_type recordVCEditCallback = ^(NSString *videoPath, UIImage *photo) {
      if (videoPath != nil) {
          TUIMultimediaVideoEditorController *videoEditorController = [[TUIMultimediaVideoEditorController alloc] init];
          videoEditorController.sourceVideoPath = videoPath;
          videoEditorController.completeCallback = videoEditorVCCallback;
          videoEditorController.sourceType = SOURCE_TYPE_RECORD;
          [navigation pushViewController:videoEditorController animated:YES];
      } else if (photo != nil) {
          NSLog(@"record editPicture enter");
          TUIMultimediaPictureEditorController *pictureEditorController = [[TUIMultimediaPictureEditorController alloc] init];
          pictureEditorController.srcPicture = photo;
          pictureEditorController.completeCallback = photoEditorVCCallback;
          [navigation pushViewController:pictureEditorController animated:YES];
      } else {
          [navigation popViewControllerAnimated:YES];
          return;
      }
    };
    
    TUIMultimediaRecordController *recordController = [[TUIMultimediaRecordController alloc] init];
    recordController.resultCallback = recordVCEditCallback;
    recordController.isOnlySupportTakePhoto = isOnlySupportTakePhone;
    [navigation pushViewController:recordController animated:YES];
}

- (NSString *)getPictureOutFilePath {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    NSString *outFileName = [NSString stringWithFormat:@"%@-%u-temp.jpg", currentDateString, arc4random()];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:outFileName];
}

- (BOOL)saveImageAsJPEG:(UIImage *)image filePath:(NSString *)filePath {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    BOOL success = [imageData writeToFile:filePath atomically:YES];
    if (!success) {
        NSLog(@"Failed to save image as JPEG file. filePath is %@", filePath);
    }
    return success;
}

@end

