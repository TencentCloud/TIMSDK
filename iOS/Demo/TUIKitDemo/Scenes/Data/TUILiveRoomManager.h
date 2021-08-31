//
//  TUILiveRoomManager.h
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SuccessCallback)(void);
typedef void(^FailedCallback)(int code, NSString *errorMsg);
typedef void(^SuccessRoomListCallback)(NSArray<NSString *> * roomIds);

@interface TUILiveRoomManager : NSObject

+ (instancetype)sharedManager;

- (instancetype) init __attribute__((unavailable("init not available")));

/// 业务层创建房间接口
/// @param sdkAppID appId
/// @param type 房间类型,取值范围: liveRoom(普通直播间) / voiceRoom(语聊房) / groupLive(群直播间)
/// @param roomID 房间id
/// @param success 回调
/// @param failed 回调
- (void)createRoom:(int)sdkAppID type:(NSString *)type roomID:(NSString *)roomID success:(SuccessCallback)success failed:(FailedCallback)failed;

/// 业务层销毁房间接口
/// @param sdkAppID appId
/// @param type 房间类型,取值范围: liveRoom(普通直播间) / voiceRoom(语聊房) / groupLive(群直播间)
/// @param roomID 房间id
/// @param success 回调
/// @param failed 回调
- (void)destroyRoom:(int)sdkAppID type:(NSString *)type roomID:(NSString *)roomID success:(SuccessCallback _Nullable)success failed:(FailedCallback _Nullable)failed;

/// 业务层获取房间列表接口
/// @param sdkAppID appId
/// @param type 房间类型,取值范围: liveRoom(普通直播间) / voiceRoom(语聊房) / groupLive(群直播间)
/// @param success 回调
/// @param failed 回调
- (void)getRoomList:(int)sdkAppID type:(NSString *)type success:(SuccessRoomListCallback _Nullable)success failed:(FailedCallback _Nullable)failed;

/// 业务层更新房间信息
/// @param sdkAppID appId
/// @param type 房间类型,取值范围: liveRoom(普通直播间) / voiceRoom(语聊房) / groupLive(群直播间)
/// @param roomID 房间id
/// @param success 回调
/// @param failed 回调
- (void)updateRoom:(int)sdkAppID type:(NSString *)type roomID:(NSString *)roomID success:(SuccessCallback __nullable)success failed:(FailedCallback __nullable)failed;


@end

NS_ASSUME_NONNULL_END
