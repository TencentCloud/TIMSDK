//
//  TRTCLiveRoom.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/7.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCLiveRoom.h"
#import "TRTCLiveRoomMemberManager.h"
#import "TRTCLiveRoomModelDef.h"
#import "TXLiveRoomCommonDef.h"
#import "TRTCLiveRoomIMAction.h"
#import "TRTCCloudAnction.h"
#import "MJExtension.h"
#import "TRTCV2TIMMessageObservable.h"

#import "THeader.h"

static double trtcLiveSendMsgTimeOut = 60;
static double trtcLiveHandleMsgTimeOut = 10;
static double trtcLiveCheckStatusTimeOut = 3;

@interface NSNumber (String)

- (BOOL)isEqualToString:(NSString *)string;

@end

@implementation NSNumber (String)

- (BOOL)isEqualToString:(NSString *)string {
    return NO;
}

@end

@interface TRTCLiveRoom () <TRTCLiveRoomMembermanagerDelegate, V2TIMAdvancedMsgListener, V2TIMGroupListener, V2TIMSignalingListener>

@property (nonatomic, strong) TRTCCloudAnction *trtcAction;
@property (nonatomic, strong) TRTCLiveRoomMemberManager *memberManager;
@property (nonatomic, strong) TRTCLiveRoomConfig *config;
@property (nonatomic, strong) TRTCLiveUserInfo *me;
@property (nonatomic, assign) BOOL mixingPKStream; // PK是否混流
@property (nonatomic, assign) BOOL mixingLinkMicStream; // 连麦是否混流
@property (nonatomic, strong) TRTCLiveRoomInfo *curRoomInfo;

@property (nonatomic, strong, readonly) TXBeautyManager *beautyManager;
@property (nonatomic, assign) TRTCLiveRoomLiveStatus status;

@property (nonatomic, strong, readonly) NSString *roomID;
@property (nonatomic, strong, readonly) NSString *ownerId;

@property (nonatomic, copy) Callback enterRoomCallback;
@property (nonatomic, copy) ResponseCallback requestJoinAnchorCallback;
@property (nonatomic, copy) ResponseCallback requestRoomPKCallback;

@property (nonatomic, strong) TRTCPKAnchorInfo *pkAnchorInfo;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *requestRoomPKDic; // 发出的请求PK的信令ID记录
@property (nonatomic, strong) TRTCJoinAnchorInfo *joinAnchorInfo;
@property (nonatomic, strong, nullable)NSString *requestJoinAnchorID; // 请求连麦的信令ID
@property(nonatomic, strong) TRTCV2TIMMessageObservable *groupMessageObservable;

@property (nonatomic, assign, readonly) BOOL isOwner;
@property (nonatomic, assign, readonly) BOOL isAnchor;
@property (nonatomic, assign, readonly) BOOL configCdn;
@property (nonatomic, assign, readonly) BOOL shouldPlayCdn;
@property (nonatomic, assign, readonly) BOOL shouldMixStream;
@property (nonatomic, assign, readwrite) BOOL useCDNFirst;
@property (nonatomic, strong, readwrite) NSString *cdnDomain;

@property (nonatomic, strong) NSMutableDictionary<NSString *, TRTCJoinAnchorInfo *> *onJoinAnchorDic; // 正在处理上麦的观众信息（处理完毕后移除，主要用于检测Trtc进房超时）
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *requestJoinAnchorDic; // 连麦观众请求列表
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *responseRoomPKDic; // 收到请求PK列表

@end

@implementation TRTCLiveRoom

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.memberManager.delegate = self;
        self.mixingPKStream = YES;
        self.mixingLinkMicStream = YES;
    }
    return self;
}

- (void)dealloc {
    TRTCLog(@"dealloc TRTCLiveRoom");
}

+ (instancetype)sharedInstance {
    static TRTCLiveRoom *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TRTCLiveRoom alloc] init];
    });
    return instance;
}

#pragma mark - 懒加载&&只读属性
- (TRTCCloudAnction *)trtcAction {
    if (!_trtcAction) {
        _trtcAction = [[TRTCCloudAnction alloc] init];
    }
    return _trtcAction;
}

- (TRTCLiveRoomMemberManager *)memberManager {
    if (!_memberManager) {
        _memberManager = [[TRTCLiveRoomMemberManager alloc] init];
    }
    return _memberManager;
}

- (TRTCPKAnchorInfo *)pkAnchorInfo {
    if (!_pkAnchorInfo) {
        _pkAnchorInfo = [[TRTCPKAnchorInfo alloc] init];
    }
    return _pkAnchorInfo;
}

-(TRTCJoinAnchorInfo *)joinAnchorInfo {
    if (!_joinAnchorInfo) {
        _joinAnchorInfo = [[TRTCJoinAnchorInfo alloc] init];
    }
    return _joinAnchorInfo;
}

- (NSMutableDictionary<NSString *,NSString *> *)requestJoinAnchorDic {
    if (!_requestJoinAnchorDic) {
        _requestJoinAnchorDic = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _requestJoinAnchorDic;
}

- (NSMutableDictionary<NSString *,NSString *> *)responseRoomPKDic {
    if (!_responseRoomPKDic) {
        _responseRoomPKDic = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _responseRoomPKDic;
}

- (NSMutableDictionary<NSString *,NSString *> *)requestRoomPKDic {
    if (!_requestRoomPKDic) {
        _requestRoomPKDic = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _requestRoomPKDic;
}

- (NSString *)roomID {
    return self.trtcAction.roomId;
}

- (NSString *)ownerId {
    return self.memberManager.ownerId;
}

- (TXBeautyManager *)beautyManager {
    return self.trtcAction.beautyManager;
}

- (void)setStatus:(TRTCLiveRoomLiveStatus)status {
    if (_status != status) {
        if (self.curRoomInfo) {
            self.curRoomInfo.roomStatus = status;
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRoomInfoChange:)]) {
                [self.delegate trtcLiveRoom:self onRoomInfoChange:self.curRoomInfo];
            }
        } else {
            NSString *streameUrl = [NSString stringWithFormat:@"%@_stream", self.me.userId];
            TRTCLiveRoomInfo* roomInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:self.roomID
                                                                         roomName:@""
                                                                         coverUrl:@""
                                                                          ownerId:self.me.userId ?: @""
                                                                        ownerName:self.me.userName ?: @""
                                                                        streamUrl:streameUrl
                                                                      memberCount:self.memberManager.audience.count
                                                                       roomStatus:status];
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRoomInfoChange:)]) {
                [self.delegate trtcLiveRoom:self onRoomInfoChange:roomInfo];
            }
        }
    }
    _status = status;
}


#pragma mark - public method

#pragma mark - 用户
- (void)loginWithSdkAppID:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig config:(TRTCLiveRoomConfig *)config callback:(Callback)callback {
    BOOL result = [TRTCLiveRoomIMAction setupSDKWithSDKAppID:sdkAppID userSig:userSig];
    if (!result) {
        if (callback) {
            callback(-1, @"初始化失败");
        }
        return;
    } else {
        // 先移除，后添加，防止收到多条消息
        [[V2TIMManager sharedInstance] removeSignalingListener:self];
        [[V2TIMManager sharedInstance] removeAdvancedMsgListener:self];
        [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
        [[V2TIMManager sharedInstance] addSignalingListener:self]; // 添加信令监听
        if (config.isAttachedTUIKit) {
            if (!self.groupMessageObservable) {
                self.groupMessageObservable = [[TRTCV2TIMMessageObservable alloc] init];
            }
            [self.groupMessageObservable addObserver:self];
        } else {
            [[V2TIMManager sharedInstance] setGroupListener:self];
        }
    }
    @weakify(self)
    [TRTCLiveRoomIMAction loginWithUserID:userID userSig:userSig callback:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (code == 0) {
            TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
            user.userId = userID;
            self.me = user;
            self.config = config;
            [self.trtcAction setupWithUserId:userID sdkAppId:sdkAppID userSig:userSig];
            
        }
        if (callback) {
            callback(0, @"login success.");
        }
    }];
}

