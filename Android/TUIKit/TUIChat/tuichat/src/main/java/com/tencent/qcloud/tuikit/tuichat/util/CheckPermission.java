package com.tencent.qcloud.tuikit.tuichat.util;

import android.hardware.Camera;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.util.Log;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;

public class CheckPermission {

    public static final int STATE_RECORDING = -1;
    public static final int STATE_NO_PERMISSION = -2;
    public static final int STATE_SUCCESS = 1;
    private static final String TAG = CheckPermission.class.getSimpleName();

    /**
     * 用于检测是否具有录音权限
     * 
     * Used to detect whether there is recording permission
     *
     * @return
     */
    public static int getRecordState() {
        int minBuffer = AudioRecord.getMinBufferSize(44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat
                .ENCODING_PCM_16BIT);
        AudioRecord audioRecord = new AudioRecord(MediaRecorder.AudioSource.DEFAULT, 44100, AudioFormat
                .CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, (minBuffer * 100));
        short[] point = new short[minBuffer];
        int readSize = 0;
        try {

            audioRecord.startRecording();
        } catch (Exception e) {
            if (audioRecord != null) {
                audioRecord.release();
                audioRecord = null;
            }
            return STATE_NO_PERMISSION;
        }
        if (audioRecord.getRecordingState() != AudioRecord.RECORDSTATE_RECORDING) {
            if (audioRecord != null) {
                audioRecord.stop();
                audioRecord.release();
                audioRecord = null;
                Log.i(TAG, TUIChatService.getAppContext().getString(R.string.record_occupied));
            }
            return STATE_RECORDING;
        } else {
            readSize = audioRecord.read(point, 0, point.length);

            if (readSize <= 0) {
                if (audioRecord != null) {
                    audioRecord.stop();
                    audioRecord.release();
                    audioRecord = null;

                }
                Log.i(TAG, TUIChatService.getAppContext().getString(R.string.record_null));
                return STATE_NO_PERMISSION;

            } else {
                if (audioRecord != null) {
                    audioRecord.stop();
                    audioRecord.release();
                    audioRecord = null;

                }

                return STATE_SUCCESS;
            }
        }
    }

    public synchronized static boolean isCameraUseable(int cameraID) {
        boolean canUse = true;
        Camera mCamera = null;
        try {
            mCamera = Camera.open(cameraID);
            // setParameters 是针对魅族MX5。MX5通过Camera.open()拿到的Camera对象不为null
            // setParameters is for Meizu MX5. The Camera object obtained by MX5 through Camera.open() is not null
            Camera.Parameters mParameters = mCamera.getParameters();
            mCamera.setParameters(mParameters);
        } catch (Exception e) {
            e.printStackTrace();
            canUse = false;
        } finally {
            if (mCamera != null) {
                mCamera.release();
            } else {
                canUse = false;
            }
            mCamera = null;
        }
        return canUse;
    }
}