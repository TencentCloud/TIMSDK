// Copyright (c) 2019 Tencent. All rights reserved.
#define POD_PITU 1

#import "TCBeautyPanelView.h"
#import "TCMenuItemCell.h"
#if POD_PITU
#import "ZipArchive.h"
#endif

#import "TCFilter.h"
#import "TCMenuView.h"
#import "TCPituMotionManager.h"
#import <objc/message.h>
#import "TCBeautyPanelTheme.h"
#import "TCBeautyPanelActionPerformer.h"
#import "TCFilter.h"

#define BeautyViewMargin 8
#define BeautyViewSliderHeight 30
#define BeautyViewCollectionHeight 50
#define BeautyViewTitleWidth 40

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
 blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

static const CGFloat DefaultBeautyPanelHeight = 170;
static const CGFloat MenuHeight = 130;

static const float BeautyMinLevel = 0;
static const float BeautyMaxLevel = 9;

static const float DefaultWhitnessLevel = 1;
static const float DefaultBeautyLevel = 6;

typedef NS_ENUM(NSUInteger, BeautyMenuItem) {
    BeautyMenuItemPiTu,
    BeautyMenuItemLastBeautyTypeItem = BeautyMenuItemPiTu,
    BeautyMenuItemWhite,
    BeautyMenuItemRed,
    BeautyMenuItemLastBeautyValueItem = BeautyMenuItemRed,
};

@interface TCPituDownloadTask : NSObject
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *destPath;
@property (strong, nonatomic) NSString *dir;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURLSessionDownloadTask *task;
+ (instancetype)taskWithDestPath:(NSString *)destPath dir:(NSString *)dir name:(NSString *)name;
@end
@implementation TCPituDownloadTask
+ (instancetype)taskWithDestPath:(NSString *)destPath dir:(NSString *)dir name:(NSString *)name
{
    TCPituDownloadTask *ret = [[TCPituDownloadTask alloc] init];
    ret.destPath = destPath;
    ret.dir = dir;
    ret.name = name;
    return ret;
}
@end

#define L(x) [_theme localizedString:x]

/// 菜单条目对象
@interface  TCBeautyPanelItem : NSObject <TCMenuItem>
@property (strong, nonatomic) NSString *title; ///< 菜单标题
@property (strong, nonatomic) UIImage *icon;   ///< 菜单图标
@property (nullable, weak, nonatomic) id target;///< 菜单动作执行对象，为空时会发送到actionPerformer
@property (assign, nonatomic) SEL action;      ///< 菜单动作
@property (assign, nonatomic) double minValue; ///< 条目值的调节范围下限, 与上限范围相同时不显示滑杆
@property (assign, nonatomic) double maxValue; ///< 条目值的调节范围上限, 与下限范围相同时不显示滑杆
@property (nullable, strong, nonatomic) id userInfo; ///< 附带信息
@end

@implementation  TCBeautyPanelItem
+ (instancetype)itemWithTitle:(NSString *)title icon:(UIImage *)icon target:(id)target action:(SEL)action minValue:(double)minValue maxValue:(double)maxValue
{
    TCBeautyPanelItem *item = [[ TCBeautyPanelItem alloc] init];
    item.target = target;
    item.title = title;
    item.icon = icon;
    item.action = action;
    item.minValue = minValue;
    item.maxValue = maxValue;
    return item;
}
+ (instancetype)itemWithTitle:(NSString *)title icon:(UIImage *)icon {
    return [self itemWithTitle:title icon:icon target:nil action:nil minValue:0 maxValue:0];
}
@end
static  TCBeautyPanelItem * makeMenuItem(NSString *title, UIImage *icon, id target, SEL action, double minValue, double maxValue) {
    return [ TCBeautyPanelItem itemWithTitle:title icon:icon target:target action:action minValue:minValue maxValue:maxValue];
}

