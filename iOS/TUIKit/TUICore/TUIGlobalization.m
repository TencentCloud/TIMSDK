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
    NSString *language = [self tk_localizableLanguageKey];
    language = [@"Localizable" stringByAppendingPathComponent:language];
    NSBundle *bundle = [NSBundle bundleWithPath:[TUIKitLocalizable(bundleName) pathForResource:language ofType:@"lproj"]];
    value = [bundle localizedStringForKey:key value:value table:nil];
    NSString *resultStr = [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
    return resultStr;
}

+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(nonnull NSString *)bundleName
{
    return [self g_localizedStringForKey:key value:nil bundle:bundleName];
}

+ (NSString *)tk_localizableLanguageKey
{
    // 自定义
    NSString *customLanguage = [self getCustomLanguage];
    if (customLanguage.length) {
        return customLanguage;
    }
    
    // 默认跟随系统
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            language = @"zh-Hans"; // 简体中文
        } else { // zh-Hant\zh-HK\zh-TW
            language = @"zh-Hant"; // 繁體中文
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
    
    // harvy, 由于暂时不支持繁体，避免繁体中文也使用英文，此处强制使用简体中文
    if ([language hasPrefix:@"zh"]) {
        language = @"zh-Hans";
    }
    
    return language;
}

+ (void)setCustomLanguage:(NSString *)language
{
    [NSUserDefaults.standardUserDefaults setObject:language?:@"" forKey:TUICustomLanguageKey];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:TUIChangeLanguageNotification object:nil];
    });
}

+ (NSString *)getCustomLanguage
{
    return [NSUserDefaults.standardUserDefaults objectForKey:TUICustomLanguageKey];
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
    NSString *customLanguage = [TUIGlobalization tk_localizableLanguageKey];
    if (customLanguage.length) {
        NSString *path = [[NSBundle mainBundle] pathForResource:customLanguage ofType:@"lproj"];
        if (path.length) {
            return [NSBundle bundleWithPath:path];
        }
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
        //动态继承、交换，方法类似KVO，通过修改[NSBundle mainBundle]对象的isa指针，使其指向它的子类TUIBundle，这样便可以调用子类的方法；其实这里也可以使用method_swizzling来交换mainBundle的实现，来动态判断，可以同样实现。
        object_setClass([NSBundle mainBundle], [TUIBundle class]);
    });
}

@end

