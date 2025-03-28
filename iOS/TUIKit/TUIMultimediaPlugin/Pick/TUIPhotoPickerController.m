//
//  TUIPhotoPickerController.m
//  TUIPhotoPickerController
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import "TUIPhotoPickerController.h"
#import "TUIMultimediaNavController.h"
#import "TUIPhotoPreviewController.h"
#import <TUIMultimediaCore/TUIAssetCell.h>
#import <TUIMultimediaCore/TUIAssetModel.h>
#import <TUIMultimediaCore/TUIAuthFooterTipView.h>
#import <TUICore/UIView+TUILayout.h>
#import <TUICore/UIView+TUIUtil.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TUIRequestOperation.h"
#import <TIMCommon/TIMDefine.h>
#import <PhotosUI/PhotosUI.h>
#import <TUIMultimediaCore/TUIImageManager.h>
#import <TUIMultimediaCore/TUIAlbumCollectionView.h>
#import <TUIMultimediaCore/TUIMultimediaCore.h>

@interface TUIPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, PHPhotoLibraryChangeObserver,UITableViewDataSource,UITableViewDelegate> {
    TUIAlbumModel *_albumModel;
    
    UIView *_bottomToolBar;
    UIButton *_previewButton;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    
    BOOL _shouldScrollToBottom;
    BOOL _showTakePhotoBtn;
    BOOL _authorizationLimited;
    
    CGFloat _offsetItemCount;
}
@property CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) TUIAlbumCollectionView *collectionView;
@property (nonatomic, strong) TUIAuthFooterTipView *authFooterTipView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL isSavingMedia;
@property (nonatomic, assign) BOOL isFetchingMedia;

@property (nonatomic, strong) UIButton *albumChangeButton;
@property (nonatomic, strong) UIImageView *albumChangeIcon;
@property (nonatomic, strong) UIView *albumBKView;
@property (nonatomic, strong) UITableView *albumTableView;
@property (nonatomic, strong) NSMutableArray *albumList;
@property (nonatomic, assign) BOOL isShowingAlbums;

@end

static CGSize AssetGridThumbnailSize;
static CGFloat itemMargin = 5;

@implementation TUIPhotoPickerController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TUIMultimediaNavController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TUIMultimediaNavController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)setAlbumModel:(TUIAlbumModel *)albumModel {
    if (albumModel) {
        _albumModel = albumModel;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchAlbums];
            [self fetchAssets];
        });
    }
}

