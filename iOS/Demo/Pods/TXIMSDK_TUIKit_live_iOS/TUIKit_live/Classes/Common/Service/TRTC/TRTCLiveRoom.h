//
//  TRTCLiveRoom.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/7.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCLiveRoomDelegate.h"
#import "TRTCLiveRoomDef.h"
#import "TRTCCloud.h"

NS_ASSUME_NONNULL_BEGIN

@class TXAudioEffectManager;
@class TXBeautyManager;
@interface TRTCLiveRoom : NSObject <TRTCCloudDelegate>

@property(nonatomic, weak)id<TRTCLiveRoomDelegate> delegate;

+ (instancetype)sharedInstance;

#pragma mark - 登录登出相关

//////////////////////////////////////////////////////////
//
//                  登录登出相关
//
//////////////////////////////////////////////////////////

/// 登录到组件系统
/// - Parameters:
///   - sdkAppID: 您可以在实时音视频控制台 > 【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID。
///   - userID: 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）。
///   - userSig:  腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
///   - config: 全局配置信息，请在登录时初始化，登录之后不可变更。 isAttachedTUIKit 项目中是否引入并使用TUIKit
///   - callback: 登录回调，成功时 code 为0。
/// - Note:
///   - userSig 建议设定 7 天，能够有效规避 usersign 过期导致的 IM 收发消息失败、TRTC 连麦失败等情况
- (void)loginWithSdkAppID:(int)sdkAppID
                  userID:(NSString *)userID
                 userSig:(NSString *)userSig
                  config:(TRTCLiveRoomConfig *)config
                callback:(Callback _Nullable)callback
NS_SWIFT_NAME(login(sdkAppID:userID:userSig:config:callback:));

// 退出登录
/// - Parameter callback:  登出回调，成功时 code 为0
- (void)logout:(Callback _Nullable)callback
NS_SWIFT_NAME(logout(_:));

/// 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
/// - Parameters:
///   - name: 用户昵称
///   - avatarURL: 用户头像地址
///   - callback: 个人信息设置回调，成功时 code 为0
- (void)setSelfProfileWithName:(NSString *)name
                     avatarURL:(NSString * _Nullable)avatarURL
                      callback:(Callback _Nullable)callback
NS_SWIFT_NAME(setSelfProfile(name:avatarURL:callback:));

#pragma mark - 房间管理相关
//////////////////////////////////////////////////////////
//
//                  房间管理相关
//
//////////////////////////////////////////////////////////

/// 创建房间（主播调用），若房间不存在，系统将自动创建一个新房间。
/// 主播开播的正常调用流程是：
/// 1.【主播】调用 startCameraPreview() 打开摄像头预览，此时可以调整美颜参数。
/// 2.【主播】调用 createRoom() 创建直播间，房间创建成功与否会通过 callback 通知给主播。
/// 3.【主播】调用 startPublish() 开始推流。
/// - Parameters:
///   - roomID: 房间标识，需要由您分配并进行统一管理。多个 roomid 可以汇总成一个直播间列表，腾讯云暂不提供直播间列表的管理服务，请自行管理您的直播间列表。
///   - roomParam: TRTCCreateRoomParam | 房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您自行管理，可忽略该参数。
///   - callback:  进入房间的结果回调，成功时 code 为0。
/// - Note:
///   - 主播开始直播的时候调用，可重复创建自己已创建过的房间。
- (void)createRoomWithRoomID:(UInt32)roomID
                   roomParam:(TRTCCreateRoomParam *)roomParam
                    callback:(Callback _Nullable)callback
NS_SWIFT_NAME(createRoom(roomID:roomParam:callback:));

/// 销毁房间（主播调用）
/// 主播在创建房间后，可以调用这个函数来销毁房间。
/// - Parameter callback: 销毁房间的结果回调，成功时 code 为0。
/// - Note:
///   - 主播在创建房间后，可以调用该函数来销毁房间。
- (void)destroyRoom:(Callback _Nullable)callback
NS_SWIFT_NAME(destroyRoom(callback:));

