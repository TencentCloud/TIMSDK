//
//  ThemeSelectController.m
//  TUIKitDemo
//
//  Created by harvy on 2022/1/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "ThemeSelectController.h"
#import "TUIDarkModel.h"
#import "TUIThemeManager.h"
#import "TUITool.h"
#import "TUICommonModel.h"
#import "Masonry.h"
#import "TUIDefine.h"

@implementation ThemeSelectCollectionViewCellModel


@end

@implementation ThemeSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setCellModel:(ThemeSelectCollectionViewCellModel *)cellModel
{
    _cellModel = cellModel;
    
    self.chooseButton.selected = cellModel.selected;
    self.descLabel.text = cellModel.themeName;
    self.backView.image = cellModel.backImage;
}

- (void)setupViews
{
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
    
    [self.contentView addSubview:self.backView];
    [self.contentView addSubview:self.chooseButton];
    [self.contentView addSubview:self.descLabel];
}

- (void)onTap
{
    if (self.onSelect) {
        self.onSelect(self.cellModel);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backView.frame = self.contentView.bounds;
    self.chooseButton.frame = CGRectMake(self.contentView.mm_w - 6 - 20, 6, 20, 20);
    self.descLabel.frame = CGRectMake(0, self.contentView.mm_h - 28, self.contentView.mm_w, 28);
}

- (UIImageView *)backView
{
    if (_backView == nil) {
        _backView = [[UIImageView alloc] init];
    }
    return _backView;
}

- (UIButton *)chooseButton
{
    if (_chooseButton == nil) {
        _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chooseButton setImage:[UIImage imageNamed:@"add_unselect"] forState:UIControlStateNormal];
        [_chooseButton setImage:[UIImage imageNamed:@"add_selected"] forState:UIControlStateSelected];
        _chooseButton.userInteractionEnabled = NO;
    }
    return _chooseButton;
}

- (UILabel *)descLabel
{
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _descLabel.font = [UIFont systemFontOfSize:13.0];
        _descLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

@end

@interface ThemeFooterCollectionViewCell()
@property (nonatomic,strong) UISwitch *switcher;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subTitleLabel;

@end
@implementation ThemeFooterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setCellModel:(ThemeSelectCollectionViewCellModel *)cellModel
{
    [super setCellModel:cellModel];
    self.titleLabel.text = NSLocalizedString(@"TUIThemeNameSystemFollowTitle", nil);
    self.subTitleLabel.text = NSLocalizedString(@"TUIThemeNameSystemFollowSubTitle", nil);
    self.switcher.on = cellModel.selected;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
    }
    return _subTitleLabel;
}
- (UISwitch *)switcher {
    if (!_switcher) {
        _switcher =  [[UISwitch alloc] init];
        _switcher.onTintColor = TUICoreDynamicColor(@"common_switch_on_color", @"#147AFF");
        [_switcher addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];

    }
    return _switcher;
}
- (void)setupViews
{
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
    self.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    [self.contentView addSubview:self.switcher];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");;
    self.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];

    [self.contentView addSubview:self.subTitleLabel];
    self.subTitleLabel.textColor = TUICoreDynamicColor(@"form_desc_color", @"#888888");
    self.subTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.subTitleLabel.font = [UIFont systemFontOfSize:12.0];
    self.subTitleLabel.backgroundColor = [UIColor clearColor];
    self.subTitleLabel.numberOfLines = 0;

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(12);
        make.width.mas_equalTo(self.contentView.mm_w * 0.8);
    }];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.switcher.mas_right);
        make.top.mas_equalTo(self.switcher.mas_bottom).mas_offset(4);
    }];
    [self.switcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-16);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(28);
        make.centerY.mas_equalTo(self.titleLabel);
    }];

}
- (void)switchClick:(id)sw {
    if (self.onSelect) {
        self.onSelect(self.cellModel);
    }
}

@end

@interface ThemeSelectController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) ThemeSelectCollectionViewCellModel *selectModel;
@property (nonatomic, strong )ThemeSelectCollectionViewCellModel *systemModel;

@end

@implementation ThemeSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self prepareData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor =  self.tintColor;
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance= appearance;
    }
    else {
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = NO;

    }
    self.navigationController.navigationBarHidden = NO;
   
}

- (UIColor *)tintColor
{
    return TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupViews
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;
    
    self.navigationController.navigationBarHidden = NO;
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"ChangeSkin", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    UIImage *image = TUICoreDynamicImage(@"nav_back_img", [UIImage imageNamed:@"ic_back_white"]);
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = YES;
    
    [self.view addSubview:self.collectionView];
}

