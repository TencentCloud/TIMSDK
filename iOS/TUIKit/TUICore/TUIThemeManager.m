//
//  TUIThemeManager.m
//  TUICore
//
//  Created by harvy on 2022/1/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIThemeManager.h"
#import "UIColor+TUIHexColor.h"

@interface TUIDarkThemeRootVC : UIViewController

@end
@implementation TUIDarkThemeRootVC
- (BOOL)shouldAutorotate {
    return NO;
}
@end

@interface TUIDarkWindow : UIWindow
@property(nonatomic, readonly, class) TUIDarkWindow *sharedInstance;
@property(nonatomic, strong) UIWindow *previousKeyWindow;
@end
@implementation TUIDarkWindow

+ (void)load {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(windowDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

+ (void)windowDidBecomeActive {
    UIWindow *darkWindow = [self sharedInstance];
    if (@available(iOS 13.0, *)) {
        UIScene *scene = UIApplication.sharedApplication.connectedScenes.anyObject;
        if (scene) {
            darkWindow.windowScene = (UIWindowScene *)scene;
        }
    }
    [darkWindow setRootViewController:[TUIDarkThemeRootVC new]];
    darkWindow.hidden = NO;
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)becomeKeyWindow {
    _previousKeyWindow = [self appKeyWindow];
    [super becomeKeyWindow];
}

- (void)resignKeyWindow {
    [super resignKeyWindow];
    [_previousKeyWindow makeKeyWindow];
    _previousKeyWindow = nil;
}

- (UIWindow *)appKeyWindow {
    UIWindow *keywindow = UIApplication.sharedApplication.keyWindow;
    if (keywindow == nil) {
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    UIWindow *tmpWindow = nil;
                    if (@available(iOS 15.0, *)) {
                        tmpWindow = scene.keyWindow;
                    }
                    if (tmpWindow == nil) {
                        for (UIWindow *window in scene.windows) {
                            if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO &&
                                CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
                                tmpWindow = window;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    if (keywindow == nil) {
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO && CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
                keywindow = window;
                break;
            }
        }
    }
    return keywindow;
}

+ (instancetype)sharedInstance {
    static TUIDarkWindow *shareWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      shareWindow = [[self alloc] init];
      shareWindow.frame = UIScreen.mainScreen.bounds;
      shareWindow.userInteractionEnabled = YES;
      shareWindow.windowLevel = UIWindowLevelNormal - 1;
      shareWindow.hidden = YES;
      shareWindow.opaque = NO;
      shareWindow.backgroundColor = [UIColor clearColor];
      shareWindow.layer.backgroundColor = [UIColor clearColor].CGColor;
    });
    return shareWindow;
}

- (void)setOverrideUserInterfaceStyle:(UIUserInterfaceStyle)overrideUserInterfaceStyle {
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [NSNotificationCenter.defaultCenter postNotificationName:TUIDidApplyingThemeChangedNotfication object:nil];
            if ([TUIThemeManager.shareManager respondsToSelector:@selector(allListenerExcuteonApplyThemeMethod:module:)]) {
                [TUIThemeManager.shareManager performSelector:@selector(allListenerExcuteonApplyThemeMethod:module:) withObject:nil withObject:nil];
            }
        }
    }
}
@end

@implementation TUITheme

+ (UIColor *)dynamicColor:(NSString *)colorKey module:(TUIThemeModule)module defaultColor:(NSString *)hex {
    TUITheme *theme = TUICurrentTheme(module);
    TUITheme *darkTheme = TUIDarkTheme(module);
    if (theme) {
        return [theme dynamicColor:colorKey defaultColor:hex];
    } else {
        if (@available(iOS 13.0, *)) {
            return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
              switch (traitCollection.userInterfaceStyle) {
                  case UIUserInterfaceStyleDark:
                      if(darkTheme){
                          return [darkTheme dynamicColor:colorKey defaultColor:hex];
                      }
                  case UIUserInterfaceStyleLight:
                  case UIUserInterfaceStyleUnspecified:
                  default:
                      return [UIColor tui_colorWithHex:hex];
              }
            }];
        } else {
            return [UIColor tui_colorWithHex:hex];
        }
    }
}

- (UIColor *)dynamicColor:(NSString *)colorKey defaultColor:(NSString *)hex {
    UIColor *color = nil;

    NSString *colorHex = [self.manifest objectForKey:colorKey];
    if (colorHex && [colorHex isKindOfClass:NSString.class]) {
        color = [UIColor tui_colorWithHex:colorHex];
    }

    if (color == nil) {
        color = [UIColor tui_colorWithHex:hex];
    }
    return color;
}

+ (UIImage *)dynamicImage:(NSString *)imageKey module:(TUIThemeModule)module defaultImage:(UIImage *)image {
    TUITheme *theme = TUICurrentTheme(module);
    TUITheme *darkTheme = TUIDarkTheme(module);
    if (theme) {
        return [theme dynamicImage:imageKey defaultImage:image];
    } else {
        UIImage *lightImage = image;
        UIImage *darkImage = [darkTheme dynamicImage:imageKey defaultImage:image];
        return [self imageWithImageLight:lightImage dark:darkImage];
    }
}

