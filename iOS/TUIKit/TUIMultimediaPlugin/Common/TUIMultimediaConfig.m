// Copyright (c) 2024 Tencent. All rights reserved.
// Created by eddardliu on 2024/10/21.

#import <TUICore/UIColor+TUIHexColor.h>
#import <TUICore/TUIThemeManager.h>

#import "TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"

#define DEFAULT_CONFIG_FILE @"config/default_config"

@interface TUIMultimediaConfig() {
    NSDictionary * _jsonDicFromFile;
    NSDictionary * _jsonDicFromSetting;
}
@end

@implementation TUIMultimediaConfig

+ (instancetype)sharedInstance {
    static TUIMultimediaConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    NSData *jsonData = [NSData dataWithContentsOfFile:[TUIMultimediaCommon.bundle pathForResource:DEFAULT_CONFIG_FILE ofType:@"json"]];
    NSError *err = nil;
    _jsonDicFromFile = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err || ![_jsonDicFromFile isKindOfClass:[NSDictionary class]]) {
        NSLog(@"[TUIMultimedia] Json parse failed: %@", err);
        _jsonDicFromFile = nil;
    }
    return self;
}

- (void)setConfig:(NSString*)jsonString {
    _jsonDicFromFile = nil;
    if (jsonString == nil) {
        return;
    }
    
    NSError *err = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        _jsonDicFromFile = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if (err || ![_jsonDicFromFile isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[TUIMultimediaConfig setConfig]  Json parse failed: %@", err);
            _jsonDicFromFile = nil;
        }
    } else {
        NSLog(@"Error converting string to data");
    }
}

- (BOOL)isSupportRecordBeauty {
    return [self getBoolFromDic:@"support_record_beauty" defaultValue:YES];
}

- (BOOL)isSupportRecordAspect {
    return [self getBoolFromDic:@"support_record_aspect" defaultValue:YES];
}

- (BOOL)isSupportRecordTorch {
    return [self getBoolFromDic:@"support_record_torch" defaultValue:YES];
}

- (BOOL)isSupportRecordScrollFilter {
    return [self getBoolFromDic:@"support_record_scroll_filter" defaultValue:YES];
}

- (BOOL)isSupportVideoEditGraffiti {
    return [self getBoolFromDic:@"support_video_edit_graffiti" defaultValue:YES];
}

- (BOOL)isSupportVideoEditPaster {
    return [self getBoolFromDic:@"support_video_edit_paster" defaultValue:YES];
}

- (BOOL)isSupportVideoEditSubtitle {
    return [self getBoolFromDic:@"support_video_edit_subtitle" defaultValue:YES];
}

- (BOOL)isSupportVideoEditBGM {
    return [self getBoolFromDic:@"support_video_edit_bgm" defaultValue:YES];
}

- (UIColor *)getThemeColor {
   return TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
}

- (int)getVideoQuality {
    return [self getIntFromDic:@"video_quality" defaultValue:2];
}

- (int)getMaxRecordDurationMs {
    return [self getIntFromDic:@"max_record_duration_ms" defaultValue:15000];
}

- (int)getMinRecordDurationMs {
    return [self getIntFromDic:@"min_record_duration_ms" defaultValue:2000];
}

- (NSString *)getPicturePasterConfigFilePath {
    return [self getStringFromDic:@"picture_paster_config_file_path" defaultValue:@"config/picture_paster_data"];
}

- (NSString *)getBGMConfigFilePath {
    return [self getStringFromDic:@"bgm_config_file_path" defaultValue:@"config/bgm_data"];
}

-(BOOL) getBoolFromDic:(NSString*) dicKey defaultValue:(BOOL) defaultValue{
    if (_jsonDicFromSetting != nil) {
        return [_jsonDicFromSetting[dicKey] caseInsensitiveCompare:@"true"] == NSOrderedSame;
    }
    
    if (_jsonDicFromFile != nil) {
        return [_jsonDicFromFile[dicKey] caseInsensitiveCompare:@"true"] == NSOrderedSame;
    }
    return defaultValue;
}

-(int) getIntFromDic:(NSString*) dicKey defaultValue:(int) defaultValue{
    if (_jsonDicFromSetting != nil) {
        return [(NSNumber *)_jsonDicFromFile[dicKey] intValue];
    }
    
    if (_jsonDicFromFile != nil) {
        return [(NSNumber *)_jsonDicFromFile[dicKey] intValue];
    }
    return defaultValue;
}

-(NSString*) getStringFromDic:(NSString*) dicKey defaultValue:(NSString*) defaultValue{
    if (_jsonDicFromSetting != nil) {
        return _jsonDicFromSetting[dicKey];
    }
    
    if (_jsonDicFromFile != nil) {
        return _jsonDicFromFile[dicKey];
    }
    return defaultValue;
}

@end
