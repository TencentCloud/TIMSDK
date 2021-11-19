package com.tencent.liteav.trtccalling.model;

import android.content.Context;

import com.tencent.liteav.trtccalling.model.impl.TRTCCallingImpl;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.List;

/**
 * TRTC 语音/视频通话接口
 * 本功能使用腾讯云实时音视频 / 腾讯云即时通信IM 组合实现
 * 使用方式如下
 * 1. 初始化
 * TRTCCalling sCall = TRTCCallingImpl.sharedInstance(context);
 * sCall.init();
 * <p>
 * 2. 监听回调
 * sCall.addDelegate(new TRTCCallingDelegate());
 * <p>
 * 3. 登录到IM系统中
 * sCall.login(A, password, callback);
 * <p>
 * 4. 给B拨打电话
 * sCall.call(B, TYPE_VIDEO_CALL);
 * <p>
 * 5. 打开自己的摄像头
 * sCall.openCamera(true, txCloudVideoView);
 * <p>
 * 6. 接听/拒绝电话
 * 此时B如果也登录了IM系统，会收到TRTCVideoCallListener的onInvited(A, null, false, TYPE_VIDEO_CALL)回调
 * B 可以调用 sCall.accept 接受 / sCall.reject 拒绝
 * <p>
 * 7. 观看对方的画面
 * 由于A打开了摄像头，B接受通话后会收到 onUserVideoAvailable(A, true) 回调
 * B 可以调用 startRemoteView(A, txCloudVideoView) 就可以看到A的画面了
 * <p>
 * 8. 结束通话
 * 需要结束通话时，A、B 任意一方可以调用 sCall.hangup 挂断电话
 * <p>
 * 9. 销毁实例
 * sCall.destroy();
 * TRTCCallingImpl.destroySharedInstance();
 */
public abstract class TRTCCalling {
    public static final int TYPE_UNKNOWN    = 0;
    public static final int TYPE_AUDIO_CALL = 1;
    public static final int TYPE_VIDEO_CALL = 2;

    private static TRTCCalling              sTRTCCalling;

    public interface ActionCallBack {
        void onError(int code, String msg);

        void onSuccess();
    }

    /**
     * 用于获取单例
     *
     * @param context
     * @return 单例
     */
    public static TRTCCalling sharedInstance(Context context) {
        synchronized (TRTCCallingImpl.class) {
            if (sTRTCCalling == null) {
                sTRTCCalling = new TRTCCallingImpl(context);
            }
            return sTRTCCalling;
        }
    }

    /**
     * 销毁单例
     */
    public static void destroySharedInstance() {
        synchronized (TRTCCallingImpl.class) {
            if (sTRTCCalling != null) {
                sTRTCCalling.destroy();
                sTRTCCalling = null;
            }
        }
    }

    /**
     * 销毁函数，如果不需要再运行该实例，请调用该接口
     */
    public abstract void destroy();

    /**
     * 增加回调接口
     *
     * @param delegate 上层可以通过回调监听事件
     */
    public abstract void addDelegate(TRTCCallingDelegate delegate);


    /**
     * 移除回调接口
     *
     * @param delegate 需要移除的监听器
     */
    public abstract void removeDelegate(TRTCCallingDelegate delegate);


    /**
     * 登录IM接口，所有功能需要先进行登录后才能使用
     *
     * @param sdkAppId
     * @param userId
     * @param userSig
     * @param callback
     */
    public abstract void login(int sdkAppId, final String userId, String userSig, final ActionCallBack callback);

    /**
     * 登出接口，登出后无法再进行拨打操作
     */
    public abstract void logout(final ActionCallBack callBack);

    /**
     * C2C邀请通话，被邀请方会收到 {@link TRTCCallingDelegate#onInvited } 的回调
     * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
     *
     * @param userIdList 被邀请方
     * @param type   1-语音通话，2-视频通话
     */
    public abstract void call(List<String> userIdList, int type);

    /**
     * IM群组邀请通话，被邀请方会收到 {@link TRTCCallingDelegate#onInvited } 的回调
     * 如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到 {@link TRTCCallingDelegate#onGroupCallInviteeListUpdate(List)} 的回调
     *
     * @param userIdList 邀请列表
     * @param type       1-语音通话，2-视频通话
     * @param groupId    IM群组ID
     */
    public abstract void groupCall(List<String> userIdList, int type, String groupId);

    /**
     * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数接听来电
     */
    public abstract void accept();

    /**
     * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数拒绝来电
     */
    public abstract void reject();

    /**
     * 当您处于通话中，可以调用该函数结束通话
     */
    public abstract void hangup();

    /**
     * 当您收到 onUserVideoAvailable 回调时，可以调用该函数将远端用户的摄像头数据渲染到指定的TXCloudVideoView中
     *
     * @param userId           远端用户id
     * @param txCloudVideoView 远端用户数据将渲染到该view中
     */
    public abstract void startRemoteView(String userId, TXCloudVideoView txCloudVideoView);

    /**
     * 当您收到 onUserVideoAvailable 回调为false时，可以停止渲染数据
     *
     * @param userId 远端用户id
     */
    public abstract void stopRemoteView(String userId);

    /**
     * 您可以调用该函数开启摄像头，并渲染在指定的TXCloudVideoView中
     * 处于通话中的用户会收到 {@link TRTCCallingDelegate#onUserVideoAvailable(java.lang.String, boolean)} 回调
     *
     * @param isFrontCamera    是否开启前置摄像头
     * @param txCloudVideoView 摄像头的数据将渲染到该view中
     */
    public abstract void openCamera(boolean isFrontCamera, TXCloudVideoView txCloudVideoView);

    /**
     * 您可以调用该函数关闭摄像头
     * 处于通话中的用户会收到 {@link TRTCCallingDelegate#onUserVideoAvailable(java.lang.String, boolean)} 回调
     */
    public abstract void closeCamera();

    /**
     * 您可以调用该函数切换前后摄像头
     *
     * @param isFrontCamera true:切换前置摄像头 false:切换后置摄像头
     */
    public abstract void switchCamera(boolean isFrontCamera);

    /**
     * 是否静音mic
     *
     * @param isMute true:麦克风关闭 false:麦克风打开
     */
    public abstract void setMicMute(boolean isMute);

    /**
     * 是否开启免提
     *
     * @param isHandsFree true:开启免提 false:关闭免提
     */
    public abstract void setHandsFree(boolean isHandsFree);

    /**
     * 视频通话切换为语音通话模式
     */
    public abstract void switchToAudioCall();

    /**
     * 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
     *
     * @param userName 用户昵称
     * @param avatarURL 用户头像
     * @param callback 是否设置成功的结果回调
     */
    public abstract void setSelfProfile(String userName, String avatarURL, TRTCCallingCallback.ActionCallback callback);

    /**
     * 收到离线邀请时处理邀请信令，无法走信令监听回调onReceiveNewInvitation（仅支持在线）
     *
     * @param sender
     * @param content
     */
    public abstract void receiveNewInvitation(String sender, String content);

    /**
     * 设置铃声(建议在30s以内)
     *
     * @param filePath 接听方铃音路径
     */
    public abstract void setCallingBell(String filePath);

    /**
     * 开启静音模式（接听方不响铃音）
     * @param enable
     */
    public abstract void enableMuteMode(boolean enable);
}
