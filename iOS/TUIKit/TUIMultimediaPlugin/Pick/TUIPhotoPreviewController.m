//
//  TUIPhotoPreviewController.m
//  TUIPhotoPreviewController
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import "TUIPhotoPreviewController.h"
#import "TUIPhotoPreviewCell.h"
#import "TUIMultimediaProcessor.h"
#import "TUIMultimediaNavController.h"
#import <TUICore/UIView+TUILayout.h>
#import <TUICore/UIView+TUIUtil.h>
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMDefine.h>
#import <TUIMultimediaCore/TUISelectedPhotosView.h>
#import <TUIMultimediaCore/TUIAssetModel.h>
#import <TUIMultimediaCore/TUIImageManager.h>

@interface TUIPhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate> {
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    UILabel *_indexLabel;
    
    UIView *_toolBar;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    TUISelectedPhotosView *_selectedScrollView;
    
    UIButton *_editPhotoButton;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    
    CGFloat _offsetItemCount;
    
    BOOL _didSetIsSelectOriginalPhoto;
}
@property (nonatomic, assign) BOOL isHideNaviBar;

@property (nonatomic, assign) double progress;
@property (strong, nonatomic) UIAlertController *alertView;
@property (nonatomic, strong) UIView *iCloudErrorView;

@property (nonatomic, strong) TUIMultimediaNavController *multiMediaNavVC;
@end

@implementation TUIPhotoPreviewController

- (void)setIsSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    _didSetIsSelectOriginalPhoto = YES;
}

- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.multiMediaNavVC.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [TUIImageManager defaultManager].shouldFixOrientation = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    [TUIImageManager defaultManager].shouldFixOrientation = YES;
    
    if (!_didSetIsSelectOriginalPhoto) {
        _isSelectOriginalPhoto = self.multiMediaNavVC.isSelectOriginalPhoto;
    }
    
    [self configCollectionView];
    [self configCustomNaviBar];
    [self configSelectedScrollView];
    [self configBottomToolBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [_collectionView setContentOffset:CGPointMake((self.view.mm_w + 20) * self.currentShowIndex, 0) animated:NO];
    [self refreshNaviBarAndBottomBarState];
    [self updateSelectedScrollViewWithModels:self.selectedModels];
    [self onScrollToItemAtIndex:self.currentShowIndex];

}

- (TUIMultimediaNavController *)multiMediaNavVC {
    return (TUIMultimediaNavController *)self.navigationController;
}

