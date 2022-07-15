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


@interface TUISelectAvatarCardItem : NSObject

@property (nonatomic, strong) NSString *posterUrlStr;
@property (nonatomic, assign) BOOL isSelect;

@end

@implementation TUISelectAvatarCardItem

@end

@interface TUISelectAvatarCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectedView;
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
    
        self.imageView.layer.masksToBounds = YES;
    
        [self.contentView addSubview:self.imageView];
    
        [self.imageView addSubview:self.selectedView];
  }
    
  return self;
    
}


- (void)setCardItem:(TUISelectAvatarCardItem *)cardItem {
    
    _cardItem = cardItem;
    
    [self updateSelectedUI];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:cardItem.posterUrlStr] placeholderImage:TUICoreBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head_img")];
}

- (BOOL)currentSlectedStateOfDelete {
 
    return self.cardItem.isSelect;
    
}

- (void)updateSelectedUI {
    
    if (self.cardItem.isSelect){
        self.imageView.layer.borderColor = TUICoreDynamicColor(@"", @"#006EFF").CGColor;
        self.imageView.layer.borderWidth = 2;
        self.selectedView.hidden = NO;
    }
    else {
        self.imageView.layer.borderColor = UIColor.clearColor.CGColor;
        self.selectedView.hidden = YES;
    }
}

- (UIImageView *)selectedView {
    
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _selectedView.image = [UIImage imageNamed:TUICoreImagePath(@"icon_avatar_selected")];
    }
    return _selectedView;
}

- (void)layoutSubviews {
    
    self.selectedView.frame = CGRectMake(self.imageView.frame.size.width - 16 - 4 , 4 ,
                                       16 , 16);
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
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] bounds] collectionViewLayout:flowLayout];
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

        for (int i = 0 ; i< GroupAvatarCount; i++) {
            TUISelectAvatarCardItem *cardItem = [self creatCardItemByURL:GroupAvatarURL(i+1)];
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

- (TUISelectAvatarCardItem *)creatCardItemByURL:(NSString *)urlStr{
    TUISelectAvatarCardItem *cardItem = [[TUISelectAvatarCardItem alloc] init];
    cardItem.posterUrlStr = urlStr;
    cardItem.isSelect = NO;
    if ([cardItem.posterUrlStr isEqualToString:self.profilFaceURL] ) {
        cardItem.isSelect = YES;
        self.currentSelectCardItem = cardItem;
    }
    return cardItem;
}
- (void)setupNavigator{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    if (self.selectAvatarType == TUISelectAvatarTypeCover ) {
        [self.titleView setTitle:TUIKitLocalizableString(TUIKitChooseCover)];
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
        self.selectCallBack(self.currentSelectCardItem.posterUrlStr);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat margin = 15;

    CGFloat padding = 13;

    int rowCount = 4.0;

    if (self.selectAvatarType == TUISelectAvatarTypeCover ) {
        rowCount = 2.0;
    }
    else {
        rowCount = 4.0;
    }
    
    CGFloat width = (self.view.frame.size.width - 2 * margin - (rowCount - 1) * padding) /rowCount ;
    
    CGFloat height = 77;
    
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
    [self changeSelectedAllStatus:NO];
    
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

- (void)changeSelectedAllStatus:(BOOL)selectAll {
    [self selectedAllStatus:selectAll];
    [self.collectionView reloadData];
}
- (void)selectedAllStatus:(BOOL)select{
    for (TUISelectAvatarCardItem *card in self.dataArr) {
        card.isSelect = select;
    }
}
@end