- (void)prepareData
{
    NSString *lastThemeID = [self.class getCacheThemeID];
    BOOL isSystemDark = NO;
    BOOL isSystemLight = NO;
    if (@available(iOS 13.0, *)) {
        if ([lastThemeID isEqualToString:@"system"]) {
            if ((self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)) {
                isSystemDark = YES;
            }
            else {
                isSystemLight = YES;
            }
        }

    }
    ThemeSelectCollectionViewCellModel *system = [[ThemeSelectCollectionViewCellModel alloc] init];
    system.backImage = [self imageWithColors:@[@"#FEFEFE", @"#FEFEFE"]];
    system.themeID = @"system";
    system.themeName =  NSLocalizedString(@"ThemeNameSystem", nil);
    system.selected = [lastThemeID isEqual:system.themeID];
    self.systemModel = system;
    
    ThemeSelectCollectionViewCellModel *serious = [[ThemeSelectCollectionViewCellModel alloc] init];
    serious.backImage = [UIImage imageNamed:@"theme_cover_serious"];
    serious.themeID = @"serious";
    serious.themeName =  NSLocalizedString(@"ThemeNameSerious", nil);
    serious.selected = [lastThemeID isEqual:serious.themeID];
    
    ThemeSelectCollectionViewCellModel *light = [[ThemeSelectCollectionViewCellModel alloc] init];
    light.backImage = [UIImage imageNamed:@"theme_cover_light"];
    light.themeID = @"light";
    light.themeName = NSLocalizedString(@"ThemeNameLight", nil);
    light.selected = ([lastThemeID isEqual:light.themeID] || isSystemLight);
    
    ThemeSelectCollectionViewCellModel *mingmei = [[ThemeSelectCollectionViewCellModel alloc] init];
    mingmei.backImage = [UIImage imageNamed:@"theme_cover_lively"];
    mingmei.themeID = @"lively";
    mingmei.themeName = NSLocalizedString(@"ThemeNameLivey", nil);
    mingmei.selected = [lastThemeID isEqual:mingmei.themeID];
    
    ThemeSelectCollectionViewCellModel *dark = [[ThemeSelectCollectionViewCellModel alloc] init];
    dark.backImage = [UIImage imageNamed:@"theme_cover_dark"];
    dark.themeID = @"dark";
    dark.themeName = NSLocalizedString(@"ThemeNameDark", nil);
    dark.selected = ([lastThemeID isEqual:dark.themeID]|| isSystemDark);
    
    self.datas = [NSMutableArray arrayWithArray:@[light, serious, mingmei,dark]];
    
    for (ThemeSelectCollectionViewCellModel *cellModel in self.datas) {
        if (cellModel.selected) {
            self.selectModel = cellModel;
            break;
        }
    }
    if (self.selectModel == nil ||[lastThemeID isEqualToString:@"system"]) {
        self.selectModel = system;
    }
}

- (void)back
{
    if (self.disable) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

+ (void)cacheThemeID:(NSString *)themeID
{
    [NSUserDefaults.standardUserDefaults setObject:themeID forKey:@"current_theme_id"];
    [NSUserDefaults.standardUserDefaults synchronize];
}
+ (NSString *)getCacheThemeID
{
    NSString *lastThemeID = [NSUserDefaults.standardUserDefaults objectForKey:@"current_theme_id"];
    if (lastThemeID == nil || lastThemeID.length == 0) {
        lastThemeID = @"system";
    }
    return lastThemeID;
}

+ (void)changeFollowSystemChangeThemeSwitch:(BOOL)flag {
    if (flag) {
        [NSUserDefaults.standardUserDefaults setObject:@"0" forKey:@"followSystemChangeThemeSwitch"];
    }
    else {
        [NSUserDefaults.standardUserDefaults setObject:@"1" forKey:@"followSystemChangeThemeSwitch"];
    }
    [NSUserDefaults.standardUserDefaults synchronize];
}
+ (BOOL)followSystemChangeThemeSwitch {
    /**
     * 第一次启动/未设置 默认跟随系统
     * The first time to start or not setting, follow the system settings in default
     */
    if ([[self.class getCacheThemeID] isEqualToString:@"system"]) {
        return YES;
    }
    NSString *followSystemChangeThemeSwitch = [NSUserDefaults.standardUserDefaults objectForKey:@"followSystemChangeThemeSwitch"];
    if (followSystemChangeThemeSwitch && followSystemChangeThemeSwitch.length >0) {
        if ([followSystemChangeThemeSwitch isEqualToString:@"1"] ) {
            return YES;
        }
    }
    return NO;

}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ThemeSelectCollectionViewCell *reusableView = nil;
    if (kind == UICollectionElementKindSectionFooter)
    {
        BOOL changeThemeswitch = [self.class followSystemChangeThemeSwitch];
        ThemeSelectCollectionViewCellModel *system = [[ThemeSelectCollectionViewCellModel alloc] init];
        system.selected = changeThemeswitch;
        ThemeSelectCollectionViewCell *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerview.cellModel = system;
        __weak typeof(self) weakSelf = self;
        footerview.onSelect = ^(ThemeSelectCollectionViewCellModel * _Nonnull cellModel) {
            [weakSelf onSelectFollowSystem:cellModel];
        };
        reusableView = footerview;
    }
    return reusableView;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThemeSelectCollectionViewCellModel *cellModel = self.datas[indexPath.item];
    ThemeSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.cellModel = cellModel;
    
    __weak typeof(self) weakSelf = self;
    cell.onSelect = ^(ThemeSelectCollectionViewCellModel * _Nonnull cellModel) {
        [weakSelf onSelectTheme:cellModel];
    };
    return cell;
}
- (void)onSelectFollowSystem:(ThemeSelectCollectionViewCellModel *)cellModel {
    [self.class changeFollowSystemChangeThemeSwitch:cellModel.selected];

    if (cellModel.selected) {
        for (ThemeSelectCollectionViewCellModel *cellModel in self.datas) {
            if (cellModel.selected) {
                self.selectModel = cellModel;
                break;
            }
        }
        [self onSelectTheme:self.selectModel];
    }
    else {
        [self onSelectTheme:self.systemModel];
    }
    
}
- (void)onSelectTheme:(ThemeSelectCollectionViewCellModel *)cellModel
{
    if (self.disable) {
        return;
    }
    if (cellModel && ![cellModel.themeID isEqualToString:@"system"]) {
        /**
         * 只要选了皮肤，就关闭开关
         * As long as the theme is selected, turn off the switch
         */
        [self.class changeFollowSystemChangeThemeSwitch:YES];
    }
    
    /**
     * 切换主题
     * Change the theme
     */
    self.selectModel.selected = NO;
    cellModel.selected = YES;
    self.selectModel = cellModel;
    [self.collectionView reloadData];
    
    /**
     * 缓存当前选中的主题
     * Cache the currently selected theme
     */
    [self.class cacheThemeID:self.selectModel.themeID];
    
    // Applying theme
    [self.class applyTheme:self.selectModel.themeID];
    
    // Notify
    if ([self.delegate respondsToSelector:@selector(onSelectTheme:)]) {
        [self.delegate onSelectTheme:self.selectModel];
    }
}