/// 进入房间（观众调用）
/// 观众观看直播的正常调用流程是：
/// 1.【观众】向您的服务端获取最新的直播间列表，其中有多个直播间的 roomid 和房间信息。
/// 2.【观众】观众选择一个直播间以后，调用 enterRoom() 进入该房间。
/// 3.【观众】如果您的服务器所管理的房间列表中包含每一个房间的主播 userId，则可以直接在 enterRoom() 成功后调用 startPlay(userId) 即可播放主播的画面。
/// 如果您管理的房间列表只有 roomid 也没有关系，观众在 enterRoom() 成功后很快会收到来自 TRTCLiveRoomDelegate 中的 onAnchorEnter(userId) 回调。
/// 此时使用回调中的 userId 调用 startPlay(userId) 即可播放主播的画面。
/// - Parameters:
///   - roomID: 房间标识。
///   - useCDNFirst: 是否优先使用CDN播放
///   - cdnDomain: CDN域名
///   - callback: 进入房间的结果回调，成功时 code 为0。
/// - Note:
///   - 观众进入直播房间的时候调用
///   - 主播不可调用这个接口进入自己已创建的房间，而要用createRoom
- (void)enterRoomWithRoomID:(UInt32)roomID
                useCDNFirst:(BOOL)useCDNFirst
                  cdnDomain:(NSString * _Nullable)cdnDomain
                   callback:(Callback)callback
NS_SWIFT_NAME(enterRoom(roomID:useCDNFirst:cdnDomain:callback:));

/// 退出房间（观众调用）
/// - Parameter callback: 退出房间的结果回调，成功时 code 为0。
/// - Note:
///   - 观众离开直播房间的时候调用
///   - 主播不可调用这个接口离开房间

- (void)exitRoom:(Callback _Nullable)callback
NS_SWIFT_NAME(exitRoom(callback:));

/// 获取房间列表的详细信息
/// 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您自行管理，可忽略该函数。
/// - Parameter roomIDs: 房间号列表
/// - Parameter callback: 房间详细信息回调
- (void)getRoomInfosWithRoomIDs:(NSArray<NSNumber *> *)roomIDs
                       callback:(RoomInfoCallback _Nullable)callback
NS_SWIFT_NAME(getRoomInfos(roomIDs:callback:));

/// 获取房间内所有的主播列表，enterRoom() 成功后调用才有效。
/// - Parameter callback: 用户详细信息回调
- (void)getAnchorList:(UserListCallback _Nullable)callback
NS_SWIFT_NAME(getAnchorList(callback:));

/// 获取房间内所有的观众信息，enterRoom() 成功后调用才有效。
/// - Parameter callback: 用户详细信息回调
- (void)getAudienceList:(UserListCallback _Nullable)callback
NS_SWIFT_NAME(getAudienceList(callback:));

#pragma mark - 推拉流相关
//////////////////////////////////////////////////////////
//
//                  推拉流相关
//
//////////////////////////////////////////////////////////

/// 开启本地视频的预览画面
/// - Parameters:
///   - frontCamera: true：前置摄像头；false：后置摄像头。
///   - view: 承载视频画面的控件。
///   - callback: 操作回调。
- (void)startCameraPreviewWithFrontCamera:(BOOL)frontCamera
                                     view:(UIView *)view
                                 callback:(Callback _Nullable)callback
NS_SWIFT_NAME(startCameraPreview(frontCamera:view:callback:));

/// 停止本地视频采集及预览
- (void)stopCameraPreview;

/// 开始直播（推流），适用于如下两种场景：
/// 1. 主播开播的时候调用
/// 2. 观众开始连麦时调用
/// - Parameters:
///   - streamID: 用于绑定直播 CDN 的 streamId，如果您希望您的观众通过直播 CDN 进行观看，需要指定当前主播的直播 streamId。
///   - callback: 操作回调
- (void)startPublishWithStreamID:(NSString *)streamID
                        callback:(Callback _Nullable)callback
NS_SWIFT_NAME(startPublish(streamID:callback:));

