//
//  NSBundle+TUIKIT.h
//  Pods
//
//  Created by harvy on 2020/10/9.
//

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

// TUIKit 字符串国际化
#define TUIKitLocalizableString(key) [TUIGlobalization g_localizedStringForKey:@""#key"" bundle:TUIKitLocalizableBundle]

@interface TUIGlobalization:NSObject

// 字符串国际化，bundle 的格式参考 TUIKitLocalizable.bundle
+ (NSString *)g_localizedStringForKey:(NSString *)key bundle:(NSString *)bundleName;

@end