- (void)configCustomNaviBar {
    _naviBar = [[UIView alloc] initWithFrame:CGRectZero];
    _naviBar.backgroundColor = RGBA(29, 29, 29, 0.98);
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    
    [_backButton setImage:[[UIImage tui_imageNamedFromMyBundle:@"navi_back"]
                           rtl_imageFlippedForRightToLeftLayoutDirection] 
                 forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(onBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _selectButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_selectButton setImage:self.multiMediaNavVC.photoDefImage forState:UIControlStateNormal];
    [_selectButton setImage:self.multiMediaNavVC.photoSelImage forState:UIControlStateSelected];
    _selectButton.imageView.clipsToBounds = YES;
    _selectButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    _selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_selectButton addTarget:self action:@selector(onSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _selectButton.hidden = YES;
    
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.adjustsFontSizeToFitWidth = YES;
    _indexLabel.font = [UIFont systemFontOfSize:14];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    
    [_naviBar addSubview:_selectButton];
    [_naviBar addSubview:_indexLabel];
    [_naviBar addSubview:_backButton];
    [self.view addSubview:_naviBar];
}

- (void)configSelectedScrollView {
    _selectedScrollView = [[TUISelectedPhotosView alloc] init];
    [_selectedScrollView setPhotoList:self.selectedModels];
    [_selectedScrollView setClickListener:self];
    _selectedScrollView.backgroundColor = RGBA(29, 29, 29, 0.98);
    _selectedScrollView.bouncesZoom = YES;
    _selectedScrollView.maximumZoomScale = 4;
    _selectedScrollView.minimumZoomScale = 1.0;
    _selectedScrollView.multipleTouchEnabled = YES;
//    _selectedScrollView.delegate = self;
    _selectedScrollView.scrollsToTop = NO;
    _selectedScrollView.showsHorizontalScrollIndicator = NO;
    _selectedScrollView.showsVerticalScrollIndicator = YES;
    _selectedScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _selectedScrollView.delaysContentTouches = NO;
    _selectedScrollView.canCancelContentTouches = YES;
    _selectedScrollView.alwaysBounceVertical = NO;
    _selectedScrollView.pagingEnabled = NO;
    _selectedScrollView.bounces = NO;
    if (@available(iOS 11, *)) {
        _selectedScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_selectedScrollView];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    _toolBar.backgroundColor = RGBA(29, 29, 29, 0.98);
    
    _editPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editPhotoButton.backgroundColor = [UIColor clearColor];
    [_editPhotoButton addTarget:self action:@selector(onEditPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _editPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_editPhotoButton setTitle:self.multiMediaNavVC.editImageBtnTitleStr forState:UIControlStateNormal];
    [_editPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, [TUICommonTools tui_isRightToLeftLayout] ? 10 : -10, 0, 0);
    _originalPhotoButton.backgroundColor = [UIColor clearColor];
    [_originalPhotoButton addTarget:self action:@selector(onOriginalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_originalPhotoButton setTitle:self.multiMediaNavVC.fullImageBtnTitleStr forState:UIControlStateNormal];
    [_originalPhotoButton setTitle:self.multiMediaNavVC.fullImageBtnTitleStr forState:UIControlStateSelected];
    [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_originalPhotoButton setImage:self.multiMediaNavVC.photoPreviewOriginDefImage forState:UIControlStateNormal];
    [_originalPhotoButton setImage:self.multiMediaNavVC.photoOriginSelImage forState:UIControlStateSelected];
    
    _originalPhotoLabel = [[UILabel alloc] init];
    _originalPhotoLabel.textAlignment = NSTextAlignmentCenter;
    _originalPhotoLabel.font = [UIFont systemFontOfSize:12];
    _originalPhotoLabel.textColor = [UIColor grayColor];
    _originalPhotoLabel.backgroundColor = [UIColor clearColor];
    if (_isSelectOriginalPhoto) [self showTotalPhotoBytes];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(onDoneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:self.multiMediaNavVC.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitleColor:self.multiMediaNavVC.oKButtonTitleColorNormal forState:UIControlStateNormal];
    
    _numberImageView = [[UIImageView alloc] initWithImage:self.multiMediaNavVC.photoNumberIconImage];
    _numberImageView.backgroundColor = [UIColor clearColor];
    _numberImageView.clipsToBounds = YES;
    _numberImageView.contentMode = UIViewContentModeScaleAspectFit;
    _numberImageView.hidden = self.selectedModels.count <= 0;
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.adjustsFontSizeToFitWidth = YES;
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",self.selectedModels.count];
    _numberLabel.hidden = self.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoneButtonClick)];
    [_numberLabel addGestureRecognizer:tapGesture];
    
    [_toolBar addSubview:_doneButton];
    [_toolBar addSubview:_editPhotoButton];
    [_toolBar addSubview:_originalPhotoButton];
    [_toolBar addSubview:_originalPhotoLabel];
    [_toolBar addSubview:_numberImageView];
    [_toolBar addSubview:_numberLabel];
    [self.view addSubview:_toolBar];
}

- (void)configCollectionView {
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.assetModels.count * (self.view.mm_w + 20), 0);
    if (@available(iOS 11, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TUIPhotoPreviewCell class] forCellWithReuseIdentifier:@"TUIPhotoPreviewCell"];
    [_collectionView registerClass:[TUIPhotoPreviewCell class] forCellWithReuseIdentifier:@"TUIPhotoPreviewCellGIF"];
    [_collectionView registerClass:[TUIVideoPreviewCell class] forCellWithReuseIdentifier:@"TUIVideoPreviewCell"];
    [_collectionView registerClass:[TUIGifPreviewCell class] forCellWithReuseIdentifier:@"TUIGifPreviewCell"];
}

#pragma mark - Layout
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    BOOL isFullScreen = (self.view.mm_h == Screen_Height);
    CGFloat statusBarHeight = isFullScreen ? [TUICommonTools tui_statusBarHeight] : 0;
    CGFloat statusBarHeightInterval = isFullScreen ? (statusBarHeight - 20) : 0;
    CGFloat naviBarHeight = statusBarHeight + self.multiMediaNavVC.navigationBar.mm_h;
    _naviBar.frame = CGRectMake(0, 0, self.view.mm_w, naviBarHeight);
    _backButton.frame = CGRectMake(10, 10 + statusBarHeightInterval, 44, 44);
    _selectButton.frame = CGRectMake(self.view.mm_w - 56, 10 + statusBarHeightInterval, 44, 44);
    _indexLabel.frame = _selectButton.frame;
    
    _layout.itemSize = CGSizeMake(self.view.mm_w + 20, self.view.mm_h);
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    _collectionView.frame = CGRectMake(-10, 0, self.view.mm_w + 20, self.view.mm_h);
    [_collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetX = _offsetItemCount * _layout.itemSize.width;
        [_collectionView setContentOffset:CGPointMake(offsetX, 0)];
    }
    
    CGFloat toolBarHeight = 44 + [TUICommonTools tui_safeAreaInsets].bottom + 2;
    CGFloat toolBarTop = self.view.mm_h - toolBarHeight;
    _toolBar.frame = CGRectMake(0, toolBarTop, self.view.mm_w, toolBarHeight);
    
    _editPhotoButton.frame = CGRectMake(0, 0, 56, 44);
    CGFloat fullImageWidth = [self.multiMediaNavVC.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
    fullImageWidth += 40;
    _originalPhotoButton.frame = CGRectMake(_toolBar.mm_w /  2 - fullImageWidth / 2, 0, fullImageWidth, 44);
    
    [_originalPhotoLabel sizeToFit];
    _originalPhotoLabel.frame = CGRectMake(_toolBar.mm_w /2 -_originalPhotoLabel.mm_w /2 ,
                                           33,
                                           _originalPhotoLabel.mm_w,
                                           _originalPhotoLabel.mm_h);
    _originalPhotoLabel.alpha = 0;
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.mm_w - _doneButton.mm_w - 12, 0, MAX(44, _doneButton.mm_w), 44);
    _numberImageView.frame = CGRectMake(_doneButton.mm_x - 24 - 5, 10, 24, 24);
    _numberLabel.frame = _numberImageView.frame;
    
    if (isRTL()) {
        for (UIView *subview in _naviBar.subviews) {
            [subview resetFrameToFitRTL];
        }
        for (UIView *subview in _toolBar.subviews) {
            [subview resetFrameToFitRTL];
        }
    }

    [self layoutSelectedScrollView];
}

