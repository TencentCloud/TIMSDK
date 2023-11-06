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
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.view.page.RoomMainActivity;
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
        RoomEngineManager.sharedInstance().enterRoom(roomId, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                if (RoomEngineManager.sharedInstance().getRoomStore().isAutoShowRoomMainUi()) {
                    goRoomMainActivity();
                }
                decideMediaStatus(enableAudio, enableVideo, isSoundOnSpeaker);
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

    private void decideMediaStatus(boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker) {
        decideAudioRoute(isSoundOnSpeaker);

        boolean isPushAudio = isPushAudio(enableAudio);
        if (RoomPermissionUtil.hasAudioPermission()) {
            if (!isPushAudio) { // 先静音再开 mic，避免漏音
                RoomEngineManager.sharedInstance().muteLocalAudio();
            }
            RoomEngineManager.sharedInstance().openLocalMicrophone(new TUIRoomDefine.ActionCallback() {
                @Override
                public void onSuccess() {
                    decideCameraStatus(enableVideo);
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    decideCameraStatus(enableVideo);
                }
            });
        } else {
            if (isPushAudio) {
                RoomEngineManager.sharedInstance().openLocalMicrophone(new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        decideCameraStatus(enableVideo);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String s) {
                        decideCameraStatus(enableVideo);
                    }
                });
            } else {
                decideCameraStatus(enableVideo);
            }
        }
    }

    private void decideAudioRoute(boolean isSoundOnSpeaker) {
        RoomEngineManager.sharedInstance().setAudioRoute(isSoundOnSpeaker);
    }

    private void decideCameraStatus(boolean enableVideo) {
        RoomStore roomStore = RoomEngineManager.sharedInstance().getRoomStore();
        if (!enableVideo) {
            return;
        }
        if (roomStore.roomInfo.isCameraDisableForAllUser && roomStore.userModel.role == GENERAL_USER) {
            return;
        }
        if (roomStore.roomInfo.speechMode != SPEAK_AFTER_TAKING_SEAT || roomStore.userModel.role == ROOM_OWNER) {
            RoomEngineManager.sharedInstance().openLocalCamera(null);
        }
    }

    private boolean isPushAudio(boolean enableAudio) {
        RoomStore roomStore = RoomEngineManager.sharedInstance().getRoomStore();
        if (!enableAudio) {
            return false;
        }
        if (roomStore.roomInfo.isMicrophoneDisableForAllUser && roomStore.userModel.role == GENERAL_USER) {
            return false;
        }
        if (roomStore.userModel.role == ROOM_OWNER) {
            return true;
        }
        return roomStore.roomInfo.speechMode != SPEAK_AFTER_TAKING_SEAT;
    }

    private void goRoomMainActivity() {
        Intent intent = new Intent(mContext, RoomMainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }
}
