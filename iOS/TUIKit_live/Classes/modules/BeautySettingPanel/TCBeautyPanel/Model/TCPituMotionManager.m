// Copyright (c) 2019 Tencent. All rights reserved.

#import "TCPituMotionManager.h"
#import <UIKit/UIKit.h>

#define L(x) NSLocalizedString(x, nil)

@implementation TCPituMotionManager
{
    NSMutableDictionary<NSString *, TCPituMotion *> *_map;
}

+ (instancetype)sharedInstance
{
    static TCPituMotionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TCPituMotionManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *initList = @[
            @[@"video_boom", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_boom.zip", L(@"Boom")],
// - Remove From Demo
            @[@"video_nihongshu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_nihongshu.zip", L(@"霓虹鼠")],
            @[@"video_fengkuangdacall", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_fengkuangdacall.zip", L(@"疯狂打call")],
            @[@"video_Qxingzuo_iOS", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_Qxingzuo_iOS.zip", L(@"Q星座")],
            @[@"video_caidai_iOS", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_caidai_iOS.zip", L(@"彩色丝带")],
            @[@"video_liuhaifadai", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_liuhaifadai.zip", L(@"刘海发带")],
            @[@"video_purplecat", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_purplecat.zip", L(@"紫色小猫")],
            @[@"video_huaxianzi", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_huaxianzi.zip", L(@"花仙子")],
            @[@"video_baby_agetest", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_baby_agetest.zip", L(@"小公举")],
            // 星耳，变脸
            @[@"video_3DFace_dogglasses2", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_3DFace_dogglasses2.zip", L(@"眼镜狗")],
            @[@"video_rainbow", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_rainbow.zip", L(@"彩虹云")],
// - /Remove From Demo
        ];
        NSArray *gestureMotionArray = @[
            @[@"video_pikachu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/Android/181/video_pikachu.zip", L(@"皮卡丘")],
// - Remove From Demo
            @[@"video_liuxingyu", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_liuxingyu.zip", L(@"流星雨")],
            @[@"video_kongxue2", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_kongxue2.zip", L(@"控雪")],
            @[@"video_dianshizhixing", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_dianshizhixing.zip", L(@"电视之星")],
            @[@"video_bottle1", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_bottle1.zip", L(@"瓶盖挑战")],
// - /Remove From Demo
        ];
        NSArray *cosmeticMotionArray = @[
// - Remove From Demo
            @[@"video_cherries", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_cherries.zip", L(@"樱桃")],
            @[@"video_haiyang2", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_haiyang2.zip", L(@"海洋")],
            @[@"video_fenfenxia_square_iOS", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_fenfenxia_square_iOS.zip", L(@"粉粉霞")],
            @[@"video_guajiezhuang", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_guajiezhuang.zip", L(@"寡姐妆")],
            @[@"video_qixichun", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_qixichun.zip", L(@"七夕唇印")],
            @[@"video_gufengzhuang", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_gufengzhuang.zip", L(@"古风妆")],
            @[@"video_dxxiaochounv", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_dxxiaochounv.zip", L(@"小丑女")],
            @[@"video_remix1", @"https://pitu-sticker-1252463788.cos.ap-guangzhou.myqcloud.com/video_remix1.zip", L(@"混合妆")],
// - /Remove From Demo
            @[@"video_qingchunzannan_iOS", @"http://res.tu.qq.com/materials/video_qingchunzannan_iOS.zip", L(@"原宿复古")],
        ];
        NSArray *backgroundRemovalArray = @[
            @[@"video_xiaofu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_xiaofu.zip", L(@"AI抠背")],
        ];
        NSArray *(^generate)(NSArray *) = ^(NSArray *inputArray){
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:inputArray.count];
            self->_map = [[NSMutableDictionary alloc] initWithCapacity:inputArray.count];
            for (NSArray *item in inputArray) {
                TCPituMotion *address = [[TCPituMotion alloc] initWithId:item[0] name:item[2] url:item[1]];
                [array addObject:address];
                self->_map[item[0]] = address;
            }
            return array;
        };

        _motionPasters = generate(initList);
        _cosmeticPasters = generate(cosmeticMotionArray);
        _gesturePasters = generate(gestureMotionArray);
        _backgroundRemovalPasters = generate(backgroundRemovalArray);
    }
    return self;
}

- (TCPituMotion *)motionWithIdentifier:(NSString *)identifier
{
    return _map[identifier];
}

@end

@implementation TCPituMotion
- (instancetype)initWithId:(NSString *)identifier name:(NSString *)name url:(NSString *)address
{
    if (self = [super init]) {
        _identifier = identifier;
        _name = name;
        _url = [NSURL URLWithString: address];
    }
    return self;
}
@end
