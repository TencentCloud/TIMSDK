//
//  TRTCLiveRoomMemberManager.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/11.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TRTCLiveRoomMemberManager;
@class TRTCLiveUserInfo;
@protocol TRTCLiveRoomMembermanagerDelegate <NSObject>

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onUserEnter:(TRTCLiveUserInfo *)user isAnchor:(BOOL)isAnchor;

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onUserLeave:(TRTCLiveUserInfo *)user isAnchor:(BOOL)isAnchor;

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onChangeStreamId:(NSString *)streamID userId:(NSString *)userId;

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onChangeAnchorList:(NSArray<NSDictionary<NSString *, id> *> *)anchorList;

@end

@interface TRTCLiveRoomMemberManager : NSObject

@property (nonatomic, weak)id<TRTCLiveRoomMembermanagerDelegate> delegate;
@property (nonatomic, copy) NSString *ownerId;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TRTCLiveUserInfo *> *anchors;
@property (nonatomic, strong, readonly) NSArray<TRTCLiveUserInfo *> *audience;
@property (nonatomic, strong, nullable) TRTCLiveUserInfo *pkAnchor;

- (void)setOwner:(TRTCLiveUserInfo *)user;

- (void)addAnchor:(TRTCLiveUserInfo *)user;

- (void)removeAnchor:(NSString *)userId;

- (void)addAudience:(TRTCLiveUserInfo *)user;

- (void)removeMember:(NSString *)userId;

- (void)prepaerPKAnchor:(TRTCLiveUserInfo *)user;

- (void)confirmPKAnchor:(NSString *)userId;

- (void)removePKAnchor;

- (void)switchMember:(NSString *)userId toAnchor:(BOOL)toAnchor streamId:(NSString * _Nullable)streamId;

- (void)updateStream:(NSString *)userId streamId:(NSString * _Nullable)streamId;

- (void)updateProfile:(NSString *)userId name:(NSString *)name avatar:(NSString *)avatar;

- (void)updateAnchorsWithGroupinfo:(NSDictionary<NSString *, id> *)groupInfo;

- (void)setmembers:(NSArray<TRTCLiveUserInfo *> *)members groupInfo:(NSDictionary<NSString *, id> *)groupInfo;

- (void)clearMembers;

@end

NS_ASSUME_NONNULL_END
