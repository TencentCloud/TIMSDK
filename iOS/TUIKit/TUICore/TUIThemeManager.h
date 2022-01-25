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
 */

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

@class TUITheme;
@class TUIThemeManager;

NS_ASSUME_NONNULL_BEGIN

#define TUIShareThemeManager TUIThemeManager.shareManager

// 应用的主题发生了变化的通知
#define TUIDidApplyingThemeChangedNotfication @"TUIDidApplyingThemeChangedNotfication"
#define TUIDidApplyingThemeChangedNotficationThemeKey @"TUIDidApplyingThemeChangedNotficationThemeKey"
#define TUIDidApplyingThemeChangedNotficationModuleKey @"TUIDidApplyingThemeChangedNotficationModuleKey"

// 注册模块对应的主题资源根路径
#define TUIRegisterThemeResourcePath(path, module) [TUIShareThemeManager registerThemeResourcePath:path forModule:module];

// 获取当前使用的主题
#define TUICurrentTheme(module) [TUIShareThemeManager currentThemeForModule:module]

// 获取对应的黑夜主题
#define TUIDarkTheme(module) [TUIShareThemeManager darkThemeForModule:module]

// 获取动态颜色
#define TUIDynamicColor(colorKey, themeModule, defaultHex)  [TUITheme dynamicColor:colorKey module:themeModule defaultColor:defaultHex]
#define TUIDemoDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleDemo, defaultHex)
#define TUICoreDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleCore, defaultHex)
#define TUIChatDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleChat, defaultHex)
#define TUIConversationDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleConversation, defaultHex)
#define TUIContactDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleContact, defaultHex)
#define TUIGroupDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleGroup, defaultHex)
#define TUISearchDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleSearch, defaultHex)
#define TUICallingDynamicColor(colorKey, defaultHex) TUIDynamicColor(colorKey, TUIThemeModuleCalling, defaultHex)

// 动态获取图片
#define TUIDynamicImage(imageKey, themeModule, defaultImg) [TUITheme dynamicImage:imageKey module:themeModule defaultImage:defaultImg]
#define TUIDemoDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleDemo, defaultImg)
#define TUICoreDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleCore, defaultImg)
#define TUIChatDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleChat, defaultImg)
#define TUIConversationDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleConversation, defaultImg)
#define TUIContactDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleContact, defaultImg)
#define TUIGroupDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleGroup, defaultImg)
#define TUISearchDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleSearch, defaultImg)
#define TUICallingDynamicImage(imageKey, defaultImg) TUIDynamicImage(imageKey, TUIThemeModuleCalling, defaultImg)

// 主题模块
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

// 主题 ID
@property (nonatomic, copy) NSString *themeID;
// 主题所属的模块
@property (nonatomic, assign) TUIThemeModule module;
// 主题描述
@property (nonatomic, copy, nullable) NSString *themeDesc;
// 主题对应的配置信息
@property (nonatomic, strong) NSDictionary *manifest;
// 主题对应的 resource 路径
@property (nonatomic, copy) NSString *resourcePath;

// 获取动态颜色
+ (UIColor *__nullable)dynamicColor:(NSString *)colorKey module:(TUIThemeModule)module defaultColor:(NSString *)hex;
// 获取动态图片
+ (UIImage *__nullable)dynamicImage:(NSString *)imageKey module:(TUIThemeModule)module defaultImage:(UIImage *)image;

@end

@protocol TUIThemeManagerListener <NSObject>

// 主题发生了变化
// 也可以监听 @ref TUIDidApplyingThemeChangedNotfication 通知
- (void)onApplyTheme:(TUITheme *)theme module:(TUIThemeModule)module;

// 监听错误
- (void)onError:(NSInteger)code message:(NSString *)message userInfo:(NSString *)userInfo;

@end

@interface TUIThemeManager : NSObject

+ (instancetype)shareManager;

- (void)addListener:(id<TUIThemeManagerListener>)listener;
- (void)removeListener:(id<TUIThemeManagerListener>)listener;

// 注册主题资源根路径
// 如果不指定黑夜主题的ID的话，内部默认使用 @"dark" 来表示黑夜模式
- (void)registerThemeResourcePath:(NSString *)path forModule:(TUIThemeModule)module;
- (void)registerThemeResourcePath:(NSString *)path darkThemeID:(NSString *)darkThemeID forModule:(TUIThemeModule)module;

// 获取当前正在使用的主题
- (TUITheme *)currentThemeForModule:(TUIThemeModule)module;

// 获取每个模块对应的黑夜主题
- (TUITheme *)darkThemeForModule:(TUIThemeModule)module;

// 应用主题
- (void)applyTheme:(NSString *)themeID forModule:(TUIThemeModule)module;

// 卸载主题
// 使用默认值，如果有暗黑资源的话，会自动跟随系统适配暗黑模式
- (void)unApplyThemeForModule:(TUIThemeModule)module;

@end

NS_ASSUME_NONNULL_END
