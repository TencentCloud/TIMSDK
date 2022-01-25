//
//  TUIThemeManager.m
//  TUICore
//
//  Created by harvy on 2022/1/5.
//

#import "TUIThemeManager.h"
#import "UIColor+TUIHexColor.h"

@implementation TUITheme

// 获取动态颜色
+ (UIColor *)dynamicColor:(NSString *)colorKey module:(TUIThemeModule)module defaultColor:(NSString *)hex
{
    TUITheme *theme = TUICurrentTheme(module);
    TUITheme *darkTheme = TUIDarkTheme(module);
    if (theme) {
        // 指定了主题
        return [theme dynamicColor:colorKey defaultColor:hex];
    } else {
        // 不指定主题
        // 如果配置了黑夜主题，跟随系统适配暗黑，默认返回 defaut
        // 如果没有配置黑夜主题，使用默认值
        if (@available(iOS 13.0, *)) {
            return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                switch (traitCollection.userInterfaceStyle) {
                    case UIUserInterfaceStyleDark:
                        // 加载暗黑，如果没有配置黑夜主题，使用默认值
                        return [darkTheme dynamicColor:colorKey defaultColor:hex] ?: [UIColor colorWithHex:hex];
                    case UIUserInterfaceStyleLight:
                    case UIUserInterfaceStyleUnspecified:
                    default:
                        return [UIColor colorWithHex:hex];
                }
            }];
        } else {
            return [UIColor colorWithHex:hex];
        }
    }
}

- (UIColor *)dynamicColor:(NSString *)colorKey defaultColor:(NSString *)hex
{
    UIColor *color = [UIColor colorWithHex:hex];
    if ([self.manifest.allKeys containsObject:colorKey]) {
        NSString *colorHex = [self.manifest objectForKey:colorKey];
        if ([colorHex isKindOfClass:NSString.class]) {
            color = [UIColor colorWithHex:colorHex];
        }
    }
    return color;
}

+ (UIImage *)dynamicImage:(NSString *)imageKey module:(TUIThemeModule)module defaultImage:(UIImage *)image
{
    TUITheme *theme = TUICurrentTheme(module);
    TUITheme *darkTheme = TUIDarkTheme(module);
    if (theme) {
        // 指定了主题
        return [theme dynamicImage:imageKey defaultImage:image];
    } else {
        // 未指定主题
        UIImage *lightImage = image;
        UIImage *darkImage = [darkTheme dynamicImage:imageKey defaultImage:image];
        return [self imageWithImageLight:lightImage dark:darkImage];
    }
}

- (UIImage *)dynamicImage:(NSString *)imageKey defaultImage:(UIImage *)image
{
    UIImage *dynamic = image;
    if ([self.manifest.allKeys containsObject:imageKey]) {
        NSString *imageName = [self.manifest objectForKey:imageKey];
        if ([imageName isKindOfClass:NSString.class]) {
            imageName = [self.resourcePath stringByAppendingPathComponent:imageName];
            dynamic = [UIImage imageWithContentsOfFile:imageName];
        }
    }
    if (dynamic == nil) {
        dynamic = image;
    }
    return dynamic;
}

+ (UIImage *)imageWithImageLight:(UIImage *)lightImage dark:(UIImage *)darkImage {
    if (@available(iOS 13.0, *)) {
        UITraitCollection *const scaleTraitCollection = [UITraitCollection currentTraitCollection];
        UITraitCollection *const darkUnscaledTraitCollection = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
        UITraitCollection *const darkScaledTraitCollection = [UITraitCollection traitCollectionWithTraitsFromCollections:@[scaleTraitCollection, darkUnscaledTraitCollection]];
        UIImage *image = [lightImage imageWithConfiguration:[lightImage.configuration configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]];
        darkImage = [darkImage imageWithConfiguration:[darkImage.configuration configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]];
        [image.imageAsset registerImage:darkImage withTraitCollection:darkScaledTraitCollection];
        return image;
    } else {
        return lightImage;
    }
}



@end

@interface TUIThemeManager ()

// 各模块的主题资源路径，module:主题路径
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *themeResourcePathCache;

// 当前使用module使用的主题，module: 主题
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, TUITheme *> *currentThemeCache;

// 每个module对应的黑夜模式主题, 如果有的话
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, TUITheme *> *darkThemeCache;

// 所有的监听者
@property (nonatomic, strong) NSHashTable *listeners;

@end

