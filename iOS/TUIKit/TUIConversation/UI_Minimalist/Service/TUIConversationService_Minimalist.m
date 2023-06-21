
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUIConversationService_Minimalist.h"
#import <TUICore/TUIThemeManager.h>

@implementation TUIConversationService_Minimalist

+ (void)load {
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUIConversationTheme_Minimalist", TUIConversationBundle_Key_Class), TUIThemeModuleConversation_Minimalist);
}

+ (TUIConversationService_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIConversationService_Minimalist *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIConversationService_Minimalist alloc] init];
    });
    return g_sharedInstance;
}

@end
