//
//  TUIBaseChatViewController+AuthControl.m
//  TUIChat
//
//  Created by wyl on 2022/2/14.
//

#import "TUIBaseChatViewController+AuthControl.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIMessageController.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUIDefine.h"
#import "TUIMessageMultiChooseView.h"
#import "TUIMessageSearchController.h"
#import "TUIChatDataProvider.h"
#import "TUIMessageDataProvider.h"
#import "TUICameraViewController.h"
#import "TUITool.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "NSDictionary+TUISafe.h"
#import "NSString+emoji.h"
#import "TUIThemeManager.h"
#import "PhotosUI/PhotosUI.h"
#import "TUIUserAuthorizationCenter.h"

@interface TUIBaseChatViewController (AuthControl)<UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, TUICameraViewControllerDelegate, TUINotificationProtocol,PHPickerViewControllerDelegate>
@end
@implementation TUIBaseChatViewController (AuthControl)
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
    // 快速点的时候会回调多次
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
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                [self.delegate chatController:self didSendMessage:message];
            }
        }
        else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            if (url) {
                [self transcodeIfNeed:url];
                return;
            }
            
            // 在某些情况下，UIImagePickerControllerMediaURL 可能为空，使用 UIImagePickerControllerPHAsset
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
            
            // 在 ios 12 的情况下，UIImagePickerControllerMediaURL 及 UIImagePickerControllerPHAsset 可能为空，需要使用其他方式获取视频文件原始路径
            url = [info objectForKey:UIImagePickerControllerReferenceURL];
            if (url) {
                [self originURLWithRefrenceURL:url completion:^(BOOL success, NSURL *URL) {
                    if (success) {
                        [self transcodeIfNeed:URL];
                    }
                }];
                return;
            }
            
            // 其他，不支持
            [self.view makeToast:@"not support this video"];
        }
    }];
}

// 根据 UIImagePickerControllerReferenceURL 获取原始文件路径
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
            // 此处会有重复回调的问题
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

// 获取 NSURL 查询字符串信息
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

// 转码
- (void)transcodeIfNeed:(NSURL *)url
{
    if ([url.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
        // mp4 直接发送
        [self sendVideoWithUrl:url];
    } else {
        // 非 mp4 文件 => mp4 文件
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
        V2TIMMessage *message = [TUIMessageDataProvider getVideoMessageWithURL:url];
        [self sendMessage:message];
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
            [self.delegate chatController:self didSendMessage:message];
        }
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
            // 存在同名文件，对文件名进行递增
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
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                [self.delegate chatController:self didSendMessage:message];
            }
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

- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithImage:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 0.75);
    NSString *path = [TUIKit_Image_Path stringByAppendingString:[TUITool genImageName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:path];
    [self sendMessage:message];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
        [self.delegate chatController:self didSendMessage:message];
    }
}

- (void)cameraViewControllerDidCancel:(TUICameraViewController *)controller {
}

//MARK: iOS14使用新的相册管理器
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
        //判断相册权限
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
        // 请求权限，需注意 limited 权限仅在 accessLevel 为 readAndWrite 时生效
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
        //获取相册访问权限 ios8之后推荐用这种方法 //该方法提示用户授权对相册的访问
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusDenied) {
                [TUIUserAuthorizationCenter showAlert:TUIChatAuthControlTypePhoto];
            }else if (status == PHAuthorizationStatusAuthorized){
                //有权限 可直接跳转
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

//MARK: PHPickerViewControllerDelegate

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
                    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
                    V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:path];
                    [strongSelf sendMessage:message];
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                        [strongSelf.delegate chatController:strongSelf didSendMessage:message];
                    }
                });
            }];
        }
        else if ([itemProvoider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
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
        else {
            NSString * typeIdentifier = result.itemProvider.registeredTypeIdentifiers.firstObject;
            [itemProvoider loadFileRepresentationForTypeIdentifier:typeIdentifier completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage * result;
                    NSData * data = [NSData dataWithContentsOfURL:url];
                    result = [UIImage imageWithData:data];
                    //注：模拟器上 typeIdentifier 为public.jepg时拿不到url
                    //见苹果developer原话：There is a separate JEPG transcoding issue that only affects the simulator (63426347), please refer to https://developer.apple.com/forums/thread/658135 for more information.
                });
            }];
        }
    }
}


@end