- (void)logout:(Callback)callback {
    @weakify(self)
    [TRTCLiveRoomIMAction logout:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        self.me = nil;
        self.config = nil;
        [self.trtcAction reset];
        if (callback) {
            callback(code, message);
        }
        //通常情况下，同一个APP，对应的sdkAppId不会发生改变，不需要releaseSDK；特殊情况需要releaseSDK的，由业务层主动调用。
        //[TRTCLiveRoomIMAction releaseSdk];
    }];
}

- (void)setSelfProfileWithName:(NSString *)name avatarURL:(NSString *)avatarURL callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    me.avatarURL = avatarURL;
    me.userName = name;
    @weakify(self)
    [TRTCLiveRoomIMAction setProfileWithName:name avatar:avatarURL callback:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (code == 0) {
            [self.memberManager updateProfile:me.userId name:name avatar:avatarURL];
        }
        if (callback) {
            callback(code, message);
        }
    }];
}

- (void)createRoomWithRoomID:(UInt32)roomID roomParam:(TRTCCreateRoomParam *)roomParam callback:(Callback)callback {
    [TRTCCloud sharedInstance].delegate = self;
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    BOOL result = [self checkRoomUnjoined:callback];
    if (!result) {
        return;
    }
    NSString *roomIDStr = [NSString stringWithFormat:@"%u", (unsigned int)roomID];
    self.curRoomInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:roomIDStr
                                                       roomName:roomParam.roomName
                                                       coverUrl:roomParam.coverUrl
                                                        ownerId:me.userId
                                                      ownerName:me.userName
                                                      streamUrl:[NSString stringWithFormat:@"%@_stream", me.userId]
                                                    memberCount:0
                                                     roomStatus:TRTCLiveRoomLiveStatusSingle];
    @weakify(self)
    [TRTCLiveRoomIMAction createRoomWithRoomID:roomIDStr
                                     roomParam:roomParam success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members, NSDictionary<NSString *,id> * _Nonnull customInfo, TRTCLiveRoomInfo * _Nullable roomInfo) {
        @strongify(self)
        if (!self) {
            return;
        }
        self.status = TRTCLiveRoomLiveStatusSingle;
        self.trtcAction.roomId = roomIDStr;
        [self.memberManager setmembers:members groupInfo:customInfo];
        [self.memberManager setOwner:me];
        if (callback) {
            callback(0, @"");
        }
    } error:callback];
}

- (void)destroyRoom:(Callback)callback {
    TRTCLiveUserInfo *user = [self checkUserLogIned:callback];
    if (!user) {
        return;
    }
    NSString *roomId = [self checkRoomJoined:callback];
    if (!roomId) {
        return;
    }
    if (![self checkIsOwner:callback]) {
        return;
    }
    [TRTCLiveRoomIMAction destroyRoomWithRoomID:roomId callback:callback];
    [self reset];
}

- (void)enterRoomWithRoomID:(UInt32)roomID
                useCDNFirst:(BOOL)useCDNFirst
                  cdnDomain:(NSString *)cdnDomain
                   callback:(Callback)callback {
    self.useCDNFirst = useCDNFirst;
    self.cdnDomain = cdnDomain;
    [TRTCCloud sharedInstance].delegate = self;
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    if (![self checkRoomUnjoined:callback]) {
        return;
    }
    NSString *roomIDStr = [NSString stringWithFormat:@"%u", (unsigned int)roomID];
    if (self.shouldPlayCdn) {
        self.trtcAction.roomId = roomIDStr;
        [self imEnter:roomIDStr callback:callback];
    } else {
        self.trtcAction.roomId = roomIDStr;
        [self trtcEnter:roomIDStr userId:me.userId callback:^(int code, NSString * _Nullable message) {
            if (code != 0) {
                callback(code, message);
            } else {
                @weakify(self)
                [self imEnter:roomIDStr callback:^(int code, NSString * _Nullable message) {
                    @strongify(self)
                    if (!self) {
                        return;
                    }
                    callback(code, message);
                    if (code != 0 && [self canDelegateResponseMethod:@selector(trtcLiveRoom:onError:message:)]) {
                        [self.delegate trtcLiveRoom:self onError:code message:message];
                    }
                }];
            }
        }];
    }
    
}

- (void)imEnter:(NSString *)roomID callback:(Callback)callback {
    @weakify(self)
    [TRTCLiveRoomIMAction enterRoomWithRoomID:roomID success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members, NSDictionary<NSString *,id> * _Nonnull customInfo, TRTCLiveRoomInfo * _Nullable roomInfo) {
        @strongify(self)
        if (!self) {
            return;
        }
        [self.memberManager setmembers:members groupInfo:customInfo];
        self.curRoomInfo = roomInfo;
        self.status = roomInfo != nil ? roomInfo.roomStatus : TRTCLiveRoomLiveStatusSingle;
        if (callback) {
            callback(0, @"");
        }
        if (self.shouldPlayCdn) {
            [self notifyAvailableStreams];
        }
    } error:callback];
}

- (void)trtcEnter:(NSString *)roomID userId:(NSString *)userId callback:(Callback)callback {
    self.enterRoomCallback = callback;
    [self.trtcAction enterRoomWithRoomID:roomID urlDomain:@"" userId:userId role:TRTCRoleAudience];
    NSString *uuid = [self.trtcAction.curroomUUID mutableCopy];
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([uuid isEqualToString:self.trtcAction.curroomUUID] && self.enterRoomCallback) {
            self.enterRoomCallback(-1, @"enterRoom 请求超时");
            self.enterRoomCallback = nil;
        }
    });
}

- (void)exitRoom:(Callback)callback {
    if (![self checkUserLogIned:callback]) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    if (self.isOwner) {
        if (callback) {
            callback(-1, @"只有普通成员才能退房");
        }
        return;
    }
    [self reset];
    [TRTCLiveRoomIMAction exitRoomWithRoomID:roomID callback:callback];
}

- (void)getRoomInfosWithRoomIDs:(NSArray<NSNumber *> *)roomIDs callback:(RoomInfoCallback)callback {
    NSMutableArray *strRoomIds = [[NSMutableArray alloc] initWithCapacity:2];
    [roomIDs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* str = [obj stringValue];
        [strRoomIds addObject:str];
    }];
    [TRTCLiveRoomIMAction getRoomInfoWithRoomIds:strRoomIds success:^(NSArray<TRTCLiveRoomInfo *> * _Nonnull roomInfos) {
        NSMutableArray *sortInfo = [[NSMutableArray alloc] initWithCapacity:2];
        NSMutableDictionary *resultMap = [[NSMutableDictionary alloc] initWithCapacity:2];
        for (TRTCLiveRoomInfo *room in roomInfos) {
            resultMap[room.roomId] = room;
        }
        for (NSString *roomId in strRoomIds) {
            if ([resultMap.allKeys containsObject:roomId]) {
                TRTCLiveRoomInfo *roomInfo = resultMap[roomId];
                if (roomInfo) {
                    [sortInfo addObject:roomInfo];
                }
            }
        }
        if (callback) {
            callback(0, @"success", sortInfo);
        }
    } error:^(int code, NSString * _Nonnull message) {
        if (callback) {
            callback(code, message, @[]);
        }
    }];
}

