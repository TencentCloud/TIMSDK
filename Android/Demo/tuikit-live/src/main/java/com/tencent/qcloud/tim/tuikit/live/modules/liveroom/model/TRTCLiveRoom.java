package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model;

import android.content.Context;
import android.os.Handler;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.TRTCLiveRoomImpl;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.List;

public abstract class TRTCLiveRoom {
    protected TRTCLiveRoom() {
    }


    //////////////////////////////////////////////////////////
    //
    //                  获取组件实例
    //
    //////////////////////////////////////////////////////////

    /**
     * 获取 TRTCLiveRoom 单例对象
     *
     * @param context Android 上下文，内部会转为 ApplicationContext 用于系统 API 调用
     * @return TRTCLiveRoom 实例
     * @note 可以调用 {@link TRTCLiveRoom#destroySharedInstance()} 销毁单例对象
     */
    public static synchronized TRTCLiveRoom sharedInstance(Context context) {
        return TRTCLiveRoomImpl.sharedInstance(context);
    }

    /**
     * 销毁 TRTCLiveRoom 单例对象
     *
     * @note 销毁实例后，外部缓存的 TRTCLiveRoom 实例不能再使用，需要重新调用 {@link TRTCLiveRoom#sharedInstance(Context)} 获取新实例
     */
    public static void destroySharedInstance() {
        TRTCLiveRoomImpl.destroySharedInstance();
    }

    /**
     * 设置组件回调接口
     * <p>
     * 您可以通过 TRTCLiveRoomDelegate 获得 TRTCLiveRoom 的各种状态通知
     *
     * @param delegate 回调接口
     * @note TRTCLiveRoomDelegate 中的事件，默认是在 Main Thread 中回调给您；如果您需要指定事件回调所在的线程，可使用 {@link TRTCLiveRoom#setDelegateHandler(Handler)}
     */
    public abstract void setDelegate(TRTCLiveRoomDelegate delegate);

    /**
     * 设置事件回调所在的线程
     *
     * @param handler 线程，TRTCLiveRoom 中的各种状态通知回调会通过该 handler 通知给您，注意不要跟 setDelegate 进行混用。
     */
    public abstract void setDelegateHandler(Handler handler);

    //////////////////////////////////////////////////////////
    //
    //                  登录登出相关
    //
    //////////////////////////////////////////////////////////

