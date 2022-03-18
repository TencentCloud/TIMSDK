package com.tencent.liteav.trtccalling;

import android.view.View;

public interface TUICalling {
    /* 呼叫类型 */
    enum Type {
        AUDIO,
        VIDEO
    }

    /* 角色 */
    enum Role {
        CALL,
        CALLED
    }

    enum Event {
        CALL_START,      // 通话开始
        CALL_SUCCEED,    // 通话接通成功
        CALL_END,        // 通话结束
        CALL_FAILED,     // 通话失败
    }

    /**
     * 设置用户昵称
     *
     * @param nickname 用户昵称 (长度不得超过500个字节)
     * @param callback 设置结果回调
     */
    void setUserNickname(String nickname, TUICallingCallback callback);

    /**
     * 设置用户头像
     *
     * @param avatar   用户头像, 头像必须是URL格式 (长度不得超过500个字节)
     *                 例如: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
     * @param callback 设置结果回调
     */
    void setUserAvatar(String avatar, TUICallingCallback callback);

    /**
     * 拨打电话
     *
     * @param userIDs 接听方用户userId数组
     * @param type    呼叫类型
     */
    void call(String[] userIDs, Type type);

    /**
     * 设置监听器
     *
     * @param listener 监听器
     */
    void setCallingListener(TUICallingListener listener);

    /**
     * 设置铃声(建议在30s以内)
     *
     * @param filePath 接听方铃音路径
     */
    void setCallingBell(String filePath);

    /**
     * 开启静音模式（接听方不响铃音）
     *
     * @param enable
     */
    void enableMuteMode(boolean enable);

    /**
     * 开启悬浮窗
     *
     * @param enable
     */
    void enableFloatWindow(boolean enable);

    /**
     * 开启自定义视图
     * 开启后，会在呼叫/被叫开始回调中，接收到CallingView的实例，由开发者自行决定展示方式
     * 注意：必须全屏或者与屏幕等比例展示，否则会有展示异常
     *
     * @param enable
     */
    void enableCustomViewRoute(boolean enable);

    /**
     * 平台：目前仅Android需要此接口
     * 应用场景：Android端由于厂商系统版本区别,部分手机应用在后台时需要"悬浮窗"权限或"后台拉起应用"权限,否则无法拉起应用;
     * 针对无权限拉不起应用的场景,增加以下接口;
     * 当应用在后台收到请求且无权限时,响铃,用户点击通知栏消息或者桌面icon进入应用时,查询通话请求,拉起通话界面
     */
    void queryOfflineCalling();

    interface TUICallingListener {

        /**
         * 被叫时请求拉起接听页面
         *
         * @retrun isAgree 是否同意
         */
        boolean shouldShowOnCallView();

        /**
         * 呼叫开始回调。主叫、被叫均会触发
         *
         * @param userIDs 本次通话用户id（自己除外）
         * @param type    通话类型:视频\音频
         * @param role    通话角色:主叫\被叫
         */
        void onCallStart(String[] userIDs, TUICalling.Type type, TUICalling.Role role, View tuiCallingView);

        /**
         * @param userIDs   本次通话用户id（自己除外）
         * @param type      通话类型:视频\音频
         * @param role      通话角色:主叫\被叫
         * @param totalTime 通话时长
         */
        void onCallEnd(String[] userIDs, TUICalling.Type type, TUICalling.Role role, long totalTime);

        /**
         * 通话事件回调
         *
         * @param event   事件类型
         * @param message 事件提示
         */
        void onCallEvent(TUICalling.Event event, TUICalling.Type type, TUICalling.Role role, String message);
    }

    //回调事件
    interface TUICallingCallback {
        void onCallback(int code, String msg);
    }

}
