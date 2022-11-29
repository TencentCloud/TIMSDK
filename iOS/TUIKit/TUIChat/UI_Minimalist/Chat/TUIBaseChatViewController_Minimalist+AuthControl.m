//
//  TUIBaseChatViewController+AuthControl.m
//  TUIChat
//
//  Created by wyl on 2022/2/14.
//

#import "TUIBaseChatViewController_Minimalist+AuthControl.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIBaseMessageController_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUIFileMessageCellData_Minimalist.h"
#import "TUIVoiceMessageCellData_Minimalist.h"
#import "TUIDefine.h"
#import "TUIMessageMultiChooseView_Minimalist.h"
#import "TUIMessageController_Minimalist.h"
#import "TUIChatDataProvider_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUICameraViewController.h"
#import "TUITool.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "NSDictionary+TUISafe.h"
#import "NSString+emoji.h"
#import "TUIThemeManager.h"
#import "PhotosUI/PhotosUI.h"
#import "TUIUserAuthorizationCenter.h"
#import <objc/runtime.h>

@interface TUIBaseChatViewController_Minimalist (AuthControl)<UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, TUICameraViewControllerDelegate, TUINotificationProtocol,PHPickerViewControllerDelegate>

@property (nonatomic, copy) void (^cameraViewControllerDidPictureLibCallback)(void);

@end

@implementation TUIBaseChatViewController_Minimalist (AuthControl)


- (void (^)(void))cameraViewControllerDidPictureLibCallback  {
    return objc_getAssociatedObject(self, @selector(cameraViewControllerDidPictureLibCallback));
}

- (void)setCameraViewControllerDidPictureLibCallback:(void (^)(void))cameraViewControllerDidPictureLibCallback {
    objc_setAssociatedObject(self, @selector(cameraViewControllerDidPictureLibCallback), cameraViewControllerDidPictureLibCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
#pragma mark - UIImagePickerController & UIDocumentPickerViewController
- (void)selectPhotoForSend
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)takePictureForSend
{
    __weak typeof(self)weakSelf = self;

    void(^actionBlock)(void) = ^(void) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        TUICameraViewController *vc = [[TUICameraViewController alloc] init];
        vc.type = TUICameraMediaTypePhoto;
        vc.delegate = strongSelf;
        [strongSelf.navigationController pushViewController:vc animated:YES];
    };
    if ([TUIUserAuthorizationCenter isEnableCameraAuthorization]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            actionBlock();
        });
    }
    else {
        if (![TUIUserAuthorizationCenter isEnableCameraAuthorization]) {
            [TUIUserAuthorizationCenter cameraStateActionWithPopCompletion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        actionBlock();
                    });
            }];
        };
    }

}

- (void)takeVideoForSend
{
    __weak typeof(self)weakSelf = self;
    void(^actionBlock)(void) = ^(void) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        TUICameraViewController *vc = [[TUICameraViewController alloc] init];
        vc.type = TUICameraMediaTypeVideo;
        vc.videoMinimumDuration = 1.5;
        vc.delegate = strongSelf;
        [strongSelf.navigationController pushViewController:vc animated:YES];
    };
    
    if ([TUIUserAuthorizationCenter isEnableMicroAuthorization] &&
        [TUIUserAuthorizationCenter isEnableCameraAuthorization]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            actionBlock();
        });
    }
    else {
        if (![TUIUserAuthorizationCenter isEnableMicroAuthorization]) {
            [TUIUserAuthorizationCenter microStateActionWithPopCompletion:^{
                if ([TUIUserAuthorizationCenter isEnableCameraAuthorization]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        actionBlock();
                    });
                }
            }];
        }
        if (![TUIUserAuthorizationCenter isEnableCameraAuthorization]) {
            [TUIUserAuthorizationCenter cameraStateActionWithPopCompletion:^{
                if ([TUIUserAuthorizationCenter isEnableMicroAuthorization]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        actionBlock();
                    });
                }
            }];
        }
    }
 

}

