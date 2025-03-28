//
//  TUIMultimediaAlbumPicker.m
//  TUIMultimediaPlugin
//
//  Created by yiliangwang on 2024/11/5.
//

#import "TUIMultimediaAlbumPicker.h"

@implementation TUIMultimediaAlbumPicker
- (void)pickMediaWithCaller:(UIViewController *)caller originalMediaPicked:(IAlbumPickerCallback)mediaPicked progressCallback:(IAlbumPickerCallback)progressCallback finishedCallback:(IAlbumPickerCallback)finishedCallback
{
    UIViewController * pushVC = caller;
    TUIMultimediaNavController *imagePickerVc = [self createImagePickerVCoriginalMediaPicked:mediaPicked progressCallback:progressCallback finishedCallback:finishedCallback];
    if (pushVC && imagePickerVc) {
        [pushVC presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

- (TUIMultimediaNavController *)createImagePickerVCoriginalMediaPicked:(IAlbumPickerCallback)originalMediaPicked
    progressCallback:(IAlbumPickerCallback)progressCallback
    finishedCallback:(IAlbumPickerCallback)finishedCallback {
    
    TUIMultimediaNavController *imagePickerVc = [[TUIMultimediaNavController alloc] initWithMaxImagesCount:9 delegate:(id)self];
    imagePickerVc.modalPresentationStyle = 0;
    
    @weakify(self)
    [imagePickerVc setDidFinishPickingHandle:^(NSArray<TUIAssetPickModel *> *models, BOOL isSelectOriginalPhoto) {
        @strongify(self)
        
        __block BOOL hasFileSizeExceed = NO;
        __block BOOL hasImageSizeExceed = NO;
        dispatch_group_t group = dispatch_group_create();
        
        for (TUIAssetPickModel *model in models) {
            dispatch_group_enter(group);
            if ([[TUIImageManager defaultManager] isVideo:model.asset]) {
                [self handleVideoAsset:model
                originalMediaPicked:^(NSDictionary *param) {
                    if (originalMediaPicked) {
                        originalMediaPicked(param);
                    }
                }
                progressCallback:^(NSDictionary *param) {
                    if (progressCallback) {
                        progressCallback(param);
                    }
                }
                finishedCallback:^(NSDictionary *param) {
                    if (finishedCallback) {
                        finishedCallback(param);
                    }
                }
                completion:^(BOOL limitedFlag) {
                    if (limitedFlag) {
                        hasFileSizeExceed = YES;
                    }
                    dispatch_group_leave(group);
                }];
            } else {
                [self handleImageAsset:model
                isSelectOriginalPhoto:isSelectOriginalPhoto
                   originalMediaPicked:^(NSDictionary *param) {
                    if (originalMediaPicked) {
                        originalMediaPicked(param);
                    }
                } progressCallback:^(NSDictionary *param) {
                    if (progressCallback) {
                        progressCallback(param);
                    }
                } finishedCallback:^(NSDictionary *param) {
                    if (finishedCallback) {
                        finishedCallback(param);
                    }
                } completion:^(BOOL limitedFlag) {
                    if (limitedFlag) {
                        hasImageSizeExceed = YES;
                    }
                    dispatch_group_leave(group);
                }];
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (hasFileSizeExceed || hasImageSizeExceed) {
                [self showFileCheckToast:YES];
            }
        });
    }];
    
    return imagePickerVc;
}
- (void)handleVideoAsset:(TUIAssetPickModel *)model
     originalMediaPicked:(IAlbumPickerCallback)mediaPicked
        progressCallback:(IAlbumPickerCallback)progressCallback
        finishedCallback:(IAlbumPickerCallback)finishedCallback
              completion:(void (^)(BOOL limitedFlag))completion {
    
    if (model.editurl) {
        //Edited; no transcoding needed, can be sent directly.
        UIImage * snapaImage = [[TUIImageManager defaultManager] getImageWithVideoURL:model.editurl];
        NSString *snapshotPath = [[TUIImageManager defaultManager] genImagePath:snapaImage isVideoSnapshot:YES];
        NSInteger duration  = [[TUIImageManager defaultManager] getDurationWithVideoURL:model.editurl];
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createVideoMessage:model.editurl.path type:model.editurl.path.pathExtension duration:(int)duration snapshotPath:snapshotPath];
        NSDictionary *param = @{@"message": message,@"type":@"video"};
        if (finishedCallback) {
            finishedCallback(param);
        }
    }
    else {
        
        [[TUIImageManager defaultManager] getAssetBytes:model.asset completion:^(NSInteger assetBytes) {
            // For videos larger than 200MB, directly report a file size exceeded warning and do not compress.
            if (assetBytes > 200 * 1024 * 1024) {
                completion(YES);
                return;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Show video snapshot on screen first
                    NSString *snapshotPath = [[TUIImageManager defaultManager] genImagePath:model.image isVideoSnapshot:YES];
                    TUIMessageCellData *placeHolderCellData = [TUIVideoMessageCellData placeholderCellDataWithSnapshotUrl:snapshotPath thubImage:model.image];
                    NSString *random = [NSString stringWithFormat:@"%u", arc4random()];
                    placeHolderCellData.msgID = [NSString stringWithFormat:@"%@%@", snapshotPath, random];
                    NSDictionary *param = @{@"placeHolderCellData" : placeHolderCellData,@"type":@"video"};
                    if (mediaPicked) {
                        mediaPicked(param);
                    }
                    __weak typeof(self)weakSelf = self;
                    //Video transcoding and compression; replace the placeholder image after completion.
                    [self getVideoOutputPathWithAsset:model.asset placeHolderCellData:placeHolderCellData
                                             progress:^(NSDictionary *param) {
                                                if (progressCallback) {
                                                    progressCallback(param);
                                                }
                        }
                                             complete:^(NSString *videoPath) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    V2TIMMessage *message = [[V2TIMManager sharedInstance] createVideoMessage:videoPath type:videoPath.pathExtension duration:model.asset.duration snapshotPath:snapshotPath];
                                                    NSDictionary *param = @{@"message": message,
                                                                            @"placeHolderCellData" : placeHolderCellData,
                                                                            @"type":@"video"};
                                                    if (finishedCallback) {
                                                        finishedCallback(param);
                                                    }
                                                });
                    } failure:^(NSString *errorMessage, NSError *error) {
                        // Handle error if needed
                    }];
                });
            }
            completion(NO);
        }];
    }

}

