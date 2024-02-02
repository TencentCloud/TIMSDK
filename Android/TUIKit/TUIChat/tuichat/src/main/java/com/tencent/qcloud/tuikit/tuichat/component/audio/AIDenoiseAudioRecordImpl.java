package com.tencent.qcloud.tuikit.tuichat.component.audio;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.model.AIDenoiseSignatureManager;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.HashMap;
import java.util.Map;

public class AIDenoiseAudioRecordImpl implements AudioRecorder.IAudioRecorder {
    private static final String TAG = "AIDenoiseAudioRecordImpl";

    private AudioRecorder.AudioRecorderInternalCallback callback;
    private boolean isRecording = false;
    private final Handler handler = new Handler(Looper.getMainLooper());

    AIDenoiseAudioRecordImpl() {}

    @Override
    public void startRecord(String outputPath, AudioRecorder.AudioRecorderInternalCallback callback) {
        TUIChatLog.i(TAG, "startRecord output path is " + outputPath);
        if (isRecording) {
            TUIChatLog.w(TAG, "startRecord failed, is in recording");
            if (callback != null) {
                String errorMessage = TUIChatService.getAppContext().getString(R.string.record_rejected_for_in_recording);
                callback.onFailed(TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING, errorMessage);
            }
            return;
        }
        this.callback = callback;
        String signature = AIDenoiseSignatureManager.getInstance().getSignature();
        if (TextUtils.isEmpty(signature)) {
            TUIChatLog.e(TAG, "denoise signature is empty");
            if (this.callback != null) {
                this.callback.onFailed(TUIConstants.TUICalling.ERROR_SIGNATURE_ERROR, "denoise signature is empty");
                this.callback = null;
            }
            return;
        }
        isRecording = true;
        handler.removeCallbacksAndMessages(null);
        final AIDenoiseRecorderCallback aiDenoiseRecordCallback = new AIDenoiseRecorderCallback(this.callback);

        Map<String, Object> audioRecordParam = new HashMap<>();
        audioRecordParam.put(TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE, signature);
        audioRecordParam.put(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID, TUILogin.getSdkAppId());
        audioRecordParam.put(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, outputPath);
        TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD, TUIConstants.TUICalling.METHOD_NAME_START_RECORD_AUDIO_MESSAGE, audioRecordParam,
            aiDenoiseRecordCallback);
    }

    private void resetRecordStatus() {
        isRecording = false;
        handler.removeCallbacksAndMessages(null);
    }

    @Override
    public void stopRecord() {
        if (!isRecording) {
            return;
        }
        AIDenoiseRecorderCallback aiDenoiseRecordCallback = new AIDenoiseRecorderCallback(this.callback);

        TUICore.callService(
            TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD, TUIConstants.TUICalling.METHOD_NAME_STOP_RECORD_AUDIO_MESSAGE, null, aiDenoiseRecordCallback);
    }

    @Override
    public void cancelRecord() {
        if (!isRecording) {
            return;
        }
        AIDenoiseRecorderCallback aiDenoiseRecordCallback = new AIDenoiseRecorderCallback(new AudioRecorder.AudioRecorderInternalCallback() {
            @Override
            public void onStarted() {
                // do nothing
            }

            @Override
            public void onFinished() {
                if (AIDenoiseAudioRecordImpl.this.callback != null) {
                    AIDenoiseAudioRecordImpl.this.callback.onCanceled();
                }
                AIDenoiseAudioRecordImpl.this.callback = null;
            }

            @Override
            public void onCanceled() {
                // do nothing
            }

            @Override
            public void onFailed(int errorCode, String errorMessage) {
                if (AIDenoiseAudioRecordImpl.this.callback != null) {
                    AIDenoiseAudioRecordImpl.this.callback.onFailed(errorCode, errorMessage);
                }
                AIDenoiseAudioRecordImpl.this.callback = null;
            }
        });

        TUICore.callService(
            TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD, TUIConstants.TUICalling.METHOD_NAME_STOP_RECORD_AUDIO_MESSAGE, null, aiDenoiseRecordCallback);
    }

    @Override
    public boolean isRecording() {
        return isRecording;
    }

    class AIDenoiseRecorderCallback extends TUIServiceCallback {
        private AudioRecorder.AudioRecorderInternalCallback callback;

        AIDenoiseRecorderCallback(AudioRecorder.AudioRecorderInternalCallback callback) {
            this.callback = callback;
        }

        @Override
        public void onServiceCallback(int errorCode, String errorMessage, Bundle bundle) {
            String recordMethod = bundle.getString(TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE);
            if (TextUtils.equals(recordMethod, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START)) {
                processRecordStartCallback(errorCode, errorMessage);
            } else if (TextUtils.equals(recordMethod, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_STOP)) {
                processRecordStopCallback(errorCode, errorMessage);
            } else {
                TUIChatLog.e(TAG, "unknown callkit recorder method:" + recordMethod + ", errorCode:" + errorCode);
            }
        }

        private void processRecordStartCallback(int errorCode, String errorMessage) {
            TUIChatLog.i(TAG, "recorder begin, errorCode:" + errorCode);
            switch (errorCode) {
                case TUIConstants.TUICalling.ERROR_NONE:
                    if (callback != null) {
                        callback.onStarted();
                    }
                    handler.postDelayed(() -> {
                        if (!isRecording) {
                            return;
                        }
                        stopRecord();
                        ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(com.tencent.qcloud.tuikit.tuichat.R.string.record_limit_tips));
                    }, TUIChatConfigs.getGeneralConfig().getAudioRecordMaxTime() * 1000 - 200);
                    return;
                case TUIConstants.TUICalling.ERROR_STATUS_IN_CALL:
                    handler.post(() -> {
                        resetRecordStatus();
                        if (callback != null) {
                            callback.onFailed(TUIConstants.TUICalling.ERROR_STATUS_IN_CALL, errorMessage);
                            AIDenoiseAudioRecordImpl.this.callback = null;
                        }
                    });
                    return;
                case TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING:
                    handler.post(() -> {
                        resetRecordStatus();
                        if (callback != null) {
                            callback.onFailed(TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING, errorMessage);
                        }
                        AIDenoiseAudioRecordImpl.this.callback = null;
                    });
                    return;
                case TUIConstants.TUICalling.ERROR_MIC_PERMISSION_REFUSED:
                    handler.post(() -> {
                        resetRecordStatus();
                        if (callback != null) {
                            callback.onFailed(TUIConstants.TUICalling.ERROR_MIC_PERMISSION_REFUSED, errorMessage);
                        }
                        AIDenoiseAudioRecordImpl.this.callback = null;
                    });
                    return;
                case TUIConstants.TUICalling.ERROR_REQUEST_AUDIO_FOCUS_FAILED:
                case TUIConstants.TUICalling.ERROR_RECORD_INIT_FAILED:
                case TUIConstants.TUICalling.ERR_MIC_START_FAIL:
                case TUIConstants.TUICalling.ERR_MIC_NOT_AUTHORIZED:
                case TUIConstants.TUICalling.ERR_MIC_SET_PARAM_FAIL:
                case TUIConstants.TUICalling.ERR_MIC_OCCUPY:
                    handler.post(() -> {
                        resetRecordStatus();
                        if (callback != null) {
                            callback.onFailed(TUIConstants.TUICalling.ERROR_RECORD_FAILED, errorMessage);
                        }
                        AIDenoiseAudioRecordImpl.this.callback = null;
                    });
                    return;
                case TUIConstants.TUICalling.ERROR_PATH_FORMAT_NOT_SUPPORT:
                case TUIConstants.TUICalling.ERROR_INVALID_PARAM:
                case TUIConstants.TUICalling.ERROR_SIGNATURE_ERROR:
                case TUIConstants.TUICalling.ERROR_SIGNATURE_EXPIRED:
                default:
                    handler.post(() -> {
                        resetRecordStatus();
                        if (callback != null) {
                            callback.onFailed(TUIConstants.TUICalling.ERROR_INVALID_PARAM, errorMessage);
                        }
                        AIDenoiseAudioRecordImpl.this.callback = null;
                    });
            }
        }

        private void processRecordStopCallback(int errorCode, String errorMessage) {
            if (!isRecording) {
                TUIChatLog.i(TAG, "processRecordStopCallback, is not in recording");
                return;
            }
            TUIChatLog.i(TAG, "record complete, errorCode:" + errorCode);
            switch (errorCode) {
                case TUIConstants.TUICalling.ERROR_NONE:
                    handler.post(() -> {
                        resetRecordStatus();
                        if (callback != null) {
                            callback.onFinished();
                        }
                        AIDenoiseAudioRecordImpl.this.callback = null;
                    });
                    return;
                case TUIConstants.TUICalling.ERROR_NO_MESSAGE_TO_RECORD:
                case TUIConstants.TUICalling.ERROR_RECORD_FAILED:
                    handler.post(() -> {
                        resetRecordStatus();
                        if (callback != null) {
                            callback.onFailed(TUIConstants.TUICalling.ERROR_RECORD_FAILED, errorMessage);
                        }
                        AIDenoiseAudioRecordImpl.this.callback = null;
                    });
                    break;
                default:
                    resetRecordStatus();
                    if (callback != null) {
                        callback.onFinished();
                    }
                    AIDenoiseAudioRecordImpl.this.callback = null;
                    break;
            }
        }
    }
}
