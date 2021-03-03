//
//  NSBundle+TUIKIT.h
//  Pods
//
//  Created by harvy on 2020/10/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define TUILocalizableString(key) [NSBundle tk_localizedStringForKey:@""#key""]
#define TUIEmojiLocalizableString(key) [NSBundle tk_emojiLocalizedStringForKey:@""#key""]

@interface NSBundle (TUIKIT)

#pragma mark - TUIKit 代码相关国际化
+ (NSString *)tk_localizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)tk_localizedStringForKey:(NSString *)key;


#pragma mark - TUIKit 内置表情相关国际化
+ (NSString *)tk_emojiLocalizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)tk_emojiLocalizedStringForKey:(NSString *)key;

+ (NSString *)tk_localizableLanguageKey;

@end

NS_ASSUME_NONNULL_END