#pragma mark -
@interface TCBeautyPanel()
<TCMenuViewDataSource, TCMenuViewDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>
{
    TCMenuView *_menu;
    UIView *_bottomBackgroundView;
    NSInteger _previousMenuIndex;
    NSArray<NSString *> *_menuArray; // 菜单标题
    NSArray<NSArray *> *_optionsContainer; // 每个菜单的内容
    NSMutableDictionary<NSNumber*, NSIndexPath*> *_selectedIndexMap;
    NSArray<TCFilter *> *_filters;
    id<TCBeautyPanelThemeProtocol> _theme;
    NSObject *_actionPerformerPlaceholder;
    NSURLSession *_urlSession;
    NSMutableDictionary *_runningTask;
}
@property (nonatomic, strong) NSMutableDictionary<NSNumber*,NSNumber*> *beautyLevelDic; ///< 不同美颜类型下的数值
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSNumber*>* filterValueDic; ///< 各滤镜的数值
@property (nonatomic, strong) UILabel *sliderValueLabel;           ///< 滑杆数值显示
@property (nonatomic, strong) UISlider *slider;                    ///< 数值调节滑杆
@property (nonatomic, strong) NSURLSessionDownloadTask *operation; ///< 资源下载
@property (nonatomic, assign) TCBeautyStyle beautyStyle;

@end

@implementation TCBeautyPanel

