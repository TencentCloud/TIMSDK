package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.state.SeatState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.Comparator;

public class UserListComparator implements Comparator<UserState.UserInfo> {
    private static final int LESSER  = -1;
    private static final int EQUAL   = 0;
    private static final int GREATER = 1;

    /**
     * Sorting priority:
     * 1. Myself;
     * 2. Room owner;
     * 3. Room manager;
     * 4. Screen sharing user;
     * 5. User has camera and audio;
     * 6. User has camera;
     * 7. User has audio;
     * 8. User on seat;
     * 9. User off seat;
     */
    @Override
    public int compare(UserState.UserInfo o1, UserState.UserInfo o2) {
        if (o1 == null || o2 == null) {
            return EQUAL;
        }
        if (TextUtils.equals(o1.userId, TUILogin.getUserId())) {
            return LESSER;
        }
        if (TextUtils.equals(o2.userId, TUILogin.getUserId())) {
            return GREATER;
        }
        if (o1.role.get() == TUIRoomDefine.Role.ROOM_OWNER) {
            return LESSER;
        }
        if (o2.role.get() == TUIRoomDefine.Role.ROOM_OWNER) {
            return GREATER;
        }
        if (o1.role.get() != o2.role.get()) {
            return o1.role.get() == TUIRoomDefine.Role.MANAGER ? LESSER : GREATER;
        }
        UserState userState = ConferenceController.sharedInstance().getUserState();
        if (TextUtils.equals(o1.userId, userState.screenStreamUser.get())) {
            return LESSER;
        }
        if (TextUtils.equals(o2.userId, userState.screenStreamUser.get())) {
            return GREATER;
        }
        boolean hasCamera1 = userState.hasCameraStreamUsers.contains(o1.userId);
        boolean hasCamera2 = userState.hasCameraStreamUsers.contains(o2.userId);
        if (hasCamera1 != hasCamera2) {
            return hasCamera1 ? LESSER : GREATER;
        }
        boolean hasAudio1 = userState.hasAudioStreamUsers.contains(o1.userId);
        boolean hasAudio2 = userState.hasAudioStreamUsers.contains(o2.userId);
        if (hasAudio1 != hasAudio2) {
            return hasAudio1 ? LESSER : GREATER;
        }
        SeatState seatState = ConferenceController.sharedInstance().getSeatState();
        boolean isOnSeat1 = seatState.seatedUsers.contains(o1.userId);
        boolean isOnSeat2 = seatState.seatedUsers.contains(o2.userId);
        if (isOnSeat1 != isOnSeat2) {
            return isOnSeat1 ? LESSER : GREATER;
        }
        return EQUAL;
    }
}
