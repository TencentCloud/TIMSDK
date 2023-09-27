package com.tencent.cloud.tuikit.roomkit.model;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.ROOM_ID_INVALID;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.GENERAL_USER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.ROOM_OWNER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.activity.RoomMainActivity;
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
        RoomEngineManager.sharedInstance().setSelfInfo(userName, avatarURL, callback);
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
        RoomEngineManager.sharedInstance().createRoom(roomInfo, callback);
    }

    @Override
    public void enterRoom(String roomId, boolean enableMic, boolean enableCamera, boolean isSoundOnSpeaker,
                          TUIRoomDefine.GetRoomInfoCallback callback) {
        Log.i(TAG, "enterRoom roomId=" + roomId + " enableMic=" + enableMic + " enableCamera=" + enableCamera
                + " isSoundOnSpeaker=" + isSoundOnSpeaker);
        if (TextUtils.isEmpty(roomId)) {
            if (callback != null) {
                callback.onError(ROOM_ID_INVALID, "room id is empty");
            }
            return;
        }
        RoomEngineManager.sharedInstance().enterRoom(roomId, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                if (RoomEngineManager.sharedInstance().getRoomStore().isAutoShowRoomMainUi()) {
                    goRoomMainActivity();
                }
                decideMediaStatus(enableMic, enableCamera, isSoundOnSpeaker);
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

    private void decideMediaStatus(boolean enableMic, boolean enableCamera, boolean isSoundOnSpeaker) {
        decideAudioRoute(isSoundOnSpeaker);
        if (isMicCanOpen(enableMic)) {
            RoomEngineManager.sharedInstance().openLocalMicrophone(new TUIRoomDefine.ActionCallback() {
                @Override
                public void onSuccess() {
                    decideCameraStatus(enableCamera);
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    decideCameraStatus(enableCamera);
                }
            });
        } else {
            decideCameraStatus(enableCamera);
        }
    }

    private void decideAudioRoute(boolean isSoundOnSpeaker) {
        RoomEngineManager.sharedInstance().setAudioRoute(isSoundOnSpeaker);
    }

    private void decideCameraStatus(boolean enableCamera) {
        RoomStore roomStore = RoomEngineManager.sharedInstance().getRoomStore();
        if (!enableCamera) {
            return;
        }
        if (roomStore.roomInfo.isCameraDisableForAllUser && roomStore.userModel.role == GENERAL_USER) {
            return;
        }
        if (roomStore.roomInfo.speechMode != SPEAK_AFTER_TAKING_SEAT || roomStore.userModel.role == ROOM_OWNER) {
            RoomEngineManager.sharedInstance().openLocalCamera(null);
        }
    }

    private boolean isMicCanOpen(boolean enableMic) {
        RoomStore roomStore = RoomEngineManager.sharedInstance().getRoomStore();
        if (!enableMic) {
            return false;
        }
        if (roomStore.roomInfo.isMicrophoneDisableForAllUser && roomStore.userModel.role == GENERAL_USER) {
            return false;
        }
        return roomStore.roomInfo.speechMode != SPEAK_AFTER_TAKING_SEAT || roomStore.userModel.role == ROOM_OWNER;
    }

    private void goRoomMainActivity() {
        Intent intent = new Intent(mContext, RoomMainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }
}
