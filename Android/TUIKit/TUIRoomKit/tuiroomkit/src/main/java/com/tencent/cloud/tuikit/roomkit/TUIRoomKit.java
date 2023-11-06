/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Module:   TUIRoomKit
 * Function: 多人音视频主功能接口
 */

package com.tencent.cloud.tuikit.roomkit;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.TUIRoomKitImpl;

public abstract class TUIRoomKit {
    /**
     * 1.1 创建 TUIRoomKit 实例（单例模式）
     */
    public static TUIRoomKit createInstance() {
        return TUIRoomKitImpl.sharedInstance();
    }

    /**
     * 1.2 销毁 TUIRoomKit 实例（单例模式）
     */
    public static void destroyInstance() {
        TUIRoomKitImpl.destroyInstance();
    }

    /**
     * 2.1 设置个人信息，包括用户名和头像
     *
     * @param userName 个人的用户名。
     * @param avatarURL 个人的头像链接。
     */
    public abstract void setSelfInfo(String userName, String avatarURL, TUIRoomDefine.ActionCallback callback);

    /**
     * 3.1 创建房间
     *
     * @param roomInfo 创建房间的参数，包含房间号、房间名称等，其中 roomId 是必填项，其余可为默认值。
     */
    public abstract void createRoom(TUIRoomDefine.RoomInfo roomInfo, TUIRoomDefine.ActionCallback callback);

    /**
     * 3.2 进入房间
     *
     * @param roomId           进入房间的房间号。
     * @param enableAudio      true 进房打开麦克风，并推送本地音频数据到远端，其他成员可以正常听到本地声音；
     *                         false 进房只打开麦克风，不推送本地音频数据到远端，其他成员无法听到本地声音；
     * @param enableVideo      true 进房打开摄像头，并推送本地视频数据到远端，其他成员可以正常看到本地画面；
     *                         false 进房不打开摄像头，也不推送本地视频数据到远端，其他成员无法看到本地画面；
     * @param isSoundOnSpeaker 是否使用扬声器播放声音，true 则使用扬声器，false 则使用听筒。
     */
    public abstract void enterRoom(String roomId, boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker,
                                   TUIRoomDefine.GetRoomInfoCallback callback);
}
