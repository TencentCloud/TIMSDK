//
//  TUISelectAvatarController.m
//  TUIKitDemo
//
//  Created by wyl on 2022/6/27.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUISelectAvatarController.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

#define UserAvatarURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/avatar/avatar_%d.png",x]
#define UserAvatarCount 26

#define GroupAvatarURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/group-avatar/group_avatar_%d.png",x]
#define GroupAvatarCount 24

#define Community_coverURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/community-cover/community_cover_%d.png",x]
#define Community_coverCount 12

#define BackGroundCoverURL(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%d.png",x]

#define BackGroundCoverURL_full(x) [NSString stringWithFormat:@"https://im.sdk.cloud.tencent.cn/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%d_full.png",x]

#define BackGroundCoverCount 7

@interface TUISelectAvatarCardItem : NSObject

@property (nonatomic, strong) NSString *posterUrlStr;
@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, copy) NSString *fullUrlStr;
@property (nonatomic, assign) BOOL isDefaultBackgroundItem;

@property (nonatomic, assign) BOOL isGroupGridAvatar;
@property (nonatomic, copy) NSString *createGroupType;
@property (nonatomic, strong) UIImage *cacheGroupGridAvatarImage;

@end

@implementation TUISelectAvatarCardItem

@end

@interface TUISelectAvatarCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectedView;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) TUISelectAvatarCardItem *cardItem;

- (void)updateSelectedUI;

@end

@implementation TUISelectAvatarCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  
    if (self) {
    
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
        [self.imageView setUserInteractionEnabled:YES];
    
        self.imageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    
        self.imageView.layer.borderWidth = 2;

        self.imageView.layer.masksToBounds = YES;
    
        [self.contentView addSubview:self.imageView];
    
        [self.imageView addSubview:self.selectedView];
        
        [self setupMaskView];
  }
    
    return self;
    
}

- (void)layoutSubviews {

    [self updateCellView];

    self.selectedView.frame = CGRectMake(self.imageView.frame.size.width - 16 - 4 , 4 ,
                                       16 , 16);
}

- (void)updateCellView {
    [self updateSelectedUI];
    [self updateImageView];
    [self updateMaskView];
}

- (void)updateSelectedUI {
    
    if (self.cardItem.isSelect){
        self.imageView.layer.borderColor = TUICoreDynamicColor(@"", @"#006EFF").CGColor;
        self.selectedView.hidden = NO;
    }
    else {
        if (self.cardItem.isDefaultBackgroundItem) {
            self.imageView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.1].CGColor;
        }
        else {
            self.imageView.layer.borderColor = UIColor.clearColor.CGColor;
        }
        self.selectedView.hidden = YES;
    }
}

- (void)updateImageView {
    if (self.cardItem.isGroupGridAvatar) {
        [self updateNormalGroupGridAvatar];
    }
    else {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.cardItem.posterUrlStr]
                          placeholderImage:TUICoreBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head_img")];
    }
}
- (void)updateMaskView {
    if (self.cardItem.isDefaultBackgroundItem) {
        self.maskView.hidden = NO;
        self.maskView.frame = CGRectMake(0, self.imageView.frame.size.height - 28, self.imageView.frame.size.width, 28);
        [self.descLabel sizeToFit];
        self.descLabel.mm_center();
    }
    else {
        self.maskView.hidden = YES;
    }
}

- (void)updateNormalGroupGridAvatar {
    if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cardItem.cacheGroupGridAvatarImage) {
        [self.imageView sd_setImageWithURL:nil placeholderImage:self.cardItem.cacheGroupGridAvatarImage];
    }
}

- (void)setupMaskView {
    self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.maskView.backgroundColor = [UIColor colorWithHex:@"cccccc"];
    [self.imageView addSubview:self.maskView];
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.text = TUIKitLocalizableString(TUIKitDefaultBackground);
    self.descLabel.textColor = [UIColor whiteColor];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    [self.maskView addSubview:self.descLabel];
    [self.descLabel sizeToFit];
    self.descLabel.mm_center();
}

- (void)setCardItem:(TUISelectAvatarCardItem *)cardItem {
    _cardItem = cardItem;
}

- (UIImageView *)selectedView {
    
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _selectedView.image = [UIImage imageNamed:TUICoreImagePath(@"icon_avatar_selected")];
    }
    return _selectedView;
}


@end

@interface TUISelectAvatarController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) TUISelectAvatarCardItem *currentSelectCardItem;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation TUISelectAvatarController

static NSString * const reuseIdentifier = @"TUISelectAvatarCollectionCell";

