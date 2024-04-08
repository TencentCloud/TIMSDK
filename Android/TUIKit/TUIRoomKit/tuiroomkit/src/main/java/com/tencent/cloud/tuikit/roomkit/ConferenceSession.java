package com.tencent.cloud.tuikit.roomkit;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

public class ConferenceSession {
    private static final String TAG = "ConferenceSession";

    private String id;

    private boolean isMuteMicrophone = false;
    private boolean isOpenCamera     = false;
    private boolean isSoundOnSpeaker = true;

    private String  name;
    private boolean enableMicrophoneForAllUser = true;
    private boolean enableCameraForAllUser     = true;
    private boolean enableMessageForAllUser    = true;
    private boolean enableSeatControl          = false;

    private TUIRoomDefine.ActionCallback actionCallback;

    private ConferenceSession(String id) {
        this.id = id;
    }

    public static ConferenceSession newInstance(String id) {
        Log.d(TAG, "newInstance : " + id);
        return new ConferenceSession(id);
    }

    public ConferenceSession setActionCallback(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "setActionCallback : " + callback);
        this.actionCallback = callback;
        return this;
    }

    public void quickStart() {
        Log.d(TAG, "quickStart");
        TUIRoomDefine.RoomInfo roomInfo = new TUIRoomDefine.RoomInfo();
        roomInfo.roomId = id;
        if (TextUtils.isEmpty(name)) {
            name = id;
        }
        roomInfo.name = name;
        roomInfo.isMicrophoneDisableForAllUser = !enableMicrophoneForAllUser;
        roomInfo.isCameraDisableForAllUser = !enableCameraForAllUser;
        roomInfo.isMessageDisableForAllUser = !enableMessageForAllUser;
        roomInfo.isSeatEnabled = enableSeatControl;
        roomInfo.seatMode = TUIRoomDefine.SeatMode.APPLY_TO_TAKE;

        quickStartInternal(roomInfo, !isMuteMicrophone, isOpenCamera, isSoundOnSpeaker, actionCallback);
    }

    public void join() {
        Log.d(TAG, "join");
        joinInternal(id, !isMuteMicrophone, isOpenCamera, isSoundOnSpeaker, actionCallback);
    }

    public ConferenceSession setMuteMicrophone(boolean muteMicrophone) {
        Log.d(TAG, "setMuteMicrophone : " + muteMicrophone);
        isMuteMicrophone = muteMicrophone;
        return this;
    }

    public ConferenceSession setOpenCamera(boolean openCamera) {
        Log.d(TAG, "setOpenCamera : " + openCamera);
        isOpenCamera = openCamera;
        return this;
    }

    public ConferenceSession setSoundOnSpeaker(boolean soundOnSpeaker) {
        Log.d(TAG, "setSoundOnSpeaker : " + soundOnSpeaker);
        isSoundOnSpeaker = soundOnSpeaker;
        return this;
    }

    public ConferenceSession setName(String name) {
        Log.d(TAG, "setName : " + name);
        this.name = name;
        return this;
    }

    public ConferenceSession setEnableMicrophoneForAllUser(boolean enableMicrophoneForAllUser) {
        Log.d(TAG, "setEnableMicrophoneForAllUser : " + enableMicrophoneForAllUser);
        this.enableMicrophoneForAllUser = enableMicrophoneForAllUser;
        return this;
    }

    public ConferenceSession setEnableCameraForAllUser(boolean enableCameraForAllUser) {
        Log.d(TAG, "setEnableCameraForAllUser : " + enableCameraForAllUser);
        this.enableCameraForAllUser = enableCameraForAllUser;
        return this;
    }

    public ConferenceSession setEnableMessageForAllUser(boolean enableMessageForAllUser) {
        Log.d(TAG, "setEnableMessageForAllUser : " + enableMessageForAllUser);
        this.enableMessageForAllUser = enableMessageForAllUser;
        return this;
    }

    public ConferenceSession setEnableSeatControl(boolean enableSeatControl) {
        Log.d(TAG, "setEnableSeatControl : " + enableSeatControl);
        this.enableSeatControl = enableSeatControl;
        return this;
    }

    private void quickStartInternal(TUIRoomDefine.RoomInfo roomInfo, boolean openAudio, boolean openVideo,
                                    boolean isSoundOnSpeaker, TUIRoomDefine.ActionCallback callback) {
        RoomEngineManager manager = RoomEngineManager.sharedInstance();
        manager.createRoom(roomInfo, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                manager.enterRoom(roomInfo.roomId, openAudio, openVideo, isSoundOnSpeaker,
                        new TUIRoomDefine.GetRoomInfoCallback() {
                            @Override
                            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                                Log.i(TAG, "onSuccess");
                                if (callback != null) {
                                    callback.onSuccess();
                                }
                            }

                            @Override
                            public void onError(TUICommonDefine.Error error, String message) {
                                Log.e(TAG, "enterRoom onError error=" + error + " message=" + message);
                                if (callback != null) {
                                    callback.onError(error, message);
                                }
                            }
                        });
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.e(TAG, "createRoom onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    private void joinInternal(String roomId, boolean openAudio, boolean openVideo, boolean isSoundOnSpeaker,
                              TUIRoomDefine.ActionCallback callback) {
        RoomEngineManager.sharedInstance()
                .enterRoom(roomId, openAudio, openVideo, isSoundOnSpeaker, new TUIRoomDefine.GetRoomInfoCallback() {
                    @Override
                    public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                        Log.i(TAG, "onSuccess");
                        if (callback != null) {
                            callback.onSuccess();
                        }
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "enterRoom onError error=" + error + " message=" + message);
                        if (callback != null) {
                            callback.onError(error, message);
                        }
                    }
                });
    }
}
