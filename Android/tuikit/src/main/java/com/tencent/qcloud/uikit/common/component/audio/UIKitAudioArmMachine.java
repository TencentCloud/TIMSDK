package com.tencent.qcloud.uikit.common.component.audio;


import android.media.MediaPlayer;
import android.media.MediaRecorder;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.utils.UIUtils;


public class UIKitAudioArmMachine {

    private boolean playing, innerRecording;
    private volatile Boolean recording = false;
    public static String CURRENT_RECORD_FILE = UIKitConstants.RECORD_DIR + "auto_";
    private AudioRecordCallback mRecordCallback;
    private AudioPlayCallback mPlayCallback;

    private String recordAudioPath;
    private long startTime, endTime;
    private MediaPlayer mPlayer;
    private MediaRecorder mRecorder;
    private static UIKitAudioArmMachine instance = new UIKitAudioArmMachine();


    private UIKitAudioArmMachine() {

    }

    public static UIKitAudioArmMachine getInstance() {
        return instance;
    }


    public void startRecord(AudioRecordCallback callback) {
        synchronized (recording) {
            mRecordCallback = callback;
            recording = true;
            new RecordThread().start();
        }
    }

    public void stopRecord() {
        synchronized (recording) {
            if (recording) {
                recording = false;
                endTime = System.currentTimeMillis();
                if (mRecordCallback != null)
                    mRecordCallback.recordComplete(endTime - startTime);
                if (mRecorder != null && innerRecording) {
                    try {
                        innerRecording = false;
                        mRecorder.stop();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                }

            }
        }


    }


    public void playRecord(String filePath, AudioPlayCallback callback) {
        this.mPlayCallback = callback;
        new PlayThread(filePath).start();


    }


    public void stopPlayRecord() {
        if (mPlayer != null) {
            mPlayer.stop();
            playing = false;
            mPlayCallback.playComplete();
        }
    }

    public boolean isPlayingRecord() {
        return playing;
    }


    public String getRecordAudioPath() {
        return recordAudioPath;
    }

    public int getDuration() {
        return (int) (endTime - startTime);
    }

    public interface AudioRecordCallback {
        void recordComplete(long duration);
    }

    public interface AudioPlayCallback {
        void playComplete();
    }


    private class RecordThread extends Thread {
        @Override
        public void run() {
            //根据采样参数获取每一次音频采样大小
            try {

                mRecorder = new MediaRecorder();
                mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
                //RAW_AMR虽然被高版本废弃，但它兼容低版本还是可以用的
                mRecorder.setOutputFormat(MediaRecorder.OutputFormat.RAW_AMR);
                recordAudioPath = CURRENT_RECORD_FILE + System.currentTimeMillis();
                mRecorder.setOutputFile(recordAudioPath);
                mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
                startTime = System.currentTimeMillis();
                synchronized (recording) {
                    if (recording == false)
                        return;
                    mRecorder.prepare();
                    mRecorder.start();
                }
                innerRecording = true;
                new Thread() {
                    @Override
                    public void run() {
                        while (recording && innerRecording) {
                            try {
                                RecordThread.sleep(200);
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }
                            if (System.currentTimeMillis() - startTime >= TUIKit.getBaseConfigs().getAudioRecordMaxTime() * 1000) {
                                stopRecord();
                                return;
                            }
                        }
                    }
                }.start();

            } catch (Exception e) {
                e.printStackTrace();
            }

        }
    }


    private class PlayThread extends Thread {
        String audioPath;

        PlayThread(String filePath) {
            audioPath = filePath;
        }

        public void run() {
            try {
                mPlayer = new MediaPlayer();
                mPlayer.setDataSource(audioPath);
                mPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                    @Override
                    public void onCompletion(MediaPlayer mp) {
                        mPlayCallback.playComplete();
                        playing = false;
                    }
                });
                mPlayer.prepare();
                mPlayer.start();
                playing = true;
            } catch (Exception e) {
                UIUtils.toastLongMessage("语音文件已损坏或不存在");
                e.printStackTrace();
                mPlayCallback.playComplete();
                playing = false;
            }
        }
    }


}
