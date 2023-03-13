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
#define TUIKitLocalizableString(key)    \
    [TUIGlobalization g_localizedStringForKey:@""#key""  bundle:TUIKitLocalizableBundle]

#define TUICoreLocalizableString(key)   \
    [TUIGlobalization g_localizedStringForKey:@""#key""  bundle:TUICoreLocalizableBundle]

#define TUIChatLocalizableString(key)   \
    [TUIGlobalization g_localizedStringForKey:@""#key""  bundle:TUIChatLocalizableBundle]

#define TUIConversationLocalizableString(key)   \
    [TUIGlobalization g_localizedStringForKey:@""#key""  bundle:TUIConversationLocalizableBundle]

#define TUIContactLocalizableString(key)   \
    [TUIGlobalization g_localizedStringForKey:@""#key""  bundle:TUIContactLocalizableBundle]

#define TUIGroupLocalizableString(key)   \
    [TUIGlobalization g_localizedStringForKey:@""#key""  bundle:TUIGroupLocalizableBundle]

#define TUISearchLocalizableString(key)   \
    [TUIGlobalization g_localizedStringForKey:@""#key""  bundle:TUISearchLocalizableBundle]

#define TUICustomLanguageKey @"TUICustomLanguageKey"
#define TUIChangeLanguageNotification @"TUIChangeLanguageNotification"

@interface TUIGlobalization:NSObject

+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(NSString *)bundleName;

+ (void)setCustomLanguage:(NSString *)language;

+ (NSString *)tk_localizableLanguageKey;

@end

