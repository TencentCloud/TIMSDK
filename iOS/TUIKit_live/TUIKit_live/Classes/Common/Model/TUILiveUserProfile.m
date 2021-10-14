//
//  TUILiveUserProfile.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/23.
//

#import "TUILiveUserProfile.h"
#import "TRTCLiveRoom.h"

static V2TIMUserFullInfo *__loginUserInfo = nil;

@implementation TUILiveUserProfile

+ (void)refreshLoginUserInfo:(TUILiveRequestCallback _Nullable)callback {
    return [self refreshLoginUserInfoWithUserId:[self getLoginUserInfo].userID callBack:callback];
}

+ (void)onLogout {
    __loginUserInfo = nil;
}

+ (V2TIMUserFullInfo *)getLoginUserInfo {
    return __loginUserInfo;
}

+ (void)refreshLoginUserInfoWithUserId:(NSString *)userId callBack:(TUILiveRequestCallback _Nullable)callback {
    if ([userId length] == 0) {
        if (callback) {
            callback(-1, @"refreshLoginUserInfoWithUserId：userId 为空");
        }
        return;
    }
    [[V2TIMManager sharedInstance] getUsersInfo:@[userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        __loginUserInfo = infoList.firstObject;
        [[TRTCLiveRoom sharedInstance] setSelfProfileWithName:[self getLoginUserInfo].nickName ?:@"" avatarURL:[self getLoginUserInfo].faceURL ?:@"" callback:nil];
    } fail:nil];
}

@end
