//
//  NSBundle+TUIKIT.h
//  Pods
//
//  Created by harvy on 2020/10/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

/**
 * TUIKit 字符串国际化
 * Get localized strings in TUIKit
 */
#define TUIKitLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TUIKitLocalizableBundle]

#define TUICoreLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TUICoreLocalizableBundle]

#define TUIChatLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TUIChatLocalizableBundle]

#define TUIConversationLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TUIConversationLocalizableBundle]

#define TUIContactLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TUIContactLocalizableBundle]

#define TUIGroupLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TUIGroupLocalizableBundle]

#define TUISearchLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TUISearchLocalizableBundle]

#define TIMCommonLocalizableString(key) [TUIGlobalization getLocalizedStringForKey:@"" #key "" bundle:TIMCommonLocalizableBundle]

#define isRTL() [TUIGlobalization getRTLOption]

#define TUICustomLanguageKey @"TUICustomLanguageKey"
#define TUIChangeLanguageNotification @"TUIChangeLanguageNotification"

#define TUIKitGlobalizationRTLOptionKey @"TUIKitGlobalizationRTLOptionKey"

@interface TUIGlobalization : NSObject

/**
 * 获取本地化字符串
 * Get localized string
 */
+ (NSString *)getLocalizedStringForKey:(NSString *)key bundle:(NSString *)bundleName;

/**
 * 获取首选语言
 * Get preferred language
 */
+ (NSString *)getPreferredLanguage;

/**
 * 将首选语言设置为指定的值
 * Set the preferred language to the specified value.
 */
+ (void)setPreferredLanguage:(NSString *)language;

/**
 * 忽略繁体中文，改用简体中文
 * Ignore traditional chinese and switch to simplified chinese
 */
+ (void)ignoreTraditionChinese:(BOOL)ignore;

+ (void)setRTLOption:(BOOL)op;

+ (BOOL)getRTLOption;

#pragma mark - Deprecated
+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(NSString *)bundleName __attribute__((deprecated("use getLocalizedStringForKey:bundle:")));
+ (NSString *)tk_localizableLanguageKey __attribute__((deprecated("use getPreferredLanguage")));

@end
