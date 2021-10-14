//
//  TUIKitLive.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by kayev on 2021/7/21.
//

#import "TUIKitLive.h"
#import "TRTCLiveRoom.h"
#import "TUILiveUserProfile.h"
#import "TUILiveGroupLiveMessageHandle.h"
#import "TUILiveFloatWindow.h"
#import "TUIGlobalization.h"

@interface TUILiveUserProfile (private)
+ (void)refreshLoginUserInfoWithUserId:(NSString *)userId callBack:(TUILiveRequestCallback _Nullable)callback;
@end

@interface TUIKitLive()<TUILiveRoomAnchorDelegate, V2TIMGroupListener>

@property (nonatomic, assign) int sdkAppId;


@end

@implementation TUIKitLive

+ (instancetype)shareInstance {
    static TUIKitLive *__liveManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __liveManager = [[TUIKitLive alloc] init];
    });
    return __liveManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[V2TIMManager sharedInstance] addGroupListener:self];
    }
    return self;
}

#pragma mark - Public Methods
- (void)setIsAttachedTUIKit:(BOOL)isAttachedTUIKit {
    _isAttachedTUIKit = isAttachedTUIKit;
    if (isAttachedTUIKit) {
        [[TUILiveGroupLiveMessageHandle shareInstance] startObserver:self];
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
    if (self.isAttachedTUIKit) {
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

#pragma mark - TUILiveRoomAnchorDelegate

- (void)onRoomCreate:(TRTCLiveRoomInfo *)roomInfo {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(onRoomCreate:)]) {
        [self.groupLiveDelegate onRoomCreate:roomInfo];
    }
}

- (void)onRoomDestroy:(TRTCLiveRoomInfo *)roomInfo {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(onRoomDestroy:)]) {
        [self.groupLiveDelegate onRoomDestroy:roomInfo];
    }
}

- (void)getPKRoomIDList:(TUILiveOnRoomListCallback _Nullable)callback {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(getPKRoomIDList:)]) {
        [self.groupLiveDelegate getPKRoomIDList:callback];
    }
}

- (void)onRoomError:(TRTCLiveRoomInfo *)roomInfo errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(onRoomError:errorCode:errorMessage:)]) {
        [self.groupLiveDelegate onRoomError:roomInfo errorCode:errorCode errorMessage:errorMessage];
    }
}

#pragma mark V2TIMGroupListener
- (void)notify:(NSString *)notifyName buildInfo:(void (^)(void(^safeAddKeyValue)(id key, id value)))infoBuilder {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    void(^safeAdd)(id key, id value) = ^(id key, id value) {
        if (key && value) {
            userInfo[key] = value;
        }
    };
    infoBuilder(safeAdd);
    [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:nil userInfo:userInfo];
}

- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    // onMemberEnter
    [self notify:@"V2TIMGroupNotify_onMemberEnter" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"memberList", memberList);
    }];
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member {
    // onMemberLeave
    [self notify:@"V2TIMGroupNotify_onMemberLeave" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"member", member);
    }];
}

- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    // onMemberInvited
    [self notify:@"V2TIMGroupNotify_onMemberInvited" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
        safeAddKeyValue(@"memberList", memberList);
    }];
}

- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [self notify:@"V2TIMGroupNotify_onGroupDismissed" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
    }];
}

- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [self notify:@"V2TIMGroupNotify_onGroupRecycled" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
    }];
}


- (void)onGroupAttributeChanged:(NSString *)groupID attributes:(NSMutableDictionary<NSString *,NSString *> *)attributes {
    // onGroupAttributeChanged
    [self notify:@"V2TIMGroupNotify_onGroupAttributeChanged" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"attributes", attributes);
    }];
}

- (void)onRevokeAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList {
    // onRevokeAdministrator
    [self notify:@"V2TIMGroupNotify_onRevokeAdministrator" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
        safeAddKeyValue(@"memberList", memberList);
    }];
}

- (void)onReceiveRESTCustomData:(NSString *)groupID data:(NSData *)data {
    // onReceiveRESTCustomData
    [self notify:@"V2TIMGroupNotify_onReceiveRESTCustomData" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"data", data);
    }];
}


@end