- (TUIAlbumModel *)albumModel {
    return _albumModel;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    multiMediaNavVC.isSelectOriginalPhoto = _isSelectOriginalPhoto;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isFirstAppear = NO;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)navLeftBarButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[TUIImageManager defaultManager] authorizationStatusAuthorized] || [System_Version floatValue] < 15.0) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    self.isFirstAppear = YES;
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    _isSelectOriginalPhoto = multiMediaNavVC.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    UIView *albumChangeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    albumChangeView.backgroundColor = [UIColor clearColor];
    self.albumChangeButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.albumChangeButton addTarget:self action:@selector(onAlbumChangeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [albumChangeView addSubview:self.albumChangeButton];
    
    self.albumChangeIcon = [[UIImageView alloc] init];
    self.albumChangeIcon.image = [UIImage tui_imageNamedFromMyBundle:@"change_album"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAlbumChangeButtonClick)];
    [self.albumChangeIcon addGestureRecognizer:tap];
    self.albumChangeIcon.userInteractionEnabled = YES;
    [albumChangeView addSubview:self.albumChangeIcon];
    self.navigationItem.titleView = albumChangeView;
    [self refreshAlbumChangeView];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:multiMediaNavVC.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:multiMediaNavVC action:@selector(onCancelButtonClick)];
    [TUICommonTools configBarButtonItem:cancelItem multiMediaNavVC:multiMediaNavVC];
    self.navigationItem.leftBarButtonItem = cancelItem;

    _showTakePhotoBtn = NO;
    _authorizationLimited = self.albumModel.isCameraRoll && [[TUIImageManager defaultManager] isPHAuthorizationStatusLimited];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    [self configCollectionView];
    [self configBottomToolBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.mm_h;
    CGFloat footerTipViewH = _authorizationLimited ? 80 : 0;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    BOOL isFullScreen = self.view.mm_h == [UIScreen mainScreen].bounds.size.height;
    CGFloat toolBarHeight = 50 + [TUICommonTools tui_safeAreaInsets].bottom;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden && isFullScreen) {
            top += [TUICommonTools tui_statusBarHeight];
        }
        collectionViewHeight = self.view.mm_h - toolBarHeight - top;
    } else {
        collectionViewHeight = self.view.mm_h - toolBarHeight;
    }
    collectionViewHeight -= footerTipViewH;
    
    self.collectionView.frame = CGRectMake(0, top, self.view.mm_w, collectionViewHeight);
    CGFloat itemWH = (self.view.mm_w - (self.columnNumber + 1) * itemMargin) / self.columnNumber;
    _layout.itemSize = CGSizeMake(itemWH, itemWH);
    _layout.minimumInteritemSpacing = itemMargin;
    _layout.minimumLineSpacing = itemMargin;
    [self.collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetY = _offsetItemCount * (_layout.itemSize.height + _layout.minimumLineSpacing);
        [self.collectionView setContentOffset:CGPointMake(0, offsetY)];
    }
    
    CGFloat toolBarTop = 0;
    if (!self.navigationController.navigationBar.isHidden) {
        toolBarTop = self.view.mm_h - toolBarHeight;
    } else {
        CGFloat navigationHeight = naviBarHeight + [TUICommonTools tui_statusBarHeight];
        toolBarTop = self.view.mm_h - toolBarHeight - navigationHeight;
    }
    _bottomToolBar.frame = CGRectMake(0, toolBarTop, self.view.mm_w, toolBarHeight);
    if (_authFooterTipView) {
        CGFloat footerTipViewY = _bottomToolBar ? toolBarTop - footerTipViewH : self.view.mm_h - footerTipViewH;
        _authFooterTipView.frame = CGRectMake(0, footerTipViewY, self.view.mm_w, footerTipViewH);;
    }
    
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    CGFloat previewWidth = [multiMediaNavVC.previewBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    
    CGFloat fullImageWidth = [multiMediaNavVC.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
    fullImageWidth += 40;
    _originalPhotoButton.frame = CGRectMake(_bottomToolBar.mm_w / 2 - fullImageWidth / 2, 0, fullImageWidth, 44);
    [_originalPhotoLabel sizeToFit];
    _originalPhotoLabel.frame = CGRectMake(self.view.mm_w /2 -_originalPhotoLabel.mm_w /2 ,
                                           33,
                                           _originalPhotoLabel.mm_w,
                                           _originalPhotoLabel.mm_h);
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.mm_w - _doneButton.mm_w - 12, 0, MAX(44, _doneButton.mm_w), 50);
    _numberImageView.frame = CGRectMake(_doneButton.mm_x - 24 - 5, 13, 24, 24);
    _numberLabel.frame = _numberImageView.frame;
    
    if (isRTL()) {
        for (UIView *subview in _bottomToolBar.subviews) {
            [subview resetFrameToFitRTL];
        }
    }
    [TUIImageManager defaultManager].columnNumber = [TUIImageManager defaultManager].columnNumber;
    
}
 
#pragma mark Album Logic
- (UIView *)albumBKView{
    if (!_albumBKView) {
        _albumBKView = [[UIView alloc] initWithFrame:CGRectMake(self.collectionView.mm_x, self.collectionView.mm_y,
                                                                self.collectionView.mm_w, self.view.mm_h - self.collectionView.mm_x)];
        _albumBKView.backgroundColor = [UIColor blackColor];
        _albumBKView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAlbumBKView)];
        [_albumBKView addGestureRecognizer:tap];
        [self.view insertSubview:_albumBKView belowSubview:self.albumTableView];
    }
    return _albumBKView;
}

