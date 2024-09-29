package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.ALREADY_IN_SEAT;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.PERMISSION_DENIED;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ExtensionType.CONFERENCE_LIST_MANAGER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RequestAction.REQUEST_TO_OPEN_REMOTE_CAMERA;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RequestAction.REQUEST_TO_OPEN_REMOTE_MICROPHONE;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.ResolutionMode.LANDSCAPE;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.ResolutionMode.PORTRAIT;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.GENERAL_USER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.ROOM_OWNER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM_LOW;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceExitedReason.EXITED_BY_SELF;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceFinishedReason.FINISHED_BY_OWNER;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceConstant.KEY_ERROR;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_CREATE_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.ENABLE_FLOAT_CHAT;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_EXITED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_FINISHED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_REASON;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_ROOM_ID;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.KeepAliveService;
import com.tencent.cloud.tuikit.roomkit.common.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.common.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomToast;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.model.controller.InvitationController;
import com.tencent.cloud.tuikit.roomkit.model.controller.MediaController;
import com.tencent.cloud.tuikit.roomkit.model.controller.RoomController;
import com.tencent.cloud.tuikit.roomkit.model.controller.UserController;
import com.tencent.cloud.tuikit.roomkit.model.controller.ViewController;
import com.tencent.cloud.tuikit.roomkit.model.data.InvitationState;
import com.tencent.cloud.tuikit.roomkit.model.data.MediaState;
import com.tencent.cloud.tuikit.roomkit.model.data.RoomState;
import com.tencent.cloud.tuikit.roomkit.model.data.SeatState;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.model.data.ViewState;
import com.tencent.cloud.tuikit.roomkit.model.entity.TakeSeatRequestEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.view.page.RoomWindowManager;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.store.FloatChatStore;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ConferenceController {
    private static final String TAG = "ConferenceController";

    private static ConferenceController sInstance;

    private ViewController       mViewController;
    private UserController       mUserController;
    private RoomController       mRoomController;
    private MediaController      mMediaController;
    private InvitationController mInvitationController;

    private boolean mIsLoginSuccess = false;

    private Context         mContext;
    private TUIRoomEngine   mRoomEngine;
    private ConferenceState mConferenceState;
    private TUIRoomObserver mObserver;

    private final TUIConferenceListManager          mConferenceListManager;
    private final TUIConferenceListManager.Observer mConferenceListObserver;

    private TRTCCloud    mTRTCCloud;
    private TRTCObserver mTRTCObserver;

    private RoomWindowManager mRoomFloatWindowManager;

    public static ConferenceController sharedInstance() {
        return sharedInstance(TUILogin.getAppContext());
    }

    public static ConferenceController sharedInstance(Context context) {
        if (sInstance == null) {
            synchronized (ConferenceController.class) {
                if (sInstance == null) {
                    sInstance = new ConferenceController(context);
                }
            }
        }
        return sInstance;
    }

    public ViewController getViewController() {
        return mViewController;
    }

    public UserController getUserController() {
        return mUserController;
    }

    public RoomController getRoomController() {
        return mRoomController;
    }

    public MediaController getMediaController() {
        return mMediaController;
    }

    public InvitationController getInvitationController() {
        return mInvitationController;
    }

    public SeatState getSeatState() {
        return mConferenceState.seatState;
    }

    public ViewState getViewState() {
        return mConferenceState.viewState;
    }

    public RoomState getRoomState() {
        return mConferenceState.roomState;
    }

    public UserState getUserState() {
        return mConferenceState.userState;
    }

    public MediaState getMediaState() {
        return mConferenceState.mediaState;
    }

    public InvitationState getInvitationState() {
        return mConferenceState.invitationState;
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
                        mConferenceState.audioModel.setMicOpen(true);
                    } else if (requestAction == REQUEST_TO_OPEN_REMOTE_CAMERA) {
                        mConferenceState.videoModel.setCameraOpened(true);
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

        Log.d(TAG, "responseRemoteRequest requestAction=" + requestAction + " agree=" + agree);
        mRoomEngine.responseRemoteRequest(requestId, agree, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "responseRemoteRequest onSuccess");
                if (callback != null) {
                    callback.onSuccess();
                }
                mConferenceState.removeTakeSeatRequest(requestId);
                mConferenceState.seatState.removeTakeSeatRequest(requestId);
                mConferenceState.viewState.removePendingTakeSeatRequest(requestId);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "responseRemoteRequest onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void cancelRequest(String requestId, TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.cancelRequest(requestId, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                if (TextUtils.equals(requestId, mConferenceState.userModel.takeSeatRequestId)) {
                    mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                    mConferenceState.userModel.takeSeatRequestId = null;
                }
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.e(TAG, "onError error=" + error + " message=" + message);
                if (TextUtils.equals(requestId, mConferenceState.userModel.takeSeatRequestId)) {
                    mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                    mConferenceState.userModel.takeSeatRequestId = null;
                }
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void setLocalVideoView(TUIRoomDefine.VideoStreamType videoStreamType, TUIVideoView videoView) {
        mRoomEngine.setLocalVideoView(videoView);
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
                mRoomEngine.openLocalCamera(mConferenceState.videoModel.isFrontCamera, mConferenceState.videoModel.getResolution(),
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

    public void enableLocalAudio() {
        if (!isAllowToToggleAudio()) {
            return;
        }
        if (ConferenceController.sharedInstance().getConferenceState().audioModel.isMicOpen()) {
            ConferenceController.sharedInstance().unMuteLocalAudio(null);
        } else {
            ConferenceController.sharedInstance().openLocalMicrophone(null);
        }
    }

    public void disableLocalAudio() {
        if (ConferenceController.sharedInstance().getConferenceState().audioModel.isMicOpen()) {
            ConferenceController.sharedInstance().muteLocalAudio();
        }
    }

    public void openLocalMicrophone(TUIRoomDefine.ActionCallback micCallback) {
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                Log.d(TAG, "openLocalMicrophone");
                mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, micCallback);
                mConferenceState.audioModel.setMicOpen(true);
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
        mConferenceState.audioModel.setMicOpen(false);
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
        mConferenceState.setAutoShowRoomMainUi(enable);
    }

    public void enterFloatWindow() {
        mConferenceState.setInFloatWindow(true);
    }

    public void exitFloatWindow() {
        mConferenceState.setInFloatWindow(false);
    }

    public void setAudioCaptureVolume(int volume) {
        mRoomEngine.getTRTCCloud().setAudioCaptureVolume(volume);
        mConferenceState.audioModel.setCaptureVolume(volume);
    }

    public void setAudioPlayOutVolume(int volume) {
        mRoomEngine.getTRTCCloud().setAudioPlayoutVolume(volume);
        mConferenceState.audioModel.setPlayVolume(volume);
    }

    public void enableAudioVolumeEvaluation(boolean enable) {
        TRTCCloudDef.TRTCAudioVolumeEvaluateParams params = new TRTCCloudDef.TRTCAudioVolumeEvaluateParams();
        mRoomEngine.getTRTCCloud().enableAudioVolumeEvaluation(enable, params);
        mConferenceState.audioModel.setEnableVolumeEvaluation(enable);
    }

    public void enableFloatChat(boolean enable) {
        Map<String, Object> params = new HashMap<>();
        mConferenceState.setEnableFloatChat(enable);
        params.put(ConferenceEventConstant.KEY_ENABLE_FLOAT_CHAT, enable);
        ConferenceEventCenter.getInstance().notifyUIEvent(ENABLE_FLOAT_CHAT, params);
    }

    public void setCameraResolutionMode(boolean isPortrait) {
        mRoomEngine.setVideoResolutionMode(CAMERA_STREAM, isPortrait ? PORTRAIT : LANDSCAPE);
        mRoomEngine.setVideoResolutionMode(CAMERA_STREAM_LOW, isPortrait ? PORTRAIT : LANDSCAPE);
    }

    public void setVideoResolution(TUIRoomDefine.VideoQuality resolution) {
        mConferenceState.videoModel.setResolution(resolution);
        setVideoEncoderParam();
    }

    public void setVideoFps(int fps) {
        mConferenceState.videoModel.setFps(fps);
        setVideoEncoderParam();
    }

    private void setVideoEncoderParam() {
        TUIRoomDefine.RoomVideoEncoderParams params = new TUIRoomDefine.RoomVideoEncoderParams();
        params.videoResolution = mConferenceState.videoModel.getResolution();
        params.resolutionMode = PORTRAIT;
        params.fps = mConferenceState.videoModel.getFps();
        params.bitrate = mConferenceState.videoModel.getBitrate();
        Log.d(TAG, "updateVideoQualityEx videoResolution=" + params.videoResolution);
        mRoomEngine.updateVideoQualityEx(CAMERA_STREAM, params);
    }

    private ConferenceController(Context context) {
        mContext = context.getApplicationContext();
        mConferenceState = new ConferenceState();
        mRoomEngine = TUIRoomEngine.sharedInstance();
        Log.d(TAG, "createInstance mRoomEngine=" + mRoomEngine + " manager=" + this);

        mConferenceListManager = (TUIConferenceListManager) TUIRoomEngine.sharedInstance().getExtension(CONFERENCE_LIST_MANAGER);
        mConferenceListObserver = new ConferenceListObserver(mConferenceState);
        mConferenceListManager.addObserver(mConferenceListObserver);

        mObserver = new RoomEngineObserver(mConferenceState);
        mRoomEngine.addObserver(mObserver);
        mRoomFloatWindowManager = new RoomWindowManager(mContext);

        mTRTCCloud = TUIRoomEngine.sharedInstance().getTRTCCloud();
        mTRTCObserver = new TRTCObserver();
        mTRTCCloud.addListener(mTRTCObserver);

        mViewController = new ViewController(mConferenceState, mRoomEngine);
        mUserController = new UserController(mConferenceState, mRoomEngine);
        mRoomController = new RoomController(mConferenceState, mRoomEngine);
        mMediaController = new MediaController(mConferenceState, mRoomEngine);
        mInvitationController = new InvitationController(mConferenceState, mRoomEngine);
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
        mViewController.updateRoomProcess(ViewState.RoomProcess.COMING);
        roomInfo.name = transferConferenceName(roomInfo.name);
        loginRoomEngine(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "createRoom roomInfo=" + roomInfo + " thread.name=" + Thread.currentThread().getName());
                mRoomEngine.createRoom(roomInfo, new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        Log.i(TAG, "createRoom onSuccess thread.name=" + Thread.currentThread().getName());
                        mConferenceState.userModel.initRole(ROOM_OWNER);
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, TUICommonDefine.Error.SUCCESS);
                        params.put(KEY_ROOM_ID, roomInfo.roomId);
                        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_CREATE_ROOM, params);
                        if (callback != null) {
                            callback.onSuccess();
                        }
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "createRoom onError error=" + error + " message=" + message);
                        mViewController.updateRoomProcess(ViewState.RoomProcess.NONE);
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, error);
                        params.put(KEY_ROOM_ID, roomInfo.roomId);
                        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_CREATE_ROOM, params);
                        if (callback != null) {
                            callback.onError(error, message);
                        }
                    }
                });
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                mViewController.updateRoomProcess(ViewState.RoomProcess.NONE);
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, error);
                params.put(KEY_ROOM_ID, roomInfo.roomId);
                ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_CREATE_ROOM, params);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void enterRoom(String roomId, boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker,
                          TUIRoomDefine.GetRoomInfoCallback callback) {
        mViewController.updateRoomProcess(ViewState.RoomProcess.COMING);
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
                        mViewController.updateRoomProcess(ViewState.RoomProcess.IN);
                        mViewController.anchorEnterRoomTimeFromBoot();
                        initRoomStore(engineRoomInfo);
                        setVideoEncoderParam();
                        getSeatApplicationList();
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
                                ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
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
                        mViewController.updateRoomProcess(ViewState.RoomProcess.NONE);
                        if (callback != null) {
                            callback.onError(error, message);
                        }
                        Map<String, Object> params = new HashMap<>(1);
                        params.put(KEY_ERROR, error);
                        params.put(KEY_ROOM_ID, roomId);
                        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
                    }
                });
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                mViewController.updateRoomProcess(ViewState.RoomProcess.NONE);
                if (callback != null) {
                    callback.onError(error, message);
                }
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, error);
                params.put(KEY_ROOM_ID, roomId);
                ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
            }
        });
    }

    public void enterEncryptRoom(String roomId, boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker, String password,
                                 TUIRoomDefine.GetRoomInfoCallback callback) {
        mViewController.updateRoomProcess(ViewState.RoomProcess.COMING);
        TUIRoomDefine.EnterRoomOptions options = new TUIRoomDefine.EnterRoomOptions();
        options.password = password;
        mRoomEngine.enterRoom(roomId, TUIRoomDefine.RoomType.CONFERENCE, options, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                Log.i(TAG, "enterRoom onSuccess thread.name=" + Thread.currentThread().getName());
                mViewController.updateRoomProcess(ViewState.RoomProcess.IN);
                mViewController.anchorEnterRoomTimeFromBoot();
                initRoomStore(engineRoomInfo);
                setVideoEncoderParam();
                getSeatApplicationList();
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
                        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
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
                mViewController.updateRoomProcess(ViewState.RoomProcess.NONE);
                if (callback != null) {
                    callback.onError(error, message);
                }
                Map<String, Object> params = new HashMap<>(1);
                params.put(KEY_ERROR, error);
                params.put(KEY_ROOM_ID, roomId);
                ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_ENTER_ROOM, params);
            }
        });
    }

    public void getSeatApplicationList() {
        if (!mConferenceState.roomInfo.isSeatEnabled || mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            return;
        }
        Log.d(TAG, "getSeatApplicationList");
        for (TakeSeatRequestEntity entity : mConferenceState.takeSeatRequestList) {
            mConferenceState.removeTakeSeatRequest(entity.getRequest().requestId);
        }
        mConferenceState.seatState.clearTakeSeatRequests();
        mConferenceState.viewState.clearPendingTakeSeatRequests();
        mRoomEngine.getSeatApplicationList(new TUIRoomDefine.RequestListCallback() {
            @Override
            public void onSuccess(List<TUIRoomDefine.Request> list) {
                Log.d(TAG, "getSeatApplicationList onSuccess");
                for (TUIRoomDefine.Request request : list) {
                    mConferenceState.addTakeSeatRequest(request);
                    mConferenceState.seatState.addTakeSeatRequest(request);
                    mConferenceState.viewState.addPendingTakeSeatRequest(request.requestId);
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
                mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                mConferenceState.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onRejected(requestId, userId, message);
                }
            }

            @Override
            public void onCancelled(String requestId, String userId) {
                Log.i(TAG, "takeSeat onRejected requestId=" + requestId + " userId=" + userId);
                mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                mConferenceState.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onCancelled(requestId, userId);
                }
            }

            @Override
            public void onTimeout(String requestId, String userId) {
                Log.i(TAG, "takeSeat onTimeout requestId=" + requestId + " userId=" + userId);
                if (mConferenceState.userModel.getSeatStatus() == UserModel.SeatStatus.APPLYING_TAKE_SEAT) {
                    mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                }
                mConferenceState.userModel.takeSeatRequestId = null;
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
                mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                mConferenceState.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onError(requestId, userId, code, message);
                }
            }

            private void handleTakeSeatAccepted(String requestId, String userId) {
                mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.ON_SEAT);
                mConferenceState.userModel.takeSeatRequestId = null;
                if (callback != null) {
                    callback.onAccepted(requestId, userId);
                }
            }
        });
        mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.APPLYING_TAKE_SEAT);
        mConferenceState.userModel.takeSeatRequestId = request.requestId;
        return request;
    }

    public void leaveSeat(TUIRoomDefine.ActionCallback callback) {
        mRoomEngine.leaveSeat(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                mConferenceState.userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
        mConferenceState.audioModel.setMicOpen(false);
    }

    public void autoTakeSeatForOwner(TUIRoomDefine.RequestCallback callback) {
        if (mConferenceState.userModel.getRole() == ROOM_OWNER
                && mConferenceState.roomInfo.isSeatEnabled && !mConferenceState.userModel.isOnSeat()) {
            takeSeat(-1, 0, callback);
            return;
        }
        if (callback != null) {
            callback.onAccepted(null, null);
        }
    }

    public void enableSendingMessageForOwner() {
        if (mConferenceState.userModel.getRole() != ROOM_OWNER) {
            return;
        }
        UserEntity user = mConferenceState.findUserWithCameraStream(mConferenceState.allUserList, mConferenceState.userModel.userId);
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
        Log.d(TAG, "getUserList");
        mRoomEngine.getUserList(mNextSequence, new TUIRoomDefine.GetUserListCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                Log.d(TAG, "getUserList onSuccess");
                for (TUIRoomDefine.UserInfo userInfo : userListResult.userInfoList) {
                    mConferenceState.remoteUserEnterRoom(userInfo);
                    mConferenceState.userState.remoteUserEnterRoom(userInfo);
                }

                mNextSequence = userListResult.nextSequence;
                if (mNextSequence != 0) {
                    getUserList();
                } else if (mConferenceState.roomInfo.isSeatEnabled) {
                    getSeatList();
                } else {
                    ConferenceEventCenter.getInstance().notifyEngineEvent(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, null);
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
                    mConferenceState.seatState.seatedUsers.add(item.userId);
                    mRoomEngine.getUserInfo(item.userId, new TUIRoomDefine.GetUserInfoCallback() {
                        @Override
                        public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                            Log.d(TAG, "getSeatList remoteUserTakeSeat userId=" + userInfo.userId);
                            mConferenceState.remoteUserTakeSeat(userInfo);
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
        mConferenceState.roomInfo = engineRoomInfo;
        mConferenceState.userModel.enterRoomTime = System.currentTimeMillis();
        mConferenceState.userModel.initRole(
                TextUtils.equals(engineRoomInfo.ownerId, TUILogin.getUserId()) ? ROOM_OWNER : GENERAL_USER);

        mConferenceState.roomState.updateState(engineRoomInfo);
    }

    public void release() {
        Log.d(TAG, "release");
        destroyInstance();
    }

    public void exitRoom(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "exitRoom mRoomEngine=" + mRoomEngine);
        final String roomId = mConferenceState.roomInfo.roomId;
        mRoomEngine.exitRoom(false, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "exitRoom onSuccess");
                destroyInstance();
                notifyExitRoomResult(TUICommonDefine.Error.SUCCESS);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "exitRoom onError error=" + error + " s=" + s);
                destroyInstance();
                notifyExitRoomResult(error);
                if (callback != null) {
                    callback.onError(error, s);
                }
            }

            private void notifyExitRoomResult(TUICommonDefine.Error error) {
                Map<String, Object> params = new HashMap<>(2);
                params.put(KEY_ERROR, error);
                ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_EXIT_ROOM, params);

                Map<String, Object> param = new HashMap<>(2);
                param.put(KEY_CONFERENCE, mConferenceState.roomState.roomInfo);
                param.put(KEY_REASON, EXITED_BY_SELF);
                TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_EXITED, param);
            }
        });
    }

    public void destroyRoom(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "destroyRoom mRoomEngine=" + mRoomEngine);
        final String roomId = mConferenceState.roomInfo.roomId;
        mRoomEngine.destroyRoom(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "destroyRoom onSuccess");
                destroyInstance();
                notifyDestroyRoomResult(TUICommonDefine.Error.SUCCESS);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "destroyRoom onError error=" + error + " s=" + s);
                destroyInstance();
                notifyDestroyRoomResult(error);
                if (callback != null) {
                    callback.onError(error, s);
                }
            }

            private void notifyDestroyRoomResult(TUICommonDefine.Error error) {
                Map<String, Object> params = new HashMap<>(2);
                params.put(KEY_ERROR, error);
                ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_USER_DESTROY_ROOM, params);

                Map<String, Object> param = new HashMap<>(2);
                param.put(KEY_CONFERENCE, mConferenceState.roomState.roomInfo);
                param.put(KEY_REASON, FINISHED_BY_OWNER);
                TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_FINISHED, param);
            }
        });
    }

    public TUIRoomEngine getRoomEngine() {
        return mRoomEngine;
    }

    public ConferenceState getConferenceState() {
        return mConferenceState;
    }

    private void destroyInstance() {
        mConferenceListManager.removeObserver(mConferenceListObserver);
        mRoomEngine.removeObserver(mObserver);
        mTRTCCloud.removeListener(mTRTCObserver);
        mConferenceState.roomInfo = null;
        BusinessSceneUtil.clearJoinRoomFlag();
        if (mConferenceState.audioModel.isMicOpen()) {
            closeLocalMicrophone();
        }
        KeepAliveService.stopKeepAliveService();
        mRoomFloatWindowManager.destroy();
        mViewController.destroy();
        mUserController.destroy();
        mRoomController.destroy();
        mMediaController.destroy();
        mInvitationController.destroy();
        FloatChatStore.sharedInstance().destroyInstance();
        sInstance = null;
        Log.d(TAG, "destroyInstance manager=" + this + " mConferenceState=" + mConferenceState);
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
        if (mConferenceState.roomInfo.isSeatEnabled && !mConferenceState.userModel.isOnSeat()) {
            RoomToast.toastShortMessageCenter(context.getString(R.string.tuiroomkit_please_raise_hand));
            return false;
        }
        if (mConferenceState.roomInfo.isMicrophoneDisableForAllUser
                && mConferenceState.userModel.getRole() == GENERAL_USER) {
            RoomToast.toastShortMessageCenter(context.getString(R.string.tuiroomkit_can_not_open_mic));
            return false;
        }
        return true;
    }

    private void decideMediaStatus(boolean enableAudio, boolean enableVideo, boolean isOpenSpeaker) {
        setCameraResolutionMode(Configuration.ORIENTATION_PORTRAIT == mContext.getResources().getConfiguration().orientation);
        mMediaController.setAudioRoute(isOpenSpeaker);

        boolean isPushAudio = isPushAudio(enableAudio);
        if (RoomPermissionUtil.hasAudioPermission()) {
            if (!isPushAudio) { // Mute first and then turn on mic to avoid sound leakage
                ConferenceController.sharedInstance().muteLocalAudio();
            }
            ConferenceController.sharedInstance().openLocalMicrophone(new TUIRoomDefine.ActionCallback() {
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
                ConferenceController.sharedInstance().openLocalMicrophone(new TUIRoomDefine.ActionCallback() {
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

    private void decideCameraStatus(boolean enableVideo) {
        ConferenceState roomStore = ConferenceController.sharedInstance().getConferenceState();
        if (!enableVideo) {
            return;
        }
        if (roomStore.roomInfo.isCameraDisableForAllUser && roomStore.userModel.getRole() == GENERAL_USER) {
            return;
        }
        if (!roomStore.roomInfo.isSeatEnabled || roomStore.userModel.getRole() == ROOM_OWNER) {
            ConferenceController.sharedInstance().openLocalCamera(null);
        }
    }

    private boolean isPushAudio(boolean enableAudio) {
        ConferenceState roomStore = ConferenceController.sharedInstance().getConferenceState();
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

    private String transferConferenceName(String conferenceName) {
        if (!TextUtils.isEmpty(conferenceName)) {
            return conferenceName;
        }
        TUIRoomDefine.LoginUserInfo selfInfo = TUIRoomEngine.getSelfInfo();
        String name = TextUtils.isEmpty(selfInfo.userName) ? selfInfo.userId : selfInfo.userName;
        return mContext.getString(R.string.tuiroomkit_meeting_title, name);
    }
}
