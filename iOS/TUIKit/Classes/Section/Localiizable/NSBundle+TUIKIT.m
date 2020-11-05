//
//  NSBundle+TUIKIT.m
//  Pods
//
//  Created by harvy on 2020/10/9.
//

#import "NSBundle+TUIKIT.h"
#import "TUIKitConfig.h"

@implementation NSBundle (TUIKIT)

+ (instancetype)tk_tuikitBundle
{
    static NSBundle *refreshBundle = nil;
    if (refreshBundle == nil) {
        refreshBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[TUIKitConfig class]] pathForResource:@"TUIKitLocalizable" ofType:@"bundle"]];
    }
    return refreshBundle;
}

+ (NSString *)tk_localizedStringForKey:(NSString *)key value:(nullable NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // 默认跟随系统
        // todo: 外部可配置
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
        
        // 从MJRefresh.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle tk_tuikitBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

+ (NSString *)tk_localizedStringForKey:(NSString *)key
{
    return [self tk_localizedStringForKey:key value:nil];
}


@end