- (UITableView *)albumTableView {
    if (!_albumTableView) {
        CGFloat tableViewHeight = self.collectionView.mm_h - 100;
        _albumTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.collectionView.mm_x, self.collectionView.mm_y - tableViewHeight,
                                                                   self.collectionView.mm_w, tableViewHeight) style:UITableViewStylePlain];
        _albumTableView.rowHeight = 54;
        _albumTableView.backgroundColor = RGB(45, 45, 45);
        _albumTableView.separatorColor = RGB(75, 75, 75);
        _albumTableView.tableFooterView = [[UIView alloc] init];
        _albumTableView.dataSource = self;
        _albumTableView.delegate = self;
        [_albumTableView registerClass:[TUIAlbumCell class] forCellReuseIdentifier:@"TUIAlbumCell"];
        [self.view addSubview:_albumTableView];
    }
    return _albumTableView;
}

- (void)onAlbumChangeButtonClick {
    if (self.isShowingAlbums) {
        [self hideAllAlbums];
    } else {
        [self showAllAlbums];
    }
}

- (void)onClickAlbumBKView {
    [self hideAllAlbums];
}

- (void)fetchAlbums {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @weakify(self)
        [[TUIMultimediaCore defaultManager] getBucketList:!self.isFirstAppear completion:^(NSArray<TUIAlbumModel *> * _Nonnull bucketList) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.albumList = [NSMutableArray arrayWithArray:bucketList];
            });
        }];
    });
}

- (void)showAllAlbums {
    [self refreshAlbumTableView];
    [UIView animateWithDuration:0.2 animations:^{
        self.albumBKView.alpha = 0.5;
        self.albumTableView.frame = CGRectOffset(self.albumTableView.frame, 0, self.albumTableView.mm_h);
        self.albumChangeIcon.transform = CGAffineTransformMakeRotation(M_PI);
    }];
    self.isShowingAlbums = YES;
}

- (void)hideAllAlbums {
    [UIView animateWithDuration:0.2 animations:^{
        self.albumBKView.alpha = 0;
        self.albumTableView.frame = CGRectOffset(self.albumTableView.frame, 0, -self.albumTableView.mm_h);
        self.albumChangeIcon.transform = CGAffineTransformMakeRotation(0);
    }];
    self.isShowingAlbums = NO;
}

- (void)refreshAlbumTableView {
    [self updateAlbumStatus];
    [self.albumTableView reloadData];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @weakify(self)
        [[TUIMultimediaCore defaultManager] getBucketList:!self.isFirstAppear completion:^(NSArray<TUIAlbumModel *> * _Nonnull bucketList) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.albumList = [NSMutableArray arrayWithArray:bucketList];
                [self updateAlbumStatus];
                [self.albumTableView reloadData];
            });
        }];
    });
}

- (void)updateAlbumStatus {
    for (TUIAlbumModel *model in self.albumList) {
        if ([model.name isEqualToString:self.albumModel.name]) {
            model.isSelected = YES;
        } else {
            model.isSelected = NO;
        }
    }
}

- (void)refreshAlbumChangeView {
    CGFloat albumChangeIconSize = 20;
    [self.albumChangeButton setTitle:self.albumModel.name forState:UIControlStateNormal];
    [self.albumChangeButton sizeToFit];
    self.albumChangeButton.mm_y = 5;
    self.albumChangeButton.mm_centerX =  (self.navigationItem.titleView.mm_w - albumChangeIconSize) / 2;
    self.albumChangeIcon.mm_width(20).mm_height(20).mm_left(self.albumChangeButton.mm_maxX + 4).mm__centerY(self.albumChangeButton.mm_centerY);
    if (isRTL()) {
        [self.albumChangeButton resetFrameToFitRTL];
        [self.albumChangeIcon resetFrameToFitRTL];
    }
}

