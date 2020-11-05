//
//  TUIKitLive.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/10.
//

#import "TUIKitLive.h"
#import "TRTCLiveRoom.h"
#import "TUILiveUserProfile.h"
#import "TUILiveGroupLiveMessageHandle.h"
#import "TUILiveFloatWindow.h"

@interface TUILiveUserProfile (private)
+ (void)refreshLoginUserInfoWithUserId:(NSString *)userId callBack:(TUILiveRequestCallback _Nullable)callback;
@end

@interface TUIKitLive ()
@property (nonatomic, assign) int sdkAppId;
@property (nonatomic, assign) BOOL isAttachedTUIKit; /// 如果引入了TUIKit，TUIKit里会给这个变量赋值
@end


@implementation TUIKitLive

+ (instancetype)shareInstance {
    static TUIKitLive *__tuikitlive = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __tuikitlive = [[TUIKitLive alloc] init];
    });
    return __tuikitlive;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setIsAttachedTUIKit:(BOOL)isAttachedTUIKit {
    _isAttachedTUIKit = isAttachedTUIKit;
    if (isAttachedTUIKit) {
        [[TUILiveGroupLiveMessageHandle shareInstance] startObserver];
    } else {
        [[TUILiveGroupLiveMessageHandle shareInstance] stopObserver];
    }
}

- (void)login:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig callback:(TUILiveRequestCallback)callback {
    self.sdkAppId = sdkAppID;
    TRTCLiveRoomConfig *roomConfig = [[TRTCLiveRoomConfig alloc] initWithAttachedTUIkit:self.isAttachedTUIKit];
    [[TRTCLiveRoom sharedInstance] loginWithSdkAppID:sdkAppID userID:userID userSig:userSig config:roomConfig callback:^(int code, NSString * _Nullable message) {
        if (callback) {
            callback(code, message);
        }
        [TUILiveUserProfile refreshLoginUserInfoWithUserId:userID callBack:nil];
    }];
}

- (void)logout:(TUILiveRequestCallback)callback {
    if ([self isFloatWindwoShow]) {
        [self exitFloatWindow];
    }
    if ([TUIKitLive shareInstance].isAttachedTUIKit) {
        return;
    }
    [[TRTCLiveRoom sharedInstance] logout:^(int code, NSString * _Nullable message) {
        if (code == 0) {
            [TUILiveUserProfile onLogout];
        }
        if (callback) {
            callback(code, message);
        }
    }];
}

- (BOOL)isFloatWindwoShow {
    return [TUILiveFloatWindow sharedInstance].isShowing;
}

- (void)exitFloatWindow {
    if ([TUILiveFloatWindow sharedInstance].isShowing) {
        [[TUILiveFloatWindow sharedInstance] hide];
        [TUILiveFloatWindow sharedInstance].backController = nil; //置为nil会退出房间
    }
}

@end
