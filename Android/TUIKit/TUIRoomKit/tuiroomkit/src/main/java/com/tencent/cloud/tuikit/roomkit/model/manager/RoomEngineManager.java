package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.CAMERA_START_FAIL;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.PERMISSION_DENIED;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RequestAction.REQUEST_TO_OPEN_REMOTE_CAMERA;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RequestAction.REQUEST_TO_OPEN_REMOTE_MICROPHONE;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.KEY_ERROR;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_CREATE_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.service.KeepAliveService;
import com.tencent.cloud.tuikit.roomkit.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.view.service.RoomFloatWindowManager;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.trtc.TRTCCloudDef;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomEngineManager {
    private static final String TAG = "RoomEngineManager";

    private static RoomEngineManager sInstance;
    private static boolean           sIsLoginSuccess = false;

    private Context         mContext;
    private TUIRoomEngine   mRoomEngine;
    private RoomStore       mRoomStore;
    private TUIRoomObserver mObserver;

    private RoomFloatWindowManager mRoomFloatWindowManager;

    private boolean mIsMicOpened = false;

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

    public void responseRemoteRequest(TUIRoomDefine.RequestAction requestAction, String requestId, boolean agree,
                                      TUIRoomDefine.ActionCallback callback) {
        if ((requestAction == REQUEST_TO_OPEN_REMOTE_MICROPHONE || requestAction == REQUEST_TO_OPEN_REMOTE_CAMERA)
                && agree) {
            PermissionCallback permissionCallback = new PermissionCallback() {
                @Override
                public void onGranted() {
                    mRoomEngine.responseRemoteRequest(requestId, true, callback);
                }

                @Override
                public void onRequesting() {
                    mRoomEngine.responseRemoteRequest(requestId, false, callback);
                }

                @Override
                public void onDenied() {
                    mRoomEngine.responseRemoteRequest(requestId, false, callback);
                }
            };
            if (requestAction == REQUEST_TO_OPEN_REMOTE_MICROPHONE) {
                RoomPermissionUtil.requestAudioPermission(mContext, permissionCallback);
                return;
            }
            if (requestAction == REQUEST_TO_OPEN_REMOTE_CAMERA) {
                RoomPermissionUtil.requestCameraPermission(mContext, permissionCallback);
                return;
            }
            return;
        }

        mRoomEngine.responseRemoteRequest(requestId, agree, callback);
    }

    public void cancelRequest(String requestId, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.cancelRequest(requestId, callback);
    }

    public void setLocalVideoView(TUIRoomDefine.VideoStreamType videoStreamType, TUIVideoView videoView) {
        mRoomEngine.setLocalVideoView(videoStreamType, videoView);
    }

    public void setRemoteVideoView(String userId, TUIRoomDefine.VideoStreamType videoStreamType,
                                   TUIVideoView videoView) {
        mRoomEngine.setRemoteVideoView(userId, videoStreamType, videoView);
    }

    public void startPlayRemoteVideo(String userId, TUIRoomDefine.VideoStreamType videoStreamType,
                                     TUIRoomDefine.PlayCallback callback) {
        mRoomEngine.startPlayRemoteVideo(userId, videoStreamType, callback);
    }

    public void stopPlayRemoteVideo(String userId, TUIRoomDefine.VideoStreamType videoStreamType) {
        mRoomEngine.stopPlayRemoteVideo(userId, videoStreamType);
    }

    public void startScreenCapture() {
        if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
            Log.w(TAG, "startScreenCapture no permission");
            return;
        }
        mRoomEngine.startScreenSharing();
    }

    public void stopScreenCapture() {
        mRoomEngine.stopScreenSharing();
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

    public void switchCamera() {
        mRoomStore.videoModel.isFrontCamera = !mRoomStore.videoModel.isFrontCamera;
        mRoomEngine.getDeviceManager().switchCamera(mRoomStore.videoModel.isFrontCamera);
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

        if (!mIsMicOpened) {
            RoomPermissionUtil.requestAudioPermission(mContext, callback);
            mIsMicOpened = true;
        } else {
            mRoomEngine.unmuteLocalAudio(micCallback);
        }
    }

    public void closeLocalMicrophone() {
        mRoomEngine.muteLocalAudio();
    }

    public void openRemoteDeviceByAdmin(String userId, TUIRoomDefine.MediaDevice device, int timeout
            , TUIRoomDefine.RequestCallback callback) {
        mRoomEngine.openRemoteDeviceByAdmin(userId, device, timeout, callback);
    }

    public void closeRemoteDeviceByAdmin(String userId, TUIRoomDefine.MediaDevice device,
                                         TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.closeRemoteDeviceByAdmin(userId, device, callback);
    }

    public void disableSendingMessageByAdmin(String userId, boolean isDisable, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.disableSendingMessageByAdmin(userId, isDisable, callback);
    }

    public void kickRemoteUserOutOfRoom(String userId, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.kickRemoteUserOutOfRoom(userId, callback);
    }

    public void takeUserOnSeatByAdmin(int seatIndex, String userId, int timeout,
                                      TUIRoomDefine.RequestCallback callback) {
        mRoomEngine.takeUserOnSeatByAdmin(seatIndex, userId, timeout, callback);
    }

    public void kickUserOffSeatByAdmin(int seatIndex, String userId, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.kickUserOffSeatByAdmin(seatIndex, userId, callback);
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

    public void startAudioRecording(String filePath) {
        TRTCCloudDef.TRTCAudioRecordingParams params = new TRTCCloudDef.TRTCAudioRecordingParams();
        params.filePath = filePath;
        mRoomEngine.getTRTCCloud().startAudioRecording(params);
    }

    public void stopAudioRecording() {
        mRoomEngine.getTRTCCloud().stopAudioRecording();
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

    public void setAudioRoute(boolean isSoundOnSpeaker) {
        mRoomEngine.getDeviceManager().setAudioRoute(
                isSoundOnSpeaker ? TXDeviceManager.TXAudioRoute.TXAudioRouteSpeakerphone :
                        TXDeviceManager.TXAudioRoute.TXAudioRouteEarpiece);
        mRoomStore.audioModel.setSoundOnSpeaker(isSoundOnSpeaker);
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
        Log.d(TAG, "enableVideoLocalMirror enable=" + enable);
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
        Log.d(TAG, "createInstance mRoomEngine=" + mRoomEngine);

        mObserver = new RoomEventDispatcher(mRoomStore);
        mRoomEngine.addObserver(mObserver);
    }

    public void changeUserRole(String userId, TUIRoomDefine.Role role, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.changeUserRole(userId, role, callback);
    }

    public void setSelfInfo(String userName, String avatarURL, TUIRoomDefine.ActionCallback callback) {
        Log.i(TAG, "setSelfInfo userName: " + userName + ",avatarURL: " + avatarURL);
        mRoomStore.userModel.userName = TextUtils.isEmpty(userName) ? "" : userName;
        mRoomStore.userModel.userAvatar = TextUtils.isEmpty(userName) ? "" : avatarURL;
        TUIRoomEngine.setSelfInfo(mRoomStore.userModel.userName, mRoomStore.userModel.userAvatar, callback);
    }

    public void getUserInfo(String userId, TUIRoomDefine.GetUserInfoCallback callback) {
        mRoomEngine.getUserInfo(userId, callback);
    }

    public void createRoom(TUIRoomDefine.RoomInfo roomInfo, TUIRoomDefine.ActionCallback callback) {
        loginRoomEngine(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "createRoom roomInfo=" + roomInfo + " thread.name=" + Thread.currentThread().getName());
                mRoomEngine.createRoom(roomInfo, new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        Log.i(TAG, "createRoom onSuccess thread.name=" + Thread.currentThread().getName());
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, TUICommonDefine.Error.SUCCESS);
                        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_CREATE_ROOM, params);
                        if (callback != null) {
                            callback.onSuccess();
                        }
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "createRoom onError error=" + error + " message=" + message);
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, error);
                        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_CREATE_ROOM, params);
                        if (callback != null) {
                            callback.onError(error, message);
                        }
                    }
                });
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, error);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_CREATE_ROOM, params);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void enterRoom(String roomId, TUIRoomDefine.GetRoomInfoCallback callback) {
        loginRoomEngine(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                setFramework();
                Log.i(TAG, "enterRoom roomId=" + roomId + " thread.name=" + Thread.currentThread().getName());
                mRoomEngine.enterRoom(roomId, new TUIRoomDefine.GetRoomInfoCallback() {
                    @Override
                    public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                        Log.i(TAG, "enterRoom onSuccess thread.name=" + Thread.currentThread().getName());
                        updateRoomStore(engineRoomInfo);
                        setVideoEncoderParam();
                        autoTakeSeatForOwner();
                        KeepAliveService.startKeepAliveService(
                                mContext.getString(mContext.getApplicationInfo().labelRes),
                                mContext.getString(R.string.tuiroomkit_app_running));
                        mRoomFloatWindowManager = new RoomFloatWindowManager(mContext);
                        if (callback != null) {
                            callback.onSuccess(engineRoomInfo);
                        }
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, TUICommonDefine.Error.SUCCESS);
                        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
                        getUserList();
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        ToastUtil.toastShortMessage("error=" + error + " message=" + message);
                        if (callback != null) {
                            callback.onError(error, message);
                        }
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, error);
                        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
                    }
                });
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                if (callback != null) {
                    callback.onError(error, message);
                }
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, error);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
            }
        });
    }

    public TUIRoomDefine.Request takeSeat(int seatIndex, int timeOut, TUIRoomDefine.RequestCallback callback) {
        Log.d(TAG, "takeSeat");
        return mRoomEngine.takeSeat(seatIndex, timeOut, new TUIRoomDefine.RequestCallback() {
            @Override
            public void onAccepted(String requestId, String userId) {
                Log.d(TAG, "takeSeat onAccepted requestId=" + requestId + " userId=" + userId);
                mRoomStore.userModel.isOnSeat = true;
                if (callback != null) {
                    callback.onAccepted(requestId, userId);
                }
            }

            @Override
            public void onRejected(String requestId, String userId, String message) {
                Log.i(TAG, "takeSeat onRejected userId=" + userId + " message=" + message);
                mRoomStore.userModel.isOnSeat = false;
                if (callback != null) {
                    callback.onRejected(requestId, userId, message);
                }
            }

            @Override
            public void onCancelled(String requestId, String userId) {
                Log.i(TAG, "takeSeat onRejected requestId=" + requestId + " userId=" + userId);
                if (callback != null) {
                    callback.onCancelled(requestId, userId);
                }
            }

            @Override
            public void onTimeout(String requestId, String userId) {
                Log.i(TAG, "takeSeat onTimeout requestId=" + requestId + " userId=" + userId);
                if (callback != null) {
                    callback.onTimeout(requestId, userId);
                }
            }

            @Override
            public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                Log.e(TAG, "takeSeat onError userId=" + userId + " code=" + code + " message=" + message);
                if (callback != null) {
                    callback.onError(requestId, userId, code, message);
                }
            }
        });
    }

    public void leaveSeat(TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.leaveSeat(callback);
    }

    private void autoTakeSeatForOwner() {
        if (mRoomStore.userModel.role == TUIRoomDefine.Role.ROOM_OWNER
                && mRoomStore.roomInfo.speechMode == SPEAK_AFTER_TAKING_SEAT) {
            takeSeat(0, 0, null);
        }
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

    private long mNextSequence = 0;

    private void getUserList() {
        mRoomEngine.getUserList(mNextSequence, new TUIRoomDefine.GetUserListCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                for (TUIRoomDefine.UserInfo userInfo : userListResult.userInfoList) {
                    mRoomStore.remoteUserEnterRoom(userInfo);
                }

                mNextSequence = userListResult.nextSequence;
                if (mNextSequence != 0) {
                    getUserList();
                } else if (mRoomStore.roomInfo.speechMode == SPEAK_AFTER_TAKING_SEAT) {
                    getSeatList();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.d(TAG, "getUserList onError, error=" + error + "  s=" + s);
            }
        });
    }

    private void getSeatList() {
        mRoomEngine.getSeatList(new TUIRoomDefine.GetSeatListCallback() {
            @Override
            public void onSuccess(List<TUIRoomDefine.SeatInfo> list) {
                for (TUIRoomDefine.SeatInfo item : list) {
                    mRoomStore.setUserOnSeat(item.userId, true);
                    mRoomEngine.getUserInfo(item.userId, new TUIRoomDefine.GetUserInfoCallback() {
                        @Override
                        public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                            mRoomStore.remoteUserTakeSeat(userInfo);
                        }

                        @Override
                        public void onError(TUICommonDefine.Error error, String s) {
                            Log.e(TAG, "getUserInfo onError, error=" + error + "  s=" + s);
                        }
                    });
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "getUserList onError, error=" + error + "  s=" + s);
            }
        });
    }

    private void updateRoomStore(TUIRoomDefine.RoomInfo engineRoomInfo) {
        mRoomStore.roomInfo = engineRoomInfo;
        mRoomStore.userModel.role =
                TextUtils.equals(engineRoomInfo.ownerId, TUILogin.getUserId()) ? TUIRoomDefine.Role.ROOM_OWNER :
                        TUIRoomDefine.Role.GENERAL_USER;
    }

    public void exitRoom(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "exitRoom mRoomEngine=" + mRoomEngine);
        mRoomEngine.exitRoom(false, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "exitRoom onSuccess");
                destroyInstance();
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, TUICommonDefine.Error.SUCCESS);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_EXIT_ROOM, params);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "exitRoom onError error=" + error + " s=" + s);
                destroyInstance();
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, error);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_EXIT_ROOM, params);
                if (callback != null) {
                    callback.onError(error, s);
                }
            }
        });
    }

    public void destroyRoom(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "destroyRoom mRoomEngine=" + mRoomEngine);
        mRoomEngine.destroyRoom(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "destroyRoom onSuccess");
                destroyInstance();
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, TUICommonDefine.Error.SUCCESS);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_DESTROY_ROOM, params);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "destroyRoom onError error=" + error + " s=" + s);
                destroyInstance();
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, error);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_DESTROY_ROOM, params);
                if (callback != null) {
                    callback.onError(error, s);
                }
            }
        });
    }

    public TUIRoomEngine getRoomEngine() {
        return mRoomEngine;
    }

    public RoomStore getRoomStore() {
        return mRoomStore;
    }

    private void destroyInstance() {
        KeepAliveService.stopKeepAliveService();
        mRoomFloatWindowManager.destroy();
        mRoomEngine.removeObserver(mObserver);
        sInstance = null;
    }

    private static void loginRoomEngine(TUIRoomDefine.ActionCallback callback) {
        if (sIsLoginSuccess) {
            if (callback != null) {
                callback.onSuccess();
            }
            return;
        }
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Log.i(TAG, "TUIRoomEngine.login");
                TUIRoomEngine.login(TUILogin.getAppContext(), TUILogin.getSdkAppId(), TUILogin.getUserId(),
                        TUILogin.getUserSig(), new TUIRoomDefine.ActionCallback() {
                            @Override
                            public void onSuccess() {
                                Log.i(TAG, "TUIRoomEngine.login onSuccess");
                                sIsLoginSuccess = true;
                                if (callback != null) {
                                    callback.onSuccess();
                                }
                            }

                            @Override
                            public void onError(TUICommonDefine.Error error, String message) {
                                Log.e(TAG, "TUIRoomEngine.login onError error=" + error + " message=" + message);
                                if (callback != null) {
                                    callback.onError(error, message);
                                }
                            }
                        });
            }
        });
    }

    private static void runOnMainThread(Runnable runnable) {
        if (Looper.getMainLooper() == Looper.myLooper()) {
            runnable.run();
        } else {
            Handler mainHandler = new Handler(Looper.getMainLooper());
            mainHandler.post(runnable);
        }
    }
}
