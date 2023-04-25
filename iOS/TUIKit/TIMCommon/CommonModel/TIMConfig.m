//
//  TIMConfig.m
//  Pods
//
//  Created by cologne on 2023/3/14.
//

#import "TIMConfig.h"

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

- (id)init
{
    self = [super init];
    if(self){
        [self updateEmojiGroups];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeTheme) name:TUIDidApplyingThemeChangedNotfication object:nil];
    }
    return self;
}

+ (id)defaultConfig
{
    static dispatch_once_t onceToken;
    static TIMConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TIMConfig alloc] init];
    });
    return config;
}
- (void)onChangeLanguage
{
    [self updateEmojiGroups];
}

- (void)updateEmojiGroups {
    self.faceGroups = [self updateFaceGroups:self.faceGroups type:emojiFaceTypeKeyBoard];
    self.chatPopDetailGroups = [self updateFaceGroups:self.chatPopDetailGroups type:emojiFaceTypePopDetail];
}

- (void)appendFaceGroup:(TUIFaceGroup *)faceGroup {
    NSMutableArray *faceGroupMenu = [NSMutableArray arrayWithArray:self.faceGroups];
    [faceGroupMenu addObject:faceGroup];
    self.faceGroups = faceGroupMenu;
}

- (NSArray *)updateFaceGroups:(NSArray *)groups type:(emojiFaceType)type {
    
    if (groups.count) {
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:groups];
        [arrayM removeObjectAtIndex:0];
        
        TUIFaceGroup *defaultFaceGroup = [self findFaceGroupAboutType:type];
        if (defaultFaceGroup) {
            [arrayM insertObject:[self findFaceGroupAboutType:type] atIndex:0];
        }
        return  [NSArray arrayWithArray:arrayM];
    }
    else {
        NSMutableArray *faceArray = [NSMutableArray array];
        TUIFaceGroup *defaultFaceGroup = [self findFaceGroupAboutType:type];
        if (defaultFaceGroup) {
            [faceArray addObject:defaultFaceGroup];
        }
        return faceArray;
    }
    return @[];
}
- (TUIFaceGroup *)findFaceGroupAboutType:(emojiFaceType)type {
    //emoji group

    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIChatFaceImagePath(@"emoji/emoji.plist")];
    for (NSDictionary *dic in emojis) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [dic objectForKey:@"face_name"];
        NSString *path = [NSString stringWithFormat:@"emoji/%@", name];
        NSString *localizableName = [TUIGlobalization g_localizedStringForKey:name bundle:@"TUIChatFace"];
        data.name = name;
        data.path = TUIChatFaceImagePath(path);
        data.localizableName = localizableName;
        [self addFaceToCache:data.path];
        [emojiFaces addObject:data];
    }
    if(emojiFaces.count != 0){
        TUIFaceGroup *emojiGroup = [[TUIFaceGroup alloc] init];
        emojiGroup.faces = emojiFaces;
        emojiGroup.groupIndex = 0;
        emojiGroup.groupPath = TUIChatFaceImagePath(@"emoji/");
        emojiGroup.menuPath = TUIChatFaceImagePath(@"emoji/menu");
        if(type == emojiFaceTypeKeyBoard) {
            emojiGroup.rowCount = 3;
            emojiGroup.itemCountPerRow = 9;
            emojiGroup.needBackDelete = YES;
        }
        else  {
            emojiGroup.rowCount = 3;
            emojiGroup.itemCountPerRow = 8;
            emojiGroup.needBackDelete = NO;
        }

        [self addFaceToCache:emojiGroup.menuPath];
        [self addFaceToCache:TUIChatFaceImagePath(@"del_normal")];
        [self addFaceToCache:TUIChatFaceImagePath(@"ic_unknown_image")];
        return emojiGroup;
    }
    
    return nil;
}

- (void)onChangeTheme
{

}

- (TUIFaceGroup *)getDefaultFaceGroup
{
    //emoji group
    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIChatFaceImagePath(@"emoji/emoji.plist")];
    for (NSDictionary *dic in emojis) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [dic objectForKey:@"face_name"];
        NSString *path = [NSString stringWithFormat:@"emoji/%@", name];
        NSString *localizableName = [TUIGlobalization g_localizedStringForKey:name bundle:@"TUIChatFace"];
        data.name = name;
        data.path = TUIChatFaceImagePath(path);
        data.localizableName = localizableName;
        [self addFaceToCache:data.path];
        [emojiFaces addObject:data];
    }
    if(emojiFaces.count != 0){
        TUIFaceGroup *emojiGroup = [[TUIFaceGroup alloc] init];
        emojiGroup.groupIndex = 0;
        emojiGroup.groupPath = TUIChatFaceImagePath(@"emoji/");
        emojiGroup.faces = emojiFaces;
        emojiGroup.rowCount = 3;
        emojiGroup.itemCountPerRow = 9;
        emojiGroup.needBackDelete = YES;
        emojiGroup.menuPath = TUIChatFaceImagePath(@"emoji/menu");
        [self addFaceToCache:emojiGroup.menuPath];
        [self addFaceToCache:TUIChatFaceImagePath(@"del_normal")];
        [self addFaceToCache:TUIChatFaceImagePath(@"ic_unknown_image")];
        return emojiGroup;
    }
    
    return nil;
}

#pragma mark - resource

- (void)addResourceToCache:(NSString *)path
{
    [[TUIImageCache sharedInstance] addResourceToCache:path];
}


- (void)addFaceToCache:(NSString *)path
{
    [[TUIImageCache sharedInstance] addFaceToCache:path];
}

@end
