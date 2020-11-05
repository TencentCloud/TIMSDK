//
//  TRTCLiveRoomMemberManager.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/11.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCLiveRoomMemberManager.h"
#import "TRTCLiveRoomDef.h"
#import "MJExtension.h"

@interface TRTCLiveRoomMemberManager ()

@property (nonatomic, strong) NSMutableArray<TRTCLiveUserInfo *> *allMembers;

@end

@implementation TRTCLiveRoomMemberManager

#pragma mark - 属性懒加载
- (NSMutableArray<TRTCLiveUserInfo *> *)allMembers {
    if (!_allMembers) {
        _allMembers = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return _allMembers;
}

- (NSMutableDictionary<NSString *,TRTCLiveUserInfo *> *)anchors {
    if (!_anchors) {
        _anchors = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _anchors;
}

- (NSArray<TRTCLiveUserInfo *> *)audience {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    [self.allMembers enumerateObjectsUsingBlock:^(TRTCLiveUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self.anchors.allKeys containsObject:obj.userId]) {
            [result addObject:obj];
        }
    }];
    return result;
}
#pragma mark - public function
- (void)setOwner:(TRTCLiveUserInfo *)user {
    [self.allMembers addObject:user];
    self.anchors[user.userId] = user;
    self.ownerId = user.userId;
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
        [self.delegate memberManager:self onUserEnter:user isAnchor:YES];
    }
    if ([self canDelegateResponseMethod:@selector(memberManager:onChangeAnchorList:)]) {
        [self.delegate memberManager:self onChangeAnchorList:[self anchorDataList]];
    }
}

- (void)addAnchor:(TRTCLiveUserInfo *)user {
    self.anchors[user.userId] = user;
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
        [self.delegate memberManager:self onUserEnter:user isAnchor:YES];
    }
    if ([self canDelegateResponseMethod:@selector(memberManager:onChangeAnchorList:)]) {
        [self.delegate memberManager:self onChangeAnchorList:[self anchorDataList]];
    }
}

- (void)removeAnchor:(NSString *)userId {
    if (self.pkAnchor && [self.pkAnchor.userId isEqualToString:userId]) {
        self.pkAnchor = nil;
    }
    TRTCLiveUserInfo *anchor = self.anchors[userId];
    if (anchor) {
        [self.anchors removeObjectForKey:userId];
        if ([self canDelegateResponseMethod:@selector(memberManager:onUserLeave:isAnchor:)]) {
            [self.delegate memberManager:self onUserLeave:anchor isAnchor:YES];
        }
        if ([self canDelegateResponseMethod:@selector(memberManager:onChangeAnchorList:)]) {
            [self.delegate memberManager:self onChangeAnchorList:[self anchorDataList]];
        }
    }
}

- (void)addAudience:(TRTCLiveUserInfo *)user {
    for (TRTCLiveUserInfo *obj in self.allMembers) {
        if ([user.userId isEqualToString:obj.userId]) {
            return;
        }
    }
    [self.allMembers addObject:user];
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
        [self.delegate memberManager:self onUserEnter:user isAnchor:NO];
    }
}

- (void)removeMember:(NSString *)userId {
    TRTCLiveUserInfo* user = nil;
    for (TRTCLiveUserInfo *obj in self.allMembers) {
        if ([userId isEqualToString:obj.userId]) {
            user = obj;
            break;
        }
    }
    if (!user) {
        return;
    }
    [self.allMembers removeObject:user];
    TRTCLiveUserInfo *anchor = self.anchors[user.userId];
    if (anchor) {
        [self removeAnchor:anchor.userId];
    } else {
        if ([self canDelegateResponseMethod:@selector(memberManager:onUserLeave:isAnchor:)]) {
            [self.delegate memberManager:self onUserLeave:user isAnchor:NO];
        }
    }
}

- (void)prepaerPKAnchor:(TRTCLiveUserInfo *)user {
    self.pkAnchor = user;
}

- (void)confirmPKAnchor:(NSString *)userId {
    // FIXME: 逻辑有问题
    if (self.pkAnchor) {
        self.anchors[self.pkAnchor.userId] = self.pkAnchor;
        if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
            [self.delegate memberManager:self onUserEnter:self.pkAnchor isAnchor:YES];
        }
        if ([self canDelegateResponseMethod:@selector(memberManager:onChangeAnchorList:)]) {
            [self.delegate memberManager:self onChangeAnchorList:[self anchorDataList]];
        }
    }
}

- (void)removePKAnchor {
    self.pkAnchor = nil;
}

