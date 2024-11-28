//
//  TUIMultimediaNavController.m
//  TUIMultimediaNavController
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "TUIMultimediaNavController.h"
#import "TUIPhotoPickerController.h"
#import "TUIPhotoPreviewController.h"
#import <TUIMultimediaCore/TUIAssetModel.h>
#import <TUIMultimediaCore/TUIAssetCell.h>
#import <TUICore/UIView+TUILayout.h>
#import <TUIMultimediaCore/TUIImageManager.h>
#import <TIMCommon/TIMDefine.h>

@interface TUIMultimediaNavController () {
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    BOOL _pushPhotoPickerVc;
    BOOL _didPushPhotoPickerVc;
    CGRect _cropRect;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
    UIStatusBarStyle _originStatusBarStyle;
}
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, assign) NSInteger HUDTimeoutCount;
@end

@implementation TUIMultimediaNavController

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithMaxImagesCount:9 delegate:nil];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)viewDidLoad {
    [super viewDidLoad];
    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [TUIImageManager defaultManager].shouldFixOrientation = NO;

    self.oKButtonTitleColorNormal   = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    self.oKButtonTitleColorDisabled = [TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF") colorWithAlphaComponent:0.5];
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
    [self configNavigationBarAppearance];
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor {
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont {
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)configNaviTitleAppearance {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    if (self.naviTitleColor) {
        textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    }
    if (self.naviTitleFont) {
        textAttrs[NSFontAttributeName] = self.naviTitleFont;
    }
    self.navigationBar.titleTextAttributes = textAttrs;
    [self configNavigationBarAppearance];
}

- (void)configNavigationBarAppearance {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *barAppearance = [[UINavigationBarAppearance alloc] init];
        if (self.navigationBar.isTranslucent) {
            UIColor *barTintColor = self.navigationBar.barTintColor;
            barAppearance.backgroundColor = [barTintColor colorWithAlphaComponent:0.85];
        } else {
            barAppearance.backgroundColor = self.navigationBar.barTintColor;
        }
        barAppearance.titleTextAttributes = self.navigationBar.titleTextAttributes;
        self.navigationBar.standardAppearance = barAppearance;
        self.navigationBar.scrollEdgeAppearance = barAppearance;
    }
}

- (void)setBarItemTextFont:(UIFont *)barItemTextFont {
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}

- (void)setBarItemTextColor:(UIColor *)barItemTextColor {
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}

- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem;
    if (@available(iOS 9, *)) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TUIMultimediaNavController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[TUIMultimediaNavController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self configNavigationBarAppearance];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<TUIMultimediaNavControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TUIMultimediaNavControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TUIMultimediaNavControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc {
    _pushPhotoPickerVc = pushPhotoPickerVc;
//    TUIAlbumPickerController *albumPickerVc = [[TUIAlbumPickerController alloc] init];
//    albumPickerVc.isFirstAppear = YES;
//    albumPickerVc.columnNumber = columnNumber;
    
    self = [super initWithRootViewController:[UIViewController new]];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.selectedAssets = [NSMutableArray array];
        
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        
        if (![[TUIImageManager defaultManager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.mm_w - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            _tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            NSString *appName = [TUICommonTools tui_getAppName];
            NSString *tipText = [NSString stringWithFormat:[NSBundle tui_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.mm_w, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            _settingBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            [self.view addSubview:_settingBtn];
            
            if ([PHPhotoLibrary authorizationStatus] == 0) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
            }
        } else {
            [self pushPhotoPickerVc];
        }
    }
    return self;
}

- (void)configDefaultSetting {
    self.timeout = 30;
    self.photoPreviewMaxWidth = 600;
    self.naviTitleColor = [UIColor whiteColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    
    self.iconThemeColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    [self configDefaultBtnTitle];
}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture80";
    self.photoDefImage = [self createHollowCircleWithColor:UIColor.whiteColor size:CGSizeMake(24, 24) lineWidth:0.6];
    UIImage *baseImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12];
    UIImage *overlayImage = [UIImage tui_imageNamedFromMyBundle:@"selected_tick_icon"];;
    UIImage *combinedImage = [self overlayImage:baseImage withImage:overlayImage];
    self.photoSelImage = combinedImage;
        
    self.photoNumberIconImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12]; // @"photo_number_icon";
    self.photoPreviewOriginDefImageName = @"preview_original_def";
    self.photoOriginDefImageName = @"photo_original_def";
    self.photoOriginSelImageName = @"photo_original_sel";
    
    self.photoOriginSelImage = [self resizeImage:combinedImage toSize:CGSizeMake(20, 20)];
    self.addMorePhotoImage = [UIImage tui_imageNamedFromMyBundle:@"addMore"];
}

- (void)setTakePictureImageName:(NSString *)takePictureImageName {
    _takePictureImageName = takePictureImageName;
    _takePictureImage = [UIImage tui_imageNamedFromMyBundle:takePictureImageName];
}

- (void)setPhotoSelImageName:(NSString *)photoSelImageName {
    _photoSelImageName = photoSelImageName;
    _photoSelImage = [UIImage tui_imageNamedFromMyBundle:photoSelImageName];
}

- (void)setPhotoDefImageName:(NSString *)photoDefImageName {
    _photoDefImageName = photoDefImageName;
    _photoDefImage = [UIImage tui_imageNamedFromMyBundle:photoDefImageName];
}

- (void)setPhotoNumberIconImageName:(NSString *)photoNumberIconImageName {
    _photoNumberIconImageName = photoNumberIconImageName;
    _photoNumberIconImage = [UIImage tui_imageNamedFromMyBundle:photoNumberIconImageName];
}

- (void)setPhotoPreviewOriginDefImageName:(NSString *)photoPreviewOriginDefImageName {
    _photoPreviewOriginDefImageName = photoPreviewOriginDefImageName;
    _photoPreviewOriginDefImage = [UIImage tui_imageNamedFromMyBundle:photoPreviewOriginDefImageName];
}

- (void)setPhotoOriginDefImageName:(NSString *)photoOriginDefImageName {
    _photoOriginDefImageName = photoOriginDefImageName;
    _photoOriginDefImage = [UIImage tui_imageNamedFromMyBundle:photoOriginDefImageName];
}

- (void)setPhotoOriginSelImageName:(NSString *)photoOriginSelImageName {
    _photoOriginSelImageName = photoOriginSelImageName;
    _photoOriginSelImage = [UIImage tui_imageNamedFromMyBundle:photoOriginSelImageName];
}

- (void)setTakePictureImage:(UIImage *)takePictureImage {
    _takePictureImage = takePictureImage;
    _takePictureImageName = @"";
}

- (void)setIconThemeColor:(UIColor *)iconThemeColor {
    _iconThemeColor = iconThemeColor;
    [self configDefaultImageName];
}

- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = [NSBundle tui_localizedStringForKey:@"Done"];
    self.cancelBtnTitleStr = [NSBundle tui_localizedStringForKey:@"Cancel"];
    self.previewBtnTitleStr = [NSBundle tui_localizedStringForKey:@"Preview"];
    self.editImageBtnTitleStr = [NSBundle tui_localizedStringForKey:@"Edit"];
    self.fullImageBtnTitleStr = [NSBundle tui_localizedStringForKey:@"Full image"];
    self.settingBtnTitleStr = [NSBundle tui_localizedStringForKey:@"Setting"];
    self.processHintStr = [NSBundle tui_localizedStringForKey:@"Processing..."];
    self.editBtnTitleStr = [NSBundle tui_localizedStringForKey:@"Edit"];
}

- (void)observeAuthrizationStatusChange {
    [_timer invalidate];
    _timer = nil;
    if ([PHPhotoLibrary authorizationStatus] == 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
    }
    
    if ([[TUIImageManager defaultManager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];

        [self pushPhotoPickerVc];
    }
}

- (void)pushPhotoPickerVc {
    _didPushPhotoPickerVc = NO;
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) {
        TUIPhotoPickerController *photoPickerVc = [[TUIPhotoPickerController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        photoPickerVc.columnNumber = self.columnNumber;
        [[TUIImageManager defaultManager] getCameraRollAlbum:NO completion:^(TUIAlbumModel *model) {
            photoPickerVc.albumModel = model;
            [self pushViewController:photoPickerVc animated:YES];
            self->_didPushPhotoPickerVc = YES;
        }];
    }
}

- (UIAlertController *)showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle tui_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = self.processHintStr;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    UIWindow *applicationWindow;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    } else {
        applicationWindow = [[UIApplication sharedApplication] keyWindow];
    }
    [applicationWindow addSubview:_progressHUD];
    [self.view setNeedsLayout];
    
    self.HUDTimeoutCount++;
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        self.HUDTimeoutCount--;
        if (self.HUDTimeoutCount <= 0) {
            self.HUDTimeoutCount = 0;
            [self hideProgressHUD];
        }
    });
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 600) {
        _timeout = 600;
    }
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
//    TUIAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
//    albumPickerVc.columnNumber = _columnNumber;
    [TUIImageManager defaultManager].columnNumber = _columnNumber;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [TUIImageManager defaultManager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    _selectedAssetIds = [NSMutableArray array];
    for (PHAsset *asset in selectedAssets) {
        TUIAssetModel *model = [TUIAssetModel modelWithAsset:asset type:[[TUIImageManager defaultManager] getAssetMediaType:asset]];
        model.isSelected = YES;
        [self addSelectedModel:model];
    }
}

