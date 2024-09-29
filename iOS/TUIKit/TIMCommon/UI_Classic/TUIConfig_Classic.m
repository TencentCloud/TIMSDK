//
//  TUIConfig_Classic.m
//  TIMCommon
//
//  Created by Tencent on 2024/7/16.
//  Copyright © 2024 Tencent. All rights reserved.

#import "TUIConfig_Classic.h"
#import <TUICore/TUIConfig.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIConfig_Classic

+ (void)enableToast:(BOOL)enable {
    [TUIConfig defaultConfig].enableToast = enable;
}

+ (void)switchLanguageToTarget:(NSString *)targetLanguage {
    [TUIGlobalization setPreferredLanguage:targetLanguage];
}

+ (void)switchThemeToTarget:(NSString *)targetTheme {
    [TUIThemeManager.shareManager applyTheme:targetTheme forModule:TUIThemeModuleAll];
}

@end
