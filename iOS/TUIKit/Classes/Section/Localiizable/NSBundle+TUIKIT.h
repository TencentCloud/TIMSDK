//
//  NSBundle+TUIKIT.h
//  Pods
//
//  Created by harvy on 2020/10/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define TUILocalizableString(key) [NSBundle tk_localizedStringForKey:@""#key""]

@interface NSBundle (TUIKIT)

+ (NSString *)tk_localizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)tk_localizedStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