- (void)layoutSelectedScrollView {
    CGFloat photoViewSize = 65;
    CGFloat photoViewMargin = 15;
    CGFloat scrollViewHeight = photoViewSize + 2 * photoViewMargin;
    _selectedScrollView.frame = CGRectMake(0, _toolBar.mm_y - scrollViewHeight, self.view.mm_w, scrollViewHeight);
    if (isRTL()) {
        _selectedScrollView.transform = CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)updateSelectedScrollViewWithModels:(NSMutableArray *)selectedModels {
    if (self.isSelectOriginalPhoto) {
        [self showTotalPhotoBytes];
    }
}

- (void)onScrollToItemAtIndex:(NSUInteger)index {
    if (index < self.assetModels.count) {
        TUIAssetModel *model = self.assetModels[index];
        [self->_selectedScrollView switchPhoto:model];
    }
}

- (BOOL)findInAllModels:(TUIAssetModel *)model findIndex:(NSUInteger *)findIndex {
    for (TUIAssetModel *modelItem in self.assetModels) {
        if ([modelItem.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            *findIndex = [self.assetModels indexOfObject:modelItem];
            return YES;
        }
    }
    return NO;
}

- (BOOL)findInSelectedModels:(TUIAssetModel *)model findIndex:(NSUInteger *)findIndex {
    for (TUIAssetModel *modelItem in self.selectedModels) {
        if ([modelItem.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            *findIndex = [self.selectedModels indexOfObject:modelItem];
            return YES;
        }
    }
    return NO;
}

#pragma mark - Notification
- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.x / _layout.itemSize.width;
}

#pragma mark - Click Event
- (void)onSelectButtonClick:(UIButton *)selectButton {
    [self selectPhoto:selectButton refreshCount:YES];
}

- (void)selectPhoto:(UIButton *)selectButton refreshCount:(BOOL)refreshCount {
    TUIAssetModel *model = self.assetModels[self.currentShowIndex];
    if (!selectButton.isSelected) {
        // 1. select:check if over the maxImagesCount
        if (self.selectedModels.count >= self.multiMediaNavVC.maxImagesCount) {
            NSString *title = [NSString stringWithFormat:[NSBundle tui_localizedStringForKey:@"Select a maximum of %zd photos"], self.multiMediaNavVC.maxImagesCount];
            [self.multiMediaNavVC showAlertWithTitle:title];
            return;
        }
        else {
            // 2. if not over the maxImagesCount
            [self.selectedModels addObject:model];
            [self->_selectedScrollView addPhoto:model];
            if (self.addAssetBlock) {
                self.addAssetBlock(model);
            }
        }
    } else {
        NSArray *selectedModels = [NSArray arrayWithArray:self.selectedModels];
        for (TUIAssetModel *modelItem in selectedModels) {
            if ([modelItem.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                NSArray *selectedModelsTmp = [NSArray arrayWithArray:self.selectedModels];
                for (NSInteger i = 0; i < selectedModelsTmp.count; i++) {
                    TUIAssetModel *model = selectedModelsTmp[i];
                    if ([model isEqual:modelItem]) {
                        [self.selectedModels removeObject:model];
                        [self->_selectedScrollView removePhoto:model];
                        if (self.delAssetBlock) {
                            self.delAssetBlock(model);
                        }
                        break;
                    }
                }
                break;
            }
        }
    }
    model.isSelected = !selectButton.isSelected;
    if (model.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:TUIOscillatoryAnimationToBigger];
    }
    [UIView showOscillatoryAnimationWithLayer:_numberImageView.layer type:TUIOscillatoryAnimationToSmaller];
    
    if (refreshCount) {
        [self refreshNaviBarAndBottomBarState];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateSelectedScrollViewWithModels:self.selectedModels];
        [self onScrollToItemAtIndex:self.currentShowIndex];
    });
}

