//
//  TRTCLiveRoomDef.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/7.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCLiveRoomDef.h"
#import <ImSDK/ImSDK.h>

@implementation TRTCCreateRoomParam

- (instancetype)initWithRoomName:(NSString *)roomName coverUrl:(NSString *)coverUrl{
    self = [super init];
    if (self) {
        self.roomName = roomName;
        self.coverUrl = coverUrl;
    }
    return self;
}

@end

@implementation TRTCLiveRoomConfig

- (instancetype)initWithAttachedTUIkit:(BOOL)isAttachedTUIKit {
    self = [super init];
    if (self) {
        self.isAttachedTUIKit = isAttachedTUIKit;
    }
    return self;
}

@end

@implementation TRTCLiveRoomInfo

- (instancetype)initWithRoomId:(NSString *)roomId
                      roomName:(NSString *)roomName
                      coverUrl:(NSString *)coverUrl
                       ownerId:(NSString *)ownerId
                     ownerName:(NSString *)ownerName
                     streamUrl:(NSString *)streamUrl
                   memberCount:(NSInteger)memberCount
                    roomStatus:(TRTCLiveRoomLiveStatus)roomStatus{
    self = [super init];
    if (self) {
        self.roomId = roomId;
        self.roomName = roomName;
        self.coverUrl = coverUrl;
        self.ownerId = ownerId;
        self.ownerName = ownerName;
        self.streamUrl = streamUrl;
        self.memberCount = memberCount;
        self.roomStatus = roomStatus;
    }
    return self;
}

@end

@implementation TRTCLiveUserInfo

- (instancetype)initWithProfile:(V2TIMGroupMemberFullInfo *)profile {
    self = [super init];
    if (self) {
        self.userId = profile.userID;
        self.userName = profile.nickName ?: @"";
        self.avatarURL = profile.faceURL ?: @"";
        self.isOwner = profile.role == V2TIM_GROUP_MEMBER_ROLE_SUPER;
    }
    return self;
}

@end
