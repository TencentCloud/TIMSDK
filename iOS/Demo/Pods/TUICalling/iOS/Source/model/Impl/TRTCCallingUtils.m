//
//  TUIUtils.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import "TRTCCallingUtils.h"

@implementation TRTCCallingUtils

+ (TRTCCallingUtils *)shareInstance {
    static dispatch_once_t onceToken;
    static TRTCCallingUtils *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TRTCCallingUtils alloc] init];
    });
    return g_sharedInstance;
}

// 实际项目中建议由后台生成一个唯一 roomID，防止 roomID 重复
+ (UInt32)generateRoomID {
    // android 最大值是 int32，roomID 不能为 0
    UInt32 random = 1 + arc4random() % (INT32_MAX - 1);
    return random;
}

+ (NSString *)loginUser {
    return [[V2TIMManager sharedInstance] getLoginUser];
}

+ (void)getCallUserModel:(NSString *)userID finished:(void(^)(CallUserModel *))finished {
    [[V2TIMManager sharedInstance] getUsersInfo:@[userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *info = infoList.firstObject;
        if (info) {
            CallUserModel *model = [[CallUserModel alloc] init];
            model.name = info.nickName;
            model.avatar = info.faceURL;
            model.userId = info.userID;
            finished(model);
        } else {
            finished(nil);
        }
    } fail:^(int code, NSString *desc) {
        finished(nil);
    }];
}

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict {
    return [[NSString alloc] initWithData:[self dictionary2JsonData:dict] encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed: %@", jsonString);
        return nil;
    }
    return dic;
}

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict {
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
        }
        return data;
    }
    else
    {
        NSLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed");
        return nil;
    }
    return dic;
}


@end