- (void)selectFileForSend
{
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    @weakify(self)
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp)
            {
                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
                CGFloat aspectWidth = image.size.width * aspectRatio;
                CGFloat aspectHeight = image.size.height * aspectRatio;

                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

            NSData *data = UIImageJPEGRepresentation(image, 0.75);
            NSString *path = [TUIKit_Image_Path stringByAppendingString:[TUITool genImageName:nil]];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            
            V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:path];
            [self sendMessage:message];
            [self excuteCallbackAfterMediaDataSelected];
        }
        else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            if (url) {
                [self transcodeIfNeed:url];
                return;
            }
            
            /**
             * 在某些情况下，UIImagePickerControllerMediaURL 可能为空，使用 UIImagePickerControllerPHAsset
             * In some cases UIImagePickerControllerMediaURL may be empty, use UIImagePickerControllerPHAsset
             */
            PHAsset *asset = nil;
            if (@available(iOS 11.0, *)) {
                asset = [info objectForKey:UIImagePickerControllerPHAsset];
            }
            if (asset) {
                [self originURLWithAsset:asset completion:^(BOOL success, NSURL *URL) {
                    if (success) {
                        [self transcodeIfNeed:URL];
                        return;
                    }
                }];
                return;
            }
            
            /**
             * 在 ios 12 的情况下，UIImagePickerControllerMediaURL 及 UIImagePickerControllerPHAsset 可能为空，需要使用其他方式获取视频文件原始路径
             * In the case of ios 12, UIImagePickerControllerMediaURL and UIImagePickerControllerPHAsset may be empty, and other methods need to be used to obtain the original path of the video file
             */
            url = [info objectForKey:UIImagePickerControllerReferenceURL];
            if (url) {
                [self originURLWithRefrenceURL:url completion:^(BOOL success, NSURL *URL) {
                    if (success) {
                        [self transcodeIfNeed:URL];
                    }
                }];
                return;
            }
            
            [self.view makeToast:@"not support this video"];
        }
    }];
}

/**
 * 根据 UIImagePickerControllerReferenceURL 获取原始文件路径
 * Get the original file path based on UIImagePickerControllerReferenceURL
 */
- (void)originURLWithRefrenceURL:(NSURL *)URL completion:(void(^)(BOOL success, NSURL *URL))completion
{
    if (completion == nil) {
        return;
    }
    NSDictionary *queryInfo = [self dictionaryWithURLQuery:URL.query];
    NSString *fileName = @"temp.mp4";
    if ([queryInfo.allKeys containsObject:@"id"] && [queryInfo.allKeys containsObject:@"ext"]) {
        fileName = [NSString stringWithFormat:@"%@.%@", queryInfo[@"id"], [queryInfo[@"ext"] lowercaseString]];
    }
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
    if ([NSFileManager.defaultManager isDeletableFileAtPath:filePath]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
    }
    NSURL *newUrl = [NSURL fileURLWithPath:filePath];
    ALAssetsLibrary *assetLibrary= [[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:URL resultBlock:^(ALAsset *asset) {
        if (asset == nil) {
            completion(NO, nil);
            return;
        }
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
        BOOL flag = [NSFileManager.defaultManager createFileAtPath:filePath contents:data attributes:nil];
        completion(flag, newUrl);
    } failureBlock:^(NSError *err) {
        completion(NO, nil);
    }];
}

- (void)originURLWithAsset:(PHAsset *)asset completion:(void(^)(BOOL success, NSURL *URL))completion
{
    if (completion == nil) {
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            completion(NO, nil);
            return;
        }
        
        NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
        if (resources.count == 0) {
            completion(NO, nil);
            return;
        }
        
        PHAssetResourceRequestOptions *options = [[PHAssetResourceRequestOptions alloc] init];
        options.networkAccessAllowed = NO;
        __block BOOL invoked = NO;
        [PHAssetResourceManager.defaultManager requestDataForAssetResource:resources.firstObject options:options dataReceivedHandler:^(NSData * _Nonnull data) {
            /**
             * 此处会有重复回调的问题
             * There will be a problem of repeated callbacks here
             */
            if (invoked) {
                return;
            }
            invoked = YES;
            if (data == nil) {
                completion(NO, nil);
                return;
            }
            NSString *fileName = @"temp.mp4";
            NSString* tempPath = NSTemporaryDirectory();
            NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
            if ([NSFileManager.defaultManager isDeletableFileAtPath:filePath]) {
                [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
            }
            NSURL *newUrl = [NSURL fileURLWithPath:filePath];
            BOOL flag = [NSFileManager.defaultManager createFileAtPath:filePath contents:data attributes:nil];
            completion(flag, newUrl);
        } completionHandler:^(NSError * _Nullable error) {
            completion(NO, nil);
        }];
    }];
}

- (NSDictionary *)dictionaryWithURLQuery:(NSString *)query
{
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *item in components) {
        NSArray *subs = [item componentsSeparatedByString:@"="];
        if (subs.count == 2) {
            [dict setObject:subs.lastObject forKey:subs.firstObject];
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];;
}