#pragma mark Asset Logic
- (void)configCollectionView {
    if (!self.collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionView = [[TUIAlbumCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        self.collectionView.backgroundColor = RGB(25, 25, 25);
        self.collectionView.alwaysBounceHorizontal = NO;
        self.collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
        self.collectionView.maxSelectDescribeText = [NSBundle tui_localizedStringForKey:@"Select a maximum of %zd photos"];
        [self.view addSubview:self.collectionView];
        if (self.albumModel) {
            [self.collectionView setBucket:self.albumModel];
            [self prepareScrollCollectionViewToBottom];
        }
        [self.collectionView setClickListener:(id)self];
    }
    self.collectionView.contentSize = CGSizeMake(self.view.mm_w, (([self getAllCellCount] + self.columnNumber - 1) / self.columnNumber) * self.view.mm_w);

    if (!_authFooterTipView && _authorizationLimited) {
        _authFooterTipView = [[TUIAuthFooterTipView alloc] initWithFrame:CGRectMake(0, 0, self.view.mm_w, 80)];
        _authFooterTipView.tipImage = [UIImage tui_imageNamedFromMyBundle:@"tip"];
        _authFooterTipView.deftailImage = [UIImage tui_imageNamedFromMyBundle:@"right_arrow"];
        UITapGestureRecognizer *footTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSettingsApplication)];
        [_authFooterTipView addGestureRecognizer:footTap];
        [self.view addSubview:_authFooterTipView];
    }
}

- (void)fetchAssets {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (self->_showTakePhotoBtn || self->_isFirstAppear || !self.albumModel.assetModels || systemVersion >= 14.0) {
            @weakify(self)
            [[TUIImageManager defaultManager] getAssetsFromFetchResult:self.albumModel.result completion:^(NSArray<TUIAssetModel *> *models) {
                @strongify(self)
                self.assetModels = [NSMutableArray arrayWithArray:models];
            }];
        } else {
            self.assetModels = [NSMutableArray arrayWithArray:self.albumModel.assetModels];
        }
    });
}

#pragma mark ToolBar Logic
- (void)configBottomToolBar {
    if (_bottomToolBar) return;
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    
    _bottomToolBar = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomToolBar.backgroundColor = RGBA(29, 29, 29, 0.98);
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewButton addTarget:self action:@selector(onPreviewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:multiMediaNavVC.previewBtnTitleStr forState:UIControlStateNormal];
    [_previewButton setTitle:multiMediaNavVC.previewBtnTitleStr forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = [self.collectionView getSelectedPhotoList].count;
    
    _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, [TUICommonTools tui_isRightToLeftLayout] ? 10 : -10, 0, 0);
    [_originalPhotoButton addTarget:self action:@selector(onOriginalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_originalPhotoButton setTitle:multiMediaNavVC.fullImageBtnTitleStr forState:UIControlStateNormal];
    [_originalPhotoButton setTitle:multiMediaNavVC.fullImageBtnTitleStr forState:UIControlStateSelected];
    [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_originalPhotoButton setImage:multiMediaNavVC.photoOriginDefImage forState:UIControlStateNormal];
    [_originalPhotoButton setImage:multiMediaNavVC.photoOriginSelImage forState:UIControlStateSelected];
    _originalPhotoButton.imageView.clipsToBounds = YES;
    _originalPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    
    _originalPhotoLabel = [[UILabel alloc] init];
    _originalPhotoLabel.textAlignment = NSTextAlignmentCenter;
    _originalPhotoLabel.font = [UIFont systemFontOfSize:12];
    _originalPhotoLabel.textColor = [UIColor grayColor];
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(onDoneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:multiMediaNavVC.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitle:multiMediaNavVC.doneBtnTitleStr forState:UIControlStateDisabled];
    [_doneButton setTitleColor:multiMediaNavVC.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:multiMediaNavVC.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
    _doneButton.enabled = [self.collectionView getSelectedPhotoList].count;
    
    _numberImageView = [[UIImageView alloc] initWithImage:multiMediaNavVC.photoNumberIconImage];
    _numberImageView.hidden = [self.collectionView getSelectedPhotoList].count <= 0;
    _numberImageView.clipsToBounds = YES;
    _numberImageView.contentMode = UIViewContentModeScaleAspectFit;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.adjustsFontSizeToFitWidth = YES;
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",[self.collectionView getSelectedPhotoList].count];
    _numberLabel.hidden = [self.collectionView getSelectedPhotoList].count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoneButtonClick)];
    [_numberLabel addGestureRecognizer:tapGesture];
    
    [_bottomToolBar addSubview:_previewButton];
    [_bottomToolBar addSubview:_doneButton];
    [_bottomToolBar addSubview:_numberImageView];
    [_bottomToolBar addSubview:_numberLabel];
    [_bottomToolBar addSubview:_originalPhotoButton];
    [_bottomToolBar addSubview:_originalPhotoLabel];
    [self.view addSubview:_bottomToolBar];
}