- (void)settingBtnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    [super pushViewController:viewController animated:animated];
}

- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius {
    if (!color) {
        color = self.iconThemeColor;
    }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)overlayImage:(UIImage *)baseImage withImage:(UIImage *)overlayImage {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:baseImage.size];
    UIImage *resultImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {

        [baseImage drawInRect:CGRectMake(0, 0, baseImage.size.width, baseImage.size.height)];
        CGFloat overlayX = (baseImage.size.width - overlayImage.size.width) / 2.0;
        CGFloat overlayY = (baseImage.size.height - overlayImage.size.height) / 2.0;
        CGPoint overlayPosition = CGPointMake(overlayX, overlayY);
        [overlayImage drawAtPoint:overlayPosition];
    }];
    return resultImage;
}

- (UIImage *)createHollowCircleWithColor:(UIColor *)color size:(CGSize)size lineWidth:(CGFloat)lineWidth {
    if (!color) {
        color = [UIColor blackColor];
    }
    
    CGFloat diameter = MIN(size.width, size.height);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize scaledSize = CGSizeMake(diameter * scale, diameter * scale);
    
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, YES);
    
    CGContextClearRect(context, CGRectMake(0, 0, scaledSize.width, scaledSize.height));
    
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetLineWidth(context, lineWidth * scale);

    CGRect scaledRect = CGRectMake(0.0f, 0.0f, scaledSize.width, scaledSize.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:scaledRect];
    CGContextAddPath(context, path.CGPath);
    
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - UIContentContainer

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![UIApplication sharedApplication].statusBarHidden) {
            if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
        }
    });
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat progressHUDY = CGRectGetMaxY(self.navigationBar.frame);
    _progressHUD.frame = CGRectMake(0, progressHUDY, self.view.mm_w, self.view.mm_h - progressHUDY);
    _HUDContainer.frame = CGRectMake((self.view.mm_w - 120) / 2, (_progressHUD.mm_h - 90 - progressHUDY) / 2, 120, 90);
    _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    _HUDLabel.frame = CGRectMake(0,40, 120, 50);
}

