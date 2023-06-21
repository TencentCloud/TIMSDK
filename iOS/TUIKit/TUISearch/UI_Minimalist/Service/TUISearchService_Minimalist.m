
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUISearchService_Minimalist.h"
#import "TUISearchBar_Minimalist.h"

#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUISearchService_Minimalist

+ (void)load {
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUISearchTheme_Minimalist", TUISearchBundle_Key_Class), TUIThemeModuleSearch_Minimalist);
}

static id gShareInstance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      gShareInstance = [[self alloc] init];
    });
    return gShareInstance;
}

@end
