// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaCommon.h"
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaPersistence.h"

static NSString *const BundleResourceUrlPrefix = @"file:///asset/";

@implementation TUIMultimediaCommon

@dynamic bundle;

+ (NSBundle *)bundle {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"TUIMultimedia" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:url];
}

+ (NSBundle *)localizableBundle {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"TUIMultimediaLocalizable" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:url];
}

+ (UIImage *)bundleImageByName:(NSString *)name {
    return [UIImage imageNamed:name inBundle:self.bundle compatibleWithTraitCollection:nil];
}

+ (UIImage *)bundleRawImageByName:(NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self bundle].resourcePath, name];
    return [UIImage imageWithContentsOfFile:path];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSString *lang = [TUIGlobalization getPreferredLanguage];
    NSString *path = [self.localizableBundle pathForResource:lang ofType:@"lproj"];
    if (path == nil) {
        path = [self.localizableBundle pathForResource:@"en" ofType:@"lproj"];
    }
    NSBundle *langBundle = [NSBundle bundleWithPath:path];
    return [langBundle localizedStringForKey:key value:nil table:nil];
}

+ (UIColor *)colorFromHex:(NSString *)hex {
    return [UIColor tui_colorWithHex:hex];
}

+ (NSArray<NSString *> *)sortedBundleResourcesIn:(NSString *)directory withExtension:(NSString *)ext {
    NSArray<NSString *> *res = [TUIMultimediaCommon.bundle pathsForResourcesOfType:ext inDirectory:directory];
    NSString *basePath = TUIMultimediaCommon.bundle.resourcePath;
    res = [res tui_multimedia_map:^NSString *(NSString *path) {
      return [path substringFromIndex:basePath.length + 1];
    }];
    return [res sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
      return [a compare:b];
    }];
}

+ (NSURL *)getURLByResourcePath:(NSString *)path {
    if (path == nil) {
        return nil;
    }
    if (![path startsWith:BundleResourceUrlPrefix]) {
        NSURL *url = [NSURL URLWithString:path];
        if (url.scheme == nil) {
            return [NSURL fileURLWithPath:path];
        }
        return url;
    }
    NSURL *bundleUrl = [[self bundle] resourceURL];
    NSURL *url = [[NSURL alloc] initWithString:[path substringFromIndex:BundleResourceUrlPrefix.length] relativeToURL:bundleUrl];
    return url;
}
@end