#pragma mark - Public API
+ (instancetype)beautyPanelWithFrame:(CGRect)frame
                     actionPerformer:(id<TCBeautyPanelActionPerformer>)actionPerformer {
    TCBeautyPanel *panel = [[TCBeautyPanel alloc] initWithFrame:frame
                                                                  theme:nil
                                                        actionPerformer:actionPerformer];
    return panel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame theme:nil actionPerformer:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                        theme:(id<TCBeautyPanelThemeProtocol>)theme
              actionPerformer:(id<TCBeautyPanelActionPerformer>)actionPerformer
{
    self = [super initWithFrame:frame];
    if(self){
        _theme = theme ?: [[TCBeautyPanelTheme alloc] init];
        _actionPerformer = actionPerformer;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _theme = [[TCBeautyPanelTheme alloc] init];
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [_urlSession invalidateAndCancel];
}

- (void)setCurrentFilterIndex:(NSInteger)index {
    index = [self _converOptionIndexToFilterArrayIndex:index];
    _currentFilterIndex = index;
    [_menu setSelectedOption:index inMenu:PanelMenuIndexFilter];
}

- (NSString*)currentFilterName
{
    NSInteger index = self.currentFilterIndex;
    return [_optionsContainer[PanelMenuIndexFilter][index] title];
}

- (float)beautyLevel {
    return [_beautyLevelDic[@(self.beautyStyle)] floatValue];
}
- (float)ruddyLevel {
    return [_beautyLevelDic[@(BeautyMenuItemRed)] floatValue];
}
- (float)whiteLevel {
    return [_beautyLevelDic[@(BeautyMenuItemWhite)] floatValue];
}
/// 重置为默认值
- (void)resetAndApplyValues
{
    // 默认值配置
    const BeautyMenuItem defaultBeautyStyle = BeautyMenuItemPiTu;
    self.beautyStyle = BeautyMenuItemPiTu;
    const TCFilterIdentifier defaultFilterIdentifier = TCFilterIdentifierBaiXi;
    // index = 0 为关闭
    NSUInteger defaultFilterIndex = [_filters indexOfObjectPassingTest:
                                     ^BOOL(TCFilter * _Nonnull obj,
                                           NSUInteger idx,
                                           BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:defaultFilterIdentifier];
    }];
    // 滤镜
    NSDictionary *defaultFilterValue = @{
                                     TCFilterIdentifierNone :@(0)
                                     ,TCFilterIdentifierBaiXi :@(5)
                                    ,TCFilterIdentifierNormal :@(5)
                                     ,TCFilterIdentifierZiRan :@(5)
                                    ,TCFilterIdentifierYinghong :@(8)
                                    ,TCFilterIdentifierYunshang :@(8)
                                    ,TCFilterIdentifierChunzhen :@(7)
                                    ,TCFilterIdentifierBailan :@(10)
                                    ,TCFilterIdentifierYuanqi :@(8)
                                    ,TCFilterIdentifierChaotuo :@(10)
                                    ,TCFilterIdentifierXiangfen :@(5)
                                    ,TCFilterIdentifierWhite :@(3)
                                    ,TCFilterIdentifierLangman :@(3)
                                    ,TCFilterIdentifierQingxin :@(3)
                                    ,TCFilterIdentifierWeimei :@(3)
                                    ,TCFilterIdentifierFennen :@(3)
                                    ,TCFilterIdentifierHuaijiu :@(3)
                                    ,TCFilterIdentifierLandiao :@(3)
                                    ,TCFilterIdentifierQingliang :@(3)
                                    ,TCFilterIdentifierRixi :@(3)
                                    };

    self.slider.hidden = NO;
    self.sliderValueLabel.hidden = NO;

    self.beautyLevelDic = [NSMutableDictionary dictionary];
    // 重置美颜滤镜
    [self.beautyLevelDic setObject:@(DefaultBeautyLevel) forKey:@(BeautyMenuItemPiTu)];
//    [self.beautyLevelDic setObject:@(DefaultWhitnessLevel) forKey:@(BeautyMenuItemWhite)];
//    [self.beautyLevelDic setObject:@(0) forKey:@(BeautyMenuItemRed)];

    NSInteger beautyValue = [self.beautyLevelDic[@(defaultBeautyStyle)] integerValue];
    [self setSliderValue:beautyValue];
    self.slider.minimumValue = BeautyMinLevel;
    self.slider.maximumValue = BeautyMaxLevel;

    self.filterValueDic = [defaultFilterValue mutableCopy];
    [_menu setSelectedOption:defaultFilterIndex+1 inMenu:PanelMenuIndexFilter];// 0为关闭
    [_menu setSelectedOption:defaultBeautyStyle inMenu:PanelMenuIndexBeauty];

    // 默认值只修改美颜和滤镜，其它均设置为关闭
    for (PanelMenuIndex i = PanelMenuIndexMotion; i < PanelMenuIndexCount; ++i) {
        [_menu setSelectedOption:0 inMenu:i];
    }

    if (self.actionPerformer) {
        // 重置基础美颜
        id<TCBeautyPanelActionPerformer> performer = self.actionPerformer;
        [performer setBeautyStyle:defaultBeautyStyle];
        [performer setBeautyLevel:DefaultBeautyLevel];

        // 重置滤镜选项
        TCFilterIdentifier defaultFilterIdentifier = _filters[defaultFilterIndex].identifier;
        UIImage *lutImage = [self filterImageByMenuOptionIndex:defaultFilterIndex+1];
        [performer setFilter:lutImage];
        
        // v7.2后的版本使用 setFilterStrength
        if ([self.actionPerformer respondsToSelector:@selector(setFilterStrength:)]) {
            [performer setFilterStrength:self.filterValueDic[defaultFilterIdentifier].floatValue/10.0];
        } else if([self.actionPerformer respondsToSelector:@selector(setFilterConcentration:)]){
            [performer setFilterConcentration:self.filterValueDic[defaultFilterIdentifier].floatValue/10.0];
        }

        // 重置各高级美颜选项，瘦脸大脸等
        NSArray<TCBeautyPanelItem *> *beautySettingItems = _optionsContainer[PanelMenuIndexBeauty];
        for (TCBeautyPanelItem *item in beautySettingItems) {
            [self _applyMenuItem:item value:0.0f];
        }

        // 关闭贴纸
        [performer setMotionTmpl:nil inDir:nil];

        // 关闭绿幕
        [performer setGreenScreenFile:nil];
    }
}

+ (NSUInteger)getHeight
{
    return DefaultBeautyPanelHeight;
}

- (NSInteger)_converOptionIndexToFilterArrayIndex:(NSInteger)index {
    const NSInteger itemCount = _optionsContainer[PanelMenuIndexFilter].count;
    if (index < 0)
        index = itemCount - 1;
    if (index > itemCount - 1)
        index = 0;
    return index;
}

- (UIImage*)filterImageByMenuOptionIndex:(NSInteger)index
{
    index = [self _converOptionIndexToFilterArrayIndex:index];

    if (index == 0) {
        return nil;
    }
    TCFilter *filter = _filters[index-1];
    return [UIImage imageWithContentsOfFile:filter.lookupImagePath];
}

-(float)filterMixLevelByIndex:(NSInteger)optionIndex
{
    optionIndex = [self _converOptionIndexToFilterArrayIndex:optionIndex];

    if (optionIndex == 0) {
        return 0;
    }
    optionIndex -= 1;
    NSString *filterID = _filters[optionIndex].identifier;
    return [self.filterValueDic[filterID] floatValue];
}

#pragma mark - Init
- (void)_applyTheme {
    self.backgroundColor = [_theme.backgroundColor colorWithAlphaComponent:0.6];
    [self _generateMenuItems];
    _menu.menuTitleColor = _theme.beautyPanelTitleColor;
    _menu.subMenuSelectionColor = _theme.beautyPanelSelectionColor;
    _menu.menuSelectionBackgroundImage = _theme.beautyPanelMenuSelectionBackgroundImage;
    [_slider setMinimumTrackTintColor:_theme.sliderMinColor];
    [_slider setMaximumTrackTintColor:_theme.sliderMaxColor];
    [_slider setThumbImage:_theme.sliderThumbImage forState:UIControlStateNormal];
    _sliderValueLabel.textColor = _theme.sliderValueColor;
    [_menu reloadData];
}

- (void)setTheme:(id<TCBeautyPanelThemeProtocol>)theme {
    _theme = theme;
    [self _applyTheme];
}


// 使用主题更新菜单条目
- (void)_generateMenuItems {
    // Menu Setup
     TCBeautyPanelItem *disableItem = [ TCBeautyPanelItem itemWithTitle:L(@"TC.BeautySettingPanel.None") icon:_theme.menuDisableIcon];

    NSMutableArray *filters = [NSMutableArray arrayWithCapacity:_filters.count];
    [filters addObject:[ TCBeautyPanelItem itemWithTitle:L(@"TC.Common.Clear") icon:_theme.menuDisableIcon]];
    for (TCFilter *filter in _filters) {
        NSString *identifier = [NSString stringWithFormat:@"TC.Common.Filter_%@", filter.identifier];
        [filters addObject:[ TCBeautyPanelItem itemWithTitle:L(identifier) icon:[_theme iconForFilter:filter.identifier]]];
    }

    NSArray *beautyArray = @[
        makeMenuItem(L(@"TC.BeautySettingPanel.Beauty-P"), _theme.beautyPanelPTuBeautyStyleIcon, nil, nil, 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.White"), _theme.beautyPanelWhitnessIcon, nil, nil, 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.Ruddy"), _theme.beautyPanelRuddyIcon,  nil, nil, 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.BigEyes"), _theme.beautyPanelEyeScaleIcon, nil, @selector(setEyeScaleLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.ThinFace"), _theme.beautyPanelFaceSlimIcon, nil, @selector(setFaceSlimLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.VFace"), _theme.beautyPanelFaceVIcon, nil, @selector(setFaceVLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.Chin"), _theme.beautyPanelChinIcon, nil, @selector(setChinLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.ShortFace"), _theme.beautyPanelFaceScaleIcon, nil, @selector(setFaceShortLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.ThinNose"), _theme.beautyPanelNoseSlimIcon, nil, @selector(setNoseSlimLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.EyeLighten"), _theme.beautyPanelEyeLightenIcon, nil, @selector(setEyeLightenLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.ToothWhiten"), _theme.beautyPanelToothWhitenIcon, nil, @selector(setToothWhitenLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.WrinkleRemove"), _theme.beautyPanelWrinkleRemoveIcon, nil, @selector(setWrinkleRemoveLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.PounchRemove"),  _theme.beautyPanelPounchRemoveIcon, nil, @selector(setPounchRemoveLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.SmileLinesRemove"), _theme.beautyPanelSmileLinesRemoveIcon, nil, @selector(setSmileLinesRemoveLevel:), 0, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.Forehead"),  _theme.beautyPanelForeheadIcon, nil, @selector(setForeheadLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.EyeDistance"), _theme.beautyPanelEyeDistanceIcon, nil,  @selector(setEyeDistanceLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.EyeAngle"), _theme.beautyPanelEyeAngleIcon, nil,  @selector(setEyeAngleLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.MouthShape"), _theme.beautyPanelMouthShapeIcon, nil,  @selector(setMouthShapeLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.NoseWing"), _theme.beautyPanelNoseWingIcon, nil,  @selector(setNoseWingLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.NosePosition"), _theme.beautyPanelNosePositionIcon, nil,  @selector(setNosePositionLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.LipsThickness"), _theme.beautyPanelLipsThicknessIcon, nil,  @selector(setLipsThicknessLevel:), -10, 10),
        makeMenuItem(L(@"TC.BeautySettingPanel.FaceBeauty"), _theme.beautyPanelFaceBeautyIcon, nil,  @selector(setFaceBeautyLevel:), 0, 10),
    ];

    NSArray *(^makeMenuItemsFromPituMotions)(NSArray<TCPituMotion *> *motions) = ^(NSArray<TCPituMotion *> *motions) {
        NSMutableArray *result = [@[disableItem] mutableCopy];
        for (TCPituMotion *motion in motions) {
            TCBeautyPanelItem *item = [ TCBeautyPanelItem itemWithTitle:motion.name
                                                                   icon:[self->_theme imageNamed:motion.identifier]];
            item.userInfo = motion;
            [result addObject:item];
        }
        return result;
    };
    NSArray *motionArray        = makeMenuItemsFromPituMotions([TCPituMotionManager sharedInstance].motionPasters);
    NSArray *koubeiArray        = makeMenuItemsFromPituMotions([TCPituMotionManager sharedInstance].backgroundRemovalPasters);
    NSArray *cosmeticArray      = makeMenuItemsFromPituMotions([TCPituMotionManager sharedInstance].cosmeticPasters);
    NSArray *gestureEffectArray = makeMenuItemsFromPituMotions([TCPituMotionManager sharedInstance].gesturePasters);
    NSArray *greenArray = @[disableItem,
                            [ TCBeautyPanelItem itemWithTitle:L(@"TC.BeautySettingPanel.GoodLuck") icon:_theme.beautyPanelGoodLuckIcon]
                           ];

    NSArray *menuArray = @[
                   L(@"TC.BeautyPanel.Menu.Beauty"),
                   L(@"TC.BeautyPanel.Menu.Filter"),
                   L(@"TC.BeautyPanel.Menu.VideoEffect"),
                   L(@"TC.BeautyPanel.Menu.Cosmetic"),
                   L(@"TC.BeautyPanel.Menu.Gesture"),
                   L(@"TC.BeautyPanel.Menu.BlendPic"),
                   L(@"TC.BeautyPanel.Menu.GreenScreen")];
    _menuArray = menuArray;
    _optionsContainer = @[ beautyArray, filters, motionArray, cosmeticArray, gestureEffectArray, koubeiArray, greenArray];
}

