// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaBGM.h"
#import <TUICore/NSDictionary+TUISafe.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"

@implementation TUIMultimediaBGM
- (instancetype)initWithName:(NSString *)name lyric:(NSString *)lyric source:(NSString *)source asset:(nullable AVAsset *)asset {
    self = [super init];
    _name = name;
    _lyric = lyric;
    _source = source;
    _asset = asset;
    _startTime = 0;
    _endTime = 0;
    if (asset != nil && asset.duration.timescale != 0) {
        _endTime = asset.duration.value / asset.duration.timescale;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    TUIMultimediaBGM *cp = [[[self class] allocWithZone:zone] init];
    cp->_name = _name;
    cp->_lyric = _lyric;
    cp->_source = _source;
    cp->_asset = _asset;
    cp->_startTime = _startTime;
    cp->_endTime = _endTime;
    return cp;
}
@end

@implementation TUIMultimediaBGMGroup

- (instancetype)initWithName:(NSString *)name bgmList:(NSArray<TUIMultimediaBGM *> *)bgmList {
    self = [super init];
    _name = name;
    _bgmList = bgmList;
    return self;
}

+ (TUIMultimediaBGMGroup *)loadGroupFromJsonDict:(NSDictionary *)dict {
    NSString *name = dict[@"bgm_type_name"];
    NSArray *jsonMusicList = dict[@"bgm_item_list"];
    NSMutableArray<TUIMultimediaBGM *> *bgmList = [NSMutableArray array];
    for (NSDictionary *music in jsonMusicList) {
        NSString *musicFile = music[@"item_bgm_path"];
        NSURL *url = [TUIMultimediaCommon getURLByResourcePath:musicFile];

        AVAsset *asset = [AVAsset assetWithURL:url];
        TUIMultimediaBGM *bgm = [[TUIMultimediaBGM alloc] initWithName:music[@"item_bgm_name"] lyric:@"" source:music[@"item_bgm_author"] asset:asset];
        double startTime = [(NSNumber *)music[@"item_start_time"] doubleValue];
        double endTime = [(NSNumber *)music[@"item_end_time"] doubleValue];
        if (startTime >= 0 && endTime > 0 && endTime > startTime) {
            bgm.startTime = MIN(bgm.endTime, startTime);
            bgm.endTime = MIN(bgm.endTime, endTime);
        }
        if (asset.duration.value != 0) {
            [bgmList addObject:bgm];
        }
    }
    return [[TUIMultimediaBGMGroup alloc] initWithName:name bgmList:bgmList];
}

+ (NSArray<TUIMultimediaBGMGroup *> *)loadBGMConfigs {
    NSData *jsonData = [NSData dataWithContentsOfFile:[TUIMultimediaCommon.bundle pathForResource:[[TUIMultimediaConfig sharedInstance] getBGMConfigFilePath] ofType:@"json"]];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"[TUIMultimedia] Json parse failed: %@", err);
        return nil;
    }

    NSMutableArray<TUIMultimediaBGMGroup *> *groupList = [NSMutableArray array];
    NSArray *jsonGroupList = dic[@"bgm_list"];
    for (NSDictionary *jsonGroup in jsonGroupList) {
        [groupList addObject:[self loadGroupFromJsonDict:jsonGroup]];
    }
    return groupList;
}

@end
