//
//  TUIContactService_Minimalist.m
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactService_Minimalist.h"

@implementation TUIContactService_Minimalist

+ (void)load {
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUIContactTheme_Minimalist", TUIContactBundle_Key_Class), TUIThemeModuleContact_Minimalist);
}

+ (TUIContactService_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIContactService_Minimalist *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIContactService_Minimalist alloc] init];
    });
    return g_sharedInstance;
}

@end
