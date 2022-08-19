//
//  TUIThemeManager.h
//  TUICore
//
//  Created by harvy on 2022/1/5.
//
/**
 *  每个模块主题的存储结构
 *      | 主题资源根路径（ThemeResourcePath）
 *      |
 *      |------ 主题1（以主题 id 命名）
 *      |                 |
 *      |                 |------- manifest.plist (主题的配置信息)
 *      |                 |------- resource （资源文件）
 *      |-------主题2
 *      |                 |
 *      |                 |------ manifest.plist (主题的配置信息)
 *      |                 |------ resource（资源文件）
 *
 *
 *
 * Storage structure of theme for each module
 *      | The root path of the theme resource（ThemeResourcePath）
 *      |
 *      |------ Theme one（named with theme identifier）
 *      |                 |
 *      |                 |------- manifest.plist (configuration information for the theme)
 *      |                 |------- resource
 *      |-------Theme two
 *      |                 |
 *      |                 |------ manifest.plist (configuration information for the theme)
 *      |                 |------ resource
 */

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

@class TUITheme;
@class TUIThemeManager;

NS_ASSUME_NONNULL_BEGIN

#define TUIShareThemeManager TUIThemeManager.shareManager

/**
 * 应用的主题发生了变化的通知
 * Notifications when the app's theme has changed
 */
#define TUIDidApplyingThemeChangedNotfication @"TUIDidApplyingThemeChangedNotfication"
#define TUIDidApplyingThemeChangedNotficationThemeKey @"TUIDidApplyingThemeChangedNotficationThemeKey"
#define TUIDidApplyingThemeChangedNotficationModuleKey @"TUIDidApplyingThemeChangedNotficationModuleKey"

/**
 * 注册模块对应的主题资源根路径
 * Register the theme resource root path of the module
 */
#define TUIRegisterThemeResourcePath(path, module) [TUIShareThemeManager registerThemeResourcePath:path forModule:module];

/**
 * 获取当前使用的主题
 * Get the theme used by the module
 */
#define TUICurrentTheme(module) [TUIShareThemeManager currentThemeForModule:module]

/**
 * 获取对应的黑夜主题
 * Get the dark night theme of the module
 */
#define TUIDarkTheme(module) [TUIShareThemeManager darkThemeForModule:module]

/**
 * 获取动态颜色
 * Get dynamic colors that change with theme
 */
#define TUIDynamicColor(colorKey, themeModule, defaultHex)  [TUITheme dynamicColor:colorKey module:themeModule defaultColor:defaultHex]
#define TUIDemoDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleDemo, defaultHex)
#define TUICoreDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleCore, defaultHex)
#define TUIChatDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleChat, defaultHex)
#define TUIConversationDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleConversation, defaultHex)
#define TUIContactDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleContact, defaultHex)
#define TUIGroupDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleGroup, defaultHex)
#define TUISearchDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleSearch, defaultHex)
#define TUICallingDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleCalling, defaultHex)

/**
 * 动态获取图片
 * Get dynamic image that change with theme
 */
#define TUIDemoBundleThemeImage(imageKey,defaultImageName) TUIDemoDynamicImage(imageKey,TUIDemoCommonBundleImage(defaultImageName))
#define TUICoreBundleThemeImage(imageKey,defaultImageName) TUICoreDynamicImage(imageKey,TUICoreCommonBundleImage(defaultImageName))
#define TUIChatBundleThemeImage(imageKey,defaultImageName) TUIChatDynamicImage(imageKey,TUIChatCommonBundleImage(defaultImageName))
#define TUIConversationBundleThemeImage(imageKey,defaultImageName) TUIConversationDynamicImage(imageKey,TUIConversationCommonBundleImage(defaultImageName))
#define TUIContactBundleThemeImage(imageKey,defaultImageName) TUIContactDynamicImage(imageKey,TUIContactCommonBundleImage(defaultImageName))
#define TUIGroupBundleThemeImage(imageKey,defaultImageName) TUIGroupDynamicImage(imageKey,TUIGroupCommonBundleImage(defaultImageName))
#define TUISearchBundleThemeImage(imageKey,defaultImageName) TUISearchDynamicImage(imageKey,TUISearchCommonBundleImage(defaultImageName))
#define TUICallingBundleThemeImage(imageKey,defaultImageName) TUICallingDynamicImage(imageKey,TUICallingCommonBundleImage(defaultImageName))