- (void)switchMember:(NSString *)userId toAnchor:(BOOL)toAnchor streamId:(NSString *)streamId {
    TRTCLiveUserInfo* user = nil;
    for (TRTCLiveUserInfo *obj in self.allMembers) {
        if ([userId isEqualToString:obj.userId]) {
            user = obj;
        }
    }
    if (!user) {
        return;
    }
    if (toAnchor) {
        user.streamId = streamId;
        if (!self.anchors[user.userId]) {
            // FIXME: 这里用户连麦麦，会切换身份。目前需求，用户上麦，不会回调房间成员变化信息（实际确实发生了变化），如果需要反馈，打开此处代码。
//            if ([self canDelegateResponseMethod:@selector(memberManager:onUserLeave:isAnchor:)]) {
//                [self.delegate memberManager:self onUserLeave:user isAnchor:NO];
//            }
//            if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
//                [self.delegate memberManager:self onUserEnter:user isAnchor:YES];
//            }
        }
        self.anchors[user.userId] = user;
    } else {
        user.streamId = nil;
        [self.anchors removeObjectForKey:user.userId];
//        if ([self canDelegateResponseMethod:@selector(memberManager:onUserLeave:isAnchor:)]) {
//            [self.delegate memberManager:self onUserLeave:user isAnchor:YES];
//        }
//        if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
//            [self.delegate memberManager:self onUserEnter:user isAnchor:NO];
//        }
    }
    if ([self canDelegateResponseMethod:@selector(memberManager:onChangeAnchorList:)]) {
        [self.delegate memberManager:self onChangeAnchorList:[self anchorDataList]];
    }
}

- (void)updateStream:(NSString *)userId streamId:(NSString *)streamId {
    TRTCLiveUserInfo *anchor = self.anchors[userId];
    if (!anchor.streamId && !streamId) {
        return;
    }
    if (anchor && ![anchor.streamId isEqualToString:streamId]) {
        anchor.streamId = streamId;
        if ([self canDelegateResponseMethod:@selector(memberManager:onChangeStreamId:userId:)]) {
            [self.delegate memberManager:self onChangeStreamId:streamId userId:anchor.userId];
        }
        if ([self canDelegateResponseMethod:@selector(memberManager:onChangeAnchorList:)]) {
            [self.delegate memberManager:self onChangeAnchorList:[self anchorDataList]];
        }
    }
}

- (void)updateProfile:(NSString *)userId name:(NSString *)name avatar:(NSString *)avatar {
    TRTCLiveUserInfo *user = self.anchors[userId];
    if (user) {
        user.userName = name;
        user.avatarURL = avatar;
        if ([self canDelegateResponseMethod:@selector(memberManager:onChangeAnchorList:)]) {
            [self.delegate memberManager:self onChangeAnchorList:[self anchorDataList]];
        }
    } else {
        TRTCLiveUserInfo *audience = nil;
        for (TRTCLiveUserInfo *obj in self.allMembers) {
            if ([userId isEqualToString:obj.userId]) {
                audience = obj;
                break;
            }
        }
        if (!audience) {
            return;
        }
        audience.userName = name;
        audience.avatarURL =avatar;
    }
    // TODO: 是不是给一个群成员资料便跟的通知（Swift代码copy）
}

- (void)updateAnchorsWithGroupinfo:(NSDictionary<NSString *,id> *)groupInfo {
    NSArray *anchorList = groupInfo[@"list"];
    if (!anchorList) {
#if DEBUG
        NSAssert(NO, @"主播列表为空");
#endif
        return;
    }
    [self handleNewOrUpdatedAnchor:anchorList];
}

- (void)setmembers:(NSArray<TRTCLiveUserInfo *> *)members groupInfo:(NSDictionary<NSString *,id> *)groupInfo {
    NSArray<NSDictionary *> *anchorList = groupInfo[@"list"];
    if (!anchorList) {
        return;
    }
    self.allMembers = [members mutableCopy];
    [anchorList enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *userId = obj[@"userId"];
        NSString *name = obj[@"name"];
        if (!userId || !name) {
            return;
        }
        NSString *streamId = obj[@"streamId"];
        TRTCLiveUserInfo *user = nil;
        for (TRTCLiveUserInfo *obj in self.allMembers) {
            if ([userId isEqualToString:obj.userId]) {
                user = obj;
                break;
            }
        }
        if (user) {
            user.streamId = streamId;
            self.anchors[userId] = user;
            if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
                [self.delegate memberManager:self onUserEnter:user isAnchor:YES];
            }
        } else {
            NSString* avatar = obj[@"avatar"];
            [self syncPKAnchor:userId name:name avatar:avatar streamId:streamId];
        }
    }];
    TRTCLiveUserInfo *owner = nil;
    for (TRTCLiveUserInfo *obj in self.allMembers) {
        if (obj.isOwner) {
            owner = obj;
            break;
        }
    }
    if (owner) {
        self.anchors[owner.userId] = owner;
        self.ownerId = owner.userId;
    }
}

