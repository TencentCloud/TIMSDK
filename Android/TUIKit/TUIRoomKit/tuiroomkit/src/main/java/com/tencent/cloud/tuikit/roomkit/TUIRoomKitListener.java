/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Module:   TUIRoomKitListener
 * Function: 多人音视频的回调接口
 */

package com.tencent.cloud.tuikit.roomkit;

public interface TUIRoomKitListener {
    /**
     * 2.1 创建房间回调
     *
     * @param code 错误码，成功时为0。
     * @param message 回调信息。
     */
    void onRoomCreate(int code, String message);

    /**
     * 2.2 进入房间回调
     *
     * @param code 错误码，成功时为0。
     * @param message 回调信息。
     */
    void onRoomEnter(int code, String message);

    /**
     * 2.3 销毁房间回调
     *
     * 房间销毁后，房间内的其他成员会退出房间，并收到 onExitRoom 的回调。
     */
    void onDestroyRoom();

    /**
     * 2.4 退出房间回调
     *
     * 自己退出房间，不影响房间的状态。
     */
    void onExitRoom();
}
