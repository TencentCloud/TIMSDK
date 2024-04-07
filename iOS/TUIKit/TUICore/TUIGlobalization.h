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
 * Get localized string
 */
+ (NSString *)getLocalizedStringForKey:(NSString *)key bundle:(NSString *)bundleName;

/**
 * Get preferred language
 */
+ (NSString *)getPreferredLanguage;

/**
 * Set the preferred language to the specified value.
 */
+ (void)setPreferredLanguage:(NSString *)language;

/**
 * Ignore traditional chinese and switch to simplified chinese
 */
+ (void)ignoreTraditionChinese:(BOOL)ignore;

+ (void)setRTLOption:(BOOL)op;

+ (BOOL)getRTLOption;

#pragma mark - Deprecated
+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(NSString *)bundleName __attribute__((deprecated("use getLocalizedStringForKey:bundle:")));
+ (NSString *)tk_localizableLanguageKey __attribute__((deprecated("use getPreferredLanguage")));

@end
