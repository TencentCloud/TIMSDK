//
//  TUIEmojiConfig.m
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIEmojiConfig.h"
typedef NS_ENUM(NSUInteger, TUIEmojiFaceType) {
    TUIEmojiFaceTypeKeyBoard = 0,
    TUIEmojiFaceTypePopDetail = 1,
    TUIEmojiFaceTypePopContextDetail = 2,
};

@interface TUIEmojiConfig ()

@end

@implementation TUIEmojiConfig

+ (void)load {
    NSLog(@"TUIEmojiConfig load%@",[TUIEmojiConfig defaultConfig]);
}

- (id)init {
    self = [super init];
    if (self) {
        [self updateEmojiGroups];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeTheme) name:TUIDidApplyingThemeChangedNotfication object:nil];
    }
    return self;
}

+ (id)defaultConfig {
    static dispatch_once_t onceToken;
    static TUIEmojiConfig *config;
    dispatch_once(&onceToken, ^{
      config = [[TUIEmojiConfig alloc] init];
    });
    return config;
}

- (void)appendFaceGroup:(TUIFaceGroup *)faceGroup {
    NSMutableArray *faceGroupMenu = [NSMutableArray arrayWithArray:self.faceGroups];
    [faceGroupMenu addObject:faceGroup];
    self.faceGroups = faceGroupMenu;
}

- (void)onChangeLanguage {
    [self updateEmojiGroups];
}

- (void)onChangeTheme { }

@end

@implementation TUIEmojiConfig (defaultFace)


- (void)updateEmojiGroups {
    self.faceGroups = [self updateFaceGroups:self.faceGroups type:TUIEmojiFaceTypeKeyBoard];
    self.chatPopDetailGroups = [self updateFaceGroups:self.chatPopDetailGroups type:TUIEmojiFaceTypePopDetail];
    self.chatContextEmojiDetailGroups = [self updateFaceGroups:self.chatContextEmojiDetailGroups type:TUIEmojiFaceTypePopContextDetail];
}


- (NSArray *)updateFaceGroups:(NSArray *)groups type:(TUIEmojiFaceType)type {
    if (groups.count) {
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:groups];
        [arrayM removeObjectAtIndex:0];

        TUIFaceGroup *defaultFaceGroup = [self findFaceGroupAboutType:type];
        if (defaultFaceGroup) {
            [arrayM insertObject:[self findFaceGroupAboutType:type] atIndex:0];
        }
        return [NSArray arrayWithArray:arrayM];
    } else {
        NSMutableArray *faceArray = [NSMutableArray array];
        TUIFaceGroup *defaultFaceGroup = [self findFaceGroupAboutType:type];
        if (defaultFaceGroup) {
            [faceArray addObject:defaultFaceGroup];
        }
        return faceArray;
    }
    return @[];
}
- (TUIFaceGroup *)findFaceGroupAboutType:(TUIEmojiFaceType)type {
    // emoji group

    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIChatFaceImagePath(@"emoji/emoji.plist")];
    for (NSDictionary *dic in emojis) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [dic objectForKey:@"face_name"];
        NSString *fileName = [dic objectForKey:@"face_file"];
        NSString *path = [NSString stringWithFormat:@"emoji/%@", fileName];
        NSString *localizableName = [TUIGlobalization getLocalizedStringForKey:name bundle:@"TUIChatFace"];
        data.name = name;
        data.path = TUIChatFaceImagePath(path);
        data.localizableName = localizableName;
        [self addFaceToCache:data.path];
        [emojiFaces addObject:data];
    }
    if (emojiFaces.count != 0) {
        TUIFaceGroup *emojiGroup = [[TUIFaceGroup alloc] init];
        emojiGroup.faces = emojiFaces;
        emojiGroup.groupIndex = 0;
        emojiGroup.groupPath = TUIChatFaceImagePath(@"emoji/");
        emojiGroup.menuPath = TUIChatFaceImagePath(@"emoji/menu");
        emojiGroup.isNeedAddInInputBar = YES;
        emojiGroup.groupName = TIMCommonLocalizableString(TUIChatFaceGroupAllEmojiName);
        if (type == TUIEmojiFaceTypeKeyBoard) {
            emojiGroup.rowCount = 4;
            emojiGroup.itemCountPerRow = 8;
            emojiGroup.needBackDelete = NO;
        } else if (type == TUIEmojiFaceTypePopDetail) {
            emojiGroup.rowCount = 3;
            emojiGroup.itemCountPerRow = 8;
            emojiGroup.needBackDelete = NO;
        }
        else if (type == TUIEmojiFaceTypePopContextDetail) {
            emojiGroup.rowCount = 20;
            emojiGroup.itemCountPerRow = 7;
            emojiGroup.needBackDelete = NO;
        }

        [self addFaceToCache:emojiGroup.menuPath];
        [self addFaceToCache:TUIChatFaceImagePath(@"del_normal")];
        [self addFaceToCache:TUIChatFaceImagePath(@"ic_unknown_image")];
        return emojiGroup;
    }

    return nil;
}

