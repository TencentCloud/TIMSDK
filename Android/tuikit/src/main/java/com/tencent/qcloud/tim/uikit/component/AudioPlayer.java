package com.tencent.qcloud.tim.uikit.component;


import android.media.MediaPlayer;
import android.media.MediaRecorder;

import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;


public class AudioPlayer {

    private static AudioPlayer instance = new AudioPlayer();
    private boolean playing;
    private boolean innerRecording;
    private volatile Boolean recording = false;
    private static String CURRENT_RECORD_FILE = TUIKitConstants.RECORD_DIR + "auto_";
    private AudioRecordCallback mRecordCallback;
    private AudioPlayCallback mPlayCallback;

    private String recordAudioPath;
    private long startTime;
    private long endTime;
    private MediaPlayer mPlayer;
    private MediaRecorder mRecorder;

    private AudioPlayer() {

    }

    public static AudioPlayer getInstance() {
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
                if (mRecordCallback != null) {
                    mRecordCallback.recordComplete(endTime - startTime);
                }
                if (mRecorder != null && innerRecording) {
                    try {
                        innerRecording = false;
                        mRecorder.stop();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                mRecordCallback = null;
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
            if (mPlayCallback != null) {
                mPlayCallback.playComplete();
                mPlayCallback = null;
            }
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
                // AMR在web端支持不好，这里使用aac
                mRecorder.setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS);
                recordAudioPath = CURRENT_RECORD_FILE + System.currentTimeMillis();
                mRecorder.setOutputFile(recordAudioPath);
                mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
                startTime = System.currentTimeMillis();
                synchronized (recording) {
                    if (recording == false) {
                        return;
                    }
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
                            if (System.currentTimeMillis() - startTime >= TUIKit.getConfigs().getGeneralConfig().getAudioRecordMaxTime() * 1000) {
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
                        if (mPlayCallback != null) {
                            mPlayCallback.playComplete();
                        }
                        playing = false;
                    }
                });
                mPlayer.prepare();
                mPlayer.start();
                playing = true;
            } catch (Exception e) {
                ToastUtil.toastLongMessage("语音文件已损坏或不存在");
                e.printStackTrace();
                if (mPlayCallback != null) {
                    mPlayCallback.playComplete();
                }
                playing = false;
            }
        }
    }


}