- (void)commonInit
{
    _runningTask = [[NSMutableDictionary alloc] initWithCapacity:1];
    _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    self.backgroundColor = [_theme.backgroundColor colorWithAlphaComponent:0.6];
    _actionPerformerPlaceholder = [[NSObject alloc] init];
    _filters = [TCFilterManager defaultManager].allFilters;

    [self _generateMenuItems];

    TCMenuView *menu = [[TCMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - MenuHeight,
                                                                            CGRectGetWidth(self.bounds), MenuHeight)
                                                      dataSource:self];
    menu.delegate = self;
    menu.minSubMenuWidth = 54;
    menu.minMenuWidth = 54;
    menu.menuTitleColor = _theme.beautyPanelTitleColor;
    menu.subMenuSelectionColor = _theme.beautyPanelSelectionColor;
    menu.menuSelectionBackgroundImage = _theme.beautyPanelMenuSelectionBackgroundImage;
    menu.subMenuBackgroundColor = [UIColor clearColor];
    menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:menu];
    _menu = menu;

    // Slider Setup
    self.slider.frame = CGRectMake(BeautyViewMargin * 4, CGRectGetMinY(menu.frame) - BeautyViewMargin - BeautyViewSliderHeight,
                                         CGRectGetWidth(self.bounds) - 10 * BeautyViewMargin - BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.slider];

    self.sliderValueLabel.frame = CGRectMake(self.slider.frame.size.width + self.slider.frame.origin.x + BeautyViewMargin, BeautyViewMargin, BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.sliderValueLabel.layer.cornerRadius = self.sliderValueLabel.frame.size.width / 2;
    self.sliderValueLabel.layer.masksToBounds = YES;
    [self addSubview:self.sliderValueLabel];
    self.sliderValueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    _bottomBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomBackgroundView.backgroundColor = menu.menuBackgroundColor;
    [self addSubview:_bottomBackgroundView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _menu.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - MenuHeight - _bottomOffset,
                             CGRectGetWidth(self.bounds), MenuHeight);
    self.slider.frame = CGRectMake(BeautyViewMargin * 4,
                                   CGRectGetMinY(_menu.frame) - BeautyViewMargin - BeautyViewSliderHeight,
                                   CGRectGetWidth(self.bounds) - 10 * BeautyViewMargin - BeautyViewSliderHeight,
                                   BeautyViewSliderHeight);
    self.sliderValueLabel.frame = CGRectMake(self.slider.frame.size.width + self.slider.frame.origin.x + BeautyViewMargin,
                                             BeautyViewMargin,
                                             BeautyViewSliderHeight,
                                             BeautyViewSliderHeight);
    _bottomBackgroundView.frame = CGRectMake(0, CGRectGetMaxY(_menu.frame),
                                             CGRectGetWidth(self.bounds),
                                             CGRectGetHeight(self.bounds) - CGRectGetMaxY(_menu.frame));
}

