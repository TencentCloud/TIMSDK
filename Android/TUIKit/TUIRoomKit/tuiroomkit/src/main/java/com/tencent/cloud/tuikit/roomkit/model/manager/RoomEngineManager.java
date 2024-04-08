package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.ALREADY_IN_SEAT;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.PERMISSION_DENIED;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RequestAction.REQUEST_TO_OPEN_REMOTE_CAMERA;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RequestAction.REQUEST_TO_OPEN_REMOTE_MICROPHONE;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.ResolutionMode.LANDSCAPE;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.ResolutionMode.PORTRAIT;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.GENERAL_USER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.ROOM_OWNER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM_LOW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.KEY_ERROR;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_CREATE_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_ROOM_ID;

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
import com.tencent.cloud.tuikit.roomkit.ConferenceObserver;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.imaccess.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.TakeSeatRequestEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.service.KeepAliveService;
import com.tencent.cloud.tuikit.roomkit.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.utils.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.page.RoomWindowManager;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomEngineManager {
    private static final String TAG = "RoomEngineManager";

    private static RoomEngineManager sInstance;

    private boolean mIsLoginSuccess = false;

    private Context         mContext;
    private TUIRoomEngine   mRoomEngine;
    private RoomStore       mRoomStore;
    private TUIRoomObserver mObserver;

    private TRTCCloud    mTRTCCloud;
    private TRTCObserver mTRTCObserver;

    private RoomWindowManager mRoomFloatWindowManager;

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
                    if (requestAction == REQUEST_TO_OPEN_REMOTE_MICROPHONE) {
                        mRoomStore.audioModel.setMicOpen(true);
                    } else if (requestAction == REQUEST_TO_OPEN_REMOTE_CAMERA) {
                        mRoomStore.videoModel.setCameraOpened(true);
                    }
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

        mRoomEngine.responseRemoteRequest(requestId, agree, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
                mRoomStore.removeTakeSeatRequest(requestId);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                if (callback != null) {
                    callback.onError(error, s);
                }
            }
        });
    }

    public void cancelRequest(String requestId, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.cancelRequest(requestId, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                if (TextUtils.equals(requestId, mRoomStore.userModel.takeSeatRequestId)) {
                    mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                    mRoomStore.userModel.takeSeatRequestId = null;
                }
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.e(TAG, "onError error=" + error + " message=" + message);
                if (TextUtils.equals(requestId, mRoomStore.userModel.takeSeatRequestId)) {
                    mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                    mRoomStore.userModel.takeSeatRequestId = null;
                }
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
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
                Log.d(TAG, "openLocalCamera");
                mRoomEngine.openLocalCamera(mRoomStore.videoModel.isFrontCamera, mRoomStore.videoModel.getResolution(),
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
        Log.d(TAG, "closeLocalCamera");
        mRoomEngine.closeLocalCamera();
    }

    public void switchCamera() {
        mRoomStore.videoModel.isFrontCamera = !mRoomStore.videoModel.isFrontCamera;
        mRoomEngine.getDeviceManager().switchCamera(mRoomStore.videoModel.isFrontCamera);
    }

    public void enableLocalAudio() {
        if (!isAllowToToggleAudio()) {
            return;
        }
        if (RoomEngineManager.sharedInstance().getRoomStore().audioModel.isMicOpen()) {
            RoomEngineManager.sharedInstance().unMuteLocalAudio(null);
        } else {
            RoomEngineManager.sharedInstance().openLocalMicrophone(null);
        }
    }

    public void disableLocalAudio() {
        if (RoomEngineManager.sharedInstance().getRoomStore().audioModel.isMicOpen()) {
            RoomEngineManager.sharedInstance().muteLocalAudio();
        }
    }

    public void openLocalMicrophone(TUIRoomDefine.ActionCallback micCallback) {
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                Log.d(TAG, "openLocalMicrophone");
                mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, micCallback);
                mRoomStore.audioModel.setMicOpen(true);
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

    public void unMuteLocalAudio(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "unmuteLocalAudio");
        mRoomEngine.unmuteLocalAudio(callback);
    }

    public void muteLocalAudio() {
        Log.d(TAG, "muteLocalAudio");
        mRoomEngine.muteLocalAudio();
    }

    public void closeLocalMicrophone() {
        Log.d(TAG, "closeLocalMicrophone");
        mRoomEngine.closeLocalMicrophone();
        mRoomStore.audioModel.setMicOpen(false);
    }

    public void disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice device, boolean isDisable,
                                               TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "disableDeviceForAllUserByAdmin device=" + device + " isDisable=" + isDisable);
        mRoomEngine.disableDeviceForAllUserByAdmin(device, isDisable, callback);
    }

    public void openRemoteDeviceByAdmin(String userId, TUIRoomDefine.MediaDevice device, int timeout
            , TUIRoomDefine.RequestCallback callback) {
        Log.d(TAG, "openRemoteDeviceByAdmin userId=" + userId + " device=" + userId);
        mRoomEngine.openRemoteDeviceByAdmin(userId, device, timeout, callback);
    }

    public void closeRemoteDeviceByAdmin(String userId, TUIRoomDefine.MediaDevice device,
                                         TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "closeRemoteDeviceByAdmin userId=" + userId + " device=" + userId);
        mRoomEngine.closeRemoteDeviceByAdmin(userId, device, callback);
    }

    public void disableSendingMessageByAdmin(String userId, boolean isDisable, TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "disableSendingMessageByAdmin userId=" + userId + " isDisable=" + isDisable);
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
        mRoomStore.audioModel.setCaptureVolume(volume);
    }

    public void setAudioPlayOutVolume(int volume) {
        mRoomEngine.getTRTCCloud().setAudioPlayoutVolume(volume);
        mRoomStore.audioModel.setPlayVolume(volume);
    }

    public void enableAudioVolumeEvaluation(boolean enable) {
        TRTCCloudDef.TRTCAudioVolumeEvaluateParams params = new TRTCCloudDef.TRTCAudioVolumeEvaluateParams();
        mRoomEngine.getTRTCCloud().enableAudioVolumeEvaluation(enable, params);
        mRoomStore.audioModel.setEnableVolumeEvaluation(enable);
    }

    public void setAudioRoute(boolean isSoundOnSpeaker) {
        mRoomEngine.getDeviceManager().setAudioRoute(
                isSoundOnSpeaker ? TXDeviceManager.TXAudioRoute.TXAudioRouteSpeakerphone :
                        TXDeviceManager.TXAudioRoute.TXAudioRouteEarpiece);
        mRoomStore.audioModel.setSoundOnSpeaker(isSoundOnSpeaker);
    }

    public void setCameraResolutionMode(boolean isPortrait) {
        mRoomEngine.setVideoResolutionMode(CAMERA_STREAM, isPortrait ? PORTRAIT : LANDSCAPE);
        mRoomEngine.setVideoResolutionMode(CAMERA_STREAM_LOW, isPortrait ? PORTRAIT : LANDSCAPE);
    }

    public void setVideoResolution(TUIRoomDefine.VideoQuality resolution) {
        mRoomStore.videoModel.setResolution(resolution);
        setVideoEncoderParam();
    }

    public void setVideoFps(int fps) {
        mRoomStore.videoModel.setFps(fps);
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
        TUIRoomDefine.RoomVideoEncoderParams params = new TUIRoomDefine.RoomVideoEncoderParams();
        params.videoResolution = mRoomStore.videoModel.getResolution();
        params.resolutionMode = PORTRAIT;
        params.fps = mRoomStore.videoModel.getFps();
        params.bitrate = mRoomStore.videoModel.getBitrate();
        Log.d(TAG, "updateVideoQualityEx videoResolution=" + params.videoResolution);
        mRoomEngine.updateVideoQualityEx(CAMERA_STREAM, params);
    }

    private RoomEngineManager(Context context) {
        mContext = context.getApplicationContext();
        mRoomStore = new RoomStore();
        mRoomEngine = TUIRoomEngine.sharedInstance();
        Log.d(TAG, "createInstance mRoomEngine=" + mRoomEngine + " manager=" + this);

        mObserver = new RoomEventDispatcher(mRoomStore);
        mRoomEngine.addObserver(mObserver);
        mRoomFloatWindowManager = new RoomWindowManager(mContext);

        mTRTCCloud = TRTCCloud.sharedInstance(mContext);
        mTRTCObserver = new TRTCObserver();
        mTRTCCloud.addListener(mTRTCObserver);
    }

    public void changeUserRole(String userId, TUIRoomDefine.Role role, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.changeUserRole(userId, role, callback);
    }

    public void setSelfInfo(String userName, String avatarURL, TUIRoomDefine.ActionCallback callback) {
        Log.i(TAG, "setSelfInfo userName: " + userName + ",avatarURL: " + avatarURL);
        TUIRoomEngine.setSelfInfo(userName, avatarURL, callback);
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
                        mRoomStore.userModel.initRole(ROOM_OWNER);
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, TUICommonDefine.Error.SUCCESS);
                        params.put(KEY_ROOM_ID, roomInfo.roomId);
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
                        params.put(KEY_ROOM_ID, roomInfo.roomId);
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
                params.put(KEY_ROOM_ID, roomInfo.roomId);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_CREATE_ROOM, params);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void enterRoom(String roomId, boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker,
                          TUIRoomDefine.GetRoomInfoCallback callback) {
        loginRoomEngine(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                setFramework();
                Log.i(TAG, "enterRoom roomId=" + roomId + " thread.name=" + Thread.currentThread().getName());
                BusinessSceneUtil.setJoinRoomFlag();
                mRoomEngine.enterRoom(roomId, new TUIRoomDefine.GetRoomInfoCallback() {
                    @Override
                    public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                        Log.i(TAG, "enterRoom onSuccess thread.name=" + Thread.currentThread().getName());
                        initRoomStore(engineRoomInfo);
                        setVideoEncoderParam();
                        autoTakeSeatForOwner(new TUIRoomDefine.RequestCallback() {
                            @Override
                            public void onAccepted(String requestId, String userId) {
                                if (callback != null) {
                                    callback.onSuccess(engineRoomInfo);
                                }
                                decideMediaStatus(enableAudio, enableVideo, isSoundOnSpeaker);
                                Map<String, Object> params = new HashMap<>(1);
                                params.put(KEY_ERROR, TUICommonDefine.Error.SUCCESS);
                                params.put(KEY_ROOM_ID, engineRoomInfo.roomId);
                                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
                                getUserList();
                            }

                            @Override
                            public void onRejected(String requestId, String userId, String message) {
                            }

                            @Override
                            public void onCancelled(String requestId, String userId) {
                            }

                            @Override
                            public void onTimeout(String requestId, String userId) {
                            }

                            @Override
                            public void onError(String requestId, String userId, TUICommonDefine.Error error,
                                                String message) {
                            }
                        });
                        KeepAliveService.startKeepAliveService(
                                mContext.getString(mContext.getApplicationInfo().labelRes),
                                mContext.getString(R.string.tuiroomkit_app_running));
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "enterRoom onError error=" + error + " message=" + message);
                        if (callback != null) {
                            callback.onError(error, message);
                        }
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, error);
                        params.put(KEY_ROOM_ID, roomId);
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
                params.put(KEY_ROOM_ID, roomId);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
            }
        });
    }

    public void getSeatApplicationList() {
        if (!mRoomStore.roomInfo.isSeatEnabled) {
            return;
        }
        Log.d(TAG, "getSeatApplicationList");
        for (TakeSeatRequestEntity entity : mRoomStore.takeSeatRequestList) {
            mRoomStore.removeTakeSeatRequest(entity.getRequest().requestId);
        }
        mRoomEngine.getSeatApplicationList(new TUIRoomDefine.RequestListCallback() {
            @Override
            public void onSuccess(List<TUIRoomDefine.Request> list) {
                Log.d(TAG, "getSeatApplicationList onSuccess");
                for (TUIRoomDefine.Request request : list) {
                    mRoomStore.addTakeSeatRequest(request);
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "getSeatApplicationList onError error=" + error + " message=" + message);
            }
        });
    }

    public TUIRoomDefine.Request takeSeat(int seatIndex, int timeOut, TUIRoomDefine.RequestCallback callback) {
        Log.d(TAG, "takeSeat");
        TUIRoomDefine.Request request = mRoomEngine.takeSeat(seatIndex, timeOut, new TUIRoomDefine.RequestCallback() {
            @Override
            public void onAccepted(String requestId, String userId) {
                Log.d(TAG, "takeSeat onAccepted requestId=" + requestId + " userId=" + userId);
                handleTakeSeatAccepted(requestId, userId);
            }

            @Override
            public void onRejected(String requestId, String userId, String message) {
                Log.i(TAG, "takeSeat onRejected userId=" + userId + " message=" + message);
                mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                mRoomStore.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onRejected(requestId, userId, message);
                }
            }

            @Override
            public void onCancelled(String requestId, String userId) {
                Log.i(TAG, "takeSeat onRejected requestId=" + requestId + " userId=" + userId);
                mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                mRoomStore.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onCancelled(requestId, userId);
                }
            }

            @Override
            public void onTimeout(String requestId, String userId) {
                Log.i(TAG, "takeSeat onTimeout requestId=" + requestId + " userId=" + userId);
                mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                mRoomStore.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onTimeout(requestId, userId);
                }
            }

            @Override
            public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                Log.e(TAG, "takeSeat onError userId=" + userId + " code=" + code + " message=" + message);
                if (code == ALREADY_IN_SEAT) {
                    handleTakeSeatAccepted(requestId, userId);
                    return;
                }
                mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                mRoomStore.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onError(requestId, userId, code, message);
                }
            }

            private void handleTakeSeatAccepted(String requestId, String userId) {
                mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.ON_SEAT);
                mRoomStore.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onAccepted(requestId, userId);
                }
            }
        });
        mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.APPLYING_TAKE_SEAT);
        mRoomStore.userModel.takeSeatRequestId = request.requestId;
        return request;
    }

    public void leaveSeat(TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.leaveSeat(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                mRoomStore.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
        mRoomStore.audioModel.setMicOpen(false);
    }

    public void autoTakeSeatForOwner(TUIRoomDefine.RequestCallback callback) {
        if (mRoomStore.userModel.getRole() == ROOM_OWNER
                && mRoomStore.roomInfo.isSeatEnabled && mRoomStore.userModel.isOffSeat()) {
            takeSeat(-1, 0, callback);
            return;
        }
        if (callback != null) {
            callback.onAccepted(null, null);
        }
    }

    public void enableSendingMessageForOwner() {
        if (mRoomStore.userModel.getRole() != ROOM_OWNER) {
            return;
        }
        UserEntity user = mRoomStore.findUserWithCameraStream(mRoomStore.allUserList, mRoomStore.userModel.userId);
        if (user.isEnableSendingMessage()) {
            return;
        }
        disableSendingMessageByAdmin(user.getUserId(), false, null);
    }

    private void setFramework() {
        String jsonStr;
        if (BusinessSceneUtil.isChatAccessRoom()) {
            jsonStr = "{\n"
                    + "  \"api\":\"setFramework\",\n"
                    + "  \"params\":\n"
                    + "  {\n"
                    + "    \"framework\": 1, \n"
                    + "    \"component\": 19, \n"
                    + "    \"language\": 1\n"
                    + "  }\n"
                    + "}";
        } else {
            jsonStr = "{\n"
                    + "  \"api\":\"setFramework\",\n"
                    + "  \"params\":\n"
                    + "  {\n"
                    + "    \"framework\": 1, \n"
                    + "    \"component\": 18, \n"
                    + "    \"language\": 1\n"
                    + "  }\n"
                    + "}";
        }
        TUIRoomEngine.callExperimentalAPI(jsonStr);
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
                } else if (mRoomStore.roomInfo.isSeatEnabled) {
                    getSeatList();
                } else {
                    RoomEventCenter.getInstance().notifyEngineEvent(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, null);
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.d(TAG, "getUserList onError, error=" + error + "  s=" + s);
            }
        });
    }

    private void getSeatList() {
        Log.d(TAG, "getSeatList");
        mRoomEngine.getSeatList(new TUIRoomDefine.GetSeatListCallback() {
            @Override
            public void onSuccess(List<TUIRoomDefine.SeatInfo> list) {
                Log.d(TAG, "getSeatList onSuccess");
                for (TUIRoomDefine.SeatInfo item : list) {
                    if (TextUtils.isEmpty(item.userId)) {
                        continue;
                    }
                    mRoomEngine.getUserInfo(item.userId, new TUIRoomDefine.GetUserInfoCallback() {
                        @Override
                        public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                            Log.d(TAG, "getSeatList remoteUserTakeSeat userId=" + userInfo.userId);
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

    private void initRoomStore(TUIRoomDefine.RoomInfo engineRoomInfo) {
        mRoomStore.roomInfo = engineRoomInfo;
        mRoomStore.userModel.enterRoomTime = System.currentTimeMillis();
        mRoomStore.userModel.initRole(
                TextUtils.equals(engineRoomInfo.ownerId, TUILogin.getUserId()) ? ROOM_OWNER : GENERAL_USER);
    }

    public void release() {
        Log.d(TAG, "release");
        destroyInstance();
    }

    public void exitRoom(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "exitRoom mRoomEngine=" + mRoomEngine);
        final String roomId = mRoomStore.roomInfo.roomId;
        if (TextUtils.isEmpty(roomId)) {
            Log.e(TAG, "no room to exit");
            return;
        }
        mRoomEngine.exitRoom(false, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "exitRoom onSuccess");
                notifyExitRoomResult(TUICommonDefine.Error.SUCCESS);
                destroyInstance();
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "exitRoom onError error=" + error + " s=" + s);
                notifyExitRoomResult(error);
                destroyInstance();
                if (callback != null) {
                    callback.onError(error, s);
                }
            }

            private void notifyExitRoomResult(TUICommonDefine.Error error) {
                Map<String, Object> params = new HashMap<>(2);
                params.put(KEY_ERROR, error);
                params.put(KEY_ROOM_ID, roomId);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_EXIT_ROOM, params);

                ConferenceObserver observer = mRoomStore.getConferenceObserver();
                if (observer != null) {
                    Log.i(TAG, "onConferenceFinished : " + roomId);
                    observer.onConferenceExisted(roomId);
                }
            }
        });
    }

    public void destroyRoom(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "destroyRoom mRoomEngine=" + mRoomEngine);
        final String roomId = mRoomStore.roomInfo.roomId;
        if (TextUtils.isEmpty(roomId)) {
            Log.e(TAG, "no room to exit");
            return;
        }
        mRoomEngine.destroyRoom(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "destroyRoom onSuccess");
                notifyDestroyRoomResult(TUICommonDefine.Error.SUCCESS);
                destroyInstance();
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "destroyRoom onError error=" + error + " s=" + s);
                notifyDestroyRoomResult(error);
                destroyInstance();
                if (callback != null) {
                    callback.onError(error, s);
                }
            }

            private void notifyDestroyRoomResult(TUICommonDefine.Error error) {
                Map<String, Object> params = new HashMap<>(2);
                params.put(KEY_ERROR, error);
                params.put(KEY_ROOM_ID, roomId);
                RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_DESTROY_ROOM, params);

                ConferenceObserver observer = mRoomStore.getConferenceObserver();
                if (observer != null) {
                    Log.i(TAG, "onConferenceFinished : " + roomId);
                    observer.onConferenceFinished(roomId);
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
        mRoomStore.roomInfo = null;
        BusinessSceneUtil.clearJoinRoomFlag();
        if (mRoomStore.audioModel.isMicOpen()) {
            closeLocalMicrophone();
        }
        KeepAliveService.stopKeepAliveService();
        mRoomFloatWindowManager.destroy();
        mRoomEngine.removeObserver(mObserver);
        mTRTCCloud.removeListener(mTRTCObserver);
        sInstance = null;
        Log.d(TAG, "destroyInstance manager=" + this + " mRoomStore=" + mRoomStore);
    }

    private void loginRoomEngine(TUIRoomDefine.ActionCallback callback) {
        if (mIsLoginSuccess) {
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
                                mIsLoginSuccess = true;
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

    private boolean isAllowToToggleAudio() {
        Context context = TUILogin.getAppContext();
        if (mRoomStore.roomInfo.isSeatEnabled && !mRoomStore.userModel.isOnSeat()) {
            RoomToast.toastShortMessageCenter(context.getString(R.string.tuiroomkit_please_raise_hand));
            return false;
        }
        if (mRoomStore.roomInfo.isMicrophoneDisableForAllUser
                && mRoomStore.userModel.getRole() == GENERAL_USER) {
            RoomToast.toastShortMessageCenter(context.getString(R.string.tuiroomkit_can_not_open_mic));
            return false;
        }
        return true;
    }

    private void decideMediaStatus(boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker) {
        decideAudioRoute(isSoundOnSpeaker);

        boolean isPushAudio = isPushAudio(enableAudio);
        if (RoomPermissionUtil.hasAudioPermission()) {
            if (!isPushAudio) { // Mute first and then turn on mic to avoid sound leakage
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
        if (roomStore.roomInfo.isCameraDisableForAllUser && roomStore.userModel.getRole() == GENERAL_USER) {
            return;
        }
        if (!roomStore.roomInfo.isSeatEnabled || roomStore.userModel.getRole() == ROOM_OWNER) {
            RoomEngineManager.sharedInstance().openLocalCamera(null);
        }
    }

    private boolean isPushAudio(boolean enableAudio) {
        RoomStore roomStore = RoomEngineManager.sharedInstance().getRoomStore();
        if (!enableAudio) {
            return false;
        }
        if (roomStore.roomInfo.isMicrophoneDisableForAllUser && roomStore.userModel.getRole() == GENERAL_USER) {
            return false;
        }
        if (roomStore.userModel.getRole() == ROOM_OWNER) {
            return true;
        }
        return !roomStore.roomInfo.isSeatEnabled;
    }

    private void switchToV2() {
        String jsonStr = "{\n"
                + "  \"api\":\"setRoomEnv\",\n"
                + "  \"params\":\n"
                + "  {\n"
                + "    \"forceEnv\": 2\n"
                + "  }\n"
                + "}";
        TUIRoomEngine.callExperimentalAPI(jsonStr);
    }
}
