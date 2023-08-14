/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Module:   TUIRoomKit
 * Function: 多人音视频主功能接口
 */

package com.tencent.cloud.tuikit.roomkit;

import android.content.Context;

import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.TUIRoomKitImpl;

public abstract class TUIRoomKit {
    public enum RoomScene {
        MEETING,
        LIVE
    }

    /**
     * 1.1 创建 TUIRoomKit 实例（单例模式）
     *
     * @param context Android 上下文。
     */
    public static TUIRoomKit sharedInstance(Context context) {
        return TUIRoomKitImpl.sharedInstance(context);
    }

    /**
     * 3.1 设置个人信息，包括用户名和头像
     *
     * @param userName 个人的用户名。
     * @param avatarURL 个人的头像链接。
     */
    public abstract void setSelfInfo(String userName, String avatarURL);

    /**
     * 4.1 是否进入预览界面
     *
     * @param enablePreview true 就进入预览界面，false 则跳过预览界面。
     */
    public abstract void enterPrepareView(boolean enablePreview);

    /**
     * 5.1 创建房间
     *
     * @param roomInfo 创建房间的参数，包含房间名，房间号等。
     * @param scene 房间类型。
     */
    public abstract void createRoom(RoomInfo roomInfo, RoomScene scene);

    /**
     * 5.2 进入房间
     *
     * @param roomInfo 进入房间的参数，包含房间名，房间号等。
     */
    public abstract void enterRoom(RoomInfo roomInfo);

    /**
     * 6.1 添加 TUIRoomKit 事件回
     *
     * @param listener TUIRoomKit 回调事件的监听器。
     */
    public abstract void addListener(TUIRoomKitListener listener);

    /**
     * 6.2 移除 TUIRoomKit 事件回调
     *
     * @param listener TUIRoomKit 回调事件的监听器。
     */
    public abstract void removeListener(TUIRoomKitListener listener);
}