- (void)getAnchorList:(UserListCallback)callback {
    if (callback) {
        callback(0, @"", self.memberManager.anchors.allValues);
    }
}

- (void)getAudienceList:(UserListCallback)callback {
    NSString *roomId = [self checkRoomJoined:nil];
    if (!roomId) {
        if (callback) {
            callback(-1, @"没有进入房间", self.memberManager.audience);
        }
        return;
    }
    @weakify(self)
    [TRTCLiveRoomIMAction getAllMembersWithRoomID:roomId success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members) {
        @strongify(self)
        if (!self) {
            return;
        }
        for (TRTCLiveUserInfo *user in members) {
            if (!self.memberManager.anchors[user.userId]) {
                [self.memberManager addAudience:user];
            }
        }
        if (callback) {
            callback(0, @"", self.memberManager.audience);
        }
    } error:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (callback) {
            callback(0, @"", self.memberManager.audience);
        }
    }];
}

- (void)startCameraPreviewWithFrontCamera:(BOOL)frontCamera view:(UIView *)view callback:(Callback)callback {
    if (![self checkUserLogIned:callback]) {
        return;
    }
    [self.trtcAction startLocalPreview:frontCamera view:view];
    callback(0, @"success");
}

- (void)stopCameraPreview {
    [self.trtcAction stopLocalPreview];
}

- (void)startPublishWithStreamID:(NSString *)streamID callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [self.trtcAction setupVideoParam:self.isOwner];
    NSString *streamIDNonnull = ([streamID isEqualToString:@""] || !streamID) ? [self.trtcAction cdnUrlForUser:me.userId roomId:roomID] : streamID;
    [self.trtcAction startPublish:streamIDNonnull];
    if (self.isOwner) {//主播
        [self.memberManager updateStream:me.userId streamId:streamIDNonnull];
        if (callback) {
            callback(0, @"");
        }
    } else if (self.ownerId) {//观众
        [self.trtcAction switchRole:TRTCRoleAnchor];
        //bug fix:与Android对齐，连麦时不需要再给主播发送一条IM消息。
        //[TRTCLiveRoomIMAction notifyStreamToAnchorWithUserId:self.ownerId streamID:streamIDNonnull callback:callback];
    } else {
        NSAssert(NO, @"");
    }
}

- (void)stopPublish:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [self.trtcAction stopPublish];
    if (self.isOwner) {
        // 主播端，会解散房间
        [self.trtcAction exitRoom];
    } else {
        // 观众结束连麦
        [self.memberManager updateStream:me.userId streamId:nil];// 未解散房间，需要清除观众推流地址
        [self stopCameraPreview];
        // 结束连麦的时候，需要延迟下播放CDN画面的时机。非连麦情况则无影响
        [self switchRoleOnLinkMic:NO needDelayPlay:YES];
    }
}

- (void)startPlayWithUserID:(NSString *)userID view:(UIView *)view callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    TRTCLiveUserInfo *user = self.memberManager.pkAnchor;
    NSString *pkAnchorRoomId = self.pkAnchorInfo.roomId;
    if (user && pkAnchorRoomId) {
        [self.trtcAction startPlay:user.userId streamID:user.streamId view:view usesCDN:self.shouldPlayCdn cdnDomain:self.cdnDomain roomId:pkAnchorRoomId callback:callback];
    } else if (self.memberManager.anchors[userID]) {
        TRTCLiveUserInfo *anchor = self.memberManager.anchors[userID];
        [self.trtcAction startPlay:anchor.userId streamID:anchor.streamId view:view usesCDN:self.shouldPlayCdn cdnDomain:self.cdnDomain roomId:roomID callback:callback];
    } else {
        if (callback) {
            callback(-1, @"未找到该主播");
        }
    }
}

- (void)stopPlayWithUserID:(NSString *)userID callback:(Callback)callback {
    if (!userID) {
        callback(-1, @"user id is nil");
        return;
    }
    [self.trtcAction stopPlay:userID usesCDN:self.shouldPlayCdn];
    if (callback) {
        callback(0, @"");
    }
}

- (void)requestJoinAnchor:(NSString *)reason timeout:(double)timeout responseCallback:(ResponseCallback)responseCallback {
    if (!responseCallback) {
        responseCallback = ^(BOOL reslut, NSString *msg) {};
    }
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        responseCallback(NO, @"还未登录");
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        responseCallback(NO, @"没有进入房间");
        return;
    }
    if (self.isAnchor) {
        responseCallback(NO, @"当前已经是连麦状态");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusRoomPK || self.pkAnchorInfo.userId) {
        responseCallback(NO, @"当前主播正在PK");
        return;
    }
    if ([self.joinAnchorInfo.userId length] > 0) {
        responseCallback(NO, @"当前用户正在等待连麦回复");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusNone) {
        responseCallback(NO, @"出错请稍后尝试");
        return;
    }
    
    if (!self.ownerId) {
        return;
    }
    self.requestJoinAnchorCallback = responseCallback;
    self.joinAnchorInfo.userId = me.userId ?: @"";
    self.joinAnchorInfo.uuid = [[NSUUID UUID] UUIDString];
    self.requestJoinAnchorID = [TRTCLiveRoomIMAction requestJoinAnchorWithUserID:self.ownerId timeout:timeout reason:reason callback:^(int code, NSString * _Nonnull message) {
        if (code != 0) {
            [self clearJoinState:YES userID:me.userId];
            if (responseCallback) {
                responseCallback(NO, message);
            }
        } else {
            NSLog(@"发送连麦消息成功");
        }
    }];
}

- (void)cancelRequestJoinAnchor:(NSString *)reason responseCallback:(Callback)responseCallback {
    if (self.requestJoinAnchorID) {
        [TRTCLiveRoomIMAction cancelRequestJoinAnchorWithRequestID:self.requestJoinAnchorID reason:reason callback:responseCallback];
        self.requestJoinAnchorID = nil;
    }
}

- (void)cancelRequestRoomPKWithRoomID:(UInt32)roomID userID:(NSString *)userID responseCallback:(Callback)responseCallback {
    if ([self.requestRoomPKDic.allKeys containsObject:userID]) {
        NSString *requestID = [self.requestRoomPKDic objectForKey:userID];
        [TRTCLiveRoomIMAction cancelRequestRoomPKWithRequestID:requestID reason:@"" callback:responseCallback];
        [self.requestRoomPKDic removeObjectForKey:userID];
    }
}

- (void)responseJoinAnchor:(NSString *)userID agree:(BOOL)agree reason:(NSString *)reason {
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me && !self.isOwner) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    if ([self.requestJoinAnchorDic.allKeys containsObject:userID]) {
        if (agree) {
            if ([TRTCCloud sharedInstance].delegate != self) {
                [TRTCCloud sharedInstance].delegate = self;
            }
            // 同意上麦后，建立上麦观众信息表
            TRTCJoinAnchorInfo *joinAnchorInfo = [[TRTCJoinAnchorInfo alloc] init];
            joinAnchorInfo.uuid = [[NSUUID UUID] UUIDString];
            joinAnchorInfo.userId = userID;
            joinAnchorInfo.isResponsed = YES;
            [self.onJoinAnchorDic setObject:joinAnchorInfo forKey:userID];
            NSString* uuid = [joinAnchorInfo.uuid copy];
            @weakify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveCheckStatusTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                if (!self) {
                    return;
                }
                TRTCJoinAnchorInfo *info = self.onJoinAnchorDic[userID];
                if (self.memberManager.anchors[userID] == nil && [uuid isEqualToString:info.uuid]) {
                    // 连麦未进房
                    [self kickoutJoinAnchor:userID callback:nil];
                    [self clearJoinState:YES userID:userID];
                } else {
                    [self clearJoinState:NO userID:userID];
                }
            });
        } else {
            [self clearJoinState:NO userID:userID];
        }
    }
    NSString *requestID = [self.requestJoinAnchorDic objectForKey:userID];
    if (requestID) {
        [TRTCLiveRoomIMAction respondJoinAnchorWithRequestID:requestID agreed:agree reason:reason callback:nil];
        [self.requestJoinAnchorDic removeObjectForKey:userID];
    }
}