- (void)transcodeIfNeed:(NSURL *)url
{
    if ([url.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
        [self sendVideoWithUrl:url];
    } else {
        NSString* tempPath = NSTemporaryDirectory();
        NSURL *urlName = [url URLByDeletingPathExtension];
        NSURL *newUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@%@.mp4", tempPath,[urlName.lastPathComponent stringByRemovingPercentEncoding]]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:newUrl.path]){
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:newUrl.path error:&error];
            if (!success || error) {
                NSAssert1(NO, @"removeItemFail: %@", error.localizedDescription);
                return;
            }
        }
        // mov to mp4
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = newUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export session failed");
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    //Video conversion finished
                    NSLog(@"Successful!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self sendVideoWithUrl:newUrl];
                    });
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)sendVideoWithUrl:(NSURL*)url {
    [TUITool dispatchMainAsync:^{
        V2TIMMessage *message = [TUIMessageDataProvider_Minimalist getVideoMessageWithURL:url];
        [self sendMessage:message];
        [self excuteCallbackAfterMediaDataSelected];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    @weakify(self)
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        @strongify(self)
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        NSString *fileName = [url lastPathComponent];
        NSString *filePath = [TUIKit_File_Path stringByAppendingString:fileName];
        if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
            /**
             * 存在同名文件，对文件名进行递增
             * If a file with the same name exists, increment the file name
             */
            int i = 0;
            NSArray *arrayM = [NSFileManager.defaultManager subpathsAtPath:TUIKit_File_Path];
            for (NSString *sub in arrayM) {
                if ([sub.pathExtension isEqualToString:fileName.pathExtension] &&
                    [sub.stringByDeletingPathExtension containsString:fileName.stringByDeletingPathExtension]) {
                    i++;
                }
            }
            if (i) {
                fileName = [fileName stringByReplacingOccurrencesOfString:fileName.stringByDeletingPathExtension withString:[NSString stringWithFormat:@"%@(%d)", fileName.stringByDeletingPathExtension, i]];
                filePath = [TUIKit_File_Path stringByAppendingString:fileName];
            }
        }
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            
            V2TIMMessage *message = [[V2TIMManager sharedInstance] createFileMessage:filePath fileName:fileName];
            [self sendMessage:message];
        }
    }];
    [url stopAccessingSecurityScopedResource];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TUICameraViewControllerDelegate
- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithVideoURL:(NSURL *)url {
    [self transcodeIfNeed:url];
}

- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithImageData:(NSData *)data {
    NSString *path = [TUIKit_Image_Path stringByAppendingString:[TUITool genImageName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:path];
    [self sendMessage:message];
    [self excuteCallbackAfterMediaDataSelected];
}


- (void)cameraViewControllerDidCancel:(TUICameraViewController *)controller {
}

- (void)cameraViewControllerDidPictureLib:(TUICameraViewController *)controller finishCallback:(void (^)(void))callback{
    [self selectPhotoForSendV2];
    if (callback) {
        self.cameraViewControllerDidPictureLibCallback = callback;
    }
}
#pragma mark - New version for Assets in iOS 14
- (void)selectPhotoForSendV2 {
    
    if (@available(iOS 14, *)) {
        PHAccessLevel level =  PHAccessLevelReadWrite;
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
          switch (status) {
              case PHAuthorizationStatusLimited:
                  NSLog(@"limited");
                  [self _takeImagePhoto];
                  break;
              case PHAuthorizationStatusDenied:
                  [TUIUserAuthorizationCenter showAlert:TUIChatAuthControlTypePhoto];
                  break;
              case PHAuthorizationStatusAuthorized:
                  NSLog(@"authorized");
                  [self _takeImagePhoto];
                  break;
              case PHAuthorizationStatusNotDetermined:
                  NSLog(@"denied");
                  [self _requestPhotoAuthorization];
                  break;

              default:
                  break;
        }
    } else {
        PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
        if (photoAuthorStatus ==PHAuthorizationStatusAuthorized ) {
            [self _takeImagePhoto];
        }else{
            [self _requestPhotoAuthorization];
        }
    }

}

- (void)_requestPhotoAuthorization {
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        /**
         * 请求权限，需注意 limited 权限仅在 accessLevel 为 readAndWrite 时生效
         * Request permission, it should be noted that limited permission only takes effect when the accessLevel is readAndWrite
         */
        [PHPhotoLibrary requestAuthorizationForAccessLevel:level handler:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusLimited: {
                    NSLog(@"limited");
                }
                    break;
                case PHAuthorizationStatusDenied:
                    NSLog(@"denied");
                    [TUIUserAuthorizationCenter showAlert:TUIChatAuthControlTypePhoto];
                    break;
                case PHAuthorizationStatusAuthorized:
                    NSLog(@"authorized");
                    [self _takeImagePhoto];
                    break;
                default:
                    break;
            }
        }];
    } else {
        /**
         * 获取相册访问权限 ios8 之后推荐用这种方法
         * 该方法提示用户授权对相册的访问
         *
         * This method is recommended for obtaining album access permissions after ios8
         * This method prompts the user to authorize access to the album
         */
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusDenied) {
                [TUIUserAuthorizationCenter showAlert:TUIChatAuthControlTypePhoto];
            }else if (status == PHAuthorizationStatusAuthorized){
                [self _takeImagePhoto];
            }
        }];
    }
}

