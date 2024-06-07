package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.TUILogin;

public class BusinessSceneUtil {
    private static final String TAG = "BusinessSceneUtil";

    private static boolean sIsChatAccessRoom = false;

    private static String sCurRoomId = null;

    public static boolean canJoinRoom() {
        int businessScene = TUILogin.getCurrentBusinessScene();
        Log.d(TAG, "canJoinRoom businessScene=" + businessScene);
        return businessScene == TUILogin.TUIBusinessScene.NONE
                || businessScene == TUILogin.TUIBusinessScene.IN_MEETING_ROOM;
    }

    public static void setJoinRoomFlag() {
        Log.d(TAG, "setJoinRoomFlag setCurrentBusinessScene : " + TUILogin.TUIBusinessScene.IN_MEETING_ROOM);
        TUILogin.setCurrentBusinessScene(TUILogin.TUIBusinessScene.IN_MEETING_ROOM);
    }

    public static void clearJoinRoomFlag() {
        Log.d(TAG, "clearJoinRoomFlag setCurrentBusinessScene : " + TUILogin.TUIBusinessScene.NONE);
        TUILogin.setCurrentBusinessScene(TUILogin.TUIBusinessScene.NONE);
    }

    public static boolean isChatAccessRoom() {
        return sIsChatAccessRoom;
    }

    public static void setChatAccessRoom(boolean isChatAccessRoom) {
        Log.d(TAG, "setChatAccessRoom : " + isChatAccessRoom);
        sIsChatAccessRoom = isChatAccessRoom;
    }

    public static void setCurRoomId(String roomId) {
        Log.d(TAG, "setCurRoomId : " + roomId);
        sCurRoomId = roomId;
    }

    public static boolean isInTheRoom(String roomId) {
        return !TextUtils.isEmpty(roomId) && roomId.equals(sCurRoomId);
    }
}
