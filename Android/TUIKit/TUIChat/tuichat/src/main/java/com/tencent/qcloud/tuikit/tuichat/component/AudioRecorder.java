package com.tencent.qcloud.tuikit.tuichat.component;

import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import com.tencent.qcloud.tuicore.TUIConfig;
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

public class AudioRecorder {
    private static final String TAG = AudioRecorder.class.getSimpleName();
    private static AudioRecorder sInstance = new AudioRecorder();
    private static String CURRENT_RECORD_FILE = TUIConfig.getRecordDir() + "auto_";
    private static int MAGIC_NUMBER = 500;
    private static int MIN_RECORD_DURATION = 1000;
    private Callback mRecordCallback;

    private String mAudioRecordPath;
    private MediaRecorder mRecorder;
    private Handler mHandler;

    private boolean mIsCallkitRecorder;
    private TUIServiceCallback mCallkitAudioRecordValueCallback;

    private AudioRecorder() {
        mHandler = new Handler();
        initCallkitAudioRecordListener();
    }

    public static AudioRecorder getInstance() {
        return sInstance;
    }

    private void initCallkitAudioRecordListener() {
        mCallkitAudioRecordValueCallback = new TUIServiceCallback() {
            @Override
            public void onServiceCallback(int errorCode, String errorMessage, Bundle bundle) {
                String recordMethod = bundle.getString(TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE);
                String path = bundle.getString(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH);
                if (TextUtils.equals(recordMethod, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START)) {
                    processCallkitRecordStart(errorCode, path);
                } else if (TextUtils.equals(recordMethod, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_STOP)) {
                    processCallkitRecordStop(errorCode, path);
                } else {
                    TUIChatLog.e(TAG, "unknown callkit recorder method:" + recordMethod + ", errorCode:" + errorCode);
                }
            }
        };
    }

