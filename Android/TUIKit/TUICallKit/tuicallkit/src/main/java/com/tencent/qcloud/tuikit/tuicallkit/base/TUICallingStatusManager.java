package com.tencent.qcloud.tuikit.tuicallkit.base;

import android.content.Context;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKitImpl;

import java.util.HashMap;

public class TUICallingStatusManager {
    private static TUICallingStatusManager sInstance;
    private final  Context                 mContext;

    private boolean                             mIsCameraOpen;
    private boolean                             mIsMicMute;
    private TUICommonDefine.Camera              mIsFrontCamera = TUICommonDefine.Camera.Front;
    private TUICommonDefine.AudioPlaybackDevice mAudioDevice   = TUICommonDefine.AudioPlaybackDevice.Speakerphone;
    private TUICallDefine.Status                mCallStatus    = TUICallDefine.Status.None;

    public boolean isCameraOpen() {
        return mIsCameraOpen;
    }

    public boolean isMicMute() {
        return mIsMicMute;
    }

    public TUICommonDefine.Camera getFrontCamera() {
        return mIsFrontCamera;
    }

    public TUICommonDefine.AudioPlaybackDevice getAudioPlaybackDevice() {
        return mAudioDevice;
    }

    public TUICallDefine.Status getCallStatus() {
        return mCallStatus;
    }

    public static TUICallingStatusManager sharedInstance(Context context) {
        if (null == sInstance) {
            synchronized (TUICallKitImpl.class) {
                if (null == sInstance) {
                    sInstance = new TUICallingStatusManager(context);
                }
            }
        }
        return sInstance;
    }

    private TUICallingStatusManager(Context context) {
        mContext = context.getApplicationContext();
    }

    public void updateCallStatus(TUICallDefine.Status status) {
        if (mCallStatus.equals(status)) {
            return;
        }
        mCallStatus = status;

        HashMap<String, Object> map = new HashMap<>();
        map.put(Constants.CALL_STATUS, status);
        TUICore.notifyEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CALL_STATUS_CHANGED, map);
    }

    public void updateCameraOpenStatus(boolean isOpen, TUICommonDefine.Camera isFrontCamera) {
        if (mIsCameraOpen == isOpen) {
            return;
        }
        mIsCameraOpen = isOpen;

        HashMap<String, Object> map = new HashMap<>();
        map.put(Constants.OPEN_CAMERA, isOpen);
        if (isOpen) {
            map.put(Constants.SWITCH_CAMERA, isFrontCamera);
        }
        TUICore.notifyEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CAMERA_OPEN, map);
    }

    public void updateFrontCameraStatus(TUICommonDefine.Camera isFrontCamera) {
        if (mIsFrontCamera.equals(isFrontCamera)) {
            return;
        }
        mIsFrontCamera = isFrontCamera;

        HashMap<String, Object> map = new HashMap<>();
        map.put(Constants.SWITCH_CAMERA, isFrontCamera);
        TUICore.notifyEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CAMERA_FRONT, map);
    }

    public void updateMicMuteStatus(boolean isMicMute) {
        if (mIsMicMute == isMicMute) {
            return;
        }
        mIsMicMute = isMicMute;

        HashMap<String, Object> map = new HashMap<>();
        map.put(Constants.MUTE_MIC, isMicMute);
        TUICore.notifyEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_MIC_STATUS_CHANGED, map);
    }

    public void updateAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice audioPlaybackDevice) {
        mAudioDevice = audioPlaybackDevice;

        HashMap<String, Object> map = new HashMap<>();
        map.put(Constants.HANDS_FREE, audioPlaybackDevice);
        TUICore.notifyEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_AUDIOPLAYDEVICE_CHANGED, map);
    }

    public void clear() {
        mIsCameraOpen = false;
        mIsFrontCamera = TUICommonDefine.Camera.Front;
        mIsMicMute = false;
        mAudioDevice = TUICommonDefine.AudioPlaybackDevice.Speakerphone;
        mCallStatus = TUICallDefine.Status.None;
    }
}