package com.tencent.qcloud.tuikit.tuicallkit.internal;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallObserver;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
import java.util.Map;

public class TUIAudioMessageRecordService implements ITUIService, ITUINotification {
    private static final String TAG = "TUIAudioMessageRecordService";

    private Context         mContext;
    private AudioRecordInfo mAudioRecordInfo;

    private AudioFocusRequest                       mFocusRequest;
    private AudioManager                            mAudioManager;
    private AudioManager.OnAudioFocusChangeListener mOnFocusChangeListener;
    private TUIServiceCallback mAudioRecordValueCallback;

    public TUIAudioMessageRecordService(Context context) {
        mContext = context.getApplicationContext();
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
    }

    @Override
    public Object onCall(String method, Map<String, Object> param, TUIServiceCallback callback) {
        this.mAudioRecordValueCallback = callback;
        if (TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_START_RECORD_AUDIO_MESSAGE, method)) {
            if (param == null) {
                TUILog.e(TAG, "startRecordAudioMessage failed, param is empty");
                notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                        TUIConstants.TUICalling.ERROR_INVALID_PARAM, null);
                return false;
            }

            //如果当前在通话中,不支持录音
            if (!TUICallDefine.Status.None.equals(TUICallingStatusManager.sharedInstance(mContext).getCallStatus())) {
                TUILog.e(TAG, "startRecordAudioMessage failed, The current call status does not support recording");
                notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                        TUIConstants.TUICalling.ERROR_STATUS_IN_CALL, null);
                return false;
            }

            //当前已经在录音中
            if (mAudioRecordInfo != null) {
                TUILog.e(TAG, "startRecordAudioMessage failed, The recording is not over, It cannot be called again");
                notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                        TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING, null);
                return false;
            }

            //获取麦克风权限
            PermissionRequest.requestPermissions(mContext, TUICallDefine.MediaType.Audio, new PermissionCallback() {
                @Override
                public void onGranted() {
                    //获取音频焦点
                    initAudioFocusManager();
                    if (requestAudioFocus() != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                        TUILog.e(TAG, "startRecordAudioMessage failed, Failed to obtain audio focus");
                        notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                                TUIConstants.TUICalling.ERROR_REQUEST_AUDIO_FOCUS_FAILED, null);
                        return;
                    }

                    mAudioRecordInfo = new AudioRecordInfo();
                    if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH)) {
                        mAudioRecordInfo.path = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH);
                    }
                    if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID)) {
                        mAudioRecordInfo.sdkAppId = (int) param.get(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID);
                    }
                    if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE)) {
                        mAudioRecordInfo.signature =
                                (String) param.get(TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE);
                    }

                    //开启音频采集
                    TRTCCloud.sharedInstance(mContext).setListener(mTRTCCloudListener);
                    startRecordAudioMessage();
                }

                @Override
                public void onDenied() {
                    super.onDenied();
                    notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                            TUIConstants.TUICalling.ERROR_MIC_PERMISSION_REFUSED, null);
                }
            });
            return true;
        }

        if (TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_STOP_RECORD_AUDIO_MESSAGE, method)) {
            stopRecordAudioMessage();
        }
        return true;
    }

    private TRTCCloudListener mTRTCCloudListener = new TRTCCloudListener() {
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            super.onError(errCode, errMsg, extraInfo);
            if (errCode == TUIConstants.TUICalling.ERR_MIC_START_FAIL
                    || errCode == TUIConstants.TUICalling.ERR_MIC_NOT_AUTHORIZED
                    || errCode == TUIConstants.TUICalling.ERR_MIC_SET_PARAM_FAIL
                    || errCode == TUIConstants.TUICalling.ERR_MIC_OCCUPY) {
                notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START, errCode, null);
            }
        }

        @Override
        public void onLocalRecordBegin(int errCode, String storagePath) {
            super.onLocalRecordBegin(errCode, storagePath);
            int tempCode = convertErrorCode("onLocalRecordBegin", errCode);
            if (errCode == TUIConstants.TUICalling.ERROR_NONE) {
                TRTCCloud.sharedInstance(mContext).startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
            }
            notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START, tempCode, storagePath);
        }

        @Override
        public void onLocalRecordComplete(int errCode, String storagePath) {
            super.onLocalRecordComplete(errCode, storagePath);
            int tempCode = convertErrorCode("onLocalRecordComplete", errCode);
            notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_STOP, tempCode, storagePath);
        }
    };

    private TUICallObserver mCallObserver = new TUICallObserver() {
        @Override
        public void onCallReceived(String callerId, List<String> calleeIdList, String groupId,
                                   TUICallDefine.MediaType callMediaType, String userData) {
            super.onCallReceived(callerId, calleeIdList, groupId, callMediaType, userData);
            //收到通话邀请,停止录制
            stopRecordAudioMessage();
        }
    };

    private void startRecordAudioMessage() {
        if (mAudioRecordInfo == null) {
            TUILog.e(TAG, "startRecordAudioMessage failed, audioRecordInfo is empty");
            return;
        }
        TUILog.i(TAG, "startRecordAudioMessage, mAudioRecordInfo: " + mAudioRecordInfo);
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "startRecordAudioMessage");
            JSONObject params = new JSONObject();
            params.put(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID, mAudioRecordInfo.sdkAppId);
            params.put(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, mAudioRecordInfo.path);
            params.put("key", mAudioRecordInfo.signature);
            jsonObject.put("params", params);
            TRTCCloud.sharedInstance(mContext).callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void stopRecordAudioMessage() {
        if (mAudioRecordInfo == null) {
            TUILog.w(TAG, "stopRecordAudioMessage, current recording status is Idle,do not need to stop");
            return;
        }

        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "stopRecordAudioMessage");
            JSONObject params = new JSONObject();
            jsonObject.put("params", params);
            TRTCCloud.sharedInstance(mContext).callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }

        TUILog.i(TAG, "stopRecordAudioMessage, stopLocalAudio");
        TRTCCloud.sharedInstance(mContext).stopLocalAudio();
        //清空录制信息
        mAudioRecordInfo = null;
        //释放音频焦点
        abandonAudioFocus();
    }

    private void notifyAudioMessageRecordEvent(String method, int errCode, String path) {
        TUILog.i(TAG, "notifyAudioMessageRecordEvent, method: " + method + ", errCode: " + errCode + ",path: " + path);
        if (mAudioRecordValueCallback != null) {
            Bundle bundleInfo = new Bundle();
            bundleInfo.putString(TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE, method);
            bundleInfo.putString(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, path);
            mAudioRecordValueCallback.onServiceCallback(errCode, "", bundleInfo);
        }
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)
                && TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS.equals(subKey)) {
            TUICallEngine.createInstance(mContext).addObserver(mCallObserver);
        }
    }

    private void initAudioFocusManager() {
        if (mAudioManager == null) {
            mAudioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
        }
        if (mOnFocusChangeListener == null) {
            mOnFocusChangeListener = new AudioManager.OnAudioFocusChangeListener() {
                @Override
                public void onAudioFocusChange(int focusChange) {
                    switch (focusChange) {
                        case AudioManager.AUDIOFOCUS_GAIN:
                            break;
                        case AudioManager.AUDIOFOCUS_LOSS:
                        case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                            //其他应用占用焦点的时候,停止录制
                            stopRecordAudioMessage();
                            break;
                        default:
                            break;
                    }

                }
            };
        }

        AudioAttributes attributes = null;
        //android 5.0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            attributes = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build();
        }
        //android 8.0
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            mFocusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setWillPauseWhenDucked(true)
                    .setAudioAttributes(attributes)
                    .setOnAudioFocusChangeListener(mOnFocusChangeListener)
                    .build();
        }
    }

    private int requestAudioFocus() {
        if (mAudioManager == null) {
            return AudioManager.AUDIOFOCUS_REQUEST_FAILED;
        }
        int result;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            result = mAudioManager.requestAudioFocus(mFocusRequest);
        } else {
            result = mAudioManager.requestAudioFocus(mOnFocusChangeListener, AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT);
        }
        return result;
    }

    private int abandonAudioFocus() {
        if (mAudioManager == null) {
            return AudioManager.AUDIOFOCUS_REQUEST_FAILED;
        }
        int result;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            result = mAudioManager.abandonAudioFocusRequest(mFocusRequest);
        } else {
            result = mAudioManager.abandonAudioFocus(mOnFocusChangeListener);
        }
        return result;
    }

    private int convertErrorCode(String method, int errorCode) {
        int targetCode;
        switch (errorCode) {
            case -1:
                targetCode = "onLocalRecordBegin".equals(method) ? TUIConstants.TUICalling.ERROR_RECORD_INIT_FAILED
                        : TUIConstants.TUICalling.ERROR_RECORD_FAILED;
                break;
            case -2:
                targetCode = TUIConstants.TUICalling.ERROR_PATH_FORMAT_NOT_SUPPORT;
                break;
            case -3:
                targetCode = TUIConstants.TUICalling.ERROR_NO_MESSAGE_TO_RECORD;
                break;
            case -4:
                targetCode = TUIConstants.TUICalling.ERROR_SIGNATURE_ERROR;
                break;
            case -5:
                targetCode = TUIConstants.TUICalling.ERROR_SIGNATURE_EXPIRED;
                break;
            default:
                targetCode = TUIConstants.TUICalling.ERROR_NONE;
                break;
        }
        return targetCode;
    }

    class AudioRecordInfo {
        public String path;       // 录制文件地址
        public int    sdkAppId;   // 应用的 SDKAppID
        public String signature;  // AI 降噪签名

        public AudioRecordInfo() {
        }

        @Override
        public String toString() {
            return "AudioRecordInfo{"
                    + "path=" + path
                    + ", SDKAppID=" + sdkAppId
                    + '}';
        }
    }
}