@implementation TUIThemeManager
dispatch_queue_t _queue;
dispatch_queue_t _read_write_queue;
static id _instance;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("theme_manager_queue", DISPATCH_QUEUE_SERIAL);
        _read_write_queue = dispatch_queue_create("read_write_secure_queue", DISPATCH_QUEUE_CONCURRENT);
        _themeResourcePathCache = [NSMutableDictionary dictionary];
        _currentThemeCache = [NSMutableDictionary dictionary];
        _darkThemeCache = [NSMutableDictionary dictionary];
        _listeners = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addListener:(id<TUIThemeManagerListener>)listener
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        if (![weakSelf.listeners containsObject:listener]) {
            [weakSelf.listeners addObject:listener];
        }
    });
}

- (void)removeListener:(id<TUIThemeManagerListener>)listener
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        if ([weakSelf.listeners containsObject:listener]) {
            [weakSelf.listeners removeObject:listener];
        }
    });
}

// 设置主题资源根路径
- (void)registerThemeResourcePath:(NSString *)path darkThemeID:(NSString *)darkThemeID forModule:(TUIThemeModule)module
{
    if (path.length == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        // 保存主题资源路径
        [weakSelf.themeResourcePathCache setObject:path forKey:@(module)];
        
        // 加载黑夜主题
        TUITheme *theme = [weakSelf loadTheme:darkThemeID module:module];
        if (theme) {
            [weakSelf setDarkTheme:theme forModule:module];
        }
    });
}

- (void)registerThemeResourcePath:(NSString *)path forModule:(TUIThemeModule)module
{
    [self registerThemeResourcePath:path darkThemeID:@"dark" forModule:module];
}

// 获取当前正在使用的主题，线程安全
- (TUITheme *)currentThemeForModule:(TUIThemeModule)module
{
    __block TUITheme *theme = nil;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(_read_write_queue, ^{
        if ([weakSelf.currentThemeCache.allKeys containsObject:@(module)]) {
            theme = [weakSelf.currentThemeCache objectForKey:@(module)];
        }
    });
    return theme;
}

// 设置主题, 线程安全
- (void)setCurrentTheme:(TUITheme *)theme forModule:(TUIThemeModule)module
{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(_read_write_queue, ^{
        if ([weakSelf.currentThemeCache.allKeys containsObject:@(module)]) {
            [weakSelf.currentThemeCache removeObjectForKey:@(module)];
        }
        if (theme) {
            [weakSelf.currentThemeCache setObject:theme forKey:@(module)];
        }
    });
}

// 获取每个模块对应的黑夜主题
- (TUITheme *)darkThemeForModule:(TUIThemeModule)module
{
    __block TUITheme *theme = nil;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(_read_write_queue, ^{
        if ([weakSelf.darkThemeCache.allKeys containsObject:@(module)]) {
            theme = [weakSelf.darkThemeCache objectForKey:@(module)];
        }
    });
    return theme;
}

// 设置每个模块对应的黑夜主题, 线程安全
- (void)setDarkTheme:(TUITheme *)theme forModule:(TUIThemeModule)module
{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(_read_write_queue, ^{
        if ([weakSelf.darkThemeCache.allKeys containsObject:@(module)]) {
            [weakSelf.darkThemeCache removeObjectForKey:@(module)];
        }
        if (theme) {
            [weakSelf.darkThemeCache setObject:theme forKey:@(module)];
        }
    });
}

// 应用主题
- (void)applyTheme:(NSString *)themeID forModule:(TUIThemeModule)module
{
    if (themeID.length == 0) {
        NSLog(@"[theme][applyTheme] invalid themeID, module:%zd", module);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        BOOL isAll = NO;
        NSMutableArray *allKeys = [NSMutableArray arrayWithArray:weakSelf.themeResourcePathCache.allKeys];
        if (module == TUIThemeModuleAll ||
            ((module & TUIThemeModuleAll) == TUIThemeModuleAll)) {
            isAll = YES;
        }
        
        if (isAll) {
            for (NSNumber *moduleObject in allKeys) {
                TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
                [weakSelf doApplyTheme:themeID forSingleModule:tmpModue];
            }
        } else {
            for (NSNumber *moduleObject in allKeys) {
                TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
                if ((module & tmpModue) == tmpModue) {
                    [weakSelf doApplyTheme:themeID forSingleModule:tmpModue];
                }
            }
        }
    });
}