- (UIImage *)dynamicImage:(NSString *)imageKey defaultImage:(UIImage *)image {
    UIImage *dynamic = nil;

    NSString *imageName = [self.manifest objectForKey:imageKey];
    if ([imageName isKindOfClass:NSString.class]) {
        imageName = [self.resourcePath stringByAppendingPathComponent:imageName];
        dynamic = [UIImage imageWithContentsOfFile:imageName];
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
        UITraitCollection *const darkScaledTraitCollection =
            [UITraitCollection traitCollectionWithTraitsFromCollections:@[ scaleTraitCollection, darkUnscaledTraitCollection ]];
        UIImage *image = [lightImage
            imageWithConfiguration:[lightImage.configuration
                                       configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]];
        darkImage = [darkImage
            imageWithConfiguration:[darkImage.configuration
                                       configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]];
        [image.imageAsset registerImage:darkImage withTraitCollection:darkScaledTraitCollection];
        return image;
    } else {
        return lightImage;
    }
}

@end

@interface TUIThemeManager ()

/**
 * 各模块的主题资源路径，module:主题路径
 * The theme resource path of each module, module: theme path
 */
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *themeResourcePathCache;

/**
 * 当前module使用的主题，module: 主题
 * The theme currently used by module, module: theme
 */
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, TUITheme *> *currentThemeCache;

/**
 * 每个module对应的黑夜模式主题, 如果有的话
 * The dark theme for each module, if any
 */
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, TUITheme *> *darkThemeCache;

@property(nonatomic, strong) NSHashTable *listeners;

- (void)allListenerExcuteonApplyThemeMethod:(TUITheme *)theme module:(TUIThemeModule)module;

@end

@implementation TUIThemeManager
#ifdef TUIThreadSafe
dispatch_queue_t _queue;
dispatch_queue_t _read_write_queue;
#endif
static id gShareInstance;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      gShareInstance = [[self alloc] init];
    });
    return gShareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
#ifdef TUIThreadSafe
        _queue = dispatch_queue_create("theme_manager_queue", DISPATCH_QUEUE_SERIAL);
        _read_write_queue = dispatch_queue_create("read_write_secure_queue", DISPATCH_QUEUE_CONCURRENT);
#endif
        _themeResourcePathCache = [NSMutableDictionary dictionary];
        _currentThemeCache = [NSMutableDictionary dictionary];
        _darkThemeCache = [NSMutableDictionary dictionary];
        _listeners = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addListener:(id<TUIThemeManagerListener>)listener {
#ifdef TUIThreadSafe
    dispatch_async(_queue, ^{
#endif
      if (![self.listeners containsObject:listener]) {
          [self.listeners addObject:listener];
      }
#ifdef TUIThreadSafe
    });
#endif
}

- (void)removeListener:(id<TUIThemeManagerListener>)listener {
#ifdef TUIThreadSafe
    dispatch_async(_queue, ^{
#endif
      if ([self.listeners containsObject:listener]) {
          [self.listeners removeObject:listener];
      }
#ifdef TUIThreadSafe
    });
#endif
}

- (void)registerThemeResourcePath:(NSString *)path darkThemeID:(NSString *)darkThemeID forModule:(TUIThemeModule)module {
    if (path.length == 0) {
        return;
    }

#ifdef TUIThreadSafe
    dispatch_async(_queue, ^{
#endif
      [self.themeResourcePathCache setObject:path forKey:@(module)];

      TUITheme *theme = [self loadTheme:darkThemeID module:module];
      if (theme) {
          [self setDarkTheme:theme forModule:module];
      }
#ifdef TUIThreadSafe
    });
#endif
}

- (void)registerThemeResourcePath:(NSString *)path forModule:(TUIThemeModule)module {
    [self registerThemeResourcePath:path darkThemeID:@"dark" forModule:module];
}

- (TUITheme *)currentThemeForModule:(TUIThemeModule)module {
    __block TUITheme *theme = nil;
#ifdef TUIThreadSafe
    dispatch_sync(_read_write_queue, ^{
#endif
      theme = [self.currentThemeCache objectForKey:@(module)];
#ifdef TUIThreadSafe
    });
#endif
    return theme;
}

- (void)setCurrentTheme:(TUITheme *)theme forModule:(TUIThemeModule)module {
#ifdef TUIThreadSafe
    dispatch_barrier_async(_read_write_queue, ^{
#endif
      if ([self.currentThemeCache.allKeys containsObject:@(module)]) {
          [self.currentThemeCache removeObjectForKey:@(module)];
      }
      if (theme) {
          [self.currentThemeCache setObject:theme forKey:@(module)];
      }
#ifdef TUIThreadSafe
    });
#endif
}