#pragma mark - chatPopMenuQueue
- (NSArray *)getChatPopMenuQueue {
    NSArray *emojis = [[NSUserDefaults standardUserDefaults] objectForKey:@"TUIChatPopMenuQueue"];
    if (emojis && [emojis isKindOfClass:[NSArray class]]) {
        if (emojis.count > 0) {
            //Randomly check whether an emoticon matches the current emoticon resource package
            //to avoid overwriting the installation context emoticon inconsistency.
            NSDictionary *dic = emojis.lastObject;
            NSString *name = [dic objectForKey:@"face_name"];
            NSString *fileName = [dic objectForKey:@"face_file"];
            NSString *path = [NSString stringWithFormat:@"emoji/%@", fileName];
            UIImage * image = [UIImage imageWithContentsOfFile:TUIChatFaceImagePath(path)];
            if (image) {
                return emojis;
            }
        }
    }
    return [NSArray arrayWithContentsOfFile:TUIChatFaceImagePath(@"emoji/emojiRecentDefaultList.plist")];
}

- (TUIFaceGroup *)getChatPopMenuRecentQueue {
    // emoji group
    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [self getChatPopMenuQueue];
    for (NSDictionary *dic in emojis) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [dic objectForKey:@"face_name"];
        NSString *fileName = [dic objectForKey:@"face_file"];
        NSString *path = [NSString stringWithFormat:@"emoji/%@", fileName];
        NSString *localizableName = [TUIGlobalization g_localizedStringForKey:name bundle:@"TUIChatFace"];
        data.name = name;
        data.path = TUIChatFaceImagePath(path);
        data.localizableName = localizableName;
        [emojiFaces addObject:data];
    }
    if (emojiFaces.count != 0) {
        TUIFaceGroup *emojiGroup = [[TUIFaceGroup alloc] init];
        emojiGroup.faces = emojiFaces;
        emojiGroup.groupIndex = 0;
        emojiGroup.groupPath = TUIChatFaceImagePath(@"emoji/");
        emojiGroup.menuPath = TUIChatFaceImagePath(@"emoji/menu");
        emojiGroup.rowCount = 1;
        emojiGroup.itemCountPerRow = 6;
        emojiGroup.needBackDelete = NO;
        emojiGroup.isNeedAddInInputBar = YES;
        return emojiGroup;
    }

    return nil;
}

- (void)updateRecentMenuQueue:(NSString *)faceName {
    NSArray *emojis = [self getChatPopMenuQueue];
    NSMutableArray *muArray = [NSMutableArray arrayWithArray:emojis];

    BOOL hasInQueue = NO;
    int index = 0;
    for (NSDictionary *dic in emojis) {
        NSString *name = [dic objectForKey:@"face_name"];
        if ([name isEqualToString:faceName]) {
            hasInQueue = YES;
            break;
        }
        index ++;
    }
    if (hasInQueue) {
        NSDictionary *targetDic = emojis[index];
        [muArray removeObjectAtIndex:index];
        [muArray insertObject:targetDic atIndex:0];
    }else {
        [muArray removeLastObject];
        NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIChatFaceImagePath(@"emoji/emoji.plist")];
        NSDictionary *targetDic = @{@"face_name" : faceName};
        for (NSDictionary *dic in emojis) {
            NSString *name = [dic objectForKey:@"face_name"];
            if ([name isEqualToString:faceName]) {
                targetDic = dic;
                break;
            }
        }
        [muArray insertObject:targetDic atIndex:0];
    }
    [[NSUserDefaults standardUserDefaults] setObject:muArray forKey:@"TUIChatPopMenuQueue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - resource

- (void)addResourceToCache:(NSString *)path {
    [[TUIImageCache sharedInstance] addResourceToCache:path];
}

- (void)addFaceToCache:(NSString *)path {
    [[TUIImageCache sharedInstance] addFaceToCache:path];
}
@end


