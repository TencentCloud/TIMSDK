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
        _avatarCornerRadius = 6.f;
        _defaultAvatarImage = [UIImage tk_imageNamed:@"default_head"];
        _defaultGroupAvatarImage = [UIImage tk_imageNamed:@"default_group"];
        
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

- (void)defaultFace
{
    NSMutableArray *faceGroups = [NSMutableArray array];
    //emoji group
    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TUIKitFace.bundle/emoji/emoji" ofType:@"plist"]];
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
    
    //tt group
    NSMutableArray *ttFaces = [NSMutableArray array];
    for (int i = 0; i <= 16; i++) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"tt%02d", i];
        NSString *path = [NSString stringWithFormat:@"tt/%@", name];
        data.name = name;
        data.path = TUIKitFace(path);
        [self addFaceToCache:data.path];
        [ttFaces addObject:data];
    }
    if(ttFaces.count != 0){
        TFaceGroup *ttGroup = [[TFaceGroup alloc] init];
        ttGroup.groupIndex = 1;
        ttGroup.groupPath = TUIKitFace(@"tt/");
        ttGroup.faces = ttFaces;
        ttGroup.rowCount = 2;
        ttGroup.itemCountPerRow = 5;
        ttGroup.menuPath = TUIKitFace(@"tt/menu");
        [self addFaceToCache:ttGroup.menuPath];
        [faceGroups addObject:ttGroup];
    }
    
    _faceGroups = faceGroups;
}





#pragma mark - resource
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