- (void)responseKickoutJoinAnchorWithRequestID:(NSString *)requestID {
    // 踢人下麦信息，形成信令消息闭环
    [TRTCLiveRoomIMAction respondKickoutJoinAnchor:requestID agree:YES message:@"同意下麦"];
}

- (void)kickoutJoinAnchor:(NSString *)userID callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me && !self.isOwner) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    if (!self.memberManager.anchors[userID]) {
        if (callback) {
            callback(-1, @"该用户尚未连麦");
        }
        return;
    }
    [TRTCLiveRoomIMAction kickoutJoinAnchorWithUserID:userID callback:callback];
    [self stopLinkMic:userID];
}

- (void)requestRoomPKWithRoomID:(UInt32)roomID userID:(NSString *)userID timeout:(double)timeout responseCallback:(ResponseCallback)responseCallback {
    if (!responseCallback) {
        responseCallback = ^(BOOL reslut, NSString *msg) {};
    }
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        responseCallback(NO, @"还未登录");
        return;
    }
    NSString *myRoomId = [self checkRoomJoined:nil];
    if (!myRoomId) {
        responseCallback(NO, @"没有进入房间");
        return;
    }
    NSString* streamId = [self checkIsPublishing:nil];
    if (!streamId) {
        responseCallback(NO, @"只有推流后才能操作");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusLinkMic || self.onJoinAnchorDic.count > 0) {
        responseCallback(NO, @"当前主播正在连麦, 无法开启PK");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusRoomPK) {
        responseCallback(NO, @"当前主播正在PK");
        return;
    }
    if (self.pkAnchorInfo.userId) {
        responseCallback(NO, @"当前用户正在等待PK回复");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusNone) {
        responseCallback(NO, @"当前房间状态未准备就绪，请重新创建或连接主播间后再试。");
        return;
    }
    NSString *roomIDStr = [NSString stringWithFormat:@"%u", (unsigned int)roomID];
    self.requestRoomPKCallback = responseCallback;
    self.pkAnchorInfo.userId = userID;
    self.pkAnchorInfo.roomId = roomIDStr;
    self.pkAnchorInfo.uuid = [[NSUUID UUID] UUIDString];
    NSString *requesetPKID = [TRTCLiveRoomIMAction requestRoomPKWithUserID:userID timeout:timeout fromRoomID:myRoomId fromStreamID:streamId callback:^(int code, NSString * _Nonnull message) {
        if (code != 0) {
            responseCallback(NO, message);
        }
    }];
    [self.requestRoomPKDic setObject:requesetPKID forKey:userID];
}

- (void)RoomPKWithRoomID:(UInt32)roomID userID:(NSString *)userID responseCallback:(ResponseCallback)responseCallback {
    
}

- (void)responseRoomPKWithUserID:(NSString *)userID agree:(BOOL)agree reason:(NSString *)reason {
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    if (![self checkIsOwner:nil]) {
        return;
    }
    NSString *streamId = [self checkIsPublishing:nil];
    if (!streamId) {
        return;
    }
    if ([self.pkAnchorInfo.userId isEqualToString:userID]) {
        self.pkAnchorInfo.isResponsed = YES;
        if (agree) {
            if ([TRTCCloud sharedInstance].delegate != self) {
                [TRTCCloud sharedInstance].delegate = self;
            }
            NSString *uuid = self.pkAnchorInfo.uuid;
            @weakify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveCheckStatusTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                if (!self) {
                    return;
                }
                if (self.status != TRTCLiveRoomLiveStatusRoomPK && [uuid isEqualToString:self.pkAnchorInfo.uuid]) {
                    [self quitRoomPK:nil];
                    [self clearPKState];
                }
            });
        } else {
            [self clearPKState];
        }
    }
    NSString *inviteID = [self.responseRoomPKDic objectForKey:userID];
    if (inviteID) {
        [TRTCLiveRoomIMAction responseRoomPKWithRequestID:inviteID agreed:agree reason:reason streamID:streamId callback:nil];
    }
}

- (void)responseQuitRoomPK:(NSString *)requestID {
    [TRTCLiveRoomIMAction respondQuitRoomPK:requestID agree:YES message:@"同意结束PK"];
}

- (void)quitRoomPK:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusRoomPK && self.memberManager.pkAnchor) {
        [self.pkAnchorInfo reset];
        self.status = TRTCLiveRoomLiveStatusSingle;
        [[TRTCCloud sharedInstance] disconnectOtherRoom];
        [self.memberManager removeAnchor:self.memberManager.pkAnchor.userId];
        [TRTCLiveRoomIMAction quitRoomPKWithUserID:self.memberManager.pkAnchor.userId callback:callback];
    } else {
        if (callback) {
            callback(-1, @"当前不是PK状态");
        }
    }
}

#pragma mark - 音频设置
- (void)switchCamera {
    [[TRTCCloud sharedInstance] switchCamera];
}

- (void)setMirror:(BOOL)isMirror {
    [[TRTCCloud sharedInstance] setVideoEncoderMirror:isMirror];
}

- (void)muteLocalAudio:(BOOL)isMuted {
    [[TRTCCloud sharedInstance] muteLocalAudio:isMuted];
}

- (void)muteRemoteAudioWithUserID:(NSString *)userID isMuted:(BOOL)isMuted {
    [[TRTCCloud sharedInstance] muteRemoteAudio:userID mute:isMuted];
}

- (void)muteAllRemoteAudio:(BOOL)isMuted {
    [[TRTCCloud sharedInstance] muteAllRemoteAudio:isMuted];
}

- (void)setAudioQuality:(NSInteger)quality {
    if (quality == 3) {
        [[TRTCCloud sharedInstance] setAudioQuality:TRTCAudioQualityMusic];
    } else if (quality == 2) {
        [[TRTCCloud sharedInstance] setAudioQuality:TRTCAudioQualityDefault];
    } else {
        [[TRTCCloud sharedInstance] setAudioQuality:TRTCAudioQualitySpeech];
    }
}

- (void)showVideoDebugLog:(BOOL)isShow {
    [[TRTCCloud sharedInstance] showDebugView:isShow ? 2 : 0];
}

#pragma mark - 发送消息
- (void)sendRoomTextMsg:(NSString *)message callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [TRTCLiveRoomIMAction sendRoomTextMsgWithRoomID:roomID message:message callback:callback];
}

- (void)sendRoomCustomMsgWithCommand:(NSString *)cmd message:(NSString *)message callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [TRTCLiveRoomIMAction sendRoomCustomMsgWithRoomID:roomID command:cmd message:message callback:callback];
}

- (TXBeautyManager *)getBeautyManager {
    return self.beautyManager;
}

- (TXAudioEffectManager *)getAudioEffectManager {
    return [[TRTCCloud sharedInstance] getAudioEffectManager];
}