    /**
     * @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
     * @param userId   当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
     * @param userSig  腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
     * @param config   全局配置信息，请在登录时初始化，登录之后不可变更
     * @param callback 登录回调，成功时 code 为0
     */
    public abstract void login(int sdkAppId, String userId, String userSig, TRTCLiveRoomDef.TRTCLiveRoomConfig config, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 退出登录
     */
    public abstract void logout(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
     *
     * @param userName  用户昵称
     * @param avatarURL 用户头像
     * @param callback  是否设置成功的结果回调
     */
    public abstract void setSelfProfile(String userName, String avatarURL, TRTCLiveRoomCallback.ActionCallback callback);


    //////////////////////////////////////////////////////////
    //
    //                  房间管理相关
    //
    //////////////////////////////////////////////////////////

    /**
     * 创建房间（主播调用）
     * <p>
     * 主播开播的正常调用流程是：
     * 1.【主播】调用 startCameraPreview() 打开摄像头预览，此时可以调整美颜参数。
     * 2.【主播】调用 createRoom 创建直播间，房间创建成功与否会通过 ActionCallback 通知给主播。
     * 3.【主播】调用 starPublish() 开始推流。
     *
     * @param roomId    房间标识，需要由您分配并进行统一管理。多个 roomId 可以汇总成一个直播间列表，腾讯云暂不提供直播间列表的管理服务，请自行管理您的直播间列表。
     * @param roomParam 房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您的服务器自行管理，可忽略该参数。
     * @param callback  创建房间的结果回调，成功时 code 为0.
     */
    public abstract void createRoom(int roomId, TRTCLiveRoomDef.TRTCCreateRoomParam roomParam, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 销毁房间（主播调用）
     * <p>
     * 主播在创建房间后，可以调用这个函数来销毁房间。
     */
    public abstract void destroyRoom(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 进入房间（观众调用）
     * <p>
     * 观众观看直播的正常调用流程如下：
     * 1.【观众】向您的服务端获取最新的直播间列表，可能包含多个直播间的 roomId 和房间信息。
     * 2.【观众】观众选择一个直播间，并调用 `enterRoom()` 进入该房间。
     * 3.【观众】调用`startPlay`并传入主播的 userId 开始播放。
     * - 若直播间列表已包含主播端的 userId 信息，观众端可直接调用 `startPlay(userId)` 即可开始播放。
     * - 若在进房前暂未获取主播的 userId，观众端在进房后会收到 `TRTCLiveRoomDelegate` 中的 `onAnchorEnter(userId)` 的事件回调，该回调中携带主播的 userId 信息，再调用`startPlay(userId)`即可播放。
     *
     * @param roomId   房间标识
     * @param callback 进入房间是否成功的结果回调
     */
    public abstract void enterRoom(int roomId, boolean useCDNFirst, final String cdnURL, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 退出房间
     *
     * @param callback 退出房间是否成功的结果回调
     */
    public abstract void exitRoom(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 获取房间列表的详细信息
     * <p>
     * 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
     *
     * @param roomIdList 房间号列表
     * @param callback   房间详细信息回调
     * @see {@link TRTCLiveRoomDef.TRTCLiveRoomInfo}
     */
    public abstract void getRoomInfos(List<Integer> roomIdList, TRTCLiveRoomCallback.RoomInfoCallback callback);

    /**
     * 获取房间内所有的主播列表，enterRoom() 成功后调用才有效。
     *
     * @param callback 用户详细信息回调
     */
    public abstract void getAnchorList(TRTCLiveRoomCallback.UserListCallback callback);

    /**
     * 获取房间内所有的观众信息，enterRoom() 成功后调用才有效。
     *
     * @param callback 用户详细信息回调
     */
    public abstract void getAudienceList(TRTCLiveRoomCallback.UserListCallback callback);

    //////////////////////////////////////////////////////////
    //
    //                  推拉流相关
    //
    //////////////////////////////////////////////////////////

    /**
     * 开启本地视频的预览画面
     *
     * @param isFront  true：前置摄像头；false：后置摄像头。
     * @param view     承载视频画面的控件
     * @param callback 操作回调
     */
    public abstract void startCameraPreview(boolean isFront, TXCloudVideoView view, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 停止本地视频采集及预览
     */
    public abstract void stopCameraPreview();

    /**
     * 开始直播（推流），适用于如下两种场景：
     * - 主播结束直播时调用
     * - 观众结束连麦时调用
     *
     * @param streamId 用于绑定直播 CDN 的 streamId，如果您希望您的观众通过直播 CDN 进行观看，需要指定当前主播的直播 streamId。
     * @param callback 操作回调
     */
    public abstract void startPublish(String streamId, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 停止直播（推流），适用于如下两种场景：
     * - 主播结束直播时调用
     * - 观众结束连麦时调用
     *
     * @param callback 操作回调
     */
    public abstract void stopPublish(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 播放远端视频画面，可以在普通观看和连麦场景中调用
     * <p>
     * 【普通观看场景】
     * - 若直播间列表已包含主播端的 userId 信息，观众端可以直接在 `enterRoom()` 成功后调用 `startPlay(userId)` 播放主播的画面。
     * - 若在进房前暂未获取主播的 userId，观众端在进房后会收到 `TRTCLiveRoomDelegate` 中的 `onAnchorEnter(userId)` 的事件回调，
     * 该回调中携带主播的 userId 信息，再调用`startPlay(userId)`即可播放主播的画面。
     * <p>
     * 【直播连麦场景】
     * 发起连麦后，主播会收到来自 TRTCLiveRoomDelegate 中的 onAnchorEnter(userId) 回调，此时使用回调中的 userId 调用 startPlay(userId) 即可播放连麦画面。
     *
     * @param userId   需要观看的用户id
     * @param view     承载视频画面的 view 控件
     * @param callback 操作回调
     */
    public abstract void startPlay(String userId, TXCloudVideoView view, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 停止播放远端视频画面
     *
     * @param userId   对方的用户信息
     * @param callback 操作回调
     * @note 在 onAnchorExit 回调时，调用这个接口
     */
    public abstract void stopPlay(String userId, TRTCLiveRoomCallback.ActionCallback callback);


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
     * 2. 【主播】会收到 {@link TRTCLiveRoomDelegate#onRequestJoinAnchor} 的回调通知。
     * 3. 【主播】调用 responseJoinAnchor() 决定是否接受来自观众的连麦请求。
     * 4. 【观众】会收到 {@link TRTCLiveRoomCallback.ActionCallback} 回调通知，该通知会携带主播的处理结果。
     * 5. 【观众】如果请求被同意，则调用 startCameraPreview() 开启本地摄像头。
     * 6. 【观众】然后调用 startPublish() 正式进入推流状态。
     * 7. 【主播】一旦观众进入连麦状态，主播就会收到 {@link TRTCLiveRoomDelegate#onAnchorEnter)} 通知。
     * 8. 【主播】主播调用 startPlay() 即可看到连麦观众的视频画面。
     * 9. 【观众】如果直播间里已经有其他观众正在跟主播进行连麦，那么新加入的这位连麦观众也会收到 onAnchorEnter() 通知，用于展示（startPlay）其他连麦者的视频画面。
     *
     * @param reason 连麦原因
     * @param timeout 超时时间
     * @param callback 请求连麦的回调
     * @see {@link TRTCLiveRoomDelegate#onRequestJoinAnchor}
     */
    public abstract void requestJoinAnchor(String reason, int timeout, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 观众取消连麦请求
     *
     * @param reason 观众取消连麦请求
     * @param callback 取消连麦的回调
     * @see {@link TRTCLiveRoomDelegate#onRequestJoinAnchor}
     */
    public abstract void cancelRequestJoinAnchor(String reason, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 主播处理连麦请求
     * <p>
     * 主播在收到 {@link TRTCLiveRoomDelegate#onRequestJoinAnchor} 回调之后会需要调用此接口来处理观众的连麦请求。
     *
     * @param userId 观众 ID
     * @param agree true：同意；false：拒绝
     * @param reason 同意/拒绝连麦的原因描述
     */
    public abstract void responseJoinAnchor(String userId, boolean agree, String reason);

    /**
     * 主播踢除连麦观众
     * <p>
     * 主播调用此接口踢除连麦观众后，被踢连麦观众会收到 {@link TRTCLiveRoomDelegate#onKickoutJoinAnchor()} 回调通知
     *
     * @param userId 连麦观众 ID
     * @see {@link TRTCLiveRoomDelegate#onKickoutJoinAnchor()}
     */
    public abstract void kickoutJoinAnchor(String userId, TRTCLiveRoomCallback.ActionCallback callback);

    //////////////////////////////////////////////////////////
    //
    //                  主播 PK 相关
    //
    //////////////////////////////////////////////////////////

    /**
     * 请求跨房 PK
     * <p>
     * 主播和主播之间可以跨房间 PK，两个正在直播中的主播 A 和 B，他们之间的跨房 PK 流程如下：
     * 1. 【主播 A】调用 requestRoomPK() 向主播 B 发起连麦请求。
     * 2. 【主播 B】会收到 {@link TRTCLiveRoomDelegate#onRequestRoomPK} 回调通知。
     * 3. 【主播 B】调用 `responseRoomPK()` 决定是否接受主播 A 的 PK 请求。
     * 4. 【主播 B】如果接受主播 A 的要求，等待 `TRTCLiveRoomDelegate` 的 `onAnchorEnter` 通知，然后调用 `startPlay()` 来显示主播 A 的视频画面。
     * 5. 【主播 A】会收到 `responseCallback` 回调通知，该通知会携带来自主播 B 的处理结果。
     * 6. 【主播 A】如果请求被同意，等待 `TRTCLiveRoomDelegate` 的 `onAnchorEnter` 通知，然后调用 `startPlay()` 显示主播 B 的视频画面。
     *
     * @param roomId   被邀约房间 ID
     * @param userId   被邀约主播 ID
     * @param timeout  超时时间
     * @param callback 请求跨房 PK 的结果回调
     * @see {@link TRTCLiveRoomDelegate#onRequestRoomPK}
     */
    public abstract void requestRoomPK(int roomId, String userId, int timeout, final TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 取消请求跨房 PK
     *
     * @param roomId   被邀约房间 ID
     * @param userId   被邀约主播 ID
     * @param callback 请求跨房 PK 的结果回调
     * @see {@link TRTCLiveRoomDelegate#onRequestRoomPK}
     */
    public abstract void cancelRequestRoomPK(int roomId, String userId, final TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 响应跨房 PK 请求
     * <p>
     * 主播响应其他房间主播的 PK 请求。
     *
     * @param requestId 发起 PK 请求req ID
     * @param agree     true：同意；false：拒绝
     * @param reason    同意/拒绝 PK 的原因描述
     */
    public abstract void responseRoomPK(String requestId, boolean agree, String reason);

    /**
     * 退出跨房 PK
     * <p>
     * 当两个主播中的任何一个退出跨房 PK 状态后，另一个主播会收到 {@link TRTCLiveRoomDelegate#onQuitRoomPK} 回调通知。
     *
     * @param callback 退出跨房 PK 的结果回调
     */
    public abstract void quitRoomPK(TRTCLiveRoomCallback.ActionCallback callback);

    //////////////////////////////////////////////////////////
    //
    //                  音视频控制相关
    //
    //////////////////////////////////////////////////////////

    /**
     * 切换前后摄像头
     */
    public abstract void switchCamera();

    /**
     * 设置是否镜像展示
     */
    public abstract void setMirror(boolean isMirror);

    /**
     * 静音本地音频
     */
    public abstract void muteLocalAudio(boolean mute);

    /**
     * 静音远端音频
     */
    public abstract void muteRemoteAudio(String userId, boolean mute);

    /**
     * 静音所有远端音频
     */
    public abstract void muteAllRemoteAudio(boolean mute);

    /**
     * 音效控制相关
     */
    public abstract TXAudioEffectManager getAudioEffectManager();

    /**
     * 设置音质
     *
     * @param quality TRTC_AUDIO_QUALITY_MUSIC/TRTC_AUDIO_QUALITY_DEFAULT/TRTC_AUDIO_QUALITY_SPEECH
     */
    public abstract void setAudioQuality(int quality);

    //////////////////////////////////////////////////////////
    //
    //                 美颜滤镜相关接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 美颜控制相关
     */
    public abstract TXBeautyManager getBeautyManager();

    //////////////////////////////////////////////////////////
    //
    //                  弹幕聊天相关
    //
    //////////////////////////////////////////////////////////

    /**
     * 在房间中广播文本消息，一般用于弹幕聊天
     *
     * @param message  文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomTextMsg(String message, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 在房间中广播自定义（信令）消息，一般用于广播点赞和礼物消息
     *
     * @param cmd      命令字，由开发者自定义，主要用于区分不同消息类型
     * @param message  文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomCustomMsg(String cmd, String message, TRTCLiveRoomCallback.ActionCallback callback);

    //////////////////////////////////////////////////////////
    //
    //                  调试相关接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 是否在界面中展示debug信息
     */
    public abstract void showVideoDebugLog(boolean isShow);

    /**
     * 关注主播
     *
     * @param userId   主播id
     * @param callback 结果回调
     */
    public abstract void followAnchor(String userId, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 检查是否已经关注该主播
     *
     * @param userId   主播id
     * @param callback 结果回调
     */
    public abstract void checkFollowAnchorState(String userId, TRTCLiveRoomCallback.RoomFollowStateCallback callback);

}