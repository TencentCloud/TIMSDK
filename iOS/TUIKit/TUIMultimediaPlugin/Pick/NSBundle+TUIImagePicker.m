//
//  NSBundle+TUIImagePicker.m
//  NSBundle+TUIImagePicker
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import "NSBundle+TUIImagePicker.h"
#import "TUIMultimediaNavController.h"

@implementation NSBundle (TUIImagePicker)

+ (NSBundle *)tz_imagePickerBundle {
#ifdef SWIFT_PACKAGE
    NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
#else
    NSBundle *bundle = [NSBundle bundleForClass:[TUIMultimediaNavController class]];
#endif
    NSURL *url = [bundle URLForResource:@"TUIMultimediaPicker" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)tui_localizedStringForKey:(NSString *)key {
    return [self tui_localizedStringForKey:key value:@""];
}

+ (NSString *)tui_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = [TUIImagePickerConfig sharedInstance].languageBundle;
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    return value1;
}

@end
