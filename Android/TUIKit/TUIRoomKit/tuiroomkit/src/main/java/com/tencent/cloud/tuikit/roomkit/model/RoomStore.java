package com.tencent.cloud.tuikit.roomkit.model;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.ENTER_FLOAT_WINDOW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.EXIT_FLOAT_WINDOW;

import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.model.entity.AudioModel;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.entity.VideoModel;

import java.util.ArrayList;
import java.util.List;

public class RoomStore {
    private static final String TAG = "RoomStore";

    public RoomInfo             roomInfo;
    public UserModel            userModel;
    public AudioModel           audioModel;
    public VideoModel           videoModel;
    public TUIRoomKit.RoomScene roomScene;

    public List<TUIRoomDefine.UserInfo> allUserList;

    private boolean isInFloatWindow      = false;
    private boolean isAutoShowRoomMainUi = true;

    public RoomStore() {
        Log.d(TAG, "new RoomStore instance : " + this);
        roomInfo = new RoomInfo();
        userModel = new UserModel();
        audioModel = new AudioModel();
        videoModel = new VideoModel();
        roomScene = TUIRoomKit.RoomScene.MEETING;
        allUserList = new ArrayList<>();
    }

    public void reset() {
        Log.d(TAG, "reset RoomStore : " + this);
        roomInfo = new RoomInfo();
        audioModel = new AudioModel();
        videoModel = new VideoModel();
        allUserList.clear();
        roomScene = TUIRoomKit.RoomScene.MEETING;
        isInFloatWindow = false;
        isAutoShowRoomMainUi = true;
    }

    public boolean isInFloatWindow() {
        return isInFloatWindow;
    }

    public void setInFloatWindow(boolean inFloatWindow) {
        isInFloatWindow = inFloatWindow;
        String key = isInFloatWindow ? ENTER_FLOAT_WINDOW : EXIT_FLOAT_WINDOW;
        RoomEventCenter.getInstance().notifyUIEvent(key, null);
    }

    public boolean isAutoShowRoomMainUi() {
        return isAutoShowRoomMainUi;
    }

    public void setAutoShowRoomMainUi(boolean autoShowRoomMainUi) {
        isAutoShowRoomMainUi = autoShowRoomMainUi;
    }

    public void addUserListForEnterRoom(List<TUIRoomDefine.UserInfo> userList) {
        allUserList.addAll(userList);
        RoomEventCenter.getInstance().notifyEngineEvent(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, null);
    }
}