#pragma mark - private method
- (BOOL)canDelegateResponseMethod:(SEL)method {
    return self.delegate && [self.delegate respondsToSelector:method];
}

#pragma mark - TRTCCloudDelegate
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onError:message:)]) {
        [self.delegate trtcLiveRoom:self onError:errCode message:errMsg];
    }
}

- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(NSString *)warningMsg extInfo:(NSDictionary *)extInfo {
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onWarning:message:)]) {
        [self.delegate trtcLiveRoom:self onWarning:warningCode message:warningMsg];
    }
}

- (void)onEnterRoom:(NSInteger)result {
    [self logApi:@"onEnterRoom", nil];
    if (self.enterRoomCallback) {
        self.enterRoomCallback(0, @"success");
        self.enterRoomCallback = nil;
    }
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    if (self.shouldPlayCdn) {
        return;
    }
    if ([self.joinAnchorInfo.userId isEqualToString:userId]) {
        [self clearJoinState:NO userID:nil]; // 观众端进房信息处理
    }
    if ([self.trtcAction isUserPlaying:userId]) {
        [self.trtcAction startTRTCPlay:userId];
        return;
    }
    if (self.isOwner) {
        if ([self.memberManager.pkAnchor.userId isEqualToString:userId]) {
            self.status = TRTCLiveRoomLiveStatusRoomPK;
            [self.memberManager confirmPKAnchor:userId];
        } else if (!self.memberManager.anchors[userId]) {
            self.status = TRTCLiveRoomLiveStatusLinkMic;
            [self addTempAnchor:userId];
        }
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:userId];
        }
        [self.trtcAction updateMixingParams:self.shouldMixStream status:self.status];
    } else {
        if (!self.memberManager.anchors[userId]) {
            [self addTempAnchor:userId];
        }
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:userId];
        }
    }
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self logApi:@"onremoteUserLeaveRoom", userId, nil];
    if (self.shouldPlayCdn) {
        return;
    }
    if (self.isOwner) {
        if (self.memberManager.anchors[userId] && self.memberManager.anchors.count <= 2) {
            if (self.pkAnchorInfo.userId && self.pkAnchorInfo.roomId) {
                if ([self canDelegateResponseMethod:@selector(trtcLiveRoomOnQuitRoomPK:)]) {
                    [self.delegate trtcLiveRoomOnQuitRoomPK:self];
                }
            }
            [self clearPKState];
            [self clearJoinState:YES userID:userId];
            self.status = TRTCLiveRoomLiveStatusSingle;
        }
        [self.memberManager removeAnchor:userId];
    }
    
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorExit:)]) {
        [self.delegate trtcLiveRoom:self onAnchorExit:userId];
    }
    if (self.isOwner) {
        [self.trtcAction updateMixingParams:self.shouldMixStream status:self.status];
    }
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    [self.trtcAction onFirstVideoFrame:userId];
}

#pragma mark - TRTCLiveRoomMembermanagerDelegate
- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onUserEnter:(TRTCLiveUserInfo *)user isAnchor:(BOOL)isAnchor {
    if (isAnchor) {
        if (self.configCdn && [self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:user.userId];
        }
    } else {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAudienceEnter:)]) {
            [self.delegate trtcLiveRoom:self onAudienceEnter:user];
        }
    }
}

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onUserLeave:(TRTCLiveUserInfo *)user isAnchor:(BOOL)isAnchor {
    if (isAnchor) {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorExit:)]) {
            [self.delegate trtcLiveRoom:self onAnchorExit:user.userId];
        }
    } else {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAudienceExit:)]) {
            [self.delegate trtcLiveRoom:self onAudienceExit:user];
        }
    }
}

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onChangeStreamId:(NSString *)streamID userId:(NSString *)userId {
    if (self.shouldPlayCdn) {
        return;
    }
    if (self.shouldMixStream && ![self.ownerId isEqualToString:userId]) {
        return;
    }
    if (streamID && ![streamID isEqualToString:@""]) {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:userId];
        }
    } else {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorExit:)]) {
            [self.delegate trtcLiveRoom:self onAnchorExit:userId];
        }
    }
}

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onChangeAnchorList:(NSArray<NSDictionary<NSString *,id> *> *)anchorList {
    if (!self.isOwner) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    NSDictionary *data = @{
        @"type": @(self.status),
        @"list": anchorList,
    };
    [TRTCLiveRoomIMAction updateGroupInfoWithRoomID:roomID groupInfo:data callback:^(int code, NSString * _Nonnull message) {
        if (code != 0) {
            NSLog(@"TUILiveKit# 更新IM群%@信息失败：%d,%@", roomID, code, message);
        }
    }];
}