#pragma mark - Public

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)onCancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma clang diagnostic pop


@implementation UIImage (MyBundle)

+ (UIImage *)tui_imageNamedFromMyBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle tz_imagePickerBundle];
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // Compatible with the way the business side sets images
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end


@implementation TUICommonTools

+ (UIEdgeInsets)tui_safeAreaInsets {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (![window isKeyWindow]) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (CGRectEqualToRect(keyWindow.bounds, [UIScreen mainScreen].bounds)) {
            window = keyWindow;
        }
    }
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = [window safeAreaInsets];
        return insets;
    }
    return UIEdgeInsetsZero;
}

+ (BOOL)tui_isIPhoneX {
    if ([UIWindow instancesRespondToSelector:@selector(safeAreaInsets)]) {
        return [self tui_safeAreaInsets].bottom > 0;
    }
    return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(844, 390)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(926, 428)));
}

+ (BOOL)tui_isLandscape {
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight ||
        [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft) {
        return true;
    }
    return false;
}

+ (CGFloat)tui_statusBarHeight {
    if ([UIWindow instancesRespondToSelector:@selector(safeAreaInsets)]) {
        return [self tui_safeAreaInsets].top ?: 20;
    }
    return 20;
}

+ (NSDictionary *)tui_getInfoDictionary {
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict || !infoDict.count) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    if (!infoDict || !infoDict.count) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return infoDict ? infoDict : @{};
}