- (void)unApplyThemeForModule:(TUIThemeModule)module
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        BOOL isAll = NO;
        NSMutableArray *allKeys = [NSMutableArray arrayWithArray:weakSelf.themeResourcePathCache.allKeys];
        if (module == TUIThemeModuleAll ||
            ((module & TUIThemeModuleAll) == TUIThemeModuleAll)) {
            isAll = YES;
        }
        
        if (isAll) {
            for (NSNumber *moduleObject in allKeys) {
                TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
                [weakSelf setCurrentTheme:nil forModule:tmpModue];
            }
        } else {
            for (NSNumber *moduleObject in allKeys) {
                TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
                if ((module & tmpModue) == tmpModue) {
                    [weakSelf setCurrentTheme:nil forModule:tmpModue];
                }
            }
        }
    });
}

#pragma mark - 非线程安全的内部方法

- (void)doApplyTheme:(NSString *)themeID forSingleModule:(TUIThemeModule)module
{
    TUITheme *theme = [self loadTheme:themeID module:module];
    if (theme == nil) {
        return;
    }

    // 应用主题
    [self setCurrentTheme:theme forModule:module];
    
    // 动态切换主题
    [self notifyApplyTheme:theme module:module];
}

- (TUITheme *)loadTheme:(NSString *)themeID module:(TUIThemeModule)module
{
    // 获取当前模块对应的主题资源根路径
    NSString *themeResourcePath = [self themeResourcePathForModule:module];
    if (themeResourcePath.length == 0) {
        NSLog(@"[theme][applyTheme] theme resurce path not set, themeID:%@, module:%zd", themeID, module);
        return nil;
    }
    
    // 获取主题ID对应的资源路径并校验合法性
    themeResourcePath = [themeResourcePath stringByAppendingPathComponent:themeID];
    {
        BOOL isDirectory = NO;
        BOOL exist = [NSFileManager.defaultManager fileExistsAtPath:themeResourcePath isDirectory:&isDirectory];
        if (!exist || !isDirectory) {
            NSLog(@"[theme][applyTheme] invalid theme resurce, themeID:%@, module:%zd", themeID, module);
            return nil;
        }
    }
    
    NSString *manifestPath = [themeResourcePath stringByAppendingPathComponent:@"manifest.plist"];
    {
        BOOL isDirectory = NO;
        BOOL exist = [NSFileManager.defaultManager fileExistsAtPath:manifestPath isDirectory:&isDirectory];
        if (!exist || isDirectory) {
            NSLog(@"[theme][applyTheme] invalid manifest, themeID:%@, module:%zd", themeID, module);
            return nil;
        }
    }
    
    NSString *resourcePath = [themeResourcePath stringByAppendingPathComponent:@"resource"];
    {
        BOOL isDirectory = NO;
        BOOL exist = [NSFileManager.defaultManager fileExistsAtPath:resourcePath isDirectory:&isDirectory];
        if (!exist || !isDirectory) {
            NSLog(@"[theme][applyTheme] invalid resurce, themeID:%@, module:%zd", themeID, module);
            return nil;
        }
    }
    
    // 加载并保存当前的主题配置
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:manifestPath];
    if (dict == nil) {
        NSLog(@"[theme][applyTheme] manifest is null");
        return nil;
    }
    TUITheme *theme = [[TUITheme alloc] init];
    theme.themeID = themeID;
    theme.module = module;
    theme.themeDesc = [NSString stringWithFormat:@"theme_%@_%zd", themeID, module];
    theme.resourcePath = resourcePath;
    theme.manifest = dict;
    
    return theme;
}

- (void)notifyApplyTheme:(TUITheme *)theme module:(TUIThemeModule)module
{
    if (theme == nil) {
        return;
    }
    
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notifyApplyTheme:theme module:module];
        });
        return;
    }
    
    for (id<TUIThemeManagerListener> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(onApplyTheme:module:)]) {
            [listener onApplyTheme:theme module:module];
        }
    }
    
    NSDictionary *userInfo = @{
        TUIDidApplyingThemeChangedNotficationModuleKey:@(module),
        TUIDidApplyingThemeChangedNotficationThemeKey:theme
    };
    [NSNotificationCenter.defaultCenter postNotificationName:TUIDidApplyingThemeChangedNotfication
                                                      object:nil
                                                    userInfo:userInfo];
}

- (NSString *)themeResourcePathForModule:(TUIThemeModule)module
{
    if ([self.themeResourcePathCache.allKeys containsObject:@(module)]) {
        return [self.themeResourcePathCache objectForKey:@(module)];
    }
    return @"";
}

@end
