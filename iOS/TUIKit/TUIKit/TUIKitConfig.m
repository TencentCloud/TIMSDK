//
//  TUIKitConfig.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TUIKitConfig.h"
#import "THeader.h"
#import "THelper.h"
#import "TFaceCell.h"
#import "TFaceView.h"
#import "TMoreCell.h"

@interface TUIKitConfig ()
@property (nonatomic, strong) NSMutableDictionary *resourceCache;
@property (nonatomic, strong) NSMutableDictionary *faceCache;
@property (nonatomic, strong) dispatch_queue_t decodeResourceQueue;
@property (nonatomic, strong) dispatch_queue_t decodeFaceQueue;

@end

@implementation TUIKitConfig

- (id)init
{
    self = [super init];
    if(self){
        _decodeResourceQueue = dispatch_queue_create("tuikit.decoderesourcequeue", DISPATCH_QUEUE_SERIAL);
        _decodeFaceQueue = dispatch_queue_create("tuikit.decodefacequeue", DISPATCH_QUEUE_SERIAL);
        _resourceCache = [NSMutableDictionary dictionary];
        _faceCache = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (id)defaultConfig
{
    TUIKitConfig *config = [[TUIKitConfig alloc] init];
    if(config){
        config.msgCountPerRequest = 20;
        [config defaultResourceCache];
        [config defaultFace];
        [config defaultMore];
    }
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

- (void)defaultMore
{
    NSMutableArray *moreMenus = [NSMutableArray array];
    TMoreCellData *picture = [[TMoreCellData alloc] init];
    picture.title = @"相册";
    picture.path = TUIKitResource(@"more_picture");
    [moreMenus addObject:picture];

    TMoreCellData *camera = [[TMoreCellData alloc] init];
    camera.title = @"拍摄";
    camera.path = TUIKitResource(@"more_camera");
    [moreMenus addObject:camera];

    TMoreCellData *video = [[TMoreCellData alloc] init];
    video.title = @"视频";
    video.path = TUIKitResource(@"more_video");
    [moreMenus addObject:video];

    TMoreCellData *file = [[TMoreCellData alloc] init];
    file.title = @"文件";
    file.path = TUIKitResource(@"more_file");
    [moreMenus addObject:file];
    
    _moreMenus = moreMenus;
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
    __weak typeof(self) ws = self;
//    dispatch_async(_decodeResourceQueue, ^{
//        UIImage *image = [UIImage imageNamed:path];
//        [ws.resourceCache setValue:image forKey:path];
//    });
    
    [THelper asyncDecodeImage:path queue:_decodeResourceQueue complete:^(NSString *key, UIImage *image) {
        [ws.resourceCache setValue:image forKey:key];
    }];
}

- (UIImage *)getResourceFromCache:(NSString *)path
{
    if(path.length == 0){
        return nil;
    }
    UIImage *image = [_resourceCache objectForKey:path];
    if(!image){
        image = [UIImage imageNamed:path];
    }
    return image;
}
    
- (void)addFaceToCache:(NSString *)path
{
    __weak typeof(self) ws = self;
//    dispatch_async(_decodeFaceQueue, ^{
//        UIImage *image = [UIImage imageNamed:path];
//        [ws.faceCache setValue:image forKey:path];
//    });
    
    [THelper asyncDecodeImage:path queue:_decodeFaceQueue complete:^(NSString *key, UIImage *image) {
        [ws.faceCache setValue:image forKey:key];
    }];
}
        
- (UIImage *)getFaceFromCache:(NSString *)path
{
    if(path.length == 0){
        return nil;
    }
    UIImage *image = [_faceCache objectForKey:path];
    if(!image){
        image = [UIImage imageNamed:path];
    }
    return image;
}



@end
