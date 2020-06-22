package com.tencent.liteav.model;

import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.List;

/**
 * TRTC 音视频通话接口
 * 本功能使用腾讯云实时音视频 / 腾讯云即时通信IM 组合实现
 * 使用方式如下
 * 1. 初始化
 * ITRTCAVCall sCall = TRTCAVCallImpl.sharedInstance(context);
 * sCall.init();
 * <p>
 * 2. 监听回调
 * sCall.addListener(new TRTCAVCallListener());
 * <p>
 * 3. 登录到IM系统中
 * sCall.login(A, password, callback);
 * <p>
 * 4. 给B拨打电话
 * sCall.call(B, TYPE_VIDEO_CALL);
 * <p>
 * 5. 视频通话-打开自己的摄像头
 * sCall.openCamera(true, txCloudVideoView);
 * <p>
 * 6. 接听/拒绝电话
 * 此时B如果也登录了IM系统，会收到TRTCAVCallListener的onInvited(A, null, false, callType)回调
 * B 可以调用 sCall.accept 接受 / sCall.reject 拒绝
 * <p>
 * 7. 视频通话-观看对方的画面
 * 由于A打开了摄像头，B接受通话后会收到 onUserVideoAvailable(A, true) 回调
 * B 可以调用 startRemoteView(A, txCloudVideoView) 就可以看到A的画面了
 * <p>
 * 8. 结束通话
 * 需要结束通话时，A、B 任意一方可以调用 sCall.hangup 挂断电话
 * <p>
 * 9. 销毁实例
 * sCall.destroy();
 * TRTCAVCallImpl.destroySharedInstance();
 */
public interface ITRTCAVCall {
    int TYPE_UNKNOWN    = 0;
    int TYPE_AUDIO_CALL = 1;
    int TYPE_VIDEO_CALL = 2;

    public interface ActionCallBack {
        void onError(int code, String msg);

        void onSuccess();
    }

    /**
     * 初始化函数，请在使用所有功能之前先调用该函数进行必要的初始化
     */
    void init();

    /**
     * 销毁函数，如果不需要再运行该实例，请调用该接口
     */
    void destroy();

    /**
     * 增加回调接口
     *
     * @param listener 上层可以通过回调监听事件
     */
    void addListener(TRTCAVCallListener listener);


    /**
     * 移除回调接口
     *
     * @param listener 需要移除的监听器
     */
    void removeListener(TRTCAVCallListener listener);


    /**
     * 登录IM接口，所有功能需要先进行登录后才能使用
     *
     * @param sdkAppId
     * @param userId
     * @param userSign
     * @param callback
     */
    void login(int sdkAppId, final String userId, String userSign, final ActionCallBack callback);

    /**
     * 登出接口，登出后无法再进行拨打操作
     */
    void logout(final ActionCallBack callBack);

    /**
     * C2C邀请通话，被邀请方会收到 {@link TRTCAVCallListener#onInvited } 的回调
     * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
     *
     * @param userId 被邀请方
     * @param type   1-语音通话，2-视频通话
     */
    void call(String userId, int type);

    /**
     * IM群组邀请通话，被邀请方会收到 {@link TRTCAVCallListener#onInvited } 的回调
     * 如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到 {@link TRTCAVCallListener#onGroupCallInviteeListUpdate(List)} 的回调
     *
     * @param userIdList 邀请列表
     * @param type       1-语音通话，2-视频通话
     * @param groupId    IM群组ID
     */
    void groupCall(List<String> userIdList, int type, String groupId);

    /**
     * 当您作为被邀请方收到 {@link TRTCAVCallListener#onInvited } 的回调时，可以调用该函数接听来电
     */
    void accept();

    /**
     * 当您作为被邀请方收到 {@link TRTCAVCallListener#onInvited } 的回调时，可以调用该函数拒绝来电
     */
    void reject();

    /**
     * 当您处于通话中，可以调用该函数结束通话
     */
    void hangup();

    /**
     * 当您收到 onUserVideoAvailable 回调时，可以调用该函数将远端用户的摄像头数据渲染到指定的TXCloudVideoView中
     *
     * @param userId           远端用户id
     * @param txCloudVideoView 远端用户数据将渲染到该view中
     */
    void startRemoteView(String userId, TXCloudVideoView txCloudVideoView);

    /**
     * 当您收到 onUserVideoAvailable 回调为false时，可以停止渲染数据
     *
     * @param userId 远端用户id
     */
    void stopRemoteView(String userId);

    /**
     * 您可以调用该函数开启摄像头，并渲染在指定的TXCloudVideoView中
     * 处于通话中的用户会收到 {@link TRTCAVCallListener#onUserVideoAvailable(java.lang.String, boolean)} 回调
     *
     * @param isFrontCamera    是否开启前置摄像头
     * @param txCloudVideoView 摄像头的数据将渲染到该view中
     */
    void openCamera(boolean isFrontCamera, TXCloudVideoView txCloudVideoView);

    /**
     * 您可以调用该函数关闭摄像头
     * 处于通话中的用户会收到 {@link TRTCAVCallListener#onUserVideoAvailable(java.lang.String, boolean)} 回调
     */
    void closeCamera();

    /**
     * 您可以调用该函数切换前后摄像头
     *
     * @param isFrontCamera true:切换前置摄像头 false:切换后置摄像头
     */
    void switchCamera(boolean isFrontCamera);

    /**
     * 是否静音mic
     *
     * @param isMute true:麦克风关闭 false:麦克风打开
     */
    void setMicMute(boolean isMute);

    /**
     * 是否开启免提
     *
     * @param isHandsFree true:开启免提 false:关闭免提
     */
    void setHandsFree(boolean isHandsFree);
}
