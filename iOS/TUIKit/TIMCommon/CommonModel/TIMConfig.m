//
//  TIMConfig.m
//  Pods
//
//  Created by cologne on 2023/3/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TIMConfig.h"
#import "TIMCommonMediator.h"
#import "TUIEmojiMeditorProtocol.h"
#define kTUIKitFirstInitAppStyleID @"Classic";  // Classic / Minimalist

typedef NS_OPTIONS(NSInteger, emojiFaceType) {
    emojiFaceTypeKeyBoard = 1 << 0,
    emojiFaceTypePopDetail = 1 << 1,
};

@interface TIMConfig ()

@end

@implementation TIMConfig

+ (void)load {
    TUIRegisterThemeResourcePath(TIMCommonThemePath, TUIThemeModuleTIMCommon);
}

- (id)init {
    self = [super init];
    if (self) {
        self.enableMessageBubble = YES;
    }
    return self;
}

+ (id)defaultConfig {
    static dispatch_once_t onceToken;
    static TIMConfig *config;
    dispatch_once(&onceToken, ^{
      config = [[TIMConfig alloc] init];
    });
    return config;
}

- (NSArray<TUIFaceGroup *> *)faceGroups {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    return [service getFaceGroup];
}

- (NSArray<TUIFaceGroup *> *)chatPopDetailGroups {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    return [service getChatPopDetailGroups];
}

+ (NSString *)getCurrentStyleSelectID {
    NSString *styleID = [[NSUserDefaults standardUserDefaults] objectForKey:@"StyleSelectkey"];
    if (IS_NOT_EMPTY_NSSTRING(styleID)) {
        return styleID;
    } else {
        // First Init
        NSString *initStyleID = kTUIKitFirstInitAppStyleID;
        [[NSUserDefaults standardUserDefaults] setValue:initStyleID forKey:@"StyleSelectkey"];
        [NSUserDefaults.standardUserDefaults synchronize];
        return initStyleID;
    }
}

+ (BOOL)isClassicEntrance {
    NSString *styleID = [self.class getCurrentStyleSelectID];
    if ([styleID isKindOfClass:NSString.class]) {
        if (styleID.length > 0) {
            if ([styleID isEqualToString:@"Classic"]) {
                return YES;
            }
        }
    }
    return NO;
}
@end
