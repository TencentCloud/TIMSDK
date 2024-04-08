package com.tencent.qcloud.tuikit.tuichat.component.audio;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import androidx.core.app.ActivityCompat;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.model.AIDenoiseSignatureManager;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class AudioRecorder {
    private static final String TAG = AudioRecorder.class.getSimpleName();
    private static final AudioRecorder instance = new AudioRecorder();

    private static final int MAGIC_NUMBER = 500;
    private static final int MIN_RECORD_DURATION = 1000;
    private static final int UPDATE_AMPLITUDE_PERIOD = 100;
    private static final int DEFAULT_MAX_AMPLITUDE = 100;

    public static final int ERROR_CODE_MIC_IS_BEING_USED = -100;

    private Handler updateAmplitudeHandler;

    private IAudioRecorder recorder;

    private AudioRecorder() {
        init();
    }

    private void init() {
        updateAmplitudeHandler = new Handler(Looper.getMainLooper());

        boolean useAIDenoiseRecorder = false;
        if (TUICore.getService(TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD) == null) {
            TUIChatLog.i(TAG, "audio record service does not exists");
        } else {
            String signature = AIDenoiseSignatureManager.getInstance().getSignature();
            if (TextUtils.isEmpty(signature)) {
                TUIChatLog.e(TAG, "denoise signature is empty");
            } else {
                useAIDenoiseRecorder = true;
            }
        }

        if (useAIDenoiseRecorder) {
            recorder = new AIDenoiseAudioRecordImpl();
        } else {
            recorder = new SystemAudioRecordImpl();
        }
    }

    public static void startRecord(AudioRecorderCallback callback) {
        if (instance.recorder.isRecording()) {
            return;
        }
        if (TUILogin.getCurrentBusinessScene() != TUILogin.TUIBusinessScene.NONE) {
            String errorMessage = TUIChatService.getAppContext().getString(R.string.chat_mic_is_being_used_cant_record);
            TUIChatLog.w(TAG, errorMessage);
            if (callback != null) {
                callback.onFailed(ERROR_CODE_MIC_IS_BEING_USED, errorMessage);
            }
            return;
        }

        String audioFilePath = TUIConfig.getRecordDir() + System.currentTimeMillis() + ".m4a";
        AudioRecorderInternalCallback internalCallback = new AudioRecorderInternalCallback() {
            @Override
            public void onFinished() {
                instance.updateAmplitudeHandler.removeCallbacksAndMessages(null);
                if (callback != null) {
                    if (!FileUtil.isFileExists(audioFilePath)) {
                        callback.onFailed(TUIConstants.TUICalling.ERROR_RECORD_FAILED, "audio file not found");
                    } else {
                        callback.onFinished(audioFilePath);
                    }
                }
            }

            @Override
            public void onStarted() {
                if (callback != null) {
                    callback.onStarted();
                }
                instance.updateMicStatus(callback);
            }

            @Override
            public void onFailed(int errorCode, String errorMessage) {
                instance.updateAmplitudeHandler.removeCallbacksAndMessages(null);
                if (callback != null) {
                    callback.onFailed(errorCode, errorMessage);
                }
            }

            @Override
            public void onCanceled() {
                boolean isSuccess = FileUtil.deleteFile(audioFilePath);
                if (!isSuccess) {
                    TUIChatLog.w(TAG, "cancel record, delete audio file failed");
                }
                if (callback != null) {
                    callback.onCanceled();
                }
            }
        };
        if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIChatService.getAppContext(), Manifest.permission.RECORD_AUDIO)) {
            if (callback != null) {
                callback.onFailed(TUIConstants.TUICalling.ERROR_MIC_PERMISSION_REFUSED, "no record permission");
            }
            PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, null);
        } else {
            if (instance.recorder != null) {
                instance.recorder.startRecord(audioFilePath, internalCallback);
            }
        }
    }

    public static void stopRecord() {
        instance.recorder.stopRecord();
    }

    public static void cancelRecord() {
        instance.recorder.cancelRecord();
    }

    public static int getDuration(String audioPath) {
        if (TextUtils.isEmpty(audioPath)) {
            return 0;
        }
        int duration = 0;
        
        // Get the real audio length by initializing the player
        try {
            MediaPlayer mp = new MediaPlayer();
            mp.setDataSource(audioPath);
            mp.prepare();
            duration = mp.getDuration();
            
            // the length is processed to achieve the effect of rounding
            if (duration < MIN_RECORD_DURATION) {
                duration = 0;
            } else {
                duration = duration + MAGIC_NUMBER;
            }
        } catch (Exception e) {
            TUIChatLog.w(TAG, "getDuration failed", e);
        }
        if (duration < 0) {
            duration = 0;
        }
        return duration;
    }

    private void updateMicStatus(AudioRecorderCallback callback) {
        if (recorder != null && callback != null) {
            double ratio = recorder.getMaxAmplitude();
            double db = 0;
            if (ratio > 1) {
                db = 20 * Math.log10(ratio);
            }
            callback.onVoiceDb(db);
            updateAmplitudeHandler.postDelayed(() -> updateMicStatus(callback), UPDATE_AMPLITUDE_PERIOD);
        }
    }

    public interface AudioRecorderCallback {

        void onStarted();

        void onFinished(String outputPath);

        void onFailed(int errorCode, String errorMessage);

        void onCanceled();

        default void onVoiceDb(double db) {}
    }

    interface IAudioRecorder {

        void startRecord(String outputPath, AudioRecorderInternalCallback callback);

        void stopRecord();

        void cancelRecord();

        boolean isRecording();

        default double getMaxAmplitude() {
            return DEFAULT_MAX_AMPLITUDE;
        }
    }

    interface AudioRecorderInternalCallback {

        void onStarted();

        void onFinished();

        void onCanceled();

        void onFailed(int errorCode, String errorMessage);
    }
}