/// 停止直播（推流），适用于如下两种场景：
/// 1. 主播结束直播时调用
/// 2. 观众结束连麦时调用
/// - Parameter callback: 操作回调。
- (void)stopPublish:(Callback _Nullable)callback
NS_SWIFT_NAME(stopPublish(callback:));

/// 播放远端视频画面，可以在普通观看和连麦场景中调用
/// 【普通观看场景】
/// 1. 如果您的服务器所管理的房间列表中包含每一个房间的主播 userId，则可以直接在 enterRoom() 成功后调用 startPlay(userId) 即可播放主播的画面。
/// 2. 如果您管理的房间列表只有 roomid 也没有关系，观众在 enterRoom() 成功后很快会收到来自 TRTCLiveRoomDelegate 中的 onAnchorEnter(userId) 回调。
/// 此时使用回调中的 userId 调用 startPlay(userId) 即可播放主播的画面。
/// 【直播连麦场景】
/// 发起连麦后，主播会收到来自 TRTCLiveRoomDelegate 中的 onAnchorEnter(userId) 回调，此时使用回调中的 userId 调用 startPlay(userId) 即可播放连麦画面。
/// - Parameters:
///   - userID: 需要观看的用户 ID。
///   - view: 承载视频画面的 view 控件。
///   - callback: 操作回调。
- (void)startPlayWithUserID:(NSString *)userID
                       view:(UIView *)view
                   callback:(Callback _Nullable)callback
NS_SWIFT_NAME(startPlay(userID:view:callback:));

/// 停止渲染远端视频画面
/// - Parameters:
///   - userID: 对方的用户信息。
///   - callback: 操作回调。
/// - Note:
///   - 在 onAnchorExit 回调时，调用这个接口
- (void)stopPlayWithUserID:(NSString *)userID
                  callback:(Callback _Nullable)callback
NS_SWIFT_NAME(stopPlay(userID:callback:));

#pragma mark - 观众连麦相关
//////////////////////////////////////////////////////////
//
//                  观众连麦相关
//
//////////////////////////////////////////////////////////

/**
    * 观众请求连麦
    *
    * 主播和观众的连麦流程可以简单描述为如下几个步骤：
    * 1. 【观众】调用 requestJoinAnchor() 向主播发起连麦请求。
    * 2. 【主播】会收到 TRTCLiveRoomDelegate onRequestJoinAnchor 的回调通知。
    * 3. 【主播】调用 responseJoinAnchor() 确定是否接受观众的连麦请求。
    * 4. 【观众】会收到 responseCallback  回调通知，可以得知请求是否被同意。
    * 5. 【观众】如果请求被同意，则调用 startCameraPreview() 开启本地摄像头。
    * 6. 【观众】然后调用 startPublish() 正式进入推流状态。
    * 7. 【主播】一旦观众进入连麦状态，主播就会收到 TRTCLiveRoomDelegate onAnchorEnter 通知。
    * 8. 【主播】主播调用 startPlay() 就可以看到连麦观众的视频画面。
    * 9. 【观众】如果直播间里已经有其他观众正在跟主播进行连麦，那么新加入的这位连麦观众也会收到 onAnchorEnter() 通知，调用 startPlay() 播放其他连麦者的视频画面。
* */
   
/// 观众端请求连麦
/// - Parameters:
///   - reason: 连麦请求原因。
///   - responseCallback: 请求连麦的回调。
/// - Note: 观众发起请求后，主播端会收到`onRequestJoinAnchor`回调
- (void)requestJoinAnchor:(NSString *)reason
                  timeout:(double)timeout
         responseCallback:(ResponseCallback _Nullable)responseCallback
NS_SWIFT_NAME(requestJoinAnchor(reason:timeout:responseCallback:));

/// 观众端取消请求连麦
/// - Parameters:
///   - reason: 连麦请求原因。
///   - responseCallback: 请求连麦的回调。
/// - Note: 观众取消请求后，主播端会收到`onCancelRequestJoinAnchor`回调
- (void)cancelRequestJoinAnchor:(NSString *)reason
         responseCallback:(Callback _Nullable)responseCallback
NS_SWIFT_NAME(cancelJoinAnchor(reason:responseCallback:));

