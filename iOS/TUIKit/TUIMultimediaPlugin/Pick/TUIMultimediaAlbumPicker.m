//
//  TUIMultimediaAlbumPicker.m
//  TUIMultimediaPlugin
//
//  Created by yiliangwang on 2024/11/5.
//

#import "TUIMultimediaAlbumPicker.h"

@implementation TUIMultimediaAlbumPicker

- (void)pickMediaWithCaller:(UIViewController *)caller {
    UIViewController * pushVC = caller;
    TUIMultimediaNavController *imagePickerVc = [self createImagePickerVC];
    if (pushVC && imagePickerVc) {
        [pushVC presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

- (TUIMultimediaNavController *)createImagePickerVC {
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
                [self handleVideoAsset:model completion:^(BOOL limitedFlag) {
                    if (limitedFlag) {
                        hasFileSizeExceed = YES;
                    }
                    dispatch_group_leave(group);
                }];
            } else {
                [self handleImageAsset:model isSelectOriginalPhoto:isSelectOriginalPhoto  completion:^(BOOL limitedFlag) {
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

- (void)handleVideoAsset:(TUIAssetPickModel *)model completion:(void (^)(BOOL limitedFlag))completion {
    
    if (model.editurl) {
        //Edited; no transcoding needed, can be sent directly.
        UIImage * snapaImage = [[TUIImageManager defaultManager] getImageWithVideoURL:model.editurl];
        NSString *snapshotPath = [[TUIImageManager defaultManager] genImagePath:snapaImage isVideoSnapshot:YES];
        NSInteger duration  = [[TUIImageManager defaultManager] getDurationWithVideoURL:model.editurl];
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createVideoMessage:model.editurl.path type:model.editurl.path.pathExtension duration:(int)duration snapshotPath:snapshotPath];
        NSDictionary *param = @{TUICore_TUIChatService_SendMessageMethod_MsgKey : message};
        [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_SendMessageMethod param:param];

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
                    NSDictionary *param = @{TUICore_TUIChatService_SendMessageMethod_PlaceHolderUIMsgKey : placeHolderCellData};
                    [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_SendMessageMethod param:param];

                    __weak typeof(self)weakSelf = self;
                    //Video transcoding and compression; replace the placeholder image after completion.
                    [self getVideoOutputPathWithAsset:model.asset placeHolderCellData:placeHolderCellData complete:^(NSString *videoPath) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            V2TIMMessage *message = [[V2TIMManager sharedInstance] createVideoMessage:videoPath type:videoPath.pathExtension duration:model.asset.duration snapshotPath:snapshotPath];
                            NSDictionary *param = @{TUICore_TUIChatService_SendMessageMethod_MsgKey : message,
                                                    TUICore_TUIChatService_SendMessageMethod_PlaceHolderUIMsgKey : placeHolderCellData};
                            [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_SendMessageMethod param:param];
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
              completion:(void (^)(BOOL limitedFlag))completion {
    [[TUIImageManager defaultManager] getAssetBytes:model.asset completion:^(NSInteger assetBytes) {
        if (assetBytes > 200 * 1024 * 1024) {
            completion(YES);
            return;
        } else {
            
            if (isSelectOriginalPhoto) {
                // original image:
                [[TUIImageManager defaultManager] getOriginalPhotoDataWithAsset:model.asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    progress = progress > 0.02 ? progress : 0.02;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%f",progress);
                    });
    #ifdef DEBUG
                    NSLog(@"[TUIMultimediaNavController] getOriginalPhotoDataWithAsset:%f error:%@", progress, error);
    #endif
                } completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                    if (!isDegraded) {
                        UIImage *img = [UIImage imageWithData:data];
                        NSString *imagePath = [[TUIImageManager defaultManager] genImagePath:img isVideoSnapshot:NO];
                        V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:imagePath];
                        NSDictionary *param = @{TUICore_TUIChatService_SendMessageMethod_MsgKey : message};
                        [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_SendMessageMethod param:param];
                    }
                }];
            }
            else {
                //Not the original image.：
                NSString *imagePath = [[TUIImageManager defaultManager] genImagePath:model.image isVideoSnapshot:NO];
                V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:imagePath];
                NSDictionary *param = @{TUICore_TUIChatService_SendMessageMethod_MsgKey : message};
                [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_SendMessageMethod param:param];
            }
        }
        completion(NO);
    }];
}



- (void)getVideoOutputPathWithAsset:(PHAsset *)asset placeHolderCellData:(TUIMessageCellData *)placeHolderCellData complete:(void(^)(NSString *))completeBlock failure:(void (^)(NSString *errorMessage, NSError *error))failure {
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
            [[TUIMultimediaProcessor shareInstance] transcodeMedia:videoURL complete:^(TranscodeResult *result) {
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
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:isFile?TIMCommonLocalizableString(TUIKitFileSizeCheckSomeExceed):
                             TIMCommonLocalizableString(TUIKitImageSizeChecSomeExceed)
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

