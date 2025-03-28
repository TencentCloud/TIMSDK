package com.tencent.cloud.tuikit.roomkit.state.entity;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_GENERAL_TO_MANAGER;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_MANAGER_TO_GENERAL;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_TO_OWNER;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.qcloud.tuicore.TUILogin;

public class UserModel {
    public String userId;

    public String takeSeatRequestId;
    public long   enterRoomTime = 0L;

    private TUIRoomDefine.Role role;
    private SeatStatus         seatStatus = SeatStatus.OFF_SEAT;

    public UserModel() {
        userId = TUILogin.getUserId();
    }

    public TUIRoomDefine.Role getRole() {
        return role;
    }

    public void initRole(TUIRoomDefine.Role role) {
        this.role = role;
    }

    public void changeRole(TUIRoomDefine.Role role) {
        if (this.role == TUIRoomDefine.Role.GENERAL_USER && role == TUIRoomDefine.Role.MANAGER) {
            ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_GENERAL_TO_MANAGER, null);
        } else if (this.role == TUIRoomDefine.Role.MANAGER && role == TUIRoomDefine.Role.GENERAL_USER) {
            ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_MANAGER_TO_GENERAL, null);
        } else if (this.role != TUIRoomDefine.Role.ROOM_OWNER && role == TUIRoomDefine.Role.ROOM_OWNER) {
            ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_TO_OWNER, null);
        }
        this.role = role;
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