- (void)onBackButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock(_isSelectOriginalPhoto);
    }
}

- (void)onDoneButtonClick {
    // Alert user if pictures are being synced from iCloud
    if (_progress > 0 && _progress < 1 && (_selectButton.isSelected || !self.selectedModels.count )) {
        _alertView = [self.multiMediaNavVC showAlertWithTitle:[NSBundle tui_localizedStringForKey:@"Synchronizing photos from iCloud"]];
        return;
    }
    
    // If no photo has been selected, click OK to select the currently previewed photo.
    if (self.selectedModels.count == 0) {
        [self selectPhoto:_selectButton refreshCount:NO];
    }
    
    if (self.doneButtonClickBlock) {
        self.doneButtonClickBlock(_isSelectOriginalPhoto);
    }
}

- (void)onEditPhotoButtonClick {
    __weak typeof(self) weakSelf = self;
    TUIAssetModel * model = [self getCurrentSelectedModel];
    if (!model) {
        return;
    }
    
    if (model.type == TUIAssetMediaTypeVideo) {
        [[TUIImageManager defaultManager] requestVideoURLWithAsset:model.asset success:^(NSURL *videoURL) {
            void (^editVideoBlock)(void) = ^(void) {
                NSURL *formatUrl = videoURL;
                if (model.editurl) {
                    formatUrl = model.editurl;
                }
                [[TUIMultimediaProcessor shareInstance] editVideo:weakSelf url:formatUrl complete:^(NSURL * _Nullable uri) {
                    NSLog(@"transcode url is %@",videoURL);
                    if (uri != nil) {
                        [self replaceCurrentSelectedModel:uri];
                    }
                }];
                };
            dispatch_async(dispatch_get_main_queue(), editVideoBlock);
            NSLog(@"%@",videoURL);
        } failure:^(NSDictionary *info) {
            
        }];
    }
    else if (model.type == TUIAssetMediaTypePhoto) {
        if (model.editImage != nil) {
            [self editPictureOnMainQueue:model.editImage];
        } else {
            [[TUIImageManager defaultManager] getOriginalPhotoDataWithAsset:model.asset
            progressHandler:nil
            completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                    if (!isDegraded) {
                        UIImage *img = [UIImage imageWithData:data];
                        [self editPictureOnMainQueue:img];
                    }
                }];
        }
    }
}

- (void)editPictureOnMainQueue:(UIImage*) image {
    __weak typeof(self) weakSelf = self;
    void (^editPictureBlock)(void) = ^(void) {
        [[TUIMultimediaProcessor shareInstance] editPicture:weakSelf picture:image complete:^(UIImage * _Nullable picture) {
            if (picture != nil) {
                [self replaceCurrentSelectedPhotoModel:picture];
            }
        }];
        };
    dispatch_async(dispatch_get_main_queue(), editPictureBlock);
}

