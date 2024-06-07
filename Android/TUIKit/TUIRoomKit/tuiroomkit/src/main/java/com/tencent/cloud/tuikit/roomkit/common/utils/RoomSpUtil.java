package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.SPUtils;

public class RoomSpUtil {
    private static final String ROOM_SP_FILE_NAME     = "ROOM_SP_FILE_NAME";
    private static final String SP_ROOM_ID            = "ROOM_ID";
    private static final String SP_ROOM_AUDIO_SWITCH  = "ROOM_AUDIO_SWITCH";
    private static final String SP_ROOM_VIDEO_SWITCH  = "ROOM_VIDEO_SWITCH";

    public static void saveAudioSwitchToSp(boolean isOpen) {
        SPUtils sp = SPUtils.getInstance(ROOM_SP_FILE_NAME);
        sp.put(SP_ROOM_AUDIO_SWITCH, isOpen);
    }

    public static boolean getAudioSwitchFromSp() {
        SPUtils sp = SPUtils.getInstance(ROOM_SP_FILE_NAME);
        return sp.getBoolean(SP_ROOM_AUDIO_SWITCH, true);
    }

    public static void saveVideoSwitchToSp(boolean isOpen) {
        SPUtils sp = SPUtils.getInstance(ROOM_SP_FILE_NAME);
        sp.put(SP_ROOM_VIDEO_SWITCH, isOpen);
    }

    public static boolean getVideoSwitchFromSp() {
        SPUtils sp = SPUtils.getInstance(ROOM_SP_FILE_NAME);
        return sp.getBoolean(SP_ROOM_VIDEO_SWITCH, true);
    }

    public static String getUniqueRoomId() {
        SPUtils sp = SPUtils.getInstance(ROOM_SP_FILE_NAME);
        String roomId = sp.getString(SP_ROOM_ID);
        if (TextUtils.isEmpty(roomId) || roomId.length() < 4) {
            roomId = "100" + TUILogin.getUserId();
            sp.put(SP_ROOM_ID, roomId);
            return roomId;
        }
        String str = roomId.substring(0, 3);
        int count = 100;
        try {
            count = Integer.parseInt(str) + 1;
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        count = count < 1000 ? count : 100;
        roomId = count + TUILogin.getUserId();
        sp.put(SP_ROOM_ID, roomId);
        return roomId;
    }
}
