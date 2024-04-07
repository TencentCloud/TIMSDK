//
//  ThemeSelectController.m
//  TUIKitDemo
//
//  Created by harvy on 2022/1/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIThemeSelectController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIThemeSelectCollectionViewCellModel

@end

@implementation TUIThemeSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setCellModel:(TUIThemeSelectCollectionViewCellModel *)cellModel {
    _cellModel = cellModel;

    self.chooseButton.selected = cellModel.selected;
    self.descLabel.text = cellModel.themeName;
    self.backView.image = cellModel.backImage;
}

- (void)setupViews {
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];

    [self.contentView addSubview:self.backView];
    [self.contentView addSubview:self.chooseButton];
    [self.contentView addSubview:self.descLabel];
}

- (void)onTap {
    if (self.onSelect) {
        self.onSelect(self.cellModel);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.backView.frame = self.contentView.bounds;
    self.chooseButton.frame = CGRectMake(self.contentView.mm_w - 6 - 20, 6, 20, 20);
    self.descLabel.frame = CGRectMake(0, self.contentView.mm_h - 28, self.contentView.mm_w, 28);
}

- (UIImageView *)backView {
    if (_backView == nil) {
        _backView = [[UIImageView alloc] init];
    }
    return _backView;
}

- (UIButton *)chooseButton {
    if (_chooseButton == nil) {
        _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chooseButton setImage:TUIContactDynamicImage(@"", [UIImage imageNamed:TUIContactImagePath(@"add_unselect")]) forState:UIControlStateNormal];
        [_chooseButton setImage:TUIContactDynamicImage(@"", [UIImage imageNamed:TUIContactImagePath(@"add_selected")]) forState:UIControlStateSelected];
        _chooseButton.userInteractionEnabled = NO;
    }
    return _chooseButton;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = [UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1 / 1.0];
        _descLabel.font = [UIFont systemFontOfSize:13.0];
        _descLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

@end

@interface TUIThemeHeaderCollectionViewCell ()
@property(nonatomic, strong) UISwitch *switcher;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;

@end
@implementation TUIThemeHeaderCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupBaseViews];
    }
    return self;
}

- (void)setCellModel:(TUIThemeSelectCollectionViewCellModel *)cellModel {
    _cellModel = cellModel;
    self.titleLabel.text = TIMCommonLocalizableString(TUIKitThemeNameSystemFollowTitle);
    self.subTitleLabel.text = TIMCommonLocalizableString(TUIKitThemeNameSystemFollowSubTitle);
    self.switcher.on = cellModel.selected;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(kScale375(24));
        make.top.mas_equalTo(12);
        make.trailing.mas_equalTo(self.switcher.mas_leading).mas_offset(- 3);
        make.height.mas_equalTo(20);
    }];
    
    [self.subTitleLabel sizeToFit];
    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.switcher.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(3);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.switcher mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-kScale375(24));
        make.top.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(20);
    }];


}
- (void)setupBaseViews {
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
    self.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.titleLabel.rtlAlignment = TUITextRTLAlignmentLeading;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];

    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subTitleLabel.textColor = TIMCommonDynamicColor(@"form_desc_color", @"#888888");
    self.subTitleLabel.rtlAlignment = TUITextRTLAlignmentLeading;
    self.subTitleLabel.font = [UIFont systemFontOfSize:12.0];
    self.subTitleLabel.backgroundColor = [UIColor clearColor];
    self.subTitleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.subTitleLabel];
   
    self.switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
    _switcher.onTintColor = TIMCommonDynamicColor(@"common_switch_on_color", @"#147AFF");
    [_switcher addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];

    [self.contentView addSubview:self.switcher];
}


- (void)switchClick:(id)sw {
    if (self.onSelect) {
        self.onSelect(self.cellModel);
    }
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
    self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    
}

@end

@interface TUIThemeSelectController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *datas;

@property(nonatomic, strong) TUIThemeSelectCollectionViewCellModel *selectModel;
@property(nonatomic, strong) TUIThemeSelectCollectionViewCellModel *systemModel;

@end

@implementation TUIThemeSelectController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
    [self prepareData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
    }
    self.navigationController.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    self.navigationController.navigationBarHidden = NO;
}

- (UIColor *)tintColor {
    return TIMCommonDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;

    self.navigationController.navigationBarHidden = NO;
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(TIMAppChangeTheme)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    UIImage *image = TIMCommonDynamicImage(@"nav_back_img", [UIImage imageNamed:TIMCommonImagePath(@"nav_back")]);
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    image = [image rtl_imageFlippedForRightToLeftLayoutDirection];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = YES;

    [self.view addSubview:self.collectionView];
}

