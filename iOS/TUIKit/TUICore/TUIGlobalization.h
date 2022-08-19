//
//  NSBundle+TUIKIT.h
//  Pods
//
//  Created by harvy on 2020/10/9.
//

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

/**
 * TUIKit 字符串国际化
 * Get localized strings in TUIKit
 */
#define TUIKitLocalizableString(key) [TUIGlobalization g_localizedStringForKey:@""#key"" bundle:TUIKitLocalizableBundle]

#define TUICustomLanguageKey @"TUICustomLanguageKey"
#define TUIChangeLanguageNotification @"TUIChangeLanguageNotification"

@interface TUIGlobalization:NSObject

+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(NSString *)bundleName;

+ (void)setCustomLanguage:(NSString *)language;

+ (NSString *)tk_localizableLanguageKey;

@end

