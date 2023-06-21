package com.tencent.cloud.tuikit.roomkit.model.manager;

import android.Manifest;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.TUIRoomKitImpl;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.utils.CommonUtils;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuicore.util.ToastUtil;

public class RoomEngineManager {
    private static final String TAG = "RoomEngineManager";

    private static final int SEAT_INDEX   = -1;
    private static final int REQ_TIME_OUT = 15;

    private static RoomEngineManager sInstance;

    private Context         mContext;
    private Listener        mListener;
    private TUIRoomEngine   mRoomEngine;
    private RoomStore       mRoomStore;
    private TUIRoomObserver mObserver;

    public static RoomEngineManager sharedInstance(Context context) {
        if (sInstance == null) {
            synchronized (TUIRoomKitImpl.class) {
                if (sInstance == null) {
                    sInstance = new RoomEngineManager(context);
                }
            }
        }
        return sInstance;
    }

    private RoomEngineManager(Context context) {
        mRoomEngine = TUIRoomEngine.createInstance();
        mObserver = RoomEventCenter.getInstance().getEngineEventCent();
        mRoomEngine.addObserver(mObserver);
        mContext = context.getApplicationContext();
        mRoomStore = new RoomStore();
    }

    private void refreshRoomEngine() {
        mRoomEngine.removeObserver(mObserver);
        mRoomEngine = TUIRoomEngine.createInstance();
        mObserver = RoomEventCenter.getInstance().getEngineEventCent();
        mRoomEngine.addObserver(mObserver);
    }

    public void setListener(Listener listener) {
        mListener = listener;
    }

    public void login(final int sdkAppId, final String userId, String userSig) {
        Log.i(TAG, "setup sdkAppId: " + sdkAppId + " userSig is empty: "
                + TextUtils.isEmpty(userSig + " userId: " + userId));
        TUIRoomEngine.login(mContext, sdkAppId, userId, userSig, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "setup success");
                mRoomStore.userModel.userId = userId;
                if (mListener != null) {
                    mListener.onLogin(0, "success");
                }
            }

