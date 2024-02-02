package com.tencent.qcloud.tuikit.tuichat.component.audio;

import android.media.MediaRecorder;
import android.os.Handler;
import android.os.Looper;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class SystemAudioRecordImpl implements AudioRecorder.IAudioRecorder {
    private static final String TAG = "SystemAudioRecordImpl";

    private AudioRecorder.AudioRecorderInternalCallback callback;
    private boolean isRecording = false;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private MediaRecorder recorder;

    SystemAudioRecordImpl() {}

    @Override
    public void startRecord(String outputPath, AudioRecorder.AudioRecorderInternalCallback callback) {
        TUIChatLog.i(TAG, "startRecord output path is " + outputPath);
        if (isRecording) {
            TUIChatLog.w(TAG, "startRecord failed, is in recording");
            if (callback != null) {
                callback.onFailed(TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING, "in recording");
            }
            return;
        }
        this.callback = callback;
        isRecording = true;
        try {
            recorder = new MediaRecorder();
            recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            recorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            recorder.setOutputFile(outputPath);
            recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
            recorder.prepare();
            recorder.start();
            handler.removeCallbacksAndMessages(null);
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (!isRecording) {
                        return;
                    }
                    stopRecord();
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(com.tencent.qcloud.tuikit.tuichat.R.string.record_limit_tips));
                }
            }, (TUIChatConfigs.getGeneralConfig().getAudioRecordMaxTime() * 1000) - 200);
            if (this.callback != null) {
                this.callback.onStarted();
            }
        } catch (Exception e) {
            TUIChatLog.e(TAG, "record failed " + e.getMessage());
            isRecording = false;
            if (this.callback != null) {
                this.callback.onFailed(TUIConstants.TUICalling.ERROR_RECORD_FAILED, e.getMessage());
                this.callback =  null;
            }
        }
    }

    @Override
    public void stopRecord() {
        if (recorder == null || !isRecording) {
            return;
        }
        handler.removeCallbacksAndMessages(null);
        recorder.release();
        recorder = null;
        isRecording = false;
        if (this.callback != null) {
            this.callback.onFinished();
            this.callback =  null;
        }
    }

    @Override
    public void cancelRecord() {
        if (recorder == null || !isRecording) {
            return;
        }
        handler.removeCallbacksAndMessages(null);
        recorder.release();
        recorder = null;
        isRecording = false;
        if (this.callback != null) {
            this.callback.onCanceled();
            this.callback = null;
        }
    }

    @Override
    public double getMaxAmplitude() {
        if (recorder != null) {
            return recorder.getMaxAmplitude();
        }
        return AudioRecorder.IAudioRecorder.super.getMaxAmplitude();
    }

    @Override
    public boolean isRecording() {
        return isRecording;
    }
}
