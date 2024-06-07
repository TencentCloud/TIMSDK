package com.tencent.cloud.tuikit.roomkit.model.data;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.trtc.tuikit.common.livedata.LiveData;

public class RoomState {
    public String                           roomId        = "";
    public long                             createTime    = 0L;
    public LiveData<String>                 ownerId       = new LiveData<>("");
    public LiveData<String>                 roomName      = new LiveData<>("");
    public LiveData<Integer>                maxSeatCount  = new LiveData<>(20);
    public LiveData<Boolean>                isSeatEnabled = new LiveData<>(false);
    public LiveData<TUIRoomDefine.SeatMode> seatMode      = new LiveData<>(TUIRoomDefine.SeatMode.FREE_TO_TAKE);

    public void updateState(TUIRoomDefine.RoomInfo roomInfo) {
        roomId = roomInfo.roomId;
        createTime = roomInfo.createTime;
        ownerId.set(roomInfo.ownerId);
        roomName.set(roomInfo.name);
        maxSeatCount.set(roomInfo.maxSeatCount);
        isSeatEnabled.set(roomInfo.isSeatEnabled);
        seatMode.set(roomInfo.seatMode);
    }
}
