//
//  TUIKitConfig.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIKitConfig.h"
#import "THeader.h"
#import "TUIFaceCell.h"
#import "TUIFaceView.h"
#import "TUIInputMoreCell.h"
#import "TUIImageCache.h"
#import "UIImage+TUIKIT.h"


@interface TUIKitConfig ()


//提前加载资源（全路径）


@end

@implementation TUIKitConfig

- (id)init
{
    self = [super init];
    if(self){
        _avatarCornerRadius = 5.f;
        _defaultAvatarImage = [UIImage tk_imageNamed:@"default_c2c_head"];
        _defaultGroupAvatarImage = [UIImage tk_imageNamed:@"default_group_head"];

        [self defaultResourceCache];
        [self defaultFace];
    }
    return self;
}

+ (id)defaultConfig
{
    static dispatch_once_t onceToken;
    static TUIKitConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIKitConfig alloc] init];
    });
    return config;
}

/**
 *  初始化默认表情，并将配默认表情写入本地缓存，方便下一次快速加载
 */
- (void)defaultFace
{
    NSMutableArray *faceGroups = [NSMutableArray array];
    //emoji group
    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIKitFace(@"emoji/emoji.plist")];
    for (NSDictionary *dic in emojis) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [dic objectForKey:@"face_name"];
        NSString *path = [NSString stringWithFormat:@"emoji/%@", name];
        data.name = name;
        data.path = TUIKitFace(path);
        [self addFaceToCache:data.path];
        [emojiFaces addObject:data];
    }
    if(emojiFaces.count != 0){
        TFaceGroup *emojiGroup = [[TFaceGroup alloc] init];
        emojiGroup.groupIndex = 0;
        emojiGroup.groupPath = TUIKitFace(@"emoji/");
        emojiGroup.faces = emojiFaces;
        emojiGroup.rowCount = 3;
        emojiGroup.itemCountPerRow = 9;
        emojiGroup.needBackDelete = YES;
        emojiGroup.menuPath = TUIKitFace(@"emoji/menu");
        [self addFaceToCache:emojiGroup.menuPath];
        [faceGroups addObject:emojiGroup];
        [self addFaceToCache:TUIKitFace(@"del_normal")];
    }

    //4350 group
    NSMutableArray *faces4350 = [NSMutableArray array];
    for (int i = 0; i <= 17; i++) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"yz%02d", i];
        NSString *path = [NSString stringWithFormat:@"4350/%@", name];
        data.name = name;
        data.path = TUIKitFace(path);
        [self addFaceToCache:data.path];
        [faces4350 addObject:data];
    }
    if(faces4350.count != 0){
        TFaceGroup *group4350 = [[TFaceGroup alloc] init];
        group4350.groupIndex = 1;
        group4350.groupPath = TUIKitFace(@"4350/");
        group4350.faces = faces4350;
        group4350.rowCount = 2;
        group4350.itemCountPerRow = 5;
        group4350.menuPath = TUIKitFace(@"4350/menu");
        [self addFaceToCache:group4350.menuPath];
        [faceGroups addObject:group4350];
    }

    //4351 group
    NSMutableArray *faces4351 = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"ys%02d", i];
        NSString *path = [NSString stringWithFormat:@"4351/%@", name];
        data.name = name;
        data.path = TUIKitFace(path);
        [self addFaceToCache:data.path];
        [faces4351 addObject:data];
    }
    if(faces4351.count != 0){
        TFaceGroup *group4351 = [[TFaceGroup alloc] init];
        group4351.groupIndex = 2;
        group4351.groupPath = TUIKitFace(@"4351/");
        group4351.faces = faces4351;
        group4351.rowCount = 2;
        group4351.itemCountPerRow = 5;
        group4351.menuPath = TUIKitFace(@"4351/menu");
        [self addFaceToCache:group4351.menuPath];
        [faceGroups addObject:group4351];
    }

    //4352 group
    NSMutableArray *faces4352 = [NSMutableArray array];
    for (int i = 0; i <= 16; i++) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"gcs%02d", i];
        NSString *path = [NSString stringWithFormat:@"4352/%@", name];
        data.name = name;
        data.path = TUIKitFace(path);
        [self addFaceToCache:data.path];
        [faces4352 addObject:data];
    }
    if(faces4352.count != 0){
        TFaceGroup *group4352 = [[TFaceGroup alloc] init];
        group4352.groupIndex = 3;
        group4352.groupPath = TUIKitFace(@"4352/");
        group4352.faces = faces4352;
        group4352.rowCount = 2;
        group4352.itemCountPerRow = 5;
        group4352.menuPath = TUIKitFace(@"4352/menu");
        [self addFaceToCache:group4352.menuPath];
        [faceGroups addObject:group4352];
    }

    _faceGroups = faceGroups;
}





#pragma mark - resource
/**
 *  将配默认配置写入本地缓存，方便下一次快速加载
 */
- (void)defaultResourceCache
{
    //common
    [self addResourceToCache:TUIKitResource(@"more_normal")];
    [self addResourceToCache:TUIKitResource(@"more_pressed")];
    [self addResourceToCache:TUIKitResource(@"face_normal")];
    [self addResourceToCache:TUIKitResource(@"face_pressed")];
    [self addResourceToCache:TUIKitResource(@"keyboard_normal")];
    [self addResourceToCache:TUIKitResource(@"keyboard_pressed")];
    [self addResourceToCache:TUIKitResource(@"voice_normal")];
    [self addResourceToCache:TUIKitResource(@"voice_pressed")];
    //text msg
    [self addResourceToCache:TUIKitResource(@"sender_text_normal")];
    [self addResourceToCache:TUIKitResource(@"sender_text_pressed")];
    [self addResourceToCache:TUIKitResource(@"receiver_text_normal")];
    [self addResourceToCache:TUIKitResource(@"receiver_text_pressed")];
    //void msg
    [self addResourceToCache:TUIKitResource(@"sender_voice")];
    [self addResourceToCache:TUIKitResource(@"receiver_voice")];
    [self addResourceToCache:TUIKitResource(@"sender_voice_play_1")];
    [self addResourceToCache:TUIKitResource(@"sender_voice_play_2")];
    [self addResourceToCache:TUIKitResource(@"sender_voice_play_3")];
    [self addResourceToCache:TUIKitResource(@"receiver_voice_play_1")];
    [self addResourceToCache:TUIKitResource(@"receiver_voice_play_2")];
    [self addResourceToCache:TUIKitResource(@"receiver_voice_play_3")];
    //file msg
    [self addResourceToCache:TUIKitResource(@"msg_file")];
    //video msg
    [self addResourceToCache:TUIKitResource(@"play_normal")];
}


- (void)addResourceToCache:(NSString *)path
{
    [[TUIImageCache sharedInstance] addResourceToCache:path];
}


- (void)addFaceToCache:(NSString *)path
{
    [[TUIImageCache sharedInstance] addFaceToCache:path];
}


@end