- (void)setBottomOffset:(CGFloat)bottomOffset {
    _bottomOffset = bottomOffset;
    [self setNeedsLayout];
}
#pragma mark - Menu actionPerformer
- (void)menu:(TCMenuView *)menu didChangeToIndex:(NSInteger)menuIndex option:(NSInteger)optionIndex {
    self.sliderValueLabel.hidden  = menuIndex != PanelMenuIndexBeauty;
    self.slider.hidden = self.sliderValueLabel.hidden;

    switch (menuIndex) {
        case PanelMenuIndexBeauty: {
            float value = self.beautyLevelDic[@(optionIndex)].floatValue;

//            if (optionIndex < 3) {
//                self.beautyStyle = optionIndex;
//            }

            TCBeautyPanelItem *item = _optionsContainer[menu.menuIndex][menu.optionIndex];
            if ([item isKindOfClass:[ TCBeautyPanelItem class]]) {
                self.slider.minimumValue = item.minValue;
                self.slider.maximumValue = item.maxValue;
            }

            [self setSliderValue:value];
            [self _applyBeautySettings];
        } break;
        case PanelMenuIndexFilter: {
            _currentFilterIndex = optionIndex;
            self.slider.minimumValue = BeautyMinLevel;
            self.slider.maximumValue = BeautyMaxLevel;

            [self onSetFilterAtMenuIndex:optionIndex];
            if (optionIndex > 0) {
                TCFilterIdentifier filterId = _filters[optionIndex - 1].identifier;
                NSNumber* value = self.filterValueDic[filterId];
                [self.slider setValue:value.floatValue];
                self.slider.hidden = NO;
                self.sliderValueLabel.hidden = NO;
                [self onSetFilterAtMenuIndex:optionIndex];
                [self onSliderValueChanged:self.slider];
            }
        }
            break;
        case PanelMenuIndexMotion: case PanelMenuIndexGesture: case PanelMenuIndexCosmetic: case PanelMenuIndexKoubei:
            if (!(_previousMenuIndex != menuIndex && optionIndex == 0)) {
                // 切换一级菜单后，如果新的菜单选则的取消，不关闭动效
                [self onSetMotionWithIndex:optionIndex];
            }

            break;
        case PanelMenuIndexGreen:
            [self onSetGreenWithIndex:optionIndex];
            break;

        default:
            break;
    }
    _previousMenuIndex = menuIndex;
}