/// 主播回复观众连麦请求
/// - Parameters:
///   - user: 观众 ID。
///   - agree: true：同意；false：拒绝。
///   - reason: 同意/拒绝连麦的原因描述。
/// - Note: 主播回复后，观众端会收到`requestJoinAnchor`传入的`responseCallback`回调
- (void)responseJoinAnchor:(NSString *)userID
                     agree:(BOOL)agree
                    reason:(NSString *)reason
NS_SWIFT_NAME(responseJoinAnchor(userID:agree:reason:));

/// 主播踢除连麦观众
/// - Parameters:
///   - userID: 连麦观众 ID。
///   - callback: 操作回调。
/// - Note: 主播调用此接口踢除连麦观众后，被踢连麦观众会收到 trtcLiveRoomOnKickoutJoinAnchor() 回调通知
- (void)kickoutJoinAnchor:(NSString *)userID
                 callback:(Callback _Nullable)callback
NS_SWIFT_NAME(kickoutJoinAnchor(userID:callback:));

#pragma mark - 主播 PK 相关

//////////////////////////////////////////////////////////
//
//                  主播 PK 相关
//
//////////////////////////////////////////////////////////

/**
    * 请求跨房 PK
    *
    * 主播和主播之间可以跨房间 PK，两个正在直播中的主播 A 和 B，他们之间的跨房 PK 流程如下：
    * 1. 【主播 A】调用 requestRoomPK() 向主播 B 发起连麦请求。
    * 2. 【主播 B】会收到 TRTCLiveRoomDelegate onRequestRoomPK 回调通知。
    * 3. 【主播 B】调用 responseRoomPK() 确定是否接受主播 A 的 PK 请求。
    * 4. 【主播 B】如果接受了主播 A 的要求，等待 TRTCLiveRoomDelegate onAnchorEnter 通知，然后调用 startPlay() 来显示主播 A 的视频画面。
    * 5. 【主播 A】会收到 responseCallback 回调通知，可以得知请求是否被同意。
    * 6. 【主播 A】如果请求被同意，等待 TRTCLiveRoomDelegate onAnchorEnter 通知，然后调用 startPlay() 来显示主播 B 的视频画面
    */

/// 主播请求跨房 PK
/// - Parameters:
///   - roomID: 被邀约房间 ID。
///   - userID: 被邀约主播 ID。
///   - responseCallback: 请求跨房 PK 的结果回调。
/// - Note: 发起请求后，对方主播会收到 `onRequestRoomPK` 回调
- (void)requestRoomPKWithRoomID:(UInt32)roomID
                         userID:(NSString *)userID
                        timeout:(double)timeout
               responseCallback:(ResponseCallback _Nullable)responseCallback
NS_SWIFT_NAME(requestRoomPK(roomID:userID:timeout:responseCallback:));

/// 主播取消跨房PK的请求
/// - Parameters:
///   - roomID: 被邀约房间 ID。
///   - userID: 被邀约主播 ID。
///   - responseCallback: 请求跨房 PK 的结果回调。
/// - Note: 发起请求后，对方主播会收到 `onCancelRequestRoomPK` 回调
- (void)cancelRequestRoomPKWithRoomID:(UInt32)roomID
                        userID:(NSString *)userID
              responseCallback:(Callback _Nullable)responseCallback
NS_SWIFT_NAME(cancelRoomPK(roomID:userID:responseCallback:));



/// 响应跨房 PK 请求
/// 主播响应其他房间主播的 PK 请求。
/// - Parameters:
///   - user: 发起 PK 请求的主播 ID
///   - agree: true：同意；false：拒绝
///   - reason: 同意/拒绝 PK 的原因描述
/// - Note: 主播回复后，对方主播会收到 `requestRoomPK` 传入的 `responseCallback` 回调
- (void)responseRoomPKWithUserID:(NSString *)userID
                           agree:(BOOL)agree
                          reason:(NSString *)reason
NS_SWIFT_NAME(responseRoomPK(userID:agree:reason:));

