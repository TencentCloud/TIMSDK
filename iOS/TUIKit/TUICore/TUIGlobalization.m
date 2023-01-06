//
//  NSBundle+TUIKIT.m
//  Pods
//
//  Created by harvy on 2020/10/9.
//

#import "TUIGlobalization.h"
#import "TUIDefine.h"
#import <objc/runtime.h>

@implementation TUIGlobalization

+ (NSString *)g_localizedStringForKey:(NSString *)key value:(nullable NSString *)value bundle:(nonnull NSString *)bundleName
{
    static NSMutableDictionary *bundleCache = nil;
    if (bundleCache == nil) {
        bundleCache = [NSMutableDictionary dictionary];
    }
    NSString *language = [self tk_localizableLanguageKey];
    language = [@"Localizable" stringByAppendingPathComponent:language];
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", bundleName, language];
    NSBundle *bundle = [bundleCache objectForKey:cacheKey];
    if (bundle == nil) {
        bundle = [NSBundle bundleWithPath:[TUIKitLocalizable(bundleName) pathForResource:language ofType:@"lproj"]];
        if (bundle) {        
            [bundleCache setObject:bundle forKey:cacheKey];
        }
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    
    // It's not necessary to query at main bundle, cause it's a long-time operation
    // NSString *resultStr = [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
    return value;

}

+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(nonnull NSString *)bundleName
{
    return [self g_localizedStringForKey:key value:nil bundle:bundleName];
}

+ (NSString *)tk_localizableLanguageKey
{
    // Custom language in app
    NSString *customLanguage = [self getCustomLanguage];
    if (customLanguage.length) {
        return customLanguage;
    }
    
    // Follow system changes by default
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            language = @"zh-Hans"; // Simplified Chinese
        } else { // zh-Hant\zh-HK\zh-TW
            language = @"zh-Hant"; // Traditional Chinese
        }
    } else if ([language hasPrefix:@"ko"]) {
        language = @"ko";
    } else if ([language hasPrefix:@"ru"]) {
        language = @"ru";
    } else if ([language hasPrefix:@"uk"]) {
        language = @"uk";
    } else {
        language = @"en";
    }
    
    // harvy, since traditional Chinese is not supported for the time being, avoid using English in traditional Chinese, and force the use of simplified Chinese here
    if ([language hasPrefix:@"zh"]) {
        language = @"zh-Hans";
    }
    
    return language;
}

static NSString *_customLanguage;
+ (void)setCustomLanguage:(NSString *)language
{
    _customLanguage = language;
    [NSUserDefaults.standardUserDefaults setObject:language?:@"" forKey:TUICustomLanguageKey];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:TUIChangeLanguageNotification object:nil];
    });
}

+ (NSString *)getCustomLanguage
{
    if (_customLanguage == nil) {
        _customLanguage = [NSUserDefaults.standardUserDefaults objectForKey:TUICustomLanguageKey];
    }
    return _customLanguage;
}

@end



@interface TUIBundle : NSBundle

@end

@implementation TUIBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    if ([TUIBundle private_mainBundle]) {
        return [[TUIBundle private_mainBundle] localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

+ (NSBundle *)private_mainBundle
{
    static NSMutableDictionary *bundleCache;
    if (bundleCache == nil) {
        bundleCache = [NSMutableDictionary dictionary];
    }
    NSString *customLanguage = [TUIGlobalization tk_localizableLanguageKey];
    if (customLanguage.length) {
        NSString *path = [[NSBundle mainBundle] pathForResource:customLanguage ofType:@"lproj"] ?: @"";
        NSBundle *bundle = [bundleCache objectForKey:path];
        if (bundle == nil) {
            bundle = [NSBundle bundleWithPath:path];
            if (bundle) {
                [bundleCache setObject:bundle forKey:path];
            }
        }
        return bundle;
    }
    return nil;
}

@end

@interface NSBundle (Localization)

@end

@implementation NSBundle (Localization)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [TUIBundle class]);
    });
}

@end

