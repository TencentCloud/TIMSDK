package com.tencent.cloud.tuikit.roomkit.model.entity;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.qcloud.tuicore.TUILogin;

public class UserModel {
    public String             userId;
    public String             userName;
    public String             userAvatar;
    public TUIRoomDefine.Role role;
    public String             takeSeatRequestId;
    public long               enterRoomTime = 0L;

    private SeatStatus seatStatus = SeatStatus.OFF_SEAT;

    public UserModel() {
        userId = TUILogin.getUserId();
        userName = TUILogin.getNickName();
        userAvatar = TUILogin.getFaceUrl();
    }

    public SeatStatus getSeatStatus() {
        return seatStatus;
    }

    public void setSeatStatus(SeatStatus seatStatus) {
        this.seatStatus = seatStatus;
    }

    public enum SeatStatus {
        OFF_SEAT,
        APPLYING_TAKE_SEAT,
        ON_SEAT
    }

    public boolean isOnSeat() {
        return seatStatus == SeatStatus.ON_SEAT;
    }

    public boolean isOffSeat() {
        return seatStatus == SeatStatus.OFF_SEAT;
    }
}