    private void processCallkitRecordStart(int errorCode, String path) {
        TUIChatLog.i(TAG, "callkit recorder begin, errorCode:" + errorCode);
        switch (errorCode) {
            case TUIConstants.TUICalling.ERROR_NONE:
                mHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        stopCallkitRecord();
                        onRecordCompleted(true);
                        ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.record_limit_tips));
                    }
                }, TUIChatConfigs.getConfigs().getGeneralConfig().getAudioRecordMaxTime() * 1000);
                return;

            case TUIConstants.TUICalling.ERROR_STATUS_IN_CALL:
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        onRecordCompleted(false);
                        ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.record_rejected_for_in_call));
                    }
                });
                return;
            case TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING:
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        onRecordCompleted(false);
                        ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.record_rejected_for_in_recording));
                    }
                });
                return;
            case TUIConstants.TUICalling.ERROR_MIC_PERMISSION_REFUSED:
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        stopCallkitRecord();
                        onRecordCompleted(false);
                        ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.audio_permission_error));
                    }
                });
                return;
            case TUIConstants.TUICalling.ERROR_REQUEST_AUDIO_FOCUS_FAILED:
            case TUIConstants.TUICalling.ERROR_RECORD_INIT_FAILED:
            case TUIConstants.TUICalling.ERR_MIC_START_FAIL:
            case TUIConstants.TUICalling.ERR_MIC_NOT_AUTHORIZED:
            case TUIConstants.TUICalling.ERR_MIC_SET_PARAM_FAIL:
            case TUIConstants.TUICalling.ERR_MIC_OCCUPY:
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        stopCallkitRecord();
                        onRecordCompleted(false);
                    }
                });
                return;
            case TUIConstants.TUICalling.ERROR_PATH_FORMAT_NOT_SUPPORT:
            case TUIConstants.TUICalling.ERROR_INVALID_PARAM:
            case TUIConstants.TUICalling.ERROR_SIGNATURE_ERROR:
            case TUIConstants.TUICalling.ERROR_SIGNATURE_EXPIRED:
            default:
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        stopCallkitRecord();
                        startSystemRecorder();
                    }
                });
                return;
        }
    }

    private void processCallkitRecordStop(int errorCode, String path) {
        TUIChatLog.i(TAG, "callkit recorder complete, errorCode:" + errorCode);
        switch (errorCode) {
            case TUIConstants.TUICalling.ERROR_NONE:
                onRecordCompleted(true);
                return;
            case TUIConstants.TUICalling.ERROR_NO_MESSAGE_TO_RECORD:
            case TUIConstants.TUICalling.ERROR_RECORD_FAILED:
                onRecordCompleted(false);
                break;
            default:
                break;
        }
    }

    public void startRecord(Callback callback) {
        mRecordCallback = callback;
        mAudioRecordPath = CURRENT_RECORD_FILE + System.currentTimeMillis() + ".m4a";
        if (!startCallkitRecorder()) {
            startSystemRecorder();
        }
    }

    private boolean startCallkitRecorder() {
        if (TUICore.getService(TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD) == null) {
            TUIChatLog.i(TAG, "audio record service does not exists");
            return false;
        }

        String signature = AIDenoiseSignatureManager.getInstance().getSignature();
        if (TextUtils.isEmpty(signature)) {
            TUIChatLog.e(TAG, "denoise signature is empty");
            return false;
        }

        Map<String, Object> audioRecordParam = new HashMap<>();
        audioRecordParam.put(TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE, signature);
        audioRecordParam.put(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID, TUILogin.getSdkAppId());
        audioRecordParam.put(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, mAudioRecordPath);
        TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD, TUIConstants.TUICalling.METHOD_NAME_START_RECORD_AUDIO_MESSAGE, audioRecordParam,
            mCallkitAudioRecordValueCallback);

        mIsCallkitRecorder = true;
        TUIChatLog.i(TAG, "use callkit recorder");
        return true;
    }

    private void startSystemRecorder() {
        TUIChatLog.i(TAG, "use system media recorder");
        mIsCallkitRecorder = false;
        try {
            mRecorder = new MediaRecorder();
            mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            mRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            mRecorder.setOutputFile(mAudioRecordPath);
            mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
            mRecorder.prepare();
            mRecorder.start();
            mHandler.removeCallbacksAndMessages(null);
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    stopInternalRecord();
                    onRecordCompleted(true);
                    ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.record_limit_tips));
                }
            }, TUIChatConfigs.getConfigs().getGeneralConfig().getAudioRecordMaxTime() * 1000);
            updateMicStatus();
        } catch (Exception e) {
            TUIChatLog.w(TAG, "startRecord failed", e);
            stopInternalRecord();
            onRecordCompleted(false);
        }
    }

    public void stopRecord() {
        if (mIsCallkitRecorder) {
            stopCallkitRecord();
        } else {
            stopMediaRecord();
        }
    }

    private void stopCallkitRecord() {
        mHandler.removeCallbacksAndMessages(null);
        TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD, TUIConstants.TUICalling.METHOD_NAME_STOP_RECORD_AUDIO_MESSAGE, null,
            mCallkitAudioRecordValueCallback);
    }

    private void stopMediaRecord() {
        stopInternalRecord();
        onRecordCompleted(true);
    }

    private void stopInternalRecord() {
        mHandler.removeCallbacksAndMessages(null);
        if (mRecorder == null) {
            return;
        }
        mRecorder.release();
        mRecorder = null;
    }

    private void onRecordCompleted(boolean success) {
        if (mRecordCallback != null) {
            mRecordCallback.onCompletion(success);
            mRecordCallback = null;
        }

        if (!mIsCallkitRecorder && mRecorder != null) {
            mRecorder = null;
        }
    }

    public String getPath() {
        return mAudioRecordPath;
    }

    public int getDuration() {
        if (TextUtils.isEmpty(mAudioRecordPath)) {
            return 0;
        }
        int duration = 0;
        // 通过初始化播放器的方式来获取真实的音频长度
        // Get the real audio length by initializing the player
        try {
            MediaPlayer mp = new MediaPlayer();
            mp.setDataSource(mAudioRecordPath);
            mp.prepare();
            duration = mp.getDuration();
            // 语音长度如果是59s多，因为外部会/1000取整，会一直显示59'，所以这里对长度进行处理，达到四舍五入的效果
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

    private void updateMicStatus() {
        if (mRecorder != null) {
            double ratio = (double) mRecorder.getMaxAmplitude() / 1; // 参考振幅为 1
            double db = 0; // 分贝
            if (ratio > 1) {
                db = 20 * Math.log10(ratio);
            }
            TUIChatLog.d(TAG, "计算分贝值 = " + db + "dB");
            if (mRecordCallback != null) {
                mRecordCallback.onVoiceDb(db);
            }
            mHandler.postDelayed(mUpdateMicStatusTimer, 100); // 间隔取样时间为100秒
        }
    }

    private Runnable mUpdateMicStatusTimer = new Runnable() {
        public void run() {
            updateMicStatus();
        }
    };

    public interface Callback {

        void onCompletion(Boolean success);

        void onVoiceDb(double db);
    }
}
