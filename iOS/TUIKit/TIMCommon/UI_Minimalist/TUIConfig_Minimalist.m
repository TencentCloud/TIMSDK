//
//  TUIConfig_Minimalist.m
//  TIMCommon
//
//  Created by Tencent on 2024/7/16.
//  Copyright © 2024 Tencent. All rights reserved.

#import "TUIConfig_Minimalist.h"
#import <TUICore/TUIConfig.h>
#import <TUICore/TUIGlobalization.h>

@implementation TUIConfig_Minimalist

+ (void)enableToast:(BOOL)enable {
    [TUIConfig defaultConfig].enableToast = enable;
}

+ (void)switchLanguageToTarget:(NSString *)targetLanguage {
    [TUIGlobalization setPreferredLanguage:targetLanguage];
}

@end
