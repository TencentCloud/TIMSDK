package com.tencent.cloud.tuikit.roomkit.state;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.trtc.tuikit.common.livedata.LiveData;

public class RoomState {
    public LiveData<String>                 roomId          = new LiveData<>("");
    public long                             createTime      = 0L;
    public LiveData<String>                 ownerId         = new LiveData<>("");
    public LiveData<String>                 ownerName       = new LiveData<>("");
    public LiveData<String>                 roomName        = new LiveData<>("");
    public LiveData<Integer>                maxSeatCount    = new LiveData<>(20);
    public LiveData<Boolean>                isSeatEnabled   = new LiveData<>(false);
    public LiveData<Boolean>                isDisableScreen = new LiveData<>(false);
    public LiveData<TUIRoomDefine.SeatMode> seatMode        = new LiveData<>(TUIRoomDefine.SeatMode.FREE_TO_TAKE);
    public TUIRoomDefine.RoomInfo           roomInfo        = new TUIRoomDefine.RoomInfo();

    public void updateState(TUIRoomDefine.RoomInfo roomInfo) {
        roomId.set(roomInfo.roomId);
        createTime = roomInfo.createTime;
        ownerId.set(roomInfo.ownerId);
        ownerName.set(roomInfo.ownerName);
        roomName.set(roomInfo.name);
        maxSeatCount.set(roomInfo.maxSeatCount);
        isSeatEnabled.set(roomInfo.isSeatEnabled);
        seatMode.set(roomInfo.seatMode);
        isDisableScreen.set(roomInfo.isScreenShareDisableForAllUser);
        this.roomInfo = roomInfo;
    }
}
