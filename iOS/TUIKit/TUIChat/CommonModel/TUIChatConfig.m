//
//  TUIChatConfig.m
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//

#import "TUIChatConfig.h"
#import <TIMCommon/TIMDefine.h>

@implementation TUIChatConfig

- (id)init
{
    self = [super init];
    if(self){
        self.msgNeedReadReceipt = NO;
        self.enableVideoCall = YES;
        self.enableAudioCall = YES;
        self.enableWelcomeCustomMessage = YES;
        self.enablePopMenuEmojiReactAction = YES;
        self.enablePopMenuReplyAction = YES;
        self.enablePopMenuReferenceAction = YES;
        self.enableTypingStatus = YES;
        self.enableFloatWindowForCall = YES;
        self.enableMultiDeviceForCall = NO;
        self.timeIntervalForMessageRecall = 120;
        
        [self updateEmojiGroups];
    }
    return self;
}

+ (TUIChatConfig *)defaultConfig {
    static dispatch_once_t onceToken;
    static TUIChatConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIChatConfig alloc] init];
    });
    return config;
}


- (void)onChangeLanguage
{
    [self updateEmojiGroups];
}

- (void)updateEmojiGroups {
    self.chatContextEmojiDetailGroups = [self updateFaceGroups:self.chatContextEmojiDetailGroups];
}

- (NSArray *)updateFaceGroups:(NSArray *)groups {
    
    if (groups.count) {
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:groups];
        [arrayM removeObjectAtIndex:0];
        
        TUIFaceGroup *defaultFaceGroup = [self findFaceGroup];
        if (defaultFaceGroup) {
            [arrayM insertObject:[self findFaceGroup] atIndex:0];
        }
        return  [NSArray arrayWithArray:arrayM];
    }
    else {
        NSMutableArray *faceArray = [NSMutableArray array];
        TUIFaceGroup *defaultFaceGroup = [self findFaceGroup];
        if (defaultFaceGroup) {
            [faceArray addObject:defaultFaceGroup];
        }
        return faceArray;
    }
    return @[];
}
- (void)addFaceToCache:(NSString *)path
{
    [[TUIImageCache sharedInstance] addFaceToCache:path];
}
- (TUIFaceGroup *)findFaceGroup {
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
        emojiGroup.rowCount = 20;
        emojiGroup.itemCountPerRow = 7;
        emojiGroup.needBackDelete = NO;
        [self addFaceToCache:emojiGroup.menuPath];
        return emojiGroup;
    }
    
    return nil;
}


@end