- (void)onProvideVideo:(NSURL *)videoURL
               snapshot:(NSString *)snapshotUrl
               duration:(NSInteger)duration {
    
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createVideoMessage:videoURL.path type:videoURL.path.pathExtension duration:(int)duration snapshotPath:snapshotUrl];
    NSDictionary *param = @{TUICore_TUIChatService_SendMessageMethod_MsgKey : message};
    NSString *entranceName = [TIMConfig isClassicEntrance]?
                                TUICore_TUIChatService:TUICore_TUIChatService_Minimalist;
    [TUICore callService:entranceName
                  method:TUICore_TUIChatService_SendMessageMethod param:param];

}
- (TUIAssetModel *)getCurrentSelectedModel {
    TUIAssetModel *model = self.assetModels[self.currentShowIndex];
    return model;
}
- (void)replaceCurrentSelectedModel:(NSURL *)uri {
    TUIAssetModel * model = [self getCurrentSelectedModel];
    if (model.type == TUIAssetMediaTypeVideo) {
        model.editurl = uri;
        model.editImage = [[TUIImageManager defaultManager] getImageWithVideoURL:uri];
        if (self.refreshAssetBlock) {
            self.refreshAssetBlock(model);
        }
        [_collectionView reloadData];
        [self refreshNaviBarAndBottomBarState];
    }
}

- (void)replaceCurrentSelectedPhotoModel:(UIImage *)image {
    TUIAssetModel * model = [self getCurrentSelectedModel];
    if (model == nil || model.type != TUIAssetMediaTypePhoto) {
        return;
    }
    
    model.editImage = image;
    if (self.refreshAssetBlock) {
        self.refreshAssetBlock(model);
    }
    [_selectedScrollView freshPhoto : model];
    [_collectionView reloadData];
    [self refreshNaviBarAndBottomBarState];
}

- (void)onOriginalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.selected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showTotalPhotoBytes];
    }
}

- (void)didTapPreviewCell {
    self.isHideNaviBar = !self.isHideNaviBar;
    _naviBar.hidden = self.isHideNaviBar;
    _toolBar.hidden = self.isHideNaviBar;
    _selectedScrollView.hidden = (self.isHideNaviBar || 0 == self.selectedModels.count);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        CGFloat offSetWidth = scrollView.contentOffset.x;
        offSetWidth = offSetWidth +  ((self.view.mm_w + 20) * 0.5);
        
        NSInteger currentShowIndex = offSetWidth / (self.view.mm_w + 20);
        if (currentShowIndex < self.assetModels.count && _currentShowIndex != currentShowIndex) {
            _currentShowIndex = currentShowIndex;
            [self refreshNaviBarAndBottomBarState];
            [self onScrollToItemAtIndex:self.currentShowIndex];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewCollectionViewDidScroll" object:nil];
    }
    else {
        
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIAssetModel *model = self.assetModels[indexPath.item];
    
    TUIAssetPreviewCell *cell;
    if (TUIAssetMediaTypeVideo == model.type) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TUIVideoPreviewCell" forIndexPath:indexPath];
        TUIVideoPreviewCell *currentCell = (TUIVideoPreviewCell *)cell;
        @weakify(self)
        currentCell.iCloudSyncFailedHandle = ^(id asset, BOOL isSyncFailed) {
            @strongify(self)
            model.iCloudFailed = isSyncFailed;
            [self didICloudSyncStatusChanged:model];
        };
    } else if (TUIAssetMediaTypePhotoGif == model.type) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TUIGifPreviewCell" forIndexPath:indexPath];
        TUIGifPreviewCell *currentCell = (TUIGifPreviewCell *)cell;
        @weakify(self)
        currentCell.previewView.iCloudSyncFailedHandle = ^(id asset, BOOL isSyncFailed) {
            @strongify(self)
            model.iCloudFailed = isSyncFailed;
            [self didICloudSyncStatusChanged:model];
        };
    } else {
        NSString *reuseId = model.type == TUIAssetMediaTypePhotoGif ? @"TUIPhotoPreviewCellGIF" : @"TUIPhotoPreviewCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
        TUIPhotoPreviewCell *photoPreviewCell = (TUIPhotoPreviewCell *)cell;
        @weakify(self)
        [photoPreviewCell setImageProgressUpdateBlock:^(double progress) {
            @strongify(self)
            self.progress = progress;
            if (progress >= 1) {
                if (self.isSelectOriginalPhoto) [self showTotalPhotoBytes];
                if (self.alertView && [self->_collectionView.visibleCells containsObject:photoPreviewCell]) {
                    [self.alertView dismissViewControllerAnimated:YES completion:^{
                        self.alertView = nil;
                        [self onDoneButtonClick];
                    }];
                }
            }
        }];
        photoPreviewCell.previewView.iCloudSyncFailedHandle = ^(id asset, BOOL isSyncFailed) {
            @strongify(self)
            model.iCloudFailed = isSyncFailed;
            [self didICloudSyncStatusChanged:model];
        };
    }
    
    cell.model = model;
    
    @weakify(self)
    [cell setSingleTapGestureBlock:^{
        @strongify(self)
        [self didTapPreviewCell];
    }];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TUIPhotoPreviewCell class]]) {
        [(TUIPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TUIPhotoPreviewCell class]]) {
        [(TUIPhotoPreviewCell *)cell recoverSubviews];
    } else if ([cell isKindOfClass:[TUIVideoPreviewCell class]]) {
        TUIVideoPreviewCell *videoCell = (TUIVideoPreviewCell *)cell;
        if (videoCell.player && videoCell.player.rate != 0.0) {
            [videoCell pausePlayerAndShowNaviBar];
        }
    }
}