/// 主播退出跨房 PK
/// - Parameter callback: 退出跨房 PK 的结果回调
/// - Note: 当两个主播中的任何一个退出跨房 PK 状态后，另一个主播会收到 `trtcLiveRoomOnQuitRoomPK` 回调通知。
- (void)quitRoomPK:(Callback _Nullable)callback
NS_SWIFT_NAME(quitRoomPK(callback:));

#pragma mark - 音视频控制相关
//////////////////////////////////////////////////////////
//
//                  音视频控制相关
//
//////////////////////////////////////////////////////////

/// 切换前后摄像头
- (void)switchCamera;

/// 设置是否镜像展示
/// - Parameter isMirror: 开启/关闭镜像。
- (void)setMirror:(BOOL)isMirror
NS_SWIFT_NAME(setMirror(_:));

/// 静音本地音频。
/// - Parameter isMuted: true：开启静音；false：关闭静音。
- (void)muteLocalAudio:(BOOL)isMuted
NS_SWIFT_NAME(muteLocalAudio(_:));

/// 静音远端音频
/// - Parameters:
///   - userID: 远端的用户ID。
///   - isMuted: true：开启静音；false：关闭静音。
- (void)muteRemoteAudioWithUserID:(NSString *)userID isMuted:(BOOL)isMuted
NS_SWIFT_NAME(muteRemoteAudio(userID:isMuted:));

/// 静音所有远端音频
/// - Parameter isMuted: true：开启静音；false：关闭静音。
- (void)muteAllRemoteAudio:(BOOL)isMuted
NS_SWIFT_NAME(muteAllRemoteAudio(_:));

/// 设置音频质量，支持的值为1 2 3，代表低中高
/// - Parameter quality 音频质量
- (void)setAudioQuality:(NSInteger)quality
NS_SWIFT_NAME(setAudioiQuality(_:));

#pragma mark - 获取音效管理对象

/// 获取音效管理对象
- (TXAudioEffectManager *)getAudioEffectManager;

#pragma mark - 美颜滤镜相关
//////////////////////////////////////////////////////////
//
//                  美颜滤镜相关
//
//////////////////////////////////////////////////////////

/* 获取美颜管理对象 TXBeautyManager
*
* 通过美颜管理，您可以使用以下功能：
* - 设置"美颜风格"、“美白”、“红润”、“大眼”、“瘦脸”、“V脸”、“下巴”、“短脸”、“小鼻”、“亮眼”、“白牙”、“祛眼袋”、“祛皱纹”、“祛法令纹”等美容效果。
* - 调整“发际线”、“眼间距”、“眼角”、“嘴形”、“鼻翼”、“鼻子位置”、“嘴唇厚度”、“脸型”
* - 设置人脸挂件（素材）等动态效果
* - 添加美妆
* - 进行手势识别
*/
- (TXBeautyManager *)getBeautyManager;

//MARK: - 弹幕聊天相关

//////////////////////////////////////////////////////////
//
//                  弹幕聊天相关
//
//////////////////////////////////////////////////////////

/// 发送文本消息，房间内所有成员都可见
/// - Parameters:
///   - message: 文本消息。
///   - callback: 发送回调。
- (void)sendRoomTextMsg:(NSString *)message callback:(Callback _Nullable)callback
NS_SWIFT_NAME(sendRoomTextMsg(message:callback:));

/// 发送自定义消息
/// - Parameters:
///   - command: 命令字，由开发者自定义，主要用于区分不同消息类型
///   - message: 本文消息。
///   - callback: 发送回调。
- (void)sendRoomCustomMsgWithCommand:(NSString *)cmd message:(NSString *)message callback:(Callback _Nullable)callback
NS_SWIFT_NAME(sendRoomCustomMsg(cmd:message:callback:));

#pragma mark - 调试相关
//MARK: - 调试相关

//////////////////////////////////////////////////////////
//
//                  调试相关
//
//////////////////////////////////////////////////////////

/// 是否在界面中展示debug信息
/// - Parameter isShow: 开启/关闭 Debug 信息显示。
- (void)showVideoDebugLog:(BOOL)isShow
NS_SWIFT_NAME(showVideoDebugLog(_:));

@end

NS_ASSUME_NONNULL_END