- (TUITheme *)darkThemeForModule:(TUIThemeModule)module {
    __block TUITheme *theme = nil;
#ifdef TUIThreadSafe
    dispatch_sync(_read_write_queue, ^{
#endif
      if ([self.darkThemeCache.allKeys containsObject:@(module)]) {
          theme = [self.darkThemeCache objectForKey:@(module)];
      }
#ifdef TUIThreadSafe
    });
#endif
    return theme;
}

- (void)setDarkTheme:(TUITheme *)theme forModule:(TUIThemeModule)module {
#ifdef TUIThreadSafe
    dispatch_barrier_async(_read_write_queue, ^{
#endif
      if ([self.darkThemeCache.allKeys containsObject:@(module)]) {
          [self.darkThemeCache removeObjectForKey:@(module)];
      }
      if (theme) {
          [self.darkThemeCache setObject:theme forKey:@(module)];
      }
#ifdef TUIThreadSafe
    });
#endif
}

- (void)applyTheme:(NSString *)themeID forModule:(TUIThemeModule)module {
    if (themeID.length == 0) {
        NSLog(@"[theme][applyTheme] invalid themeID, module:%zd", module);
        return;
    }
#ifdef TUIThreadSafe
    dispatch_async(_queue, ^{
#endif
      BOOL isAll = NO;
      NSMutableArray *allKeys = [NSMutableArray arrayWithArray:self.themeResourcePathCache.allKeys];
      if (module == TUIThemeModuleAll || ((module & TUIThemeModuleAll) == TUIThemeModuleAll)) {
          isAll = YES;
      }

      if (isAll) {
          for (NSNumber *moduleObject in allKeys) {
              TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
              [self doApplyTheme:themeID forSingleModule:tmpModue];
          }
      } else {
          for (NSNumber *moduleObject in allKeys) {
              TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
              if ((module & tmpModue) == tmpModue) {
                  [self doApplyTheme:themeID forSingleModule:tmpModue];
              }
          }
      }
#ifdef TUIThreadSafe
    });
#endif
}

- (void)unApplyThemeForModule:(TUIThemeModule)module {
#ifdef TUIThreadSafe
    dispatch_async(_queue, ^{
#endif
      BOOL isAll = NO;
      NSMutableArray *allKeys = [NSMutableArray arrayWithArray:self.themeResourcePathCache.allKeys];
      if (module == TUIThemeModuleAll || ((module & TUIThemeModuleAll) == TUIThemeModuleAll)) {
          isAll = YES;
      }

      if (isAll) {
          for (NSNumber *moduleObject in allKeys) {
              TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
              [self setCurrentTheme:nil forModule:tmpModue];
          }

          [NSNotificationCenter.defaultCenter postNotificationName:TUIDidApplyingThemeChangedNotfication object:nil userInfo:nil];
      } else {
          for (NSNumber *moduleObject in allKeys) {
              TUIThemeModule tmpModue = (TUIThemeModule)[moduleObject integerValue];
              if ((module & tmpModue) == tmpModue) {
                  [self setCurrentTheme:nil forModule:tmpModue];
              }
          }
      }
#ifdef TUIThreadSafe
    });
#endif
}

#pragma mark - Not thread safe

- (void)doApplyTheme:(NSString *)themeID forSingleModule:(TUIThemeModule)module {
    TUITheme *theme = [self loadTheme:themeID module:module];
    if (theme == nil) {
        return;
    }

    [self setCurrentTheme:theme forModule:module];

    [self notifyApplyTheme:theme module:module];
}

- (TUITheme *)loadTheme:(NSString *)themeID module:(TUIThemeModule)module {
    NSString *themeResourcePath = [self themeResourcePathForModule:module];
    if (themeResourcePath.length == 0) {
        NSLog(@"[theme][applyTheme] theme resurce path not set, themeID:%@, module:%zd", themeID, module);
        return nil;
    }

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
        }
    }

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

- (void)notifyApplyTheme:(TUITheme *)theme module:(TUIThemeModule)module {
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

    [self allListenerExcuteonApplyThemeMethod:theme module:module];

    NSDictionary *userInfo = @{TUIDidApplyingThemeChangedNotficationModuleKey : @(module), TUIDidApplyingThemeChangedNotficationThemeKey : theme};
    [NSNotificationCenter.defaultCenter postNotificationName:TUIDidApplyingThemeChangedNotfication object:nil userInfo:userInfo];
}

- (void)allListenerExcuteonApplyThemeMethod:(TUITheme *)theme module:(TUIThemeModule)module {
    for (id<TUIThemeManagerListener> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(onApplyTheme:module:)]) {
            [listener onApplyTheme:theme module:module];
        }
    }
}

- (NSString *)themeResourcePathForModule:(TUIThemeModule)module {
    if ([self.themeResourcePathCache.allKeys containsObject:@(module)]) {
        return [self.themeResourcePathCache objectForKey:@(module)];
    }
    return @"";
}

@end
