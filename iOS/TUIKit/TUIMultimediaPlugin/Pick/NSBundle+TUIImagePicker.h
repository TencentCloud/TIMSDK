//
//  NSBundle+TUIImagePicker.h
//  NSBundle+TUIImagePicker
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface NSBundle (TUIImagePicker)

+ (NSBundle *)tz_imagePickerBundle;

+ (NSString *)tui_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)tui_localizedStringForKey:(NSString *)key;

@end

