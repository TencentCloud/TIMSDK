package com.tencent.cloud.tuikit.roomkit.impl;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.ROOM_ID_INVALID;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.main.RoomMainActivity;
import com.tencent.qcloud.tuicore.TUILogin;

public class TUIRoomKitImpl extends TUIRoomKit {
    private static final String TAG = "TUIRoomKitImpl";

    private static TUIRoomKit sInstance;

    private Context mContext;

    public static TUIRoomKit sharedInstance() {
        if (sInstance == null) {
            synchronized (TUIRoomKitImpl.class) {
                if (sInstance == null) {
                    sInstance = new TUIRoomKitImpl();
                }
            }
        }
        return sInstance;
    }

    public static void destroyInstance() {
        sInstance = null;
    }

    private TUIRoomKitImpl() {
        mContext = TUILogin.getAppContext();
    }

    @Override
    public void setSelfInfo(String userName, String avatarURL, TUIRoomDefine.ActionCallback callback) {
        Log.i(TAG, "set self info userName=" + userName + " avatarURL=" + avatarURL);
        ConferenceController.sharedInstance().setSelfInfo(userName, avatarURL, callback);
    }


    @Override
    public void createRoom(TUIRoomDefine.RoomInfo roomInfo, TUIRoomDefine.ActionCallback callback) {
        Log.i(TAG, "createRoom roomInfo=" + roomInfo);
        if (roomInfo == null || TextUtils.isEmpty(roomInfo.roomId)) {
            if (callback != null) {
                callback.onError(ROOM_ID_INVALID, "room id is empty");
            }
            return;
        }
        ConferenceController.sharedInstance().createRoom(roomInfo, callback);
    }

    @Override
    public void enterRoom(String roomId, boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker,
                          TUIRoomDefine.GetRoomInfoCallback callback) {
        Log.i(TAG, "enterRoom roomId=" + roomId + " enableAudio=" + enableAudio + " enableVideo=" + enableVideo
                + " isSoundOnSpeaker=" + isSoundOnSpeaker);
        if (TextUtils.isEmpty(roomId)) {
            if (callback != null) {
                callback.onError(ROOM_ID_INVALID, "room id is empty");
            }
            return;
        }
        ConferenceController.sharedInstance()
                .enterRoom(roomId, enableAudio, enableVideo, isSoundOnSpeaker, new TUIRoomDefine.GetRoomInfoCallback() {
                    @Override
                    public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                        if (ConferenceController.sharedInstance().getConferenceState().isAutoShowRoomMainUi()) {
                            goRoomMainActivity();
                        }
                        if (callback != null) {
                            callback.onSuccess(roomInfo);
                        }
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        if (callback != null) {
                            callback.onError(error, message);
                        }
                    }
                });
    }

    private void goRoomMainActivity() {
        Intent intent = new Intent(mContext, RoomMainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }
}
