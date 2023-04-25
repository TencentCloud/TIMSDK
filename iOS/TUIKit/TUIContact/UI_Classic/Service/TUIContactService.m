//
//  TUIContactService.m
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//

#import "TUIContactService.h"

@implementation TUIContactService

+ (void)load {
    TUIRegisterThemeResourcePath(TUIContactThemePath, TUIThemeModuleContact);
}

+ (TUIContactService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIContactService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIContactService alloc] init];
    });
    return g_sharedInstance;
}

@end
