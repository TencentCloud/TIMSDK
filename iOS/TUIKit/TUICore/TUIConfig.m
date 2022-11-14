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

@property (nonatomic, strong) UIImage *defaultGroupAvatarImage_Public;
@property (nonatomic, strong) UIImage *defaultGroupAvatarImage_Meeting;
@property (nonatomic, strong) UIImage *defaultGroupAvatarImage_AVChatRoom;
@property (nonatomic, strong) UIImage *defaultGroupAvatarImage_Community;

@end

@implementation TUIConfig

- (id)init
{
    self = [super init];
    if(self){
        _avatarCornerRadius = 5.f;
        _defaultAvatarImage = TUICoreBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head");
        _defaultGroupAvatarImage = TUICoreBundleThemeImage(@"default_group_head_img", @"default_group_head");
        _defaultGroupAvatarImage_Public = TUICoreBundleThemeImage(@"default_group_head_public_img", @"default_group_head_public");
        _defaultGroupAvatarImage_Meeting = TUICoreBundleThemeImage(@"default_group_head_meeting_img", @"default_group_head_meeting");
        _defaultGroupAvatarImage_AVChatRoom = TUICoreBundleThemeImage(@"default_group_head_avchatroom_img", @"default_group_head_avchatRoom");
        _defaultGroupAvatarImage_Community = TUICoreBundleThemeImage(@"", @"default_group_head_Community");
        
        _isExcludedFromUnreadCount = NO;
        _isExcludedFromLastMessage = NO;
        _enableToast = YES;
        _displayOnlineStatusIcon = NO;
        _enableGroupGridAvatar = YES;
        
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
    self.defaultAvatarImage = TUICoreBundleThemeImage(@"default_c2c_head_img", @"default_c2c_head");
    self.defaultGroupAvatarImage = TUICoreBundleThemeImage(@"default_group_head_img", @"default_group_head");
    self.defaultGroupAvatarImage_Public = TUICoreBundleThemeImage(@"default_group_head_public_img", @"default_group_head_public");
    self.defaultGroupAvatarImage_Meeting = TUICoreBundleThemeImage(@"default_group_head_meeting_img", @"default_group_head_meeting");
    self.defaultGroupAvatarImage_AVChatRoom = TUICoreBundleThemeImage(@"default_group_head_avchatroom_img", @"default_group_head_avchatroom");
    self.defaultGroupAvatarImage_Community = TUICoreBundleThemeImage(@"default_group_head_community_img", @"default_group_head_community");
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

- (UIImage *)getGroupAvatarImageByGroupType:(NSString *)groupType
{
    if ([groupType isEqualToString:GroupType_Work]) {
        return self.defaultGroupAvatarImage;
    }
    else if ([groupType isEqualToString:GroupType_Public]) {
        return self.defaultGroupAvatarImage_Public;
    }
    else if ([groupType isEqualToString:GroupType_Meeting]) {
        return self.defaultGroupAvatarImage_Meeting;
    }
    else if ([groupType isEqualToString:GroupType_AVChatRoom]) {
        return self.defaultGroupAvatarImage_AVChatRoom;
    }
    else if ([groupType isEqualToString:GroupType_Community]) {
        return self.defaultGroupAvatarImage_Community;
    }
    else {
        return self.defaultGroupAvatarImage;
    }
}

@end
