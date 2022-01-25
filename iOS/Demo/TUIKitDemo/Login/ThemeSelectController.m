//
//  ThemeSelectController.m
//  TUIKitDemo
//
//  Created by harvy on 2022/1/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "ThemeSelectController.h"
#import "TUIDarkModel.h"
#import "UIView+TUILayout.h"
#import "UIColor+TUIHexColor.h"
#import "TUIThemeManager.h"
#import "TUITool.h"
#import "TUINaviBarIndicatorView.h"


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



@interface ThemeSelectController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) ThemeSelectCollectionViewCellModel *selectModel;

@end

@implementation ThemeSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self prepareData];
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
        //iOS15新增特性：滑动边界样式
        self.navigationController.navigationBar.scrollEdgeAppearance= appearance;
    }
    else {
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
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
    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题
    
    self.navigationController.navigationBarHidden = NO;
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"ChangeSkin", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    UIImage *image = TUIDemoDynamicImage(@"nav_back_img", [UIImage imageNamed:@"ic_back_white"]);
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
    
    ThemeSelectCollectionViewCellModel *system = [[ThemeSelectCollectionViewCellModel alloc] init];
    system.backImage = [self imageWithColors:@[@"#FEFEFE", @"#FEFEFE"]];
    system.themeID = @"system";
    system.themeName =  NSLocalizedString(@"ThemeNameSystem", nil);//@"跟随系统";
    system.selected = [lastThemeID isEqual:system.themeID];
    
    ThemeSelectCollectionViewCellModel *serious = [[ThemeSelectCollectionViewCellModel alloc] init];
    serious.backImage = [UIImage imageNamed:@"theme_cover_serious"]; // [self imageWithColors:@[@"#3371CD", @"#00449E"]];
    serious.themeID = @"serious";
    serious.themeName =  NSLocalizedString(@"ThemeNameSerious", nil);// @"深沉";
    serious.selected = [lastThemeID isEqual:serious.themeID];
    
    ThemeSelectCollectionViewCellModel *light = [[ThemeSelectCollectionViewCellModel alloc] init];
    light.backImage = [UIImage imageNamed:@"theme_cover_light"]; // [self imageWithColors:@[@"#147AFF", @"#147AFF"]];
    light.themeID = @"light";
    light.themeName = NSLocalizedString(@"ThemeNameLight", nil);//@"轻快";
    light.selected = [lastThemeID isEqual:light.themeID];
    
    ThemeSelectCollectionViewCellModel *mingmei = [[ThemeSelectCollectionViewCellModel alloc] init];
    mingmei.backImage = [UIImage imageNamed:@"theme_cover_lively"]; //[self imageWithColors:@[@"#FAE1B6", @"#F38787"]];
    mingmei.themeID = @"lively";
    mingmei.themeName = NSLocalizedString(@"ThemeNameLivey", nil); // @"明媚";
    mingmei.selected = [lastThemeID isEqual:mingmei.themeID];
    
    ThemeSelectCollectionViewCellModel *dark = [[ThemeSelectCollectionViewCellModel alloc] init];
    dark.backImage = [self imageWithColors:@[@"#0B0B0B", @"#000000"]];
    dark.themeID = @"dark";
    dark.themeName = NSLocalizedString(@"ThemeNameDark", nil); //@"黑夜";
    dark.selected = [lastThemeID isEqual:dark.themeID];
    
//    self.datas = [NSMutableArray arrayWithArray:@[serious, light, mingmei, system, dark]];
    self.datas = [NSMutableArray arrayWithArray:@[light, serious, mingmei]];
    
    for (ThemeSelectCollectionViewCellModel *cellModel in self.datas) {
        if (cellModel.selected) {
            self.selectModel = cellModel;
            break;
        }
    }
    if (self.selectModel == nil) {
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
        lastThemeID = @"light";
    }
    return lastThemeID;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
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

- (void)onSelectTheme:(ThemeSelectCollectionViewCellModel *)cellModel
{
    if (self.disable) {
        return;
    }
    
    // 切换主题
    self.selectModel.selected = NO;
    cellModel.selected = YES;
    self.selectModel = cellModel;
    [self.collectionView reloadData];
    
    // 缓存当前选中的主题
    [self.class cacheThemeID:self.selectModel.themeID];
    
    // 应用主题
    [self.class applyTheme:self.selectModel.themeID];
    
    // 通知
    if ([self.delegate respondsToSelector:@selector(onSelectTheme:)]) {
        [self.delegate onSelectTheme:self.selectModel];
    }
}


+ (void)applyTheme:(NSString * __nullable)themeID
{
    NSString *lastThemeID = [self getCacheThemeID];
    if (themeID.length) {
        lastThemeID = themeID;
    }
    
    if (lastThemeID == nil || lastThemeID.length == 0 || [lastThemeID isEqual:@"system"]) {
        // 卸载主题， 跟随系统变化
        [TUIShareThemeManager unApplyThemeForModule:TUIThemeModuleAll];
    } else {
        [TUIShareThemeManager applyTheme:lastThemeID forModule:TUIThemeModuleAll];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 13.0, *)) {
            if (lastThemeID == nil || lastThemeID.length == 0 || [lastThemeID isEqual:@"system"]) {
                // 跟随系统
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = 0;
            } else if ([lastThemeID isEqual:@"dark"]) {
                // 强制切换成黑夜
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            } else {
                // 忽略系统的设置，强制修改成白天模式，并应用当前的主题
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
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(12, 16, 12, 16);
        [_collectionView registerClass:ThemeSelectCollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
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

// 创建一张渐变色图片
- (UIImage *)imageWithColors:(NSArray<NSString *> *)hexColors
{
    CGSize imageSize = CGSizeMake(165, 116);
    

    NSMutableArray *array = [NSMutableArray array];
    for(NSString *hex in hexColors) {
        UIColor *color = [UIColor colorWithHex:hex];
        [array addObject:(__bridge id)color.CGColor];
    }
    
    CGFloat locations[] = {0.5, 1.0};
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([UIColor colorWithHex:hexColors.lastObject].CGColor);
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

@end



// 获取当前 demo 的主题根路径
//NSMutableArray *arrayM = [NSMutableArray array];
//ThemeSelectCollectionViewCellModel *system = [[ThemeSelectCollectionViewCellModel alloc] init];
//system.backImage = [self imageWithColors:@[@"#FEFEFE", @"#FEFEFE"]];
//system.themeID = @"system";
//system.themeName = @"跟随系统";
//system.selected = [lastThemeID isEqual:system.themeID];
//[arrayM addObject:system];
//NSString *rootPath = [NSBundle.mainBundle pathForResource:@"TUIDemoTheme.bundle" ofType:nil];
//BOOL isDirectory = NO;
//BOOL exist = [NSFileManager.defaultManager fileExistsAtPath:rootPath isDirectory:&isDirectory];
//if (exist && isDirectory) {
//    NSArray *subPaths = [NSFileManager.defaultManager subpathsAtPath:rootPath];
//    for (NSString *path in subPaths) {
//        BOOL isManifest = [path.lastPathComponent isEqualToString:@"manifest.plist"];
//        if (!isManifest) {
//            continue;
//        }
//        NSDictionary *manifest = [NSDictionary dictionaryWithContentsOfFile:[rootPath stringByAppendingPathComponent:path]];
//        if ([manifest.allKeys containsObject:@"id"] &&
//            [manifest.allKeys containsObject:@"name"] &&
//            [manifest.allKeys containsObject:@"info"]) {
//            NSString *themeID = [manifest objectForKey:@"id"];
//
//            NSString *themeName = themeID;
//            NSString *currentLanguage = [TUIGlobalization tk_localizableLanguageKey];
//            NSDictionary *nameDict = [manifest objectForKey:@"name"];
//            if ([nameDict isKindOfClass:NSDictionary.class] && [nameDict.allKeys containsObject:currentLanguage]) {
//                themeName = [nameDict objectForKey:currentLanguage];
//            }
//
//            UIImage *backImage = [self imageWithColors:@[@"#FEFEFE", @"#FEFEFE"]];
//            NSDictionary *infoDict = [manifest objectForKey:@"info"];
//            if ([infoDict isKindOfClass:NSDictionary.class] && [infoDict.allKeys containsObject:@"cover"]) {
//                NSString *coverName = infoDict[@"cover"];
//                backImage = [UIImage imageNamed:[NSString stringWithFormat:@"TUIDemoTheme.bundle/%@/%@", themeID, coverName]];
//            }
//
//            ThemeSelectCollectionViewCellModel *cellModel = [[ThemeSelectCollectionViewCellModel alloc] init];
//            cellModel.backImage = backImage;
//            cellModel.themeID = themeID;
//            cellModel.themeName = themeName;
//            cellModel.selected = [lastThemeID isEqual:themeID];
//            [arrayM addObject:cellModel];
//        }
//    }
//    self.datas = [NSMutableArray arrayWithArray:arrayM];
//}