#define TUIDynamicImage(imageKey, themeModule, defaultImg) [TUITheme dynamicImage:imageKey module:themeModule defaultImage:defaultImg]
#define TUIDemoDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleDemo, defaultImg)
#define TUICoreDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleCore, defaultImg)
#define TUIChatDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleChat, defaultImg)
#define TUIConversationDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleConversation, defaultImg)
#define TUIContactDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleContact, defaultImg)
#define TUIGroupDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleGroup, defaultImg)
#define TUISearchDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleSearch, defaultImg)
#define TUICallingDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleCalling, defaultImg)

#define __TUIDefaultBundleImage(imageBundlePath) [UIImage imageWithContentsOfFile:imageBundlePath]
#define TUIDemoCommonBundleImage(imageName) __TUIDefaultBundleImage(TUIDemoImagePath(imageName))
#define TUICoreCommonBundleImage(imageName) __TUIDefaultBundleImage(TUICoreImagePath(imageName))
#define TUIChatCommonBundleImage(imageName) __TUIDefaultBundleImage(TUIChatImagePath(imageName))
#define TUIConversationCommonBundleImage(imageName) __TUIDefaultBundleImage(TUIConversationImagePath(imageName))
#define TUIContactCommonBundleImage(imageName) __TUIDefaultBundleImage(TUIContactImagePath(imageName))
#define TUIGroupCommonBundleImage(imageName) __TUIDefaultBundleImage(TUIGroupImagePath(imageName))
#define TUISearchCommonBundleImage(imageName) __TUIDefaultBundleImage(TUISearchImagePath(imageName))
#define TUICallingCommonBundleImage(imageName) __TUIDefaultBundleImage(TUICallingImagePath(imageName))


/**
 * 主题模块
 * The module of the theme
 */
typedef NS_ENUM(NSInteger, TUIThemeModule) {
    TUIThemeModuleAll          = 0xFF,
    TUIThemeModuleDemo         = 0x1 << 0,
    TUIThemeModuleCore         = 0x1 << 1,
    TUIThemeModuleChat         = 0x1 << 2,
    TUIThemeModuleConversation = 0x1 << 3,
    TUIThemeModuleContact      = 0x1 << 4,
    TUIThemeModuleGroup        = 0x1 << 5,
    TUIThemeModuleSearch       = 0x1 << 6,
    TUIThemeModuleCalling      = 0x1 << 7,
};

@interface TUITheme : NSObject

@property (nonatomic, copy) NSString *themeID;
@property (nonatomic, assign) TUIThemeModule module;
@property (nonatomic, copy, nullable) NSString *themeDesc;
@property (nonatomic, strong) NSDictionary *manifest;
@property (nonatomic, copy) NSString *resourcePath;

+ (UIColor *__nullable)dynamicColor:(NSString *)colorKey module:(TUIThemeModule)module defaultColor:(NSString *)hex;
+ (UIImage *__nullable)dynamicImage:(NSString *)imageKey module:(TUIThemeModule)module defaultImage:(UIImage *)image;

@end

@protocol TUIThemeManagerListener <NSObject>

/**
 * 主题发生了变化，也可以监听 @ref TUIDidApplyingThemeChangedNotfication 通知
 * Callback for theme changes, you can also listen to the notification named TUIDidApplyingThemeChangedNotfication
 */
- (void)onApplyTheme:(TUITheme *)theme module:(TUIThemeModule)module;

- (void)onError:(NSInteger)code message:(NSString *)message userInfo:(NSString *)userInfo;

@end

@interface TUIThemeManager : NSObject

+ (instancetype)shareManager;

- (void)addListener:(id<TUIThemeManagerListener>)listener;
- (void)removeListener:(id<TUIThemeManagerListener>)listener;

/**
 * 注册主题资源根路径
 * 如果不指定黑夜主题的ID的话，内部默认使用 @"dark" 来表示黑夜模式
 *
 * Register the theme resource root path of the module
 * If the ID of the dark theme is not specified, @"dark" is used internally by default to indicate the dark mode
 */
- (void)registerThemeResourcePath:(NSString *)path forModule:(TUIThemeModule)module;
- (void)registerThemeResourcePath:(NSString *)path darkThemeID:(NSString *)darkThemeID forModule:(TUIThemeModule)module;

- (TUITheme *)currentThemeForModule:(TUIThemeModule)module;
- (TUITheme *)darkThemeForModule:(TUIThemeModule)module;

- (void)applyTheme:(NSString *)themeID forModule:(TUIThemeModule)module;
- (void)unApplyThemeForModule:(TUIThemeModule)module;

@end

NS_ASSUME_NONNULL_END
