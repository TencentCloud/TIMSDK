package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model;

import java.util.List;

public class TRTCLiveRoomCallback {
    /**
     * 通用回调
     */
    public interface ActionCallback {
        void onCallback(int code, String msg);
    }

    /**
     * 获取房间信息回调
     */
    public interface RoomInfoCallback {
        void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveRoomInfo> list);
    }

    /**
     * 获取成员信息回调
     */
    public interface UserListCallback {
        void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveUserInfo> list);
    }

    /**
     * 获取主播关注状态回调
     */
    public interface RoomFollowStateCallback {
        void isFollowed();
        void isNotFollowed();
        void onFailed(String errorMessage);
    }
}
