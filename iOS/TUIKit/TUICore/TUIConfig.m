//
//  TUIConfig.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIConfig.h"
#import "TUIDefine.h"
#import "TUICommonModel.h"
#import "TUILogin.h"
#import "TUIThemeManager.h"
typedef NS_OPTIONS(NSInteger, emojiFaceType) {
    emojiFaceTypeKeyBoard = 1 << 0,
    emojiFaceTypePopDetail = 1 << 1,
};
@interface TUIConfig ()


//提前加载资源（全路径）


@end

@implementation TUIConfig

- (id)init
{
    self = [super init];
    if(self){
        _avatarCornerRadius = 5.f;
        _defaultAvatarImage = TUICoreBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head");
        _defaultGroupAvatarImage = TUICoreBundleThemeImage(@"default_group_head_img", @"default_group_head");
        _isExcludedFromUnreadCount = NO;
        _isExcludedFromLastMessage = NO;
        _enableToast = YES;
        _displayOnlineStatusIcon = NO;
        
        [self updateEmojiGroups];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeTheme) name:TUIDidApplyingThemeChangedNotfication object:nil];
    }
    return self;
}

+ (id)defaultConfig
{
    static dispatch_once_t onceToken;
    static TUIConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIConfig alloc] init];
    });
    return config;
}

- (void)onChangeLanguage
{
    [self updateEmojiGroups];
}

- (void)updateEmojiGroups {
    // 更新表情面板
    self.faceGroups = [self updateFaceGroups:self.faceGroups type:emojiFaceTypeKeyBoard];
    self.chatPopDetailGroups = [self updateFaceGroups:self.chatPopDetailGroups type:emojiFaceTypePopDetail];
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
        return emojiGroup;
    }
    
    return nil;
}

- (void)onChangeTheme
{
    // 更新默认头像
    self.defaultAvatarImage = TUICoreBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head");
    self.defaultGroupAvatarImage = TUICoreBundleThemeImage(@"default_group_head_img", @"default_group_head");
}

/**
 *  初始化默认表情，并将配默认表情写入本地缓存，方便下一次快速加载
 */
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

#pragma mark - Sence
- (void)setSceneOptimizParams:(NSString *)path
{
    
    NSURL *url = [NSURL URLWithString:@"https://demos.trtc.tencent-cloud.com/prod/base/v1/events/stat"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    NSDictionary *msgData = @{@"sdkappid":@([TUILogin getSdkAppID]),
                              @"bundleId":NSBundle.mainBundle.bundleIdentifier ?: @"",
                              @"package":@"",
                              @"component":path
    };
    NSDictionary *param = @{@"userid":[TUILogin getUserID],
                            @"event":@"useScenario",
                            @"msg":msgData
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    if (!data) {
        return;
    }
    req.HTTPBody = data;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"api-key" : @"API_KEY", @"Content-Type" : @"application/json"};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    [[session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            long code = [dic[@"errorCode"] longValue];
            if (code == 0) {
                NSLog(@"scene param [%@] success", path);
            }
            else {
                NSString *msg = dic[@"errorMessage"];
                NSLog(@"scene param [%@] failed: [%ld] %@", path, code, msg);
            }
        }
        else {
            NSLog(@"scene param [%@] error: res data nil", path);
        }
    }] resume];
}
@end