+ (NSString *)tui_getAppName {
    NSDictionary *infoDict = [self tui_getInfoDictionary];
    NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
    if (!appName) appName = [infoDict valueForKey:@"CFBundleExecutable"];
    if (!appName) {
        infoDict = [NSBundle mainBundle].infoDictionary;
        appName = [infoDict valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
        if (!appName) appName = [infoDict valueForKey:@"CFBundleExecutable"];
    }
    return appName;
}

+ (BOOL)tui_isRightToLeftLayout {
    return [TUIGlobalization getRTLOption];
}

+ (void)configBarButtonItem:(UIBarButtonItem *)item multiMediaNavVC:(TUIMultimediaNavController *)multiMediaNavVC {
    item.tintColor = multiMediaNavVC.barItemTextColor;
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = multiMediaNavVC.barItemTextColor;
    textAttrs[NSFontAttributeName] = multiMediaNavVC.barItemTextFont;
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *textAttrsHighlighted = [NSMutableDictionary dictionary];
    textAttrsHighlighted[NSFontAttributeName] = multiMediaNavVC.barItemTextFont;
    [item setTitleTextAttributes:textAttrsHighlighted forState:UIControlStateHighlighted];
}

+ (BOOL)isICloudSyncError:(NSError *)error {
    if (!error) return NO;
    if ([error.domain isEqualToString:@"CKErrorDomain"] || [error.domain isEqualToString:@"CloudPhotoLibraryErrorDomain"]) {
        return YES;
    }
    return NO;
}


@end


@interface TUIImagePickerConfig ()
@property (strong, nonatomic) NSSet *supportedLanguages;
@end

@implementation TUIImagePickerConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TUIImagePickerConfig *config = nil;
    dispatch_once(&onceToken, ^{
        if (config == nil) {
            config = [[TUIImagePickerConfig alloc] init];
            config.supportedLanguages = [NSSet setWithObjects:@"zh-Hans",@"zh-Hant",@"en", @"ar", nil];
            config.preferredLanguage = nil;
        }
    });
    NSString *identifer = [TUIGlobalization getPreferredLanguage];
    [config setPreferredLanguage:identifer];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];
    return config;
}


+ (void)onChangeLanguage {
    NSString *identifer = [TUIGlobalization getPreferredLanguage];
    [[self sharedInstance] setPreferredLanguage:identifer];
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    
    if (!preferredLanguage || !preferredLanguage.length) {
        preferredLanguage = [NSLocale preferredLanguages].firstObject;
    }

    NSString *usedLanguage = @"en";
    for (NSString *language in self.supportedLanguages) {
        if ([preferredLanguage hasPrefix:language]) {
            usedLanguage = language;
            break;
        }
    }
    _languageBundle = [NSBundle bundleWithPath:[[NSBundle tz_imagePickerBundle] pathForResource:usedLanguage ofType:@"lproj"]];
}

@end
