package com.tencent.qcloud.tuikit.tuicallkit.base;

import android.content.Context;

import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallkit.config.OfflinePushInfoConfig;

import java.util.List;

public class TUICallingAction {
    private final Context mContext;

    public TUICallingAction(Context context) {
        mContext = context;
    }

    public void inviteUser(List<String> userIdList, TUICommonDefine.ValueCallback callback) {
        TUICallDefine.CallParams params = new TUICallDefine.CallParams();
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(mContext);
        params.timeout = Constants.SIGNALING_MAX_TIME;
        TUICallEngine.createInstance(mContext).inviteUser(userIdList, params, callback);
    }

    public void accept(TUICommonDefine.Callback callback) {
        TUICallEngine.createInstance(mContext).accept(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.Accept);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(int errCode, String errMsg) {
                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.None);
                if (callback != null) {
                    callback.onError(errCode, errMsg);
                }
            }
        });
    }

    public void reject(TUICommonDefine.Callback callback) {
        TUICallEngine.createInstance(mContext).reject(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.None);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(int errCode, String errMsg) {
                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.None);
                if (callback != null) {
                    callback.onError(errCode, errMsg);
                }
            }
        });
    }

    public void hangup(TUICommonDefine.Callback callback) {
        TUICallEngine.createInstance(mContext).hangup(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.None);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(int errCode, String errMsg) {
                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.None);
                if (callback != null) {
                    callback.onError(errCode, errMsg);
                }
            }
        });
    }

    public void switchCallMediaType(TUICallDefine.MediaType callMediaType) {
        TUICallEngine.createInstance(mContext).switchCallMediaType(callMediaType);
    }

    public void openCamera(TUICommonDefine.Camera camera, TUIVideoView videoView, TUICommonDefine.Callback callback) {
        TUICallEngine.createInstance(mContext).openCamera(camera, videoView, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                TUICallDefine.Status status = TUICallingStatusManager.sharedInstance(mContext).getCallStatus();
                if (!TUICallDefine.Status.None.equals(status)) {
                    TUICommonDefine.Camera camera = TUICallingStatusManager.sharedInstance(mContext).getFrontCamera();
                    TUICallingStatusManager.sharedInstance(mContext).updateCameraOpenStatus(true, camera);
                    TUICallingStatusManager.sharedInstance(mContext).updateFrontCameraStatus(camera);
                }

                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(int errCode, String errMsg) {
                if (callback != null) {
                    callback.onError(errCode, errMsg);
                }
            }
        });
    }

    public void closeCamera() {
        TUICallEngine.createInstance(mContext).closeCamera();
        TUICommonDefine.Camera frontCamera = TUICallingStatusManager.sharedInstance(mContext).getFrontCamera();
        TUICallingStatusManager.sharedInstance(mContext).updateCameraOpenStatus(false, frontCamera);
    }

    public void switchCamera(TUICommonDefine.Camera camera) {
        TUICallEngine.createInstance(mContext).switchCamera(camera);
        TUICallingStatusManager.sharedInstance(mContext).updateFrontCameraStatus(camera);
    }

    public void openMicrophone(TUICommonDefine.Callback callback) {
        TUICallEngine.createInstance(mContext).openMicrophone(callback);
        TUICallingStatusManager.sharedInstance(mContext).updateMicMuteStatus(false);
    }

    public void closeMicrophone() {
        TUICallEngine.createInstance(mContext).closeMicrophone();
        TUICallingStatusManager.sharedInstance(mContext).updateMicMuteStatus(true);
    }

    public void selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice device) {
        TUICallEngine.createInstance(mContext).selectAudioPlaybackDevice(device);
        TUICallingStatusManager.sharedInstance(mContext).updateAudioPlaybackDevice(device);
    }

    public void startRemoteView(String userId, TUIVideoView videoView, TUICommonDefine.PlayCallback callback) {
        TUICallEngine.createInstance(mContext).startRemoteView(userId, videoView, callback);
    }

    public void stopRemoteView(String userId) {
        TUICallEngine.createInstance(mContext).stopRemoteView(userId);
    }
}
