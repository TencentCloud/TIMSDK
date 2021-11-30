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

@interface TUIConfig ()


//提前加载资源（全路径）


@end

@implementation TUIConfig

- (id)init
{
    self = [super init];
    if(self){
        _avatarCornerRadius = 5.f;
        _defaultAvatarImage = [UIImage d_imageNamed:@"default_c2c_head" bundle:TUICoreBundle];
        _defaultGroupAvatarImage = [UIImage d_imageNamed:@"default_group_head" bundle:TUICoreBundle];
        _isExcludedFromUnreadCount = NO;
        _isExcludedFromLastMessage = NO;
        _enableToast = YES;
        [self defaultFace];
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

/**
 *  初始化默认表情，并将配默认表情写入本地缓存，方便下一次快速加载
 */
- (void)defaultFace
{
    NSMutableArray *faceGroups = [NSMutableArray array];
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
        [faceGroups addObject:emojiGroup];
        [self addFaceToCache:TUIChatFaceImagePath(@"del_normal")];
    }

    _faceGroups = faceGroups;
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
