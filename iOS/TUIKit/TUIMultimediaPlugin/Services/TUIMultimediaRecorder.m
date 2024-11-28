// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaRecorder.h"
#import <TUIChat/MultimediaRecorder.h>

#import "TUIMultimediaSignatureChecker.h"
#import "TUIMultimediaEncodeConfig.h"
#import "TUIMultimediaVideoEditorController.h"
#import "TUIMultimediaConfig.h"
#import "TUIMultimediaRecordController.h"
#import "TUIMultimediaPhotoEditorController.h"
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
    
    __auto_type photoEditorVCCallback = ^(NSURL *outImageFile, int resultCode) {
        if (PHOTO_EDIT_RESULT_CODE_CANCEL == resultCode || PHOTO_EDIT_RESULT_CODE_GENERATE_FAIL == resultCode || outImageFile == nil) {
            [navigation popViewControllerAnimated:YES];
        } else {
            successBlock(outImageFile);
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
          TUIMultimediaPhotoEditorController *photoEditorController = [[TUIMultimediaPhotoEditorController alloc] init];
          photoEditorController.photo = photo;
          photoEditorController.completeCallback = photoEditorVCCallback;
          [navigation pushViewController:photoEditorController animated:YES];
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

@end