- (void)handleImageAsset:(TUIAssetPickModel *)model
   isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
     originalMediaPicked:(IAlbumPickerCallback)mediaPicked
        progressCallback:(IAlbumPickerCallback)progressCallback
        finishedCallback:(IAlbumPickerCallback)finishedCallback
              completion:(void (^)(BOOL limitedFlag))completion {
    if (model.editImage != nil) {
        [self sendImageMessage:model.editImage finishedCallback:finishedCallback];
        return;
    }
    
    [[TUIImageManager defaultManager] getAssetBytes:model.asset completion:^(NSInteger assetBytes) {
        if (assetBytes > 28 * 1024 * 1024) {
            completion(YES);
            return;
        }
        
        if (mediaPicked) {
            mediaPicked(nil);
        }
        
        if (isSelectOriginalPhoto) {
            [[TUIImageManager defaultManager] getOriginalPhotoDataWithAsset:model.asset
                                                            progressHandler:nil
                                                                 completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    [self sendImageMessage:[UIImage imageWithData:data] finishedCallback:finishedCallback];
                }
            }];
        } else {
            [self sendImageMessage:model.image finishedCallback:finishedCallback];
        }
    }];
}

- (void)sendImageMessage:(UIImage*) image finishedCallback:(IAlbumPickerCallback)finishedCallback{
    NSString *imagePath = [[TUIImageManager defaultManager] genImagePath:image isVideoSnapshot:NO];
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:imagePath];
    NSDictionary *param = @{@"message": message,@"type":@"image"};
    if (finishedCallback != nil) {
        finishedCallback(param);
    }
}

- (void)getVideoOutputPathWithAsset:(PHAsset *)asset placeHolderCellData:(TUIMessageCellData *)placeHolderCellData
                           progress:(IAlbumPickerCallback)progressHandler
                           complete:(void(^)(NSString *))completeBlock failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    [[TUIImageManager defaultManager] requestVideoURLWithAsset:asset success:^(NSURL *videoURL) {
        NSNumber *videoBytes;
        [videoURL getResourceValue:&videoBytes forKey:NSURLFileSizeKey error:nil];
        // The maximum video size sent by IMSDK is 100M
        NSString *presetName = (videoBytes.intValue > 100 * 1024 * 1024 ? AVAssetExportPreset1280x720 : AVAssetExportPresetPassthrough);
        if (videoBytes.intValue > 200 * 1024 * 1024) {
            NSLog(@"requestVideoURLWithAsset falied, The maximum video size sent by IMSDK is 100M");
            if (failure) {
                failure(@"The current video size is greater than 200M",nil);
            }
            return;
        }
        BOOL suportMultimedia = YES;
        if (suportMultimedia) {
            [[TUIMultimediaProcessor shareInstance] transcodeVideo:videoURL complete:^(TranscodeResult *result) {
                NSLog(@"TUIMultimediaMediaProcessor complete %@ ",result.transcodeUri.path);
                NSData *videoData = [NSData dataWithContentsOfURL:result.transcodeUri];
                NSString *videoPath = [NSString stringWithFormat:@"%@%@_%u.mp4", TUIKit_Video_Path, [TUITool genVideoName:nil],arc4random()];
                [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completeBlock) {
                        completeBlock(videoPath);
                    }
                });
            } progress:^(float progress) {
                NSLog(@"TUIMultimediaMediaProcessor videoTranscodingProgress %f ",progress);
                placeHolderCellData.videoTranscodingProgress = progress;                
                if (progressHandler) {
                    NSNumber *numberValue = @(progress);
                    NSDictionary *param = @{
                        @"progress": numberValue
                    };
                    progressHandler(param);
                }
            } ];
        }
        else {
            [[TUIImageManager defaultManager] getVideoOutputPathWithAsset:asset presetName:presetName progress:^(CGFloat progress) {
                placeHolderCellData.videoTranscodingProgress = progress;
            } success:^(NSString *outputPath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completeBlock) {
                        completeBlock(outputPath);
                    }
                });
            } failure:^(NSString *errorMessage, NSError *error) {
                NSLog(@"getVideoOutputPathWithAsset falied, errorMessage:%@", errorMessage);
                if (failure) {
                    failure(errorMessage,error);
                }
            }];
        }

    } failure:^(NSDictionary *info) {
        NSLog(@"requestVideoURLWithAsset falied, errorInfo:%@", info);
        if (failure) {
            failure(info.description,nil);
        }
    }];
}

- (void)showFileCheckToast:(BOOL)isFile {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:isFile?
                             TIMCommonLocalizableString(TUIKitFileSizeCheckLimited):
                             TIMCommonLocalizableString(TUIKitImageSizeCheckLimited)
                                                                message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm) style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [topViewController presentViewController:ac animated:YES completion:nil];
    });
}

@end