#pragma mark - Value Change Event Handlers
- (void)_applyBeautySettings {
    if ([self.actionPerformer respondsToSelector:@selector(setBeautyStyle:)]) {
        [self.actionPerformer setBeautyStyle:self.beautyStyle];
    }
    if ([self.actionPerformer respondsToSelector:@selector(setBeautyLevel:)]) {
        [self.actionPerformer setBeautyLevel:self.beautyLevel];
    }
    if ([self.actionPerformer respondsToSelector:@selector(setWhitenessLevel:)]) {
        [self.actionPerformer setWhitenessLevel:self.whiteLevel];
    }
    if ([self.actionPerformer respondsToSelector:@selector(setRuddyLevel:)]) {
        [self.actionPerformer setRuddyLevel:self.ruddyLevel];
    }
}

- (void)_applyMenuItem:( TCBeautyPanelItem *)item value:(float)value {
    id target = item.target ?: self.actionPerformer;

    if ([item isKindOfClass:[ TCBeautyPanelItem class]] && [target respondsToSelector:item.action]) {
        // 这里当参数类型变化时要注意修改为对应类型
        typedef float ParamType;
#if DEBUG
        // 参数类型检查
        NSMethodSignature *signature = [[target class] instanceMethodSignatureForSelector:item.action];
        const char *type = [signature getArgumentTypeAtIndex:2];
        NSAssert(strcmp(type, @encode(ParamType)) == 0, @"type mismatch");
#endif
        void(*setter)(id,SEL,ParamType) = (void(*)(id,SEL,ParamType))objc_msgSend;
        setter(target, item.action, (float)value);
    }
}