- (void)onPreviewButtonClick {
    TUIPhotoPreviewController *photoPreviewVc = [[TUIPhotoPreviewController alloc] init];
    NSArray<TUIAssetModel *> * selectArray = [self.collectionView getSelectedPhotoList];
    if (selectArray.count > 0) {
        TUIAssetModel *firstSelectedModel = selectArray.firstObject;
        NSUInteger currentIndex = 0;
        for (TUIAssetModel *modelItem in self.assetModels) {
            if ([modelItem.asset.localIdentifier isEqualToString:firstSelectedModel.asset.localIdentifier]) {
                photoPreviewVc.currentShowIndex = currentIndex;
                break;
            }
            currentIndex++;
        }
    }
    @weakify(self)
    photoPreviewVc.addAssetBlock = ^(TUIAssetModel *model) {
        model.isSelected = YES;
        [self.collectionView setSelected:model selected:YES];
    };
    photoPreviewVc.refreshAssetBlock = ^(TUIAssetModel *model) {
        [self.collectionView freshPhoto:model];
    };
    photoPreviewVc.delAssetBlock = ^(TUIAssetModel *model) {
        NSArray *selectedModels = [NSArray arrayWithArray:[self.collectionView getSelectedPhotoList]];
        for (TUIAssetModel *modelItem in selectedModels) {
            if ([model.asset.localIdentifier isEqualToString:modelItem.asset.localIdentifier]) {
                model.isSelected = NO;
                [self.collectionView setSelected:modelItem selected:NO];
                break;
            }
        }
    };
    [self pushPhotoPrevireViewController:photoPreviewVc needCheckSelectedModels:YES];
}

- (void)onOriginalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.selected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

- (void)onDoneButtonClick {
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    [multiMediaNavVC showProgressHUD];
    _doneButton.enabled = NO;
    self.isFetchingMedia = YES;
    
    NSMutableArray *pickModels = [NSMutableArray array];
    __block BOOL havenotShowAlert = YES;
    __block UIAlertController *alertView;
    [TUIImageManager defaultManager].shouldFixOrientation = YES;
    for (NSInteger i = 0; i < [self.collectionView getSelectedPhotoList].count; i++) {
        TUIAssetModel *model = [self.collectionView getSelectedPhotoList][i];
        TUIRequestOperation *operation = [[TUIRequestOperation alloc] initWithAsset:model.asset completed:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info) {
            TUIAssetPickModel *pickModel = [[TUIAssetPickModel alloc] init];
            pickModel.image = photo;
            pickModel.info = info;
            pickModel.asset = model.asset;
            if (model.editurl) {
                pickModel.editurl = model.editurl;
            }
            
            if (model.editImage) {
                pickModel.editImage = model.editImage;
            }
            
            [pickModels addObject:pickModel];
            if (pickModels.count != [self.collectionView getSelectedPhotoList].count) {
                return;
            }
            
            if (havenotShowAlert && alertView) {
                [alertView dismissViewControllerAnimated:YES completion:^{
                    alertView = nil;
                    [self didGetAllPhotos:pickModels];
                }];
            } else {
                [self didGetAllPhotos:pickModels];
            }
        } progress:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
            if (progress < 1 && havenotShowAlert && !alertView) {
                alertView = [multiMediaNavVC showAlertWithTitle:[NSBundle tui_localizedStringForKey:@"Synchronizing photos from iCloud"]];
                havenotShowAlert = NO;
                return;
            }
            if (progress >= 1) {
                havenotShowAlert = YES;
            }
        }];
        [self.operationQueue addOperation:operation];
    }
}