- (instancetype)init {
    if (self = [super init]) {
        self.selectAvatarType = TUISelectAvatarTypeUserAvatar;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NavBar_Height - StatusBar_Height);
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    [self.view addSubview:self.collectionView];
    
    self.collectionView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Register cell classes
    [self.collectionView registerClass:[TUISelectAvatarCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self setupNavigator];
    
    self.dataArr = [NSMutableArray arrayWithCapacity:3];
    
    [self loadData];
}
- (void)loadData {
    
    if (self.selectAvatarType == TUISelectAvatarTypeUserAvatar) {
        
        for (int i = 0 ; i< UserAvatarCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:UserAvatarURL(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    else if (self.selectAvatarType == TUISelectAvatarTypeGroupAvatar) {

        if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cacheGroupGridAvatarImage) {
            TUISelectAvatarCardItem *cardItem = [self creatGroupGridAvatarCardItem];
            [self.dataArr addObject:cardItem];
        }
        
        for (int i = 0 ; i< GroupAvatarCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:GroupAvatarURL(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    else if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        TUISelectAvatarCardItem *cardItem = [self creatCleanCardItem];
        [self.dataArr addObject:cardItem];
        for (int i = 0 ; i < BackGroundCoverCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:BackGroundCoverURL(i+1) fullUrl:BackGroundCoverURL_full(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    
    else {
        for (int i = 0 ; i< Community_coverCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:Community_coverURL(i+1)];
            [self.dataArr addObject:cardItem];
        }
    }
    [self.collectionView reloadData];

}

- (TUISelectAvatarCardItem *)creatCardItemByURL:(NSString *)urlStr {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = urlStr;
    cardItem.isSelect = NO;
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL] ) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (TUISelectAvatarCardItem *)creatGroupGridAvatarCardItem {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = nil;
    cardItem.isSelect = NO;
    cardItem.isGroupGridAvatar = YES;
    cardItem.createGroupType = self.createGroupType;
    cardItem.cacheGroupGridAvatarImage = self.cacheGroupGridAvatarImage;
    if (!self.profilFaceURL) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (TUISelectAvatarCardItem *)creatCardItemByURL:(NSString *)urlStr fullUrl:(NSString *)fullUrl {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = urlStr;
    cardItem.fullUrlStr = fullUrl;
    cardItem.isSelect = NO;
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL]
        || [cardItem.fullUrlStr isEqualToString:self.profilFaceURL]) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}

- (TUISelectAvatarCardItem *)creatCleanCardItem {
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = nil;
    cardItem.isSelect = NO;
    cardItem.isDefaultBackgroundItem = YES;
    if (self.profilFaceURL.length == 0 ) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}
- (void)setupNavigator{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    if (self.selectAvatarType == TUISelectAvatarTypeCover) {
        [self.titleView setTitle:TUIKitLocalizableString(TUIKitChooseCover)];
    }
    else if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        [self.titleView setTitle:TUIKitLocalizableString(TUIKitChooseBackground)];
    }
    else {
        [self.titleView setTitle:TUIKitLocalizableString(TUIKitChooseAvatar)];
    }
    
    self.rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.rightButton setTitle:TUIKitLocalizableString(Save) forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItems = @[rightItem];
}

- (void)setCurrentSelectCardItem:(TUISelectAvatarCardItem *)currentSelectCardItem {
    _currentSelectCardItem = currentSelectCardItem;
    if (_currentSelectCardItem) {
        [self.rightButton setTitleColor:TUICoreDynamicColor(@"", @"#006EFF") forState:UIControlStateNormal];
    }
    else {
        [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}
- (void)rightBarButtonClick {
    
    if (!self.currentSelectCardItem) {
        return;
    }
    
    if (self.selectCallBack) {
        if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
            if (IS_NOT_EMPTY_NSSTRING(self.currentSelectCardItem.fullUrlStr)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TUITool makeToastActivity];
                });
                @weakify(self)
                [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[[NSURL URLWithString:self.currentSelectCardItem.fullUrlStr]] progress:nil completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                    @strongify(self);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [TUITool hideToastActivity];
                            [TUITool makeToast:TUIKitLocalizableString(TUIKitChooseBackgroundSuccess)];
                            if (self.selectCallBack) {
                                self.selectCallBack(self.currentSelectCardItem.fullUrlStr);
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            
                        });
                    });
                    
                }];
            }
            else {
                [TUITool makeToast:TUIKitLocalizableString(TUIKitChooseBackgroundSuccess)];
                self.selectCallBack(self.currentSelectCardItem.fullUrlStr);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            self.selectCallBack(self.currentSelectCardItem.posterUrlStr);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat margin = 15;

    CGFloat padding = 13;

    int rowCount = 4.0;

    if (self.selectAvatarType == TUISelectAvatarTypeCover ||
        self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        rowCount = 2.0;
    }
    else {
        rowCount = 4.0;
    }
    
    CGFloat width = (self.view.frame.size.width - 2 * margin - (rowCount - 1) * padding) /rowCount ;
    
    CGFloat height = 77;
    if (self.selectAvatarType == TUISelectAvatarTypeConversationBackGroundCover) {
        height = 125;
    }
    
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(24, 15, 0, 15);
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArr count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUISelectAvatarCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // Configure the cell
    
    if (indexPath.row < self.dataArr.count) {
        cell.cardItem = self.dataArr[indexPath.row];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self recoverSelectedStatus];
    
    TUISelectAvatarCollectionCell *cell= (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    if (self.currentSelectCardItem == cell.cardItem ) {
        self.currentSelectCardItem = nil;
    }
    else {
        cell.cardItem.isSelect = YES;
        [cell updateSelectedUI];
        self.currentSelectCardItem = cell.cardItem;
    }
}

- (void)recoverSelectedStatus {
    NSInteger index = 0;
    for (TUISelectAvatarCardItem *card in self.dataArr) {
        if (self.currentSelectCardItem == card) {
            card.isSelect = NO;
            break;
        }
        index++;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    TUISelectAvatarCollectionCell *cell= (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (TUISelectAvatarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    [cell updateSelectedUI];
}
@end