- (void)_takeImagePhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 14.0, *)) {
            PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
            configuration.filter = [PHPickerFilter anyFilterMatchingSubfilters:@[[PHPickerFilter imagesFilter],
                                            [PHPickerFilter videosFilter]]];
            configuration.selectionLimit = 1; // 默认为1，为0时表示可多选。
            PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
            picker.delegate = self;
            picker.modalPresentationStyle = UIModalPresentationFullScreen;
            picker.view.backgroundColor = [UIColor whiteColor];
            [self presentViewController:picker animated:YES completion:^{
            }];
        } else {
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                picker.delegate = self;
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    });
}


- (void)excuteCallbackAfterMediaDataSelected {
    if (self.cameraViewControllerDidPictureLibCallback) {
        self.cameraViewControllerDidPictureLibCallback();
    }
}

#pragma mark - PHPickerViewControllerDelegate
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult*> *)results API_AVAILABLE(ios(14)){
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
    
    if(!results || !results.count) {
        return;
    }else{
        PHPickerResult *result = [results firstObject];
        NSItemProvider *itemProvoider = result.itemProvider;
        __weak typeof(self) weakSelf = self;
        if ([itemProvoider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
            [itemProvoider loadDataRepresentationForTypeIdentifier:(NSString *)kUTTypeImage completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
                __strong typeof(self) strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *path = [TUIKit_Image_Path stringByAppendingString:[TUITool genImageName:nil]];
                    UIImage *transImg = [[UIImage alloc] initWithData:data];
                    UIImageOrientation imageOrientation = transImg.imageOrientation;
                    if(imageOrientation != UIImageOrientationUp)
                    {
                        CGFloat aspectRatio = MIN ( 1920 / transImg.size.width, 1920 / transImg.size.height );
                        CGFloat aspectWidth = transImg.size.width * aspectRatio;
                        CGFloat aspectHeight = transImg.size.height * aspectRatio;

                        UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                        [transImg drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                        transImg = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    NSData * jpegData = UIImageJPEGRepresentation(transImg, 0.75);
                    [[NSFileManager defaultManager] createFileAtPath:path contents:jpegData attributes:nil];
                    V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:path];
                    [strongSelf sendMessage:message];
                    [strongSelf excuteCallbackAfterMediaDataSelected];
                });
            }];
        }
        else if ([itemProvoider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMPEG4]) {
             [itemProvoider loadDataRepresentationForTypeIdentifier:(NSString *)kUTTypeMovie completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSString *fileName = @"temp.mp4";
                     NSString* tempPath = NSTemporaryDirectory();
                     NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
                     if ([NSFileManager.defaultManager isDeletableFileAtPath:filePath]) {
                         [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
                     }
                     NSURL *newUrl = [NSURL fileURLWithPath:filePath];
                     BOOL flag = [NSFileManager.defaultManager createFileAtPath:filePath contents:data attributes:nil];
                     if (flag) {
                         [self transcodeIfNeed:newUrl];
                     }
                 });
             }];
         }
         else if ([itemProvoider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
            [itemProvoider loadDataRepresentationForTypeIdentifier:(NSString *)kUTTypeMovie completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 非 mp4 格式视频，暂时用 mov 后缀，后面会统一转换成 mp4 格式
                    // Non-mp4 format video, temporarily use mov suffix, will be converted to mp4 format later
                    NSString *fileName = @"temp.mov";
                    NSString* tempPath = NSTemporaryDirectory();
                    NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
                    if ([NSFileManager.defaultManager isDeletableFileAtPath:filePath]) {
                        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
                    }
                    NSURL *newUrl = [NSURL fileURLWithPath:filePath];
                    BOOL flag = [NSFileManager.defaultManager createFileAtPath:filePath contents:data attributes:nil];
                    if (flag) {
                        [self transcodeIfNeed:newUrl];
                    }
                });
            }];
         }
         else {
            NSString * typeIdentifier = result.itemProvider.registeredTypeIdentifiers.firstObject;
            [itemProvoider loadFileRepresentationForTypeIdentifier:typeIdentifier completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage * result;
                    NSData * data = [NSData dataWithContentsOfURL:url];
                    result = [UIImage imageWithData:data];

                    /**
                     * Can't get url when typeIdentifier is public.jepg on emulator:
                     * There is a separate JEPG transcoding issue that only affects the simulator (63426347), please refer to https://developer.apple.com/forums/thread/658135 for more information.
                     */
                });
            }];
        }
    }
}


@end