- (void)didGetAllPhotos:(NSArray<TUIAssetPickModel *> *)pickModels {
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    [multiMediaNavVC hideProgressHUD];
    _doneButton.enabled = YES;
    self.isFetchingMedia = NO;

    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self callDelegateMethodWithPhotos:pickModels];
    }];
}

- (void)callDelegateMethodWithPhotos:(NSArray<TUIAssetPickModel *> *)pickModels {
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (TUIAssetPickModel *model in pickModels) {
        [photos addObject:model.image];
        [assets addObject:model.asset];
        [infoArr addObject:model.info];
    }
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    if (multiMediaNavVC.didFinishPickingHandle) {
        multiMediaNavVC.didFinishPickingHandle(pickModels,_isSelectOriginalPhoto);
    }
    if (multiMediaNavVC.didFinishPickingPhotosWithInfosHandle) {
        multiMediaNavVC.didFinishPickingPhotosWithInfosHandle(pickModels,_isSelectOriginalPhoto,infoArr);
    }
}

#pragma mark - Notification
- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = self.collectionView.contentOffset.y / (_layout.itemSize.height + _layout.minimumLineSpacing);
}

#pragma mark - UITableViewDataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIAlbumCell"];
    TUIMultimediaNavController *imagePickerVc = (TUIMultimediaNavController *)self.navigationController;
    
    cell.selectedCountButton.backgroundColor = imagePickerVc.iconThemeColor;
    if (indexPath.row < self.albumList.count) {
        [cell fillWithData:self.albumList[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.albumList.count) {
        self.albumModel = self.albumList[indexPath.row];
        [self.collectionView setBucket:self.albumModel];
        _shouldScrollToBottom = YES;
        [self refreshAlbumChangeView];
        [self hideAllAlbums];
        [self fetchAssets];
    }
}

#pragma mark - AlbumClickListener
- (void)onClick:(NSInteger)index model:(nonnull TUIAssetModel *)model{
    TUIPhotoPreviewController *photoPreviewVc = [[TUIPhotoPreviewController alloc] init];
    photoPreviewVc.currentShowIndex = index;
    photoPreviewVc.assetModels = self.assetModels;
    @weakify(self);
    photoPreviewVc.addAssetBlock = ^(TUIAssetModel *model) {
        model.isSelected = YES;
        [self.collectionView setSelected:model selected:YES];
    };
    photoPreviewVc.refreshAssetBlock = ^(TUIAssetModel *model) {
        [self.collectionView freshPhoto:model];
    };
    photoPreviewVc.delAssetBlock = ^(TUIAssetModel *model) {
        NSArray *selectedModels = [NSArray arrayWithArray:[self.collectionView getSelectedPhotoList]];
        for (TUIAssetModel *modelItem in selectedModels) {
            if ([model.asset.localIdentifier isEqualToString:modelItem.asset.localIdentifier]) {
                model.isSelected = NO;
                [self.collectionView setSelected:modelItem selected:NO];
                break;
            }
        }
    };
    [self pushPhotoPrevireViewController:photoPreviewVc];
}
- (void)onSelectChanged:(TUIAssetModel *)bean {
    [self checkSelectedModels];
    [self refreshBottomToolBarStatus];
}

#pragma mark - Private Method

- (NSInteger)getAllCellCount {
    NSInteger count = self.assetModels.count;
    if (_showTakePhotoBtn) {
        count += 1;
    }
    if (_authorizationLimited) {
        count += 1;
    }
    return count;
}

- (NSInteger)getTakePhotoCellIndex {
    if (!_showTakePhotoBtn) {
        return -1;
    }
    return [self getAllCellCount] - 1;
}

- (NSInteger)getAddMorePhotoCellIndex {
    if (!_authorizationLimited) {
        return -1;
    }
    if (_showTakePhotoBtn) {
        return [self getAllCellCount] - 2;
    }
    return [self getAllCellCount] - 1;
}

- (void)openSettingsApplication {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)addMorePhoto {
    if (@available(iOS 14, *)) {
        [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:self];
    }
}

- (void)refreshBottomToolBarStatus {
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    
    _previewButton.enabled = [self.collectionView getSelectedPhotoList].count > 0;
    _doneButton.enabled = [self.collectionView getSelectedPhotoList].count > 0;
    
    _numberImageView.hidden = [self.collectionView getSelectedPhotoList].count <= 0;
    _numberLabel.hidden = [self.collectionView getSelectedPhotoList].count <= 0;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",[self.collectionView getSelectedPhotoList].count];
    
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLabel.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)pushPhotoPrevireViewController:(TUIPhotoPreviewController *)photoPreviewVc {
    [self pushPhotoPrevireViewController:photoPreviewVc needCheckSelectedModels:NO];
}

- (void)pushPhotoPrevireViewController:(TUIPhotoPreviewController *)photoPreviewVc needCheckSelectedModels:(BOOL)needCheckSelectedModels {
    @weakify(self)
    photoPreviewVc.assetModels = self.assetModels;
    photoPreviewVc.selectedModels =  [NSMutableArray arrayWithArray:[self.collectionView getSelectedPhotoList]];
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        @strongify(self)
        self.isSelectOriginalPhoto = isSelectOriginalPhoto;
        if (needCheckSelectedModels) {
            [self checkSelectedModels];
        }
        [self.collectionView reloadData];
        [self refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        @strongify(self)
        self.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [self onDoneButtonClick];
    }];
    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
        @strongify(self)
        TUIAssetPickModel *model = [[TUIAssetPickModel alloc] init];
        model.image = cropedImage;
        model.asset = asset;
        [self didGetAllPhotos:@[model]];
    }];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)getSelectedPhotoBytes {
    NSArray *selectedModels = [self.collectionView getSelectedPhotoList];
    if (0 == selectedModels.count) {
        self->_originalPhotoLabel.text = @"";
        return;
    }
    
#if 0
    @weakify(self)
    [[TUIImageManager defaultManager] getPhotosTotalBytes:selectedModels completion:^(NSString *totalBytes) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_originalPhotoLabel.text = [NSString stringWithFormat:@"%@ %@",[NSBundle tui_localizedStringForKey:@"TUIAlbumSelectorTotal"],totalBytes];
            [self->_originalPhotoLabel sizeToFit];
        });
    }];