            @Override
            public void onError(TUICommonDefine.Error code, String message) {
                Log.e(TAG, "login onError code : " + code + " message:" + message);
                if (mListener != null) {
                    mListener.onLogin(-1, message);
                }
            }
        });
        mRoomStore.loginInfo.userId = userId;
        mRoomStore.loginInfo.sdkAppId = sdkAppId;
        mRoomStore.loginInfo.userSig = userSig;
    }

    public void logout() {
        mRoomEngine.removeObserver(mObserver);
        mRoomEngine.destroyInstance();
        mRoomStore = null;
        sInstance = null;
        TUIRoomEngine.logout(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "logout success");
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.e(TAG, "logout onError code : " + error + " message:" + message);
            }
        });
    }

    public void setSelfInfo(String userName, String avatarURL) {
        Log.i(TAG, "setSelfInfo userName: " + userName + ",avatarURL: " + avatarURL);
        mRoomStore.userModel.userName = TextUtils.isEmpty(userName) ? "" : userName;
        mRoomStore.userModel.userAvatar = TextUtils.isEmpty(userName) ? "" : avatarURL;
        TUIRoomEngine.setSelfInfo(mRoomStore.userModel.userName, mRoomStore.userModel.userAvatar, null);
    }

    public void createRoom(final RoomInfo roomInfo, final TUIRoomKit.RoomScene scene) {
        if (mContext == null) {
            return;
        }
        if (roomInfo == null) {
            return;
        }
        if (TextUtils.isEmpty(roomInfo.roomId)) {
            return;
        }
        TUIRoomDefine.RoomInfo engineRoomInfo = new TUIRoomDefine.RoomInfo();

        engineRoomInfo.roomId = roomInfo.roomId;
        if (TUIRoomKit.RoomScene.MEETING.equals(scene)) {
            engineRoomInfo.roomType = TUIRoomDefine.RoomType.CONFERENCE;
        } else {
            engineRoomInfo.roomType = TUIRoomDefine.RoomType.LIVE_ROOM;
        }
        engineRoomInfo.name = roomInfo.name;
        engineRoomInfo.speechMode = roomInfo.speechMode;
        engineRoomInfo.isCameraDisableForAllUser = false;
        engineRoomInfo.isMicrophoneDisableForAllUser = false;
        engineRoomInfo.isMessageDisableForAllUser = false;
        TUIRoomEngine roomEngine = getRoomEngine();
        roomEngine.createRoom(engineRoomInfo, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "createRoom success");
                if (mListener != null) {
                    mListener.onCreateEngineRoom(0, "success", roomInfo);
                }
                enterRoom(roomInfo);
            }

            @Override
            public void onError(TUICommonDefine.Error code, String message) {
                ToastUtil.toastShortMessage("code: " + code + " message:" + message);
                Log.e(TAG, "createRoom onError code : " + code + " message:" + message);
                if (mListener != null) {
                    mListener.onCreateEngineRoom(-1, message, null);
                }
            }
        });
    }

    private void startLocalMicrophoneIfNeeded(final RoomInfo roomInfo) {
        if (!roomInfo.isOpenMicrophone) {
            return;
        }
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, null);
                mRoomEngine.startPushLocalAudio();
                mRoomStore.roomInfo.isOpenMicrophone = true;
            }
        };
        PermissionRequester.newInstance(Manifest.permission.RECORD_AUDIO)
                .title(mContext.getString(R.string.tuiroomkit_permission_mic_reason_title,
                        CommonUtils.getAppName(mContext)))
                .description(mContext.getString(R.string.tuiroomkit_permission_mic_reason))
                .settingsTip(mContext.getString(R.string.tuiroomkit_tips_start_audio))
                .callback(callback)
                .request();
    }

    public void enterRoom(final RoomInfo roomInfo) {
        if (mContext == null) {
            return;
        }
        if (roomInfo == null) {
            return;
        }
        final String roomId = roomInfo.roomId;
        if (TextUtils.isEmpty(roomId)) {
            return;
        }

        TUIRoomEngine roomEngine = getRoomEngine();
        if (roomEngine == null) {
            roomEngine = TUIRoomEngine.createInstance();
        }
        final TUIRoomEngine finalRoomEngine = roomEngine;
        roomEngine.enterRoom(roomId, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                Log.i(TAG, "enterRoom success");
                startLocalMicrophoneIfNeeded(roomInfo);
                roomInfo.name = engineRoomInfo.name;
                roomInfo.owner = engineRoomInfo.ownerId;
                roomInfo.roomId = engineRoomInfo.roomId;
                roomInfo.isCameraDisableForAllUser = engineRoomInfo.isCameraDisableForAllUser;
                roomInfo.isMicrophoneDisableForAllUser = engineRoomInfo.isMicrophoneDisableForAllUser;
                roomInfo.isMessageDisableForAllUser = engineRoomInfo.isMessageDisableForAllUser;
                roomInfo.speechMode = engineRoomInfo.speechMode;
                mRoomStore.roomInfo = roomInfo;
                mRoomStore.roomScene = TUIRoomDefine.RoomType.CONFERENCE.equals(engineRoomInfo.roomType)
                        ? TUIRoomKit.RoomScene.MEETING
                        : TUIRoomKit.RoomScene.LIVE;
                TUIRoomDefine.Role role = TUIRoomDefine.Role.GENERAL_USER;
                if (engineRoomInfo.ownerId.equals(mRoomStore.userModel.userId)) {
                    role = TUIRoomDefine.Role.ROOM_OWNER;
                }
                mRoomStore.userModel.role = role;
                if (TUIRoomDefine.SpeechMode.FREE_TO_SPEAK.equals(roomInfo.speechMode)) {
                    if (mListener != null) {
                        mListener.onEnterEngineRoom(0, "success", roomInfo);
                    }
                    return;
                }
                if (!TUIRoomDefine.Role.ROOM_OWNER.equals(role)) {
                    if (mListener != null) {
                        mListener.onEnterEngineRoom(0, "success", roomInfo);
                    }
                    return;
                }
                finalRoomEngine.takeSeat(SEAT_INDEX, REQ_TIME_OUT, new TUIRoomDefine.RequestCallback() {
                    @Override
                    public void onAccepted(String requestId, String userId) {
                        mRoomStore.userModel.isOnSeat = true;
                        if (mListener != null) {
                            mListener.onEnterEngineRoom(0, "success", roomInfo);
                        }
                    }

                    @Override
                    public void onRejected(String requestId, String userId, String message) {
                        Log.e(TAG, "takeSeat onRejected userId : " + userId + " message:" + message);
                    }

                    @Override
                    public void onCancelled(String requestId, String userId) {
                        Log.e(TAG, "takeSeat onRejected requestId : " + requestId + ",userId:" + userId);
                    }

                    @Override
                    public void onTimeout(String requestId, String userId) {
                        Log.e(TAG, "takeSeat onTimeout userId : " + userId);
                    }

                    @Override
                    public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                        Log.e(TAG, "takeSeat onError userId:" + userId + ",code : " + code + ",message:" + message);
                    }
                });
            }

            @Override
            public void onError(TUICommonDefine.Error code, String message) {
                Log.e(TAG, "enterRoom onError code : " + code + " message:" + message);
                ToastUtil.toastShortMessage("code: " + code + " message:" + message);
                if (mListener != null) {
                    mListener.onEnterEngineRoom(-1, message, null);
                }
            }
        });
    }

    public void exitRoom() {
        if (mRoomStore.roomInfo == null) {
            return;
        }
        if (mRoomStore.userModel.userId == null) {
            return;
        }
        TUIRoomEngine roomEngine = getRoomEngine();
        roomEngine.stopPushLocalVideo();
        roomEngine.stopPushLocalAudio();
        roomEngine.closeLocalCamera();
        roomEngine.closeLocalMicrophone();
        if (TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role)) {
            roomEngine.destroyRoom(null);
            if (mListener != null) {
                mListener.onDestroyEngineRoom();
            }
        } else {
            roomEngine.exitRoom(false, null);
            if (mListener != null) {
                mListener.onExitEngineRoom();
            }
        }

        refreshRoomStore();
        refreshRoomEngine();
    }

    private void refreshRoomStore() {
        mRoomStore = new RoomStore();
        mRoomStore.initialCurrentUser();
    }

    public TUIRoomEngine getRoomEngine() {
        return mRoomEngine;
    }

    public RoomStore getRoomStore() {
        return mRoomStore;
    }

    public interface Listener {
        void onLogin(int code, String message);

        void onCreateEngineRoom(int code, String message, RoomInfo roomInfo);

        void onEnterEngineRoom(int code, String message, RoomInfo roomInfo);

        void onDestroyEngineRoom();

        void onExitEngineRoom();
    }
}