#pragma mark - Private Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshNaviBarAndBottomBarState {
    TUIAssetModel *model = self.assetModels[self.currentShowIndex];
    _selectButton.selected = model.isSelected;
    [self refreshSelectButtonImageViewContentMode];
    
    _indexLabel.hidden = YES;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",self.selectedModels.count];
    _numberImageView.hidden = (self.selectedModels.count <= 0 || _isHideNaviBar || _isCropImage);
    _numberLabel.hidden = (self.selectedModels.count <= 0 || _isHideNaviBar || _isCropImage);
    
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self showTotalPhotoBytes];

    if (!_isHideNaviBar) {
        _originalPhotoButton.hidden = NO;
        if (_isSelectOriginalPhoto) _originalPhotoLabel.hidden = NO;
    }
    if (model.type == TUIAssetMediaTypeVideo || model.type == TUIAssetMediaTypePhoto) {
        [_editPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        [_editPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    _doneButton.hidden = NO;
    _selectButton.hidden = NO;
    [self didICloudSyncStatusChanged:model];
}

- (void)refreshSelectButtonImageViewContentMode {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_selectButton.imageView.image.size.width <= 27) {
            self->_selectButton.imageView.contentMode = UIViewContentModeCenter;
        } else {
            self->_selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    });
}

- (void)didICloudSyncStatusChanged:(TUIAssetModel *)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        TUIAssetModel *currentModel = self.assetModels[self.currentShowIndex];
        if (self.selectedModels.count <= 0) {
            self->_doneButton.enabled = !currentModel.iCloudFailed;
        } else {
            self->_doneButton.enabled = YES;
        }
        self->_selectButton.hidden = currentModel.iCloudFailed;
        if (currentModel.iCloudFailed) {
            self->_originalPhotoButton.hidden = YES;
            self->_originalPhotoLabel.hidden = YES;
        }
    });
}

- (void)showTotalPhotoBytes {
    if (0 == self.selectedModels.count) {
        self->_originalPhotoLabel.text = @"";
        return;
    }
    
#if 0
    [[TUIImageManager defaultManager] getPhotosTotalBytes:self.selectedModels completion:^(NSString *totalBytes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_originalPhotoLabel.text = [NSString stringWithFormat:@"%@ %@",[NSBundle tui_localizedStringForKey:@"TUIAlbumSelectorTotal"],totalBytes];
            [self->_originalPhotoLabel sizeToFit];
        });
    }];
#endif

}

- (NSInteger)currentShowIndex {
    return [TUICommonTools tui_isRightToLeftLayout] ? self.assetModels.count - _currentShowIndex - 1 : _currentShowIndex;
}


- (void)onClick:(NSInteger)index model:(TUIAssetModel *)model;{
    NSUInteger findIndex = 0;
    BOOL findModel = [self findInAllModels:model findIndex:&findIndex];
    if (findModel && _collectionView) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:findIndex inSection:0]
                                atScrollPosition:(UICollectionViewScrollPositionLeft)animated:NO];
    }
    else {
        //Other bucket
    }
}


@end