- (void)prepareData {
    NSString *lastThemeID = [self.class getCacheThemeID];
    BOOL isSystemDark = NO;
    BOOL isSystemLight = NO;
    if (@available(iOS 13.0, *)) {
        if ([lastThemeID isEqualToString:@"system"]) {
            if ((self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)) {
                isSystemDark = YES;
            } else {
                isSystemLight = YES;
            }
        }
    }

    TUIThemeSelectCollectionViewCellModel *system = [[TUIThemeSelectCollectionViewCellModel alloc] init];
    system.backImage = [self imageWithColors:@[ @"#FEFEFE", @"#FEFEFE" ]];
    system.themeID = @"system";
    system.themeName = TIMCommonLocalizableString(TUIKitThemeNameSystem);
    system.selected = [lastThemeID isEqual:system.themeID];
    self.systemModel = system;

    TUIThemeSelectCollectionViewCellModel *serious = [[TUIThemeSelectCollectionViewCellModel alloc] init];
    serious.backImage = TUIContactDynamicImage(@"", [UIImage imageNamed:TUIContactImagePath(@"theme_cover_serious")]);
    serious.themeID = @"serious";
    serious.themeName = TIMCommonLocalizableString(TUIKitThemeNameSerious);
    serious.selected = [lastThemeID isEqual:serious.themeID];

    TUIThemeSelectCollectionViewCellModel *light = [[TUIThemeSelectCollectionViewCellModel alloc] init];
    light.backImage = TUIContactDynamicImage(@"", [UIImage imageNamed:TUIContactImagePath(@"theme_cover_light")]);
    light.themeID = @"light";
    light.themeName = TIMCommonLocalizableString(TUIKitThemeNameLight);
    light.selected = ([lastThemeID isEqual:light.themeID] || isSystemLight);

    TUIThemeSelectCollectionViewCellModel *mingmei = [[TUIThemeSelectCollectionViewCellModel alloc] init];
    mingmei.backImage = TUIContactDynamicImage(@"", [UIImage imageNamed:TUIContactImagePath(@"theme_cover_lively")]);
    mingmei.themeID = @"lively";
    mingmei.themeName = TIMCommonLocalizableString(TUIKitThemeNameLivey);
    mingmei.selected = [lastThemeID isEqual:mingmei.themeID];

    TUIThemeSelectCollectionViewCellModel *dark = [[TUIThemeSelectCollectionViewCellModel alloc] init];
    dark.backImage = TUIContactDynamicImage(@"", [UIImage imageNamed:TUIContactImagePath(@"theme_cover_dark")]);
    dark.themeID = @"dark";
    dark.themeName = TIMCommonLocalizableString(TUIKitThemeNameDark);
    dark.selected = ([lastThemeID isEqual:dark.themeID] || isSystemDark);

    self.datas = [NSMutableArray arrayWithArray:@[ light, serious, mingmei, dark ]];

    for (TUIThemeSelectCollectionViewCellModel *cellModel in self.datas) {
        if (cellModel.selected) {
            self.selectModel = cellModel;
            break;
        }
    }

    if (gDisableFollowSystemStyle) {
        return;
    }

    if (self.selectModel == nil || [lastThemeID isEqualToString:@"system"]) {
        self.selectModel = system;
    }
}