- (void)clearMembers {
    [self.anchors removeAllObjects];
    [self.allMembers removeAllObjects];
    self.pkAnchor = nil;
}

#pragma mark - Private function
- (void)handleNewOrUpdatedAnchor:(NSArray<NSDictionary *> *)anchorList {
    [anchorList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *userId = obj[@"userId"];
        NSString *name = obj[@"name"];
        if (!(userId && name)) {
            return;;
        }
        NSString *avatar = obj[@"avatar"];
        NSString *streamId = obj[@"streamId"];
        TRTCLiveUserInfo *anchor = self.anchors[userId];
        TRTCLiveUserInfo *audience = nil;
        for (TRTCLiveUserInfo *obj in self.allMembers) {
            if ([obj.userId isEqualToString:userId]) {
                audience = obj;
                break;
            }
        }
        if (anchor) {
            [self syncProfile:anchor name:name avatar:avatar];
            [self updateAnchor:anchor streamId:streamId];
        } else if (audience) {
            [self syncProfile:audience name:name avatar:avatar];
            [self changeToAnchor:audience streamId:streamId];
        } else {
            [self syncPKAnchor:userId name:name avatar:avatar streamId:streamId];
        }
    }];
}

- (void)handleRemoveAnchor:(NSArray<NSDictionary<NSString *, id> *> *)anchorList {
    NSMutableArray *newAnchorIds = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSDictionary * obj in anchorList) {
        NSString *userId = obj[@"userId"];
        if (userId) {
            [newAnchorIds addObject:userId];
        }
    }
    [self.anchors enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TRTCLiveUserInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([newAnchorIds containsObject:key]) {
            // FIXME: 检查这里的实现是否和Swift的表达一致
            if ([self.allMembers containsObject:obj]) {
                [self changeToAudience:obj];
            } else {
                [self removePKAnchor];
            }
        }
    }];
}

- (void)updateAnchor:(TRTCLiveUserInfo *)anchor streamId:(NSString *)streamId {
    if ([anchor.streamId isEqualToString:streamId]) {
        return;
    }
    anchor.streamId = streamId;
    if ([self canDelegateResponseMethod:@selector(memberManager:onChangeStreamId:userId:)]) {
        [self.delegate memberManager:self onChangeStreamId:streamId userId:anchor.userId];
    }
}

- (void)changeToAnchor:(TRTCLiveUserInfo *)user streamId:(NSString *)streamId {
    user.streamId = streamId;
    self.anchors[user.userId] = user;
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserLeave:isAnchor:)]) {
        [self.delegate memberManager:self onUserLeave:user isAnchor:NO];
    }
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
        [self.delegate memberManager:self onUserEnter:user isAnchor:YES];
    }
}

- (void)changeToAudience:(TRTCLiveUserInfo *)user {
    user.streamId = nil;
    [self.anchors removeObjectForKey:user.userId];
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserLeave:isAnchor:)]) {
        [self.delegate memberManager:self onUserLeave:user isAnchor:YES];
    }
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
        [self.delegate memberManager:self onUserEnter:user isAnchor:NO];
    }
}

- (void)syncProfile:(TRTCLiveUserInfo *)user name:(NSString *)name avatar:(NSString *)avatar {
    user.userName = name;
    user.avatarURL = avatar;
}

- (void)syncPKAnchor:(NSString *)userId name:(NSString *)name avatar:(NSString *)avatar streamId:(NSString *)streamId {
    TRTCLiveUserInfo* user = [[TRTCLiveUserInfo alloc] init];
    user.userId = userId;
    user.userName = name;
    user.avatarURL = avatar;
    user.streamId = streamId;
    self.anchors[user.userId] = user;
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserEnter:isAnchor:)]) {
        [self.delegate memberManager:self onUserEnter:user isAnchor:YES];
    }
}

- (void)removePKAnchor:(TRTCLiveUserInfo *)user {
    [self.anchors removeObjectForKey:user.userId];
    if ([self canDelegateResponseMethod:@selector(memberManager:onUserLeave:isAnchor:)]) {
        [self.delegate memberManager:self onUserLeave:user isAnchor:true];
    }
}

- (NSArray<NSDictionary<NSString *, id> *> *)anchorDataList {
    if (self.ownerId && ![self.ownerId isEqualToString:@""]) {
        TRTCLiveUserInfo *user = self.anchors[self.ownerId];
        if (user) {
            [TRTCLiveUserInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                return @{
                    @"userName": @"name",
                    @"userId": @"userId",
                    @"streamId" : @"streamId"
                };
            }];
            return @[[user mj_keyValuesWithKeys:@[@"userName", @"userId", @"streamId"]]];
        }
    }
    return @[];
}

- (BOOL)canDelegateResponseMethod:(SEL)method {
    return self.delegate && [self.delegate respondsToSelector:method];
}

@end