#pragma mark - V2TIMSignalingListener
- (void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data {
    // 通过代理消息把收到的信令邀请发送出去
    NSDictionary *dic = [self checkInviteData:data];
    if (!dic) {
        return;
    }
    NSNumber *actionNumber = [dic objectForKey:@"action"];
    NSInteger action = [actionNumber integerValue];
    switch (action) {
        case TRTCLiveRoomIMActionTypeRequestJoinAnchor:
        {
            // 收到上麦请求
            // inviteID用来回复请求，inviter 发送邀请的人
            [self.requestJoinAnchorDic setObject:inviteID forKey:inviter];
            // 获取观众信息
            TRTCLiveUserInfo *audience = nil;
            for (TRTCLiveUserInfo *obj in self.memberManager.audience) {
                NSLog(@"==== userid: %@", obj.userId);
                if ([inviter isEqualToString:obj.userId]) {
                    audience = obj;
                    break;
                }
            }
            if (audience) {
                [self handleJoinAnchorRequestFromUser:audience reason:dic[@"reason"] ?: @""];
            } else {
                // TODO: 获取用户信息
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeKickoutJoinAnchor:
        {
            // 被踢下麦
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoomOnKickoutJoinAnchor:)]) {
                [self.delegate trtcLiveRoomOnKickoutJoinAnchor:self];
            }
            [self switchRoleOnLinkMic:NO];
            [self responseKickoutJoinAnchorWithRequestID:inviteID];
        }
            break;
        case TRTCLiveRoomIMActionTypeRequestRoomPK:
        {
            [self.responseRoomPKDic setObject:inviteID forKey:inviter];
            NSString *roomId = dic[@"from_room_id"];
            NSString *streamId = dic[@"from_stream_id"];
            if (roomId && streamId) {
                @weakify(self);
                [[V2TIMManager sharedInstance] getUsersInfo:@[inviter] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                    @strongify(self);
                    V2TIMUserFullInfo *info = infoList.firstObject;
                    TRTCLiveUserInfo *userInfo = [[TRTCLiveUserInfo alloc] init];
                    userInfo.userName = info.nickName;
                    userInfo.userId = info.userID;
                    userInfo.avatarURL = info.faceURL;
                    [self handleRoomPKRequestFromUser:userInfo roomId:roomId streamId:streamId];
                } fail:^(int code, NSString *desc) {
                    @strongify(self);
                    if (self.delegate && [self.delegate respondsToSelector:@selector(onError:errMsg:extInfo:)]) {
                        [self.delegate trtcLiveRoom:self onError:code message:desc];
                    }
                }];
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeQuitRoomPK:
        {
            self.status = TRTCLiveRoomLiveStatusSingle;
            TRTCLiveUserInfo *pkAnchor = self.memberManager.pkAnchor;
            if (pkAnchor) {
                [self.memberManager removeAnchor:pkAnchor.userId];
            }
            if (self.pkAnchorInfo.userId && self.pkAnchorInfo.roomId) {
                if ([self canDelegateResponseMethod:@selector(trtcLiveRoomOnQuitRoomPK:)]) {
                    [self.delegate trtcLiveRoomOnQuitRoomPK:self];
                }
            }
            [self clearPKState];
            [self responseQuitRoomPK:inviteID];
        }
            break;
        default:
            break;
    }
}

- (void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    NSDictionary *dic = [self checkInviteData:data];
    if (!dic) {
        return;
    }
    NSNumber *actionNumber = [dic objectForKey:@"action"];
    NSInteger action = [actionNumber integerValue];
    switch (action) {
        case TRTCLiveRoomIMActionTypeRespondJoinAnchor:
        {
            // 这里的逻辑为自己发出的请求收到主播响应
            if (![self.requestJoinAnchorID isEqual:inviteID]) {
                return;
            }
            self.requestJoinAnchorID = nil;
            [self switchRoleOnLinkMic:YES];
            NSString *uuid = self.joinAnchorInfo.uuid;
            @weakify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveCheckStatusTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                if (!self) {
                    return;
                }
                if (self.memberManager.anchors[invitee] == nil && [uuid isEqualToString:self.joinAnchorInfo.uuid]) {
                    [self kickoutJoinAnchor:invitee callback:nil];
                    [self clearJoinState]; // 只需要清理joinAnchorInfo即可
                } else {
                    [self clearJoinState:NO userID:nil];
                }
            });
            NSString *reason = dic[@"reason"] ?: @"";
            if (self.requestJoinAnchorCallback) {
                self.requestJoinAnchorCallback(YES, reason);
                self.requestJoinAnchorCallback = nil;
            }
        }
            break;
        case  TRTCLiveRoomIMActionTypeRespondRoomPK:
        {
            if (![self.requestRoomPKDic.allValues containsObject:inviteID]) {
                return;
            }
            if (self.status == TRTCLiveRoomLiveStatusRoomPK) {
                return;
            }
            [self.requestRoomPKDic removeObjectForKey:invitee];
            NSString *streamId = dic[@"stream_id"];
            if (streamId && self.requestRoomPKCallback) {
                [[V2TIMManager sharedInstance] getUsersInfo:@[invitee] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                    V2TIMUserFullInfo *info = infoList.firstObject;
                    TRTCLiveUserInfo *userInfo = [[TRTCLiveUserInfo alloc] init];
                    userInfo.userName = info.nickName;
                    userInfo.userId = info.userID;
                    userInfo.avatarURL = info.faceURL;
                    self.status = TRTCLiveRoomLiveStatusRoomPK;
                    [self startRoomPKWithUser:userInfo streamId:streamId];
                } fail:^(int code, NSString *desc) {
                    
                }];
                NSString *uuid = self.pkAnchorInfo.uuid;
                @weakify(self)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((trtcLiveCheckStatusTimeOut + 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self)
                    if (!self) {
                        return;
                    }
                    if (self.status != TRTCLiveRoomLiveStatusRoomPK && [uuid isEqualToString:self.pkAnchorInfo.uuid]) {
                        [self quitRoomPK:nil];
                        [self clearPKState];
                    }
                });
                NSString *reason = dic[@"reason"] ?: @"";
                if (self.requestRoomPKCallback) {
                    self.requestRoomPKCallback(YES, reason);
                    self.requestRoomPKCallback = nil;
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    NSDictionary *dic = [self checkInviteData:data];
    if (!dic) {
        return;
    }
    NSNumber *actionNumber = [dic objectForKey:@"action"];
    NSInteger action = [actionNumber integerValue];
    switch (action) {
        case TRTCLiveRoomIMActionTypeRespondJoinAnchor:
        {
            if (![self.requestJoinAnchorID isEqual:inviteID]) {
                return;
            }
            self.requestJoinAnchorID = nil;
            [self clearJoinState]; // 观众端清理
            NSString *reason = dic[@"reason"] ?: @"";
            if (self.requestJoinAnchorCallback) {
                self.requestJoinAnchorCallback(NO, reason);
                self.requestJoinAnchorCallback = nil;
            }
        }
            break;
        case  TRTCLiveRoomIMActionTypeRespondRoomPK:
        {
            if (![self.requestRoomPKDic.allValues containsObject:inviteID]) {
                return;
            }
            [self.requestRoomPKDic removeObjectForKey:invitee];
            NSString *streamId = dic[@"stream_id"];
            if (streamId && self.requestRoomPKCallback) {
                [self clearPKState];
                NSString *reason = dic[@"reason"] ?: @"";
                if (self.requestRoomPKCallback) {
                    self.requestRoomPKCallback(NO, reason);
                    self.requestRoomPKCallback = nil;
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data {
    NSDictionary *dic = [self checkInviteData:data];
    if (!dic) {
        return;
    }
    NSNumber *actionNumber = [dic objectForKey:@"action"];
    NSInteger action = [actionNumber integerValue];
    switch (action) {
        case TRTCLiveRoomIMActionTypeCancelRequestJoinAnchor:
            if (![self.requestJoinAnchorDic.allValues containsObject:inviteID]) {
                return;
            }
            [self.requestJoinAnchorDic removeObjectForKey:inviter];
            if (self.delegate && [self.delegate respondsToSelector:@selector(trtcLiveRoom:onCancelJoinAnchor:reason:)]) {
                TRTCLiveUserInfo *audience = nil;
                for (TRTCLiveUserInfo *obj in self.memberManager.audience) {
                    NSLog(@"==== userid: %@", obj.userId);
                    if ([inviter isEqualToString:obj.userId]) {
                        audience = obj;
                        break;
                    }
                }
                if (audience) {
                    [self.delegate trtcLiveRoom:self onCancelJoinAnchor:audience reason:@"取消连麦请求"];
                }
                
            }
            break;
        case TRTCLiveRoomIMActionTypeCancelRequestRoomPK:
        {
            if (![self.responseRoomPKDic.allValues containsObject:inviteID]) {
                return;
            }
            [self.responseRoomPKDic removeObjectForKey:inviter];
            @weakify(self);
            [[V2TIMManager sharedInstance] getUsersInfo:@[inviter] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self);
                V2TIMUserFullInfo *info = infoList.firstObject;
                TRTCLiveUserInfo *userInfo = [[TRTCLiveUserInfo alloc] init];
                userInfo.userName = info.nickName;
                userInfo.userId = info.userID;
                userInfo.avatarURL = info.faceURL;
                if (self.delegate && [self.delegate respondsToSelector:@selector(trtcLiveRoom:onCancelRoomPK:)]) {
                    [self.delegate trtcLiveRoom:self onCancelRoomPK:userInfo];
                }
            } fail:^(int code, NSString *desc) {
                @strongify(self);
                if (self.delegate && [self.delegate respondsToSelector:@selector(onError:errMsg:extInfo:)]) {
                    [self.delegate trtcLiveRoom:self onError:code message:desc];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)inviteeList {
    if ([self.requestJoinAnchorID isEqualToString:inviteID]) {
        // 自己请求上麦超时
        if (self.requestJoinAnchorCallback) {
            self.requestJoinAnchorCallback(NO, @"主播未回应连麦请求");
            self.requestJoinAnchorCallback = nil;
            [self clearJoinState]; // 观众端清理
        }
        return;
    }
    if ([self.requestJoinAnchorDic.allValues containsObject:inviteID]) {
        // 作为主播，某个观众的上麦请求超时
        [self.requestJoinAnchorDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:inviteID]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(trtcLiveRoom:audienceRequestJoinAnchorTimeout:)]) {
                    [self.delegate trtcLiveRoom:self audienceRequestJoinAnchorTimeout:key];
                }
                *stop = YES;
                [self.requestJoinAnchorDic removeObjectForKey:key];
                [self clearJoinState:YES userID:key]; // 主播端清理
            }
        }];
        
        return;
    }
    if ([self.requestRoomPKDic.allValues containsObject:inviteID]) {
        // 作为主播，自己发出的PK请求超时
        if (self.requestRoomPKCallback) {
            self.requestRoomPKCallback(NO, @"主播未回应跨房PK请求");
            self.requestRoomPKCallback = nil;
            [self clearPKState];
        }
        return;
    }
    if ([self.responseRoomPKDic.allValues containsObject:inviteID]) {
        // 作为主播，自己收到的PK请求超时
        if (self.delegate && [self.delegate respondsToSelector:@selector(trtcLiveRoom:anchorRequestRoomPKTimeout:)]) {
            [self.responseRoomPKDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:inviteID]) {
                    [self.delegate trtcLiveRoom:self anchorRequestRoomPKTimeout:key];
                    *stop = YES;
                    [self.responseRoomPKDic removeObjectForKey:key];
                }
            }];
        }
        [self clearPKState];
        return;
    }
}

- (NSDictionary * _Nullable)checkInviteData:(NSString *)data {
    if (!data) {
        return nil;
    }
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"信令消息解析失败%@", error);
        return nil;
    }
    NSString *versionString = [dic objectForKey:@"version"];
    if (![versionString isEqualToString:trtcLiveRoomProtocolVersion]) {
        NSLog(@"消息版本号不匹配");
        return nil;
    }
    NSString *businessID = [dic objectForKey:Signal_Business_ID];
    if (![businessID isEqualToString:Signal_Business_Live]) {
        NSLog(@"非LiveRoom信令消息，不予响应");
        return nil;
    }
    return dic;
}

