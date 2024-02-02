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
@end
