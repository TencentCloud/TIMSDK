
#import "TUILogin.h"
#import "TUICore.h"

@import ImSDK_Plus;

static int g_sdkAppID = 0;
static NSString *g_userID = nil;
static NSString *g_userSig = nil;
static NSString *g_nickName = nil;
static NSString *g_faceUrl = nil;

@implementation TUILogin

+ (void)initWithSdkAppID:(int)sdkAppID {
    // sdkappid 如果发生了变化要先 unInitSDK，否则 initSDK 会失败
    if (sdkAppID != g_sdkAppID) {
        [self logout:nil fail:nil];
        [[V2TIMManager sharedInstance] unInitSDK];
        g_sdkAppID = sdkAppID;
    }
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    config.logLevel = V2TIM_LOG_INFO;
    [[V2TIMManager sharedInstance] initSDK:sdkAppID config:config listener:nil];
}

+ (void)login:(NSString *)userID userSig:(NSString *)userSig succ:(TSucc)succ fail:(TFail)fail {
    g_userID = userID;
    g_userSig = userSig;
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userID]) {
        succ();
    } else {
        __weak __typeof(self) weakSelf = self;
        [[V2TIMManager sharedInstance] login:userID userSig:userSig succ:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf getSelfUserInfo];
            if (succ) {
                succ();
            }
        } fail:^(int code, NSString *desc) {
            if (fail) {
                fail(code, desc);
            }
        }];
    }
}

+ (void)getSelfUserInfo {
    [[V2TIMManager sharedInstance] getUsersInfo:@[g_userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *info = infoList.firstObject;
        g_nickName = info.nickName;
        g_faceUrl = info.faceURL;
    } fail:nil];
}

+ (void)logout:(TSucc)succ fail:(TFail)fail {
    g_userID = @"";
    g_userSig = @"";
    [[V2TIMManager sharedInstance] logout:^{
        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *desc) {
        if (fail) {
            fail(code, desc);
        }
    }];
}

+ (int)getSdkAppID {
    return g_sdkAppID;
}

+ (NSString *)getUserID {
    return g_userID;
}

+ (NSString *)getUserSig {
    return g_userSig;
}

+ (NSString *)getNickName {
    return g_nickName;
}

+ (NSString *)getFaceUrl {
    return g_faceUrl;
}

@end