#pragma mark - V2TIMAdvancedMsgListener
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    if (msg.groupID.length == 0 || ![msg.groupID isEqual:self.roomID]) {
        return;
    }
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        V2TIMCustomElem *elem = msg.customElem;
        NSData *data = elem.data;
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            return;
        }
        NSNumber* action = json[@"action"] ?: @(0);
        id version = json[@"version"] ?: @"";
        BOOL isString = [version isKindOfClass:[NSString class]];
        if (isString && ![version isEqualToString:trtcLiveRoomProtocolVersion]) {
            // 处理兼容性问题
        }
        [self handleActionMessage:[action intValue] elem:elem message:msg json:json];
    } else if (msg.elemType == V2TIM_ELEM_TYPE_TEXT) {
        if (msg.textElem) {
            [self handleActionMessage:TRTCLiveRoomIMActionTypeRoomTextMsg elem:msg.textElem message:msg json:@{}];
        }
    }
}

- (void)handleActionMessage:(TRTCLiveRoomIMActionType)action elem:(V2TIMElem *)elem message:(V2TIMMessage *)message json:(NSDictionary<NSString *, id> *)json {
    NSDate* sendTime = message.timestamp;
    // 超过10秒默认超时
    if (sendTime && sendTime.timeIntervalSinceNow < -10) {
        return;
    }
    NSString *userID = message.sender;
    if (!userID) {
        return;
    }
    TRTCLiveUserInfo *liveUser = [[TRTCLiveUserInfo alloc] init];
    liveUser.userId = userID;
    liveUser.userName = message.nickName ?: @"";
    liveUser.avatarURL = message.faceURL ?: @"";
    if (!self.memberManager.anchors[liveUser.userId]) {
        NSLog(@"[TRTCRoom][handleActionMessage] action:%@, json:%@", @(action), json);
        if (action != TRTCLiveRoomIMActionTypeUnknown) {
            [self.memberManager addAudience:liveUser];
        }
    }
    
    switch (action) {
        case TRTCLiveRoomIMActionTypeNotifyJoinAnchorStream:
        {
            NSString *streamId = json[@"stream_id"];
            if (streamId) {
                [self startLinkMic:userID streamId:streamId];
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeRoomTextMsg:
        {
            V2TIMTextElem *textElem = (V2TIMTextElem *)elem;
            NSString *text = textElem.text;
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRecvRoomTextMsg:fromUser:)]) {
                [self.delegate trtcLiveRoom:self onRecvRoomTextMsg:text fromUser:liveUser];
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeRoomCustomMsg:
        {
            NSString *command = json[@"command"];
            NSString *message = json[@"message"];
            if (command && message) {
                if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRecvRoomCustomMsgWithCommand:message:fromUser:)]) {
                    [self.delegate trtcLiveRoom:self onRecvRoomCustomMsgWithCommand:command message:message fromUser:liveUser];
                }
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeUpdateGroupInfo:
        {
            [self.memberManager updateAnchorsWithGroupinfo:json];
            NSNumber *roomStatus = json[@"type"];
            if (roomStatus) {
                self.status = [roomStatus intValue];
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeUnknown:
            NSLog(@"TRTCLiveRoom:未知命令");
            break;
        default:
            TRTCLog(@"TRTCLiveRoom:未知消息type");
            break;
    }
}

#pragma mark - V2TIMGroupListener
- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    for (V2TIMGroupMemberInfo *member in memberList) {
        TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
        user.userId = member.userID;
        user.userName = member.nickName ?: @"";
        user.avatarURL = member.faceURL ?: @"";
        [self.memberManager addAudience:user];
    }
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member {
    [self.memberManager removeMember:member.userID];
}

- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    for (V2TIMGroupMemberInfo *member in memberList) {
        TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
        user.userId = member.userID;
        user.userName = member.nickName ?: @"";
        user.avatarURL = member.faceURL ?: @"";
        [self.memberManager addAudience:user];
    }
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray<V2TIMGroupChangeInfo *> *)changeInfoList {
    __block V2TIMGroupChangeInfo *info = nil;
    [changeInfoList enumerateObjectsUsingBlock:^(V2TIMGroupChangeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
            info = obj;
            *stop = YES;
        }
    }];
    if (info) {
        NSDictionary *customInfo = [info.value mj_JSONObject];
        NSNumber *roomStatus = customInfo[@"type"];
        self.status = [roomStatus intValue];
    }
}

- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [self handleRoomDismissed:YES];
}

- (void)onRevokeAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    [self handleRoomDismissed:YES];
}


#pragma mark - Actions
- (void)notifyAvailableStreams {
    if (self.shouldMixStream) {
        if (self.ownerId && [self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:self.ownerId];
        }
    } else {
        [self.memberManager.anchors.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
                [self.delegate trtcLiveRoom:self onAnchorEnter:obj];
            }
        }];
    }
}

- (void)handleRoomDismissed:(BOOL)isOwnerDeleted {
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    if (self.isOwner && !isOwnerDeleted) {
        [self destroyRoom:nil];
    } else {
        [self exitRoom:nil];
    }
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRoomDestroy:)]) {
        [self.delegate trtcLiveRoom:self onRoomDestroy:roomID];
    }
}

- (void)handleJoinAnchorRequestFromUser:(TRTCLiveUserInfo *)user reason:(NSString *)reason {
    // 主播端收到上麦请求了
    if (self.status == TRTCLiveRoomLiveStatusRoomPK || self.pkAnchorInfo.userId != nil) {
        [self responseJoinAnchor:user.userId agree:NO reason:@"主播正在跨房PK中"];
        return;
    }
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRequestJoinAnchor:reason:)]) {
        [self.delegate trtcLiveRoom:self onRequestJoinAnchor:user reason:reason];
    }
}

