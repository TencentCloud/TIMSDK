//
//  TUILiveRoomAnchorViewController.h
//  TUILiveKit
//
//  Created by coddyliu on 2020/9/2.
//  Copyright © 2020 null. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCLiveRoomDef.h"


typedef NS_ENUM(NSUInteger, TUILiveRoomType) {
    TUILiveRoomTypeNormalLiveRoom, /// 普通直播间，在直播广场页点击+号创建的直播
    TUILiveRoomTypeGroupLiveRoom, /// 群直播，在IM群聊入口创建的直播
    TUILiveRoomTypeNormalVoiceRoom, /// 普通语聊房，在语聊房广场页点击+号创建的语聊房（暂不支持，后续开放）
    TUILiveRoomTypeGroupVoiceRoom, /// 群语聊房，在IM群聊入口创建的语聊房（暂不支持，后续开放）
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUILiveOnRoomListCallback)(NSArray<NSString *> * pkRoomIDList);

@protocol TUILiveRoomAnchorDelegate <NSObject>

/// 主播间创建成功回调
- (void)onRoomCreate:(TRTCLiveRoomInfo *)roomInfo;

/// 主播间关闭回调
- (void)onRoomDestroy:(TRTCLiveRoomInfo *)roomInfo;

/// 获取可以PK的主播ID列表，仅在主播间类型为TUILiveRoomTypeNormalLiveRoom时需要
- (void)getPKRoomIDList:(TUILiveOnRoomListCallback _Nullable)callback;


/// 主播间错误回调
/// @param roomInfo 主播间信息
/// @param errorCode 错误码
/// @param errorMessage 错误信息
- (void)onRoomError:(TRTCLiveRoomInfo *)roomInfo errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage;

@end

@class TRTCLiveRoom;
@class TRTCLiveRoomInfo;
@interface TUILiveRoomAnchorViewController : UIViewController

/// 主播间回调信息
@property (nonatomic, weak) id<TUILiveRoomAnchorDelegate> delegate;

/// 主播端初始化方法
/// @param roomId 自定义roomid，如果为0，内部会自行生成一个roomId
- (instancetype)initWithRoomId:(int)roomId;

/// 是否开启PK
/// @param enable YES：开启 NO：关闭，默认：YES 开启
- (void)enablePK:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
