//
//  TUIPhotoPreviewController.h
//  TUIPhotoPreviewController
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <TUIMultimediaCore/TUIAssetModel.h>
@interface TUIPhotoPreviewController : UIViewController

@property (nonatomic, strong) NSMutableArray *assetModels;      ///< All photo models
@property (nonatomic, strong) NSMutableArray *selectedModels;   ///< Select photo models
@property (nonatomic, strong) NSMutableArray *photos;           ///< All photos
@property (nonatomic, assign) NSInteger currentShowIndex;       ///< Index of the photo user click
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;       ///< If YES,return original photo
@property (nonatomic, assign) BOOL isCropImage;

/// Return the new selected photos
@property (nonatomic, copy) void (^backButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlockCropMode)(UIImage *cropedImage,id asset);

@property (nonatomic, copy) void (^addAssetBlock)(TUIAssetModel * model);
@property (nonatomic, copy) void (^delAssetBlock)(TUIAssetModel * model);
@property (nonatomic, copy) void (^refreshAssetBlock)(TUIAssetModel * model);

@end