- (void)back {
    if (self.disable) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

+ (void)cacheThemeID:(NSString *)themeID {
    [NSUserDefaults.standardUserDefaults setObject:themeID forKey:@"current_theme_id"];
    [NSUserDefaults.standardUserDefaults synchronize];
}
+ (NSString *)getCacheThemeID {
    NSString *lastThemeID = [NSUserDefaults.standardUserDefaults objectForKey:@"current_theme_id"];
    if (lastThemeID == nil || lastThemeID.length == 0) {
        lastThemeID = @"system";
    }
    return lastThemeID;
}

+ (void)changeFollowSystemChangeThemeSwitch:(BOOL)flag {
    if (flag) {
        [NSUserDefaults.standardUserDefaults setObject:@"0" forKey:@"followSystemChangeThemeSwitch"];
    } else {
        [NSUserDefaults.standardUserDefaults setObject:@"1" forKey:@"followSystemChangeThemeSwitch"];
    }
    [NSUserDefaults.standardUserDefaults synchronize];
}
+ (BOOL)followSystemChangeThemeSwitch {
    /**
     * The first time to start or not setting, follow the system settings in default
     */
    if ([[self.class getCacheThemeID] isEqualToString:@"system"]) {
        return YES;
    }
    NSString *followSystemChangeThemeSwitch = [NSUserDefaults.standardUserDefaults objectForKey:@"followSystemChangeThemeSwitch"];
    if (followSystemChangeThemeSwitch && followSystemChangeThemeSwitch.length > 0) {
        if ([followSystemChangeThemeSwitch isEqualToString:@"1"]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    TUIThemeSelectCollectionViewCell *reusableView = nil;
    if (!gDisableFollowSystemStyle && kind == UICollectionElementKindSectionHeader) {
        BOOL changeThemeswitch = [self.class followSystemChangeThemeSwitch];
        TUIThemeSelectCollectionViewCellModel *system = [[TUIThemeSelectCollectionViewCellModel alloc] init];
        system.selected = changeThemeswitch;
        TUIThemeSelectCollectionViewCell *headerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                          withReuseIdentifier:@"HeaderView"
                                                                                                 forIndexPath:indexPath];
        headerview.cellModel = system;
        __weak typeof(self) weakSelf = self;
        headerview.onSelect = ^(TUIThemeSelectCollectionViewCellModel *_Nonnull cellModel) {
          [weakSelf onSelectFollowSystem:cellModel];
        };
        reusableView = headerview;
    }
    return reusableView;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIThemeSelectCollectionViewCellModel *cellModel = self.datas[indexPath.item];
    TUIThemeSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.cellModel = cellModel;

    __weak typeof(self) weakSelf = self;
    cell.onSelect = ^(TUIThemeSelectCollectionViewCellModel *_Nonnull cellModel) {
      [weakSelf onSelectTheme:cellModel];
    };
    return cell;
}
- (void)onSelectFollowSystem:(TUIThemeSelectCollectionViewCellModel *)cellModel {
    [self.class changeFollowSystemChangeThemeSwitch:cellModel.selected];

    if (cellModel.selected) {
        for (TUIThemeSelectCollectionViewCellModel *cellModel in self.datas) {
            if (cellModel.selected) {
                self.selectModel = cellModel;
                break;
            }
        }
        [self onSelectTheme:self.selectModel];
    } else {
        [self onSelectTheme:self.systemModel];
    }
}
- (void)onSelectTheme:(TUIThemeSelectCollectionViewCellModel *)cellModel {
    if (self.disable) {
        return;
    }
    if (cellModel && ![cellModel.themeID isEqualToString:@"system"]) {
        /**
         * As long as the theme is selected, turn off the switch
         */
        [self.class changeFollowSystemChangeThemeSwitch:YES];
    }

    /**
     * Change the theme
     */
    self.selectModel.selected = NO;
    cellModel.selected = YES;
    self.selectModel = cellModel;
    [self.collectionView reloadData];

    /**
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

static BOOL gDisableFollowSystemStyle = NO;
+ (void)disableFollowSystemStyle {
    gDisableFollowSystemStyle = YES;
}

+ (void)applyLastTheme {
    [self applyTheme:nil];
}

+ (void)applyTheme:(NSString *__nullable)themeID {
    NSString *lastThemeID = [self getCacheThemeID];
    if (themeID.length) {
        lastThemeID = themeID;
    }

    if (lastThemeID == nil || lastThemeID.length == 0 || [lastThemeID isEqual:@"system"]) {
        /**
         * Uninstall the theme and let it follow system changes
         */
        [TUIShareThemeManager unApplyThemeForModule:TUIThemeModuleAll];
    } else {
        [TUIShareThemeManager applyTheme:lastThemeID forModule:TUIThemeModuleAll];
    }

    if (gDisableFollowSystemStyle) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      if (@available(iOS 13.0, *)) {
          if (lastThemeID == nil || lastThemeID.length == 0 || [lastThemeID isEqual:@"system"]) {
              /**
               * Following system settings
               */
              UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = 0;
          } else if ([lastThemeID isEqual:@"dark"]) {
              /**
               * Mandatory switch to dark mode
               */
              UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
          } else {
              /**
               * Ignoring the system settings, mandatory swtich  to light mode, and apply the current theme
               */
              UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
          }
      }
    });
}

+ (NSString *)getLastThemeName {
    NSString *themeID = [self getCacheThemeID];
    if ([themeID isEqualToString:@"system"]) {
        return TIMCommonLocalizableString(TUIKitThemeNameSystem);
    } else if ([themeID isEqualToString:@"serious"]) {
        return TIMCommonLocalizableString(TUIKitThemeNameSerious);
    } else if ([themeID isEqualToString:@"light"]) {
        return TIMCommonLocalizableString(TUIKitThemeNameLight);
    } else if ([themeID isEqualToString:@"lively"]) {
        return TIMCommonLocalizableString(TUIKitThemeNameLivey);
    } else if ([themeID isEqualToString:@"dark"]) {
        return TIMCommonLocalizableString(TUIKitThemeNameDark);
    } else {
        return @"";
    }
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = (UIScreen.mainScreen.bounds.size.width - 12.0 - 32.0) * 0.5;
        CGFloat itemHeight = itemWidth * 232.0 / 331.0;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(12, 16, 12, 16);

        if (!gDisableFollowSystemStyle) {
            layout.headerReferenceSize = CGSizeMake((UIScreen.mainScreen.bounds.size.width), 120);
        }

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        [_collectionView registerClass:TUIThemeSelectCollectionViewCell.class forCellWithReuseIdentifier:@"cell"];

        [_collectionView registerClass:[TUIThemeHeaderCollectionViewCell class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"HeaderView"];
        _collectionView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    }
    return _collectionView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (UIImage *)imageWithColors:(NSArray<NSString *> *)hexColors {
    CGSize imageSize = CGSizeMake(165, 116);

    NSMutableArray *array = [NSMutableArray array];
    for (NSString *hex in hexColors) {
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

- (void)setBackGroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    self.collectionView.backgroundColor = color;
}

// MARK: ThemeChanged

- (void)onThemeChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self prepareData];
      [self.collectionView reloadData];
    });
}
@end