#endif
}

- (void)prepareScrollCollectionViewToBottom {
    if (_shouldScrollToBottom && self.assetModels.count > 0) {
        NSInteger item = [self getAllCellCount] - 1;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        self->_shouldScrollToBottom = NO;
        self.collectionView.hidden = NO;
    } else {
        self.collectionView.hidden = NO;
    }
}

- (void)checkSelectedModels {
    NSArray *selectedModels = [self.collectionView getSelectedPhotoList];
    NSMutableSet *selectedAssets = [NSMutableSet setWithCapacity:selectedModels.count];
    for (TUIAssetModel *model in selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (TUIAssetModel *model in self.assetModels) {
        model.isSelected = NO;
        if ([selectedAssets containsObject:model.asset]) {
            model.isSelected = YES;
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TUIMultimediaNavController *imagePickerVc = (TUIMultimediaNavController *)self.navigationController;
        [imagePickerVc showProgressHUD];
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
        if (photo) {
            self.isSavingMedia = YES;
            [[TUIImageManager defaultManager] savePhotoWithImage:photo meta:meta location:self.location completion:^(PHAsset *asset, NSError *error){
                self.isSavingMedia = NO;
                if (!error && asset) {
                    [self addPHAsset:asset];
                } else {
                    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
                    [multiMediaNavVC hideProgressHUD];
                }
            }];
            self.location = nil;
        }
    } else if ([type isEqualToString:@"public.movie"]) {
        TUIMultimediaNavController *imagePickerVc = (TUIMultimediaNavController *)self.navigationController;
        [imagePickerVc showProgressHUD];
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            self.isSavingMedia = YES;
            [[TUIImageManager defaultManager] saveVideoWithUrl:videoUrl location:self.location completion:^(PHAsset *asset, NSError *error) {
                self.isSavingMedia = NO;
                if (!error && asset) {
                    [self addPHAsset:asset];
                } else {
                    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
                    [multiMediaNavVC hideProgressHUD];
                }
            }];
            self.location = nil;
        }
    }
}

- (void)addPHAsset:(PHAsset *)asset {
    TUIAssetModel *assetModel = [[TUIImageManager defaultManager] createModelWithAsset:asset];
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    [multiMediaNavVC hideProgressHUD];
    [self.assetModels addObject:assetModel];
    
    if (multiMediaNavVC.maxImagesCount < 1) {
        [self.collectionView setSelected:assetModel selected:YES];
        [self onDoneButtonClick];
        return;
    }
    
    if ([self.collectionView getSelectedPhotoList].count < multiMediaNavVC.maxImagesCount) {
        assetModel.isSelected = YES;
        [self.collectionView setSelected:assetModel selected:YES];
        [self refreshBottomToolBarStatus];
    }
    self.collectionView.hidden = YES;
    [self.collectionView reloadData];
    
    _shouldScrollToBottom = YES;
    [self prepareScrollCollectionViewToBottom];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    if (self.isSavingMedia || self.isFetchingMedia) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isShowingAlbums) {
            [self refreshAlbumTableView];
        }

        PHFetchResultChangeDetails *changeDetail = [changeInstance changeDetailsForFetchResult:self.albumModel.result];
        if (changeDetail == nil) return;
        if ([[TUIImageManager defaultManager] isPHAuthorizationStatusLimited]) {
            NSArray *changedObjects = [changeDetail changedObjects];
            changeDetail = [PHFetchResultChangeDetails changeDetailsFromFetchResult:self.albumModel.result toFetchResult:changeDetail.fetchResultAfterChanges changedObjects:changedObjects];
            if (changeDetail && changeDetail.removedObjects.count) {
                [self handleRemovedAssets:changeDetail.removedObjects];
            }
        }

        if (changeDetail.hasIncrementalChanges == NO) {
            [self.albumModel refreshFetchResult];
            [self fetchAssets];
        } else {
            NSInteger insertedCount = changeDetail.insertedObjects.count;
            NSInteger removedCount = changeDetail.removedObjects.count;
            NSInteger changedCount = changeDetail.changedObjects.count;
            if (insertedCount > 0 || removedCount > 0 || changedCount > 0) {
                self.albumModel.result = changeDetail.fetchResultAfterChanges;
                self.albumModel.photoCount = changeDetail.fetchResultAfterChanges.count;
                [self fetchAssets];
            }
        }
    });
}

- (void)handleRemovedAssets:(NSArray<PHAsset *> *)removedObjects {
    TUIMultimediaNavController *multiMediaNavVC = (TUIMultimediaNavController *)self.navigationController;
    for (PHAsset *asset in removedObjects) {
        Boolean isSelected = [multiMediaNavVC.selectedAssetIds containsObject:asset.localIdentifier];
        if (!isSelected) continue;
        NSArray *selectedModels = [NSArray arrayWithArray:[self.collectionView getSelectedPhotoList]];
        for (TUIAssetModel *modelItem in selectedModels) {
            if ([asset.localIdentifier isEqualToString:modelItem.asset.localIdentifier]) {
                [self.collectionView setSelected:modelItem selected:NO];
            }
        }
        [self refreshBottomToolBarStatus];
    }
}

#pragma clang diagnostic pop

@end