#pragma mark - value changed
- (void)onSliderValueChanged:(UISlider *)slider
{
    float value = slider.value;
    [self setSliderValue:slider.value];
    NSInteger menuIndex = _menu.menuIndex;
    if(menuIndex == PanelMenuIndexFilter) {
        if (_menu.optionIndex <= 0) { return; }
        
        NSString *filterID = _filters[_menu.optionIndex-1].identifier;
        self.filterValueDic[filterID] = @(value);
        // v7.2后的版本使用 setFilterStrength
        if ([self.actionPerformer respondsToSelector:@selector(setFilterStrength:)]) {
            [self.actionPerformer setFilterStrength:value / 10.f];
        } else if([self.actionPerformer respondsToSelector:@selector(setFilterConcentration:)]){
            [self.actionPerformer setFilterConcentration:value / 10.f];
        }
    } else if(menuIndex == PanelMenuIndexBeauty) {
        // 美颜数值变化
        NSInteger beautyIndex = _menu.optionIndex;// (int)[self selectedIndexPathForMenu:PanelMenuIndexBeauty].row;
        self.beautyLevelDic[@(beautyIndex)] = @(value);
        if(beautyIndex <= BeautyMenuItemLastBeautyValueItem) { // 选中的美颜
            [self _applyBeautySettings];
        } else { // 选中的大眼瘦脸等效果
             TCBeautyPanelItem *item = _optionsContainer[PanelMenuIndexBeauty][_menu.optionIndex];
            [self _applyMenuItem:item value:value];
        }
    }
}

- (void)onSetFilterAtMenuIndex:(NSInteger)index
{
    if ([self.actionPerformer respondsToSelector:@selector(setFilter:)]) {
        UIImage* image = [self filterImageByMenuOptionIndex:index];
        if ([self.actionPerformer respondsToSelector:@selector(setFilter:)]) {
            [self.actionPerformer setFilter:image];
        }
    }
}


- (void)onSetGreenWithIndex:(NSInteger)index
{
    if ([self.actionPerformer respondsToSelector:@selector(setGreenScreenFile:)]) {
        if (index == 0) {
            [self.actionPerformer setGreenScreenFile:nil];
        }
        if (index == 1) {
            NSURL* url = [_theme goodLuckVideoFileURL];
            [self.actionPerformer setGreenScreenFile:url.path];
        }
    }
}

- (void)onSetMotionWithIndex:(NSInteger)index
{
    if ([self.actionPerformer respondsToSelector:@selector(setMotionTmpl:inDir:)]) {
        NSString *localPackageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/packages"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPackageDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:localPackageDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (index == 0){
            [self.actionPerformer setMotionTmpl:nil inDir:localPackageDir];
        } else{
            TCBeautyPanelItem *item = _optionsContainer[_menu.menuIndex][_menu.optionIndex];
            TCPituMotion *motion = item.userInfo;
            NSString *pituPath = [NSString stringWithFormat:@"%@/%@", localPackageDir, motion.identifier];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pituPath]) {
                [self.actionPerformer setMotionTmpl:motion.identifier inDir:localPackageDir];
            }else{
                [self startLoadPitu:localPackageDir pituName:motion.identifier packageURL:motion.url];
            }
        }
    }
}

