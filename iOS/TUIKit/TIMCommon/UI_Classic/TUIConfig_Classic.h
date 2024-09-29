//
//  TUIConfig_Classic.h
//  TIMCommon
//
//  Created by Tencent on 2024/7/16.
//  Copyright © 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface TUIConfig_Classic : NSObject
/**
 *  Show the toast prompt built in TUIKit.
 *  The default value is YES.
 */
+ (void)enableToast:(BOOL)enable;

/**
 * Switch the language of TUIKit. 
 * The currently supported languages are "en", "zh-Hans", and "ar".
 */
+ (void)switchLanguageToTarget:(NSString *)targetLanguage;

/**
 * Switch the theme of TUIKit.
 * The currently supported languages are "system", "serious", "light", "lively", "dark"
 */
+ (void)switchThemeToTarget:(NSString *)targetTheme;

@end


NS_ASSUME_NONNULL_END
