//
//  TUIVoiceToText.m
//  TUIVoiceToText
//
//  Created by xia on 2023/8/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVoiceToTextConfig.h"

static NSString *const kVoiceToTextTargetLanguageCode = @"voice_to_text_target_language_code";

@interface TUIVoiceToTextConfig ()
@property(nonatomic, copy, readwrite) NSString *targetLanguageName;
@end

@implementation TUIVoiceToTextConfig

+ (TUIVoiceToTextConfig *)defaultConfig {
    static dispatch_once_t onceToken;
    static TUIVoiceToTextConfig *config;
    dispatch_once(&onceToken, ^{
      config = [[TUIVoiceToTextConfig alloc] init];
    });
    return config;
}

- (id)init {
    self = [super init];
    if (self) {
        [self loadSavedLanguage];
    }
    return self;
}

- (void)setTargetLanguageCode:(NSString *)targetLanguageCode {
    if (targetLanguageCode.length == 0 || ![targetLanguageCode isKindOfClass:NSString.class]) {
        return;
    }
    if (_targetLanguageCode == targetLanguageCode) {
        return;
    }
    _targetLanguageCode = targetLanguageCode;
    _targetLanguageName = self.languageDict[self.targetLanguageCode];
    [[NSUserDefaults standardUserDefaults] setObject:targetLanguageCode forKey:kVoiceToTextTargetLanguageCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadSavedLanguage {
    NSString *lang = [[NSUserDefaults standardUserDefaults] stringForKey:kVoiceToTextTargetLanguageCode];
    if (lang.length == 0) {
        [self setTargetLanguageCode:[self defalutTargetLanguageCode]];
        self.targetLanguageName = self.languageDict[self.targetLanguageCode];
    } else {
        self.targetLanguageCode = lang;
    }
}

- (NSString *)defalutTargetLanguageCode {
    NSString *target = nil;
    NSString *currentAppLanguage = [TUIGlobalization getPreferredLanguage];
    if ([currentAppLanguage isEqualToString:@"zh-Hans"] || [currentAppLanguage isEqualToString:@"zh-Hant"]) {
        target = @"zh";
    } else {
        target = @"en";
    }
    return target;
}

- (NSDictionary *)languageDict {
    return @{
        @"zh" : @"简体中文",
        @"zh-TW" : @"繁體中文",
        @"en" : @"English",
        @"ja" : @"日本語",
        @"ko" : @"한국어",
        @"fr" : @"Français",
        @"es" : @"Español",
        @"it" : @"Italiano",
        @"de" : @"Deutsch",
        @"tr" : @"Türkçe",
        @"ru" : @"Русский",
        @"pt" : @"Português",
        @"vi" : @"Tiếng Việt",
        @"id" : @"Bahasa Indonesia",
        @"th" : @"ภาษาไทย",
        @"ms" : @"Bahasa Melayu",
        @"hi" : @"हिन्दी"
    };
}

@end
