package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.PERMISSION_DENIED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;

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

    public static RoomEngineManager sharedInstance() {
        return sharedInstance(TUILogin.getAppContext());
    }

    public static RoomEngineManager sharedInstance(Context context) {
        if (sInstance == null) {
            synchronized (RoomEngineManager.class) {
                if (sInstance == null) {
                    sInstance = new RoomEngineManager(context);
                }
            }
        }
        return sInstance;
    }

    public static void loginRoomEngine(TUIRoomDefine.ActionCallback callback) {
        TUIRoomEngine.login(TUILogin.getAppContext(), TUILogin.getSdkAppId(), TUILogin.getUserId(),
                TUILogin.getUserSig(), callback);
    }

    public void startScreenCapture() {
        if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
            Log.w(TAG, "startScreenCapture no permission");
            return;
        }
        mRoomEngine.startScreenSharing();
        mRoomStore.videoModel.setScreenSharing(true);
    }

    public void stopScreenCapture() {
        mRoomEngine.stopScreenSharing();
        mRoomStore.videoModel.setScreenSharing(false);
    }

    public void openLocalCamera(TUIRoomDefine.ActionCallback cameraCallback) {
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                mRoomEngine.openLocalCamera(mRoomStore.videoModel.isFrontCamera, TUIRoomDefine.VideoQuality.Q_1080P,
                        cameraCallback);
            }

            @Override
            public void onDenied() {
                if (cameraCallback != null) {
                    cameraCallback.onError(PERMISSION_DENIED, "camera permission denied");
                }
            }
        };

        RoomPermissionUtil.requestCameraPermission(mContext, callback);
    }

    public void closeLocalCamera() {
        mRoomEngine.closeLocalCamera();
    }

    public void openLocalMicrophone(TUIRoomDefine.ActionCallback micCallback) {
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, micCallback);
            }

            @Override
            public void onDenied() {
                if (micCallback != null) {
                    micCallback.onError(PERMISSION_DENIED, "mic permission denied");
                }
            }
        };

        RoomPermissionUtil.requestAudioPermission(mContext, callback);
    }

    public void closeLocalMicrophone() {
        mRoomEngine.closeLocalMicrophone();
    }

    public void enableAutoShowRoomMainUi(boolean enable) {
        mRoomStore.setAutoShowRoomMainUi(enable);
    }

    public void enterFloatWindow() {
        mRoomStore.setInFloatWindow(true);
    }

    public void exitFloatWindow() {
        mRoomStore.setInFloatWindow(false);
    }

    public void setAudioCaptureVolume(int volume) {
        mRoomEngine.getTRTCCloud().setAudioCaptureVolume(volume);
        mRoomStore.audioModel.captureVolume = volume;
    }

    public void setAudioPlayOutVolume(int volume) {
        mRoomEngine.getTRTCCloud().setAudioPlayoutVolume(volume);
        mRoomStore.audioModel.playVolume = volume;
    }

    public void enableAudioVolumeEvaluation(boolean enable) {
        TRTCCloudDef.TRTCAudioVolumeEvaluateParams params = new TRTCCloudDef.TRTCAudioVolumeEvaluateParams();
        mRoomEngine.getTRTCCloud().enableAudioVolumeEvaluation(enable, params);
        mRoomStore.audioModel.enableVolumeEvaluation = enable;
    }

    public void setVideoBitrate(int bitrate) {
        mRoomStore.videoModel.bitrate = bitrate;
        setVideoEncoderParam();
    }

    public void setVideoResolution(int resolution) {
        mRoomStore.videoModel.resolution = resolution;
        setVideoEncoderParam();
    }

    public void setVideoFps(int fps) {
        mRoomStore.videoModel.fps = fps;
        setVideoEncoderParam();
    }

    public void enableVideoLocalMirror(boolean enable) {
        TRTCCloudDef.TRTCRenderParams param = new TRTCCloudDef.TRTCRenderParams();
        param.mirrorType = enable ? TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE
                : TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE;
        mRoomEngine.getTRTCCloud().setLocalRenderParams(param);
        mRoomStore.videoModel.isLocalMirror = enable;
    }

    private void setVideoEncoderParam() {
        TRTCCloudDef.TRTCVideoEncParam param = new TRTCCloudDef.TRTCVideoEncParam();
        param.videoResolution = mRoomStore.videoModel.resolution;
        param.videoBitrate = mRoomStore.videoModel.bitrate;
        param.videoFps = mRoomStore.videoModel.fps;
        param.enableAdjustRes = true;
        param.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        mRoomEngine.getTRTCCloud().setVideoEncoderParam(param);
    }

    private RoomEngineManager(Context context) {
        mContext = context.getApplicationContext();
        mRoomStore = new RoomStore();
        mRoomEngine = TUIRoomEngine.createInstance();
        mObserver = new RoomEventDispatcher(mRoomStore);
        mRoomEngine.addObserver(mObserver);
    }

    private void refreshRoomEngine() {
        mRoomEngine.removeObserver(mObserver);
        mObserver = new RoomEventDispatcher(mRoomStore);
        mRoomEngine.addObserver(mObserver);
    }

    public void setListener(Listener listener) {
        mListener = listener;
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

        Log.d(TAG, "createRoom roomId=" + engineRoomInfo.roomId + " thread.name=" + Thread.currentThread().getName());
        roomEngine.createRoom(engineRoomInfo, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "createRoom onSuccess thread.name=" + Thread.currentThread().getName());
                if (mListener != null) {
                    mListener.onCreateEngineRoom(0, "success", roomInfo);
                }
                enterRoom(roomInfo);
            }

            @Override
            public void onError(TUICommonDefine.Error code, String message) {
                Log.e(TAG, "createRoom onError code=" + code + " message=" + message);
                if (mListener != null) {
                    mListener.onCreateEngineRoom(-1, message, null);
                }
            }
        });
    }

    public void enterRoom(final RoomInfo roomInfo) {
        if (mContext == null || roomInfo == null || TextUtils.isEmpty(roomInfo.roomId)) {
            return;
        }

        setFramework();
        Log.d(TAG, "enterRoom roomId=" + roomInfo.roomId + " thread.name=" + Thread.currentThread().getName());
        mRoomEngine.enterRoom(roomInfo.roomId, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                Log.i(TAG, "enterRoom onSuccess" + " thread.name=" + Thread.currentThread().getName());
                TUICore.notifyEvent(RoomEventCenter.RoomEngineMessage.ROOM_ENGINE_MSG,
                        RoomEventCenter.RoomEngineMessage.ROOM_ENTERED, null);
                updateRoomStore(roomInfo, engineRoomInfo);
                disableMicAndCameraForGeneralUserInSpeakAfterTakingSeat();
                notifyEnterRoom(roomInfo);
                fetchUserList();
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

    private void setFramework() {
        String jsonStr = "{\n"
                + "  \"api\":\"setFramework\",\n"
                + "  \"params\":\n"
                + "  {\n"
                + "    \"framework\": 1, \n"
                + "    \"component\": 18, \n"
                + "    \"language\": 1\n"
                + "  }\n"
                + "}";
        mRoomEngine.callExperimentalAPI(jsonStr);
    }

    private long                         mNextSequence = 0;
    private List<TUIRoomDefine.UserInfo> mUserList     = new ArrayList<>();

    private void fetchUserList() {
        Log.d(TAG, "getUserList mNextSequence=" + mNextSequence);
        mRoomEngine.getUserList(mNextSequence, new TUIRoomDefine.GetUserListCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                Log.d(TAG, "getUserList onSuccess nextSequence=" + userListResult.nextSequence + " size="
                        + userListResult.userInfoList.size());
                mNextSequence = userListResult.nextSequence;
                mUserList.addAll(userListResult.userInfoList);
                if (mNextSequence != 0) {
                    fetchUserList();
                } else {
                    mRoomStore.addUserListForEnterRoom(mUserList);
                    mUserList.clear();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.d(TAG, "getUserList onError, error=" + error + "  s=" + s);
            }
        });
    }

    private void updateRoomStore(RoomInfo roomInfo, TUIRoomDefine.RoomInfo engineRoomInfo) {
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
    }

    private void notifyEnterRoom(RoomInfo roomInfo) {
        if (TUIRoomDefine.SpeechMode.FREE_TO_SPEAK.equals(roomInfo.speechMode)
                || !TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role)) {
            if (mListener != null) {
                mListener.onEnterEngineRoom(0, "success", roomInfo);
            }
            return;
        }

        mRoomEngine.takeSeat(SEAT_INDEX, REQ_TIME_OUT, new TUIRoomDefine.RequestCallback() {
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

    private void disableMicAndCameraForGeneralUserInSpeakAfterTakingSeat() {
        if (mRoomStore.roomInfo.speechMode == TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT
                && mRoomStore.userModel.role == TUIRoomDefine.Role.GENERAL_USER) {
            mRoomStore.roomInfo.isOpenCamera = false;
            mRoomStore.roomInfo.isOpenMicrophone = false;
        }
    }

    public void exitRoom() {
        if (mRoomStore.roomInfo == null) {
            return;
        }
        if (mRoomStore.userModel.userId == null) {
            return;
        }
        TUIRoomEngine roomEngine = getRoomEngine();
        if (TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role)) {
            Log.d(TAG, "destroyRoom");
            roomEngine.destroyRoom(new TUIRoomDefine.ActionCallback() {
                @Override
                public void onSuccess() {
                    Log.d(TAG, "destroyRoom onSuccess");
                    RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_DESTROY_ROOM, null);
                    if (mListener != null) {
                        mListener.onDestroyEngineRoom();
                    }
                    reset();
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    Log.e(TAG, "destroyRoom onError error=" + error + " s=" + s);
                    RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_DESTROY_ROOM, null);
                    if (mListener != null) {
                        mListener.onDestroyEngineRoom();
                    }
                    reset();
                }
            });
        } else {
            Log.d(TAG, "exitRoom");
            roomEngine.exitRoom(false, new TUIRoomDefine.ActionCallback() {
                @Override
                public void onSuccess() {
                    Log.d(TAG, "exitRoom onSuccess");
                    RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_EXIT_ROOM, null);
                    if (mListener != null) {
                        mListener.onExitEngineRoom();
                    }
                    reset();
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    Log.e(TAG, "exitRoom onError error=" + error + " s=" + s);
                    RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_EXIT_ROOM, null);
                    if (mListener != null) {
                        mListener.onExitEngineRoom();
                    }
                    reset();
                }
            });
        }
    }

    private void reset() {
        mRoomStore.reset();
        refreshRoomEngine();
    }

    public TUIRoomEngine getRoomEngine() {
        return mRoomEngine;
    }

    public RoomStore getRoomStore() {
        return mRoomStore;
    }

    public interface Listener {
        void onCreateEngineRoom(int code, String message, RoomInfo roomInfo);

        void onEnterEngineRoom(int code, String message, RoomInfo roomInfo);

        void onDestroyEngineRoom();

        void onExitEngineRoom();
    }
}