- (void)startLoadPitu:(NSString *)pituDir pituName:(NSString *)pituName packageURL:(NSURL *)packageURL{
    NSURLSessionDownloadTask *task = nil;
    @synchronized (_runningTask) {
        if (_runningTask[packageURL]) {
            return;
        }
        NSString *targetPath = [NSString stringWithFormat:@"%@/%@.zip", pituDir, pituName];
        TCPituDownloadTask *downloadTask = [TCPituDownloadTask taskWithDestPath:targetPath dir:pituDir name:pituName];

        if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
        }

        NSURLRequest *downloadReq = [NSURLRequest requestWithURL:packageURL
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:30.f];
        task = [_urlSession downloadTaskWithRequest:downloadReq];
        self->_runningTask[packageURL] = downloadTask;
    }
    [self.pituDelegate onLoadPituStart];
    [task resume];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    if (error) {
        NSURL *packageURL = task.originalRequest.URL;
        @synchronized (self->_runningTask) {
            [self->_runningTask removeObjectForKey:packageURL];
        }
        [self.pituDelegate onLoadPituFailed];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSURL *packageURL = downloadTask.originalRequest.URL;
    TCPituDownloadTask *task = self->_runningTask[packageURL];
    @synchronized (self->_runningTask) {
        [self->_runningTask removeObjectForKey:packageURL];
    }
    NSError *fsErr = nil;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:task.destPath]
                                            error:&fsErr];
    if (fsErr) {
        [self.pituDelegate onLoadPituFailed];
        return;
    }
    NSString *targetPath = task.destPath;
    NSString *pituDir = task.dir;
    NSString *pituName = task.name;
    // 解压
    BOOL unzipSuccess = NO;
    unzipSuccess = [SSZipArchive unzipFileAtPath:targetPath toDestination:pituDir overwrite:YES password:nil progressHandler:nil completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        // 删除zip文件
        NSError *fsErr = nil;
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&fsErr];
        if (fsErr) {
            NSLog(@"Error when removing temp file: %@", fsErr);
        }
    }];
    if (unzipSuccess) {
        [self.pituDelegate onLoadPituFinished];
        if ([self.actionPerformer respondsToSelector:@selector(setMotionTmpl:inDir:)]) {
            [self.actionPerformer setMotionTmpl:pituName inDir:pituDir];
        }
    } else {
        [self.pituDelegate onLoadPituFailed];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (self.pituDelegate) {
        double progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
        [self.pituDelegate onLoadPituProgress:progress];
    }
}

#pragma mark -
- (NSMutableDictionary *)beautyLevelDic
{
    if(!_beautyLevelDic){
        _beautyLevelDic = [[NSMutableDictionary alloc] init];
    }
    return _beautyLevelDic;
}

- (UISlider *)slider
{
    if(!_slider){
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 10;
        [_slider setMinimumTrackTintColor:_theme.sliderMinColor];
        [_slider setMaximumTrackTintColor:_theme.sliderMaxColor];
        [_slider setThumbImage:_theme.sliderThumbImage forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)sliderValueLabel
{
    if(!_sliderValueLabel){
        _sliderValueLabel = [[UILabel alloc] init];
        _sliderValueLabel.backgroundColor = [UIColor whiteColor];
        _sliderValueLabel.textAlignment = NSTextAlignmentCenter;
        _sliderValueLabel.text = @"0";
        [_sliderValueLabel setTextColor:_theme.sliderValueColor];
    }
    return _sliderValueLabel;
}

- (void)setSliderValue:(float)value
{
    self.sliderValueLabel.text = @(roundf(value)).stringValue;
    self.slider.value = value;
}

#pragma mark - TCMenuViewDataSource
- (NSInteger)numberOfMenusInMenu:(TCMenuView *)menu {
    return _menuArray.count;
}
- (NSString *)titleOfMenu:(TCMenuView *)menu atIndex:(NSInteger)index {
    return L(_menuArray[index]);
}

- (NSUInteger)numberOfOptionsInMenu:(TCMenuView *)menu menuIndex:(NSInteger)index {
    return _optionsContainer[index].count;
}

- (id<TCMenuItem>)menu:(TCMenuView *)menu
           itemAtMenuIndex:(NSInteger)index
               optionIndex:(NSInteger)optionIndex {
    return _optionsContainer[index][optionIndex];
}

@end