- (void)startLinkMic:(NSString *)userId streamId:(NSString *)streamId {
    self.status = TRTCLiveRoomLiveStatusLinkMic;
    [self.memberManager switchMember:userId toAnchor:YES streamId:streamId];
}

- (void)stopLinkMic:(NSString *)userId {
    self.status = self.memberManager.anchors.count <= 2 ? TRTCLiveRoomLiveStatusSingle : TRTCLiveRoomLiveStatusLinkMic;
    [self.memberManager switchMember:userId toAnchor:NO streamId:nil];
    [self.onJoinAnchorDic removeObjectForKey:userId];
}

- (void)switchRoleOnLinkMic:(BOOL)isLinkMic {
    [self switchRoleOnLinkMic:isLinkMic needDelayPlay:NO];
}

- (void)switchRoleOnLinkMic:(BOOL)isLinkMic needDelayPlay:(BOOL)needDelayPlay {
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        return;
    }
    [self.memberManager switchMember:me.userId toAnchor:isLinkMic streamId:nil];
    // 配置了CDN的情况下，上下麦的过程中需要将播放流进行切换
    if (self.configCdn) {
        if (needDelayPlay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /// 延迟1秒 防止在切换播放界面是，因为CDN混流延迟拉取到带连麦小窗的 cdn 画面。
                [self.trtcAction togglePlay:!isLinkMic];
            });
        } else {
            [self.trtcAction togglePlay:!isLinkMic];
        }
    }
    if (!isLinkMic) {
        // 这里只有下麦的时候需要在这里切换角色。上麦的时候切换角色的逻辑需要在开始推流后调用。
        [self.trtcAction switchRole:TRTCRoleAudience];
    }
}

- (void)handleRoomPKRequestFromUser:(TRTCLiveUserInfo *)user roomId:(NSString *)roomId streamId:(NSString *)streamId {
    if (self.status == TRTCLiveRoomLiveStatusLinkMic || self.onJoinAnchorDic.count > 0) {
        [self responseRoomPKWithUserID:user.userId agree:NO reason:@"主播正在连麦中"];
        return;
    }
    if ((self.pkAnchorInfo.userId != nil && ![self.pkAnchorInfo.roomId isEqualToString:roomId]) || self.status == TRTCLiveRoomLiveStatusRoomPK) {
        [self responseRoomPKWithUserID:user.userId agree:NO reason:@"主播正在PK中"];
        return;
    }
    if ([self.pkAnchorInfo.userId isEqualToString:user.userId]) {
        return;
    }
    self.pkAnchorInfo.userId = user.userId;
    self.pkAnchorInfo.roomId = roomId;
    self.pkAnchorInfo.uuid = [[NSUUID UUID] UUIDString];

    [self prepareRoomPKWithUser:user streamId:streamId];
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRequestRoomPK:)]) {
        [self.delegate trtcLiveRoom:self onRequestRoomPK:user];
    }
}

- (void)clearPKState {
    [self.pkAnchorInfo reset];
    [self.memberManager removePKAnchor];
}

- (void)clearJoinState {
    [self clearJoinState:YES userID:nil];
}

- (void)clearJoinState:(BOOL)shouldRemove userID:(NSString *)userID {
    if (shouldRemove && self.joinAnchorInfo.userId) {
        [self.memberManager removeAnchor:self.joinAnchorInfo.userId];
    }
    [self.joinAnchorInfo reset];
    if (userID) {
        [self.onJoinAnchorDic removeObjectForKey:userID];
    }
}


/// 观众连麦后，添加的临时主播
/// @param userId 主播ID
- (void)addTempAnchor:(NSString *)userId {
    TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
    user.userId = userId;
    [self.memberManager addAnchor:user];
}

/// 预先保存待PK的主播，等收到视频流后，再确认PK状态
/// @param user 主播
/// @param streamId 流id
- (void)prepareRoomPKWithUser:(TRTCLiveUserInfo *)user streamId:(NSString *)streamId {
    user.streamId = streamId;
    [self.memberManager prepaerPKAnchor:user];
}

// 发起PK的主播，收到确认回复后，调到该函数开启跨房PK
- (void)startRoomPKWithUser:(TRTCLiveUserInfo *)user streamId:(NSString *)streamId {
    NSString *roomId = self.pkAnchorInfo.roomId;
    if (!roomId) {
        return;
    }
    [self prepareRoomPKWithUser:user streamId:streamId];
    [self.trtcAction startRoomPK:roomId userId:user.userId];
}

#pragma mark - Beauty
- (void)setFilter:(UIImage *)image {
    [self.trtcAction setFilter:image];
}

- (void)setFilterConcentration:(float)concentration {
    [self.trtcAction setFilterConcentration:concentration];
}

- (void)setGreenScreenFile:(NSURL *)fileUrl {
    [self.trtcAction setGreenScreenFile:fileUrl];
}

#pragma mark - Utils
- (void)logApi:(NSString *)api, ... NS_REQUIRES_NIL_TERMINATION {
    
}

- (TRTCLiveUserInfo *)checkUserLogIned:(Callback)callback {
    if (!self.me) {
        if (callback) {
            callback(-1, @"还未登录");
        }
        return nil;
    }
    return self.me;
}

- (NSString *)checkRoomJoined:(Callback)callback {
    if ([self.roomID length] == 0) {
        if (callback) {
            callback(-1, @"还未进入房间");
        }
        return nil;
    }
    return self.roomID;
}

- (BOOL)checkRoomUnjoined:(Callback)callback {
    if ([self.roomID length] > 0) {
        if (callback) {
            callback(-1, @"当前在房间中");
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkIsOwner:(Callback)callback {
    if (!self.isOwner) {
        if (callback) {
            callback(-1, @"只有主播才能操作");
        }
        return NO;
    }
    return YES;
}

- (NSString *)checkIsPublishing:(Callback)callback {
    if (!self.me.streamId) {
        if (callback) {
             callback(-1, @"只有推流后才能操作");
        }
        return nil;
    }
    return self.me.streamId;
}

- (void)reset {
    self.enterRoomCallback = nil;
    [self.trtcAction exitRoom];
    [self.trtcAction stopAllPlay:self.shouldPlayCdn];
    self.trtcAction.roomId = nil;
    self.status = TRTCLiveRoomLiveStatusNone;
    [self clearPKState];
    [self clearJoinState];
    [self.onJoinAnchorDic removeAllObjects];
    [self.memberManager clearMembers];
    self.curRoomInfo = nil;
}

#pragma mark - private readOnly property
- (BOOL)isOwner {
    if (self.me.userId) {
        return [self.me.userId isEqualToString:self.memberManager.ownerId];
    }
    return NO;
}

- (BOOL)isAnchor {
    if (self.me.userId) {
        return self.memberManager.anchors[self.me.userId] != nil;
    }
    return false;
}

- (BOOL)configCdn {
    return self.useCDNFirst;
}

- (BOOL)shouldPlayCdn {
    return self.configCdn && !self.isAnchor;
}

- (BOOL)shouldMixStream {
    switch (self.status) {
        case TRTCLiveRoomLiveStatusNone:
            return NO;
        case TRTCLiveRoomLiveStatusSingle:
            return NO;
        case TRTCLiveRoomLiveStatusLinkMic:
            return self.mixingLinkMicStream;
        case TRTCLiveRoomLiveStatusRoomPK:
            return self.mixingPKStream;
        default:
            break;
    }
    return NO;
}

@end
