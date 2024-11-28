//
//  TUIMultimediaNavController.h
//  TUIMultimediaNavController
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <TUIMultimediaCore/TUIAssetModel.h>
#import "NSBundle+TUIImagePicker.h"
#import <TUIMultimediaCore/TUIImageManager.h>
#import "TUIPhotoPreviewController.h"
#import "TUIPhotoPreviewCell.h"

@class TUIAlbumCell, TUIAssetCell;
@protocol TUIMultimediaNavControllerDelegate;
@interface TUIMultimediaNavController : UINavigationController

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<TUIMultimediaNavControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TUIMultimediaNavControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TUIMultimediaNavControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc;

#pragma mark -
/// Maximum number of photos allowed to be selected (Default is 9)
@property (nonatomic, assign) NSInteger maxImagesCount;
/// The number of photos displayed in each row (Default is 4)
@property (nonatomic, assign) NSInteger columnNumber;
/// Default is 600px
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// The photos user have selected
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<TUIAssetModel *> *selectedModels;
@property (nonatomic, strong) NSMutableArray *selectedAssetIds;
- (void)addSelectedModel:(TUIAssetModel *)model;
- (void)removeSelectedModel:(TUIAssetModel *)model;

- (UIAlertController *)showAlertWithTitle:(NSString *)title;
- (void)showProgressHUD;
- (void)hideProgressHUD;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (assign, nonatomic) BOOL needShowStatusBar;
@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;
@property (nonatomic, strong) UIImage *takePictureImage;
@property (nonatomic, strong) UIImage *addMorePhotoImage;
@property (nonatomic, strong) UIImage *photoSelImage;
@property (nonatomic, strong) UIImage *photoDefImage;
@property (nonatomic, strong) UIImage *photoOriginSelImage;
@property (nonatomic, strong) UIImage *photoOriginDefImage;
@property (nonatomic, strong) UIImage *photoPreviewOriginDefImage;
@property (nonatomic, strong) UIImage *photoNumberIconImage;

@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;
@property (nonatomic, strong) UIColor *naviBgColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIFont *naviTitleFont;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;

@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *editImageBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;
@property (nonatomic, copy) NSString *editBtnTitleStr;
@property (nonatomic, copy) NSString *editViewCancelBtnTitleStr;
@property (strong, nonatomic) UIColor *iconThemeColor;

@property (nonatomic, copy) void (^didFinishPickingHandle)(NSArray<TUIAssetPickModel *> *models, BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<TUIAssetPickModel *> *models,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos);

- (void)onCancelButtonClick;
@end



@interface UIImage (MyBundle)
+ (UIImage *)tui_imageNamedFromMyBundle:(NSString *)name;
@end

@interface TUICommonTools : NSObject
+ (UIEdgeInsets)tui_safeAreaInsets;
+ (BOOL)tui_isIPhoneX;
+ (BOOL)tui_isLandscape;
+ (CGFloat)tui_statusBarHeight;
+ (NSDictionary *)tui_getInfoDictionary;
+ (NSString *)tui_getAppName;
+ (BOOL)tui_isRightToLeftLayout;
+ (void)configBarButtonItem:(UIBarButtonItem *)item multiMediaNavVC:(TUIMultimediaNavController *)multiMediaNavVC;
+ (BOOL)isICloudSyncError:(NSError *)error;
@end


@interface TUIImagePickerConfig : NSObject
+ (instancetype)sharedInstance;
@property (copy, nonatomic) NSString *preferredLanguage;
@property (strong, nonatomic) NSBundle *languageBundle;
@end
