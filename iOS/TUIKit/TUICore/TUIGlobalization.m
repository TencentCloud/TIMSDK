//
//  NSBundle+TUIKIT.m
//  Pods
//
//  Created by harvy on 2020/10/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGlobalization.h"
#import <objc/runtime.h>
#import "TUIDefine.h"

@implementation TUIGlobalization

+ (void)load {
    NSString *language = [TUIGlobalization getPreferredLanguage];
    if([language hasPrefix:@"ar"]) {
        [TUIGlobalization setRTLOption:YES];
    }
    else {
        [TUIGlobalization setRTLOption:NO];
    }
}

static NSString *gCustomLanguage = nil;
static BOOL gIgnoreTraditionChinese = YES;
static BOOL gRTLOption = NO;

+ (NSString *)getLocalizedStringForKey:(NSString *)key bundle:(NSString *)bundleName {
    return [self getLocalizedStringForKey:key value:nil bundle:bundleName];
}

+ (NSString *)getLocalizedStringForKey:(NSString *)key value:(nullable NSString *)value bundle:(nonnull NSString *)bundleName {
    static NSMutableDictionary *bundleCache = nil;
    if (bundleCache == nil) {
        bundleCache = [NSMutableDictionary dictionary];
    }
    NSString *language = [self getPreferredLanguage];
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
    return value ?: @"";
}

+ (NSString *)getPreferredLanguage {
    // Custom language in app
    if (gCustomLanguage == nil) {
        gCustomLanguage = [NSUserDefaults.standardUserDefaults objectForKey:TUICustomLanguageKey];
    }
    if (gCustomLanguage.length > 0) {
        return gCustomLanguage;
    }

    // Follow system changes by default
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            language = @"zh-Hans";  // Simplified Chinese
        } else {                    // zh-Hant\zh-HK\zh-TW
            language = @"zh-Hant";  // Traditional Chinese
        }
    } else if ([language hasPrefix:@"ko"]) {
        language = @"ko";
    } else if ([language hasPrefix:@"ru"]) {
        language = @"ru";
    } else if ([language hasPrefix:@"uk"]) {
        language = @"uk";
    } else if ([language hasPrefix:@"ar"]) {
        language = @"ar";
    }else if ([language hasPrefix:@"ja"]) {
        language = @"ja";
    }
    else {
        language = @"en";
    }

    // Since traditional Chinese is not supported for the time being, avoid using English in traditional Chinese, and force the use of simplified Chinese here
    if (gIgnoreTraditionChinese && [language hasPrefix:@"zh"]) {
        language = @"zh-Hans";
    }

    return language;
}

+ (void)setPreferredLanguage:(NSString *)language {
    gCustomLanguage = language;
    [NSUserDefaults.standardUserDefaults setObject:language ?: @"" forKey:TUICustomLanguageKey];
    [NSUserDefaults.standardUserDefaults synchronize];

    dispatch_async(dispatch_get_main_queue(), ^{
      [NSNotificationCenter.defaultCenter postNotificationName:TUIChangeLanguageNotification object:nil];
    });
}

+ (void)ignoreTraditionChinese:(BOOL)ignore {
    gIgnoreTraditionChinese = ignore;
}

+ (void)setRTLOption:(BOOL)op {
    gRTLOption = op;
    [UIView appearance].semanticContentAttribute =  op?UISemanticContentAttributeForceRightToLeft:UISemanticContentAttributeForceLeftToRight;
    [UISearchBar appearance].semanticContentAttribute = op?UISemanticContentAttributeForceRightToLeft:UISemanticContentAttributeForceLeftToRight;
    [UICollectionView appearance].semanticContentAttribute = op?UISemanticContentAttributeForceRightToLeft:UISemanticContentAttributeForceLeftToRight;
    [UISwitch appearance].semanticContentAttribute = op?UISemanticContentAttributeForceRightToLeft:UISemanticContentAttributeForceLeftToRight;
    
    [NSUserDefaults.standardUserDefaults setBool:op forKey:TUIKitGlobalizationRTLOptionKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)getRTLOption {
    return gRTLOption;
}

#pragma mark - Deprecated
+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(nonnull NSString *)bundleName {
    return [self getLocalizedStringForKey:key value:nil bundle:bundleName];
}

+ (NSString *)tk_localizableLanguageKey {
    return [self getPreferredLanguage];
}

@end

@interface TUIBundle : NSBundle

@end

@implementation TUIBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    if ([TUIBundle private_mainBundle]) {
        return [[TUIBundle private_mainBundle] localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

+ (NSBundle *)private_mainBundle {
    static NSMutableDictionary *bundleCache;
    if (bundleCache == nil) {
        bundleCache = [NSMutableDictionary dictionary];
    }
    NSString *customLanguage = [TUIGlobalization getPreferredLanguage];
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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      object_setClass([NSBundle mainBundle], [TUIBundle class]);
    });
}

@end