+ (void)applyLastTheme
{
    [self applyTheme:nil];
}

+ (void)applyTheme:(NSString * __nullable)themeID
{
    NSString *lastThemeID = [self getCacheThemeID];
    if (themeID.length) {
        lastThemeID = themeID;
    }
    
    if (lastThemeID == nil || lastThemeID.length == 0 || [lastThemeID isEqual:@"system"]) {
        /**
         * 卸载主题， 跟随系统变化
         * Uninstall the theme and let it follow system changes
         */
        [TUIShareThemeManager unApplyThemeForModule:TUIThemeModuleAll];
    } else {
        [TUIShareThemeManager applyTheme:lastThemeID forModule:TUIThemeModuleAll];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 13.0, *)) {
            if (lastThemeID == nil || lastThemeID.length == 0 || [lastThemeID isEqual:@"system"]) {
                /**
                 * 跟随系统
                 * Following system settings
                 */
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = 0;
            } else if ([lastThemeID isEqual:@"dark"]) {
                /**
                 * 强制切换成黑夜
                 * Mandatory switch to dark mode
                 */
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            } else {
                /**
                 * 忽略系统的设置，强制修改成白天模式，并应用当前的主题
                 * Ignoring the system settings, mandatory swtich  to light mode, and apply the current theme
                 */
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
    });
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = (UIScreen.mainScreen.bounds.size.width - 12.0 - 32.0) * 0.5;
        CGFloat itemHeight = itemWidth * 232.0 / 331.0;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(12, 16, 12, 16);
        layout.footerReferenceSize = CGSizeMake((UIScreen.mainScreen.bounds.size.width), 68);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        [_collectionView registerClass:ThemeSelectCollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[ThemeFooterCollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _collectionView;
}

- (NSMutableArray *)datas
{
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (UIImage *)imageWithColors:(NSArray<NSString *> *)hexColors
{
    CGSize imageSize = CGSizeMake(165, 116);
    

    NSMutableArray *array = [NSMutableArray array];
    for(NSString *hex in hexColors) {
        UIColor *color = [UIColor tui_colorWithHex:hex];
        [array addObject:(__bridge id)color.CGColor];
    }
    
    CGFloat locations[] = {0.5, 1.0};
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([UIColor tui_colorWithHex:hexColors.lastObject].CGColor);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)array, locations);
    CGPoint start;
    CGPoint end;
    
    start = CGPointMake(0.0, 0.0);
    end = CGPointMake(imageSize.width, imageSize.height);
    
//    switch (gradientType) {
//        case GradientFromTopToBottom:
//            start = CGPointMake(imageSize.width/2, 0.0);
//            end = CGPointMake(imageSize.width/2, imageSize.height);
//            break;
//        case GradientFromLeftToRight:
//            start = CGPointMake(0.0, imageSize.height/2);
//            end = CGPointMake(imageSize.width, imageSize.height/2);
//            break;
//        case GradientFromLeftTopToRightBottom:
//            start = CGPointMake(0.0, 0.0);
//            end = CGPointMake(imageSize.width, imageSize.height);
//            break;
//        case GradientFromLeftBottomToRightTop:
//            start = CGPointMake(0.0, imageSize.height);
//            end = CGPointMake(imageSize.width, 0.0);
//            break;
//        default:
//            break;
//    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

//MARK: ThemeChanged

- (void)onThemeChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    
}
@end
