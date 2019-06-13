package com.tencent.qcloud.tim.uikit.config;

import com.tencent.imsdk.TIMLogLevel;

/**
 * TUIKit的通用配置，比如可以设置日志打印、音视频录制时长等
 */
public class GeneralConfig {

    private static final String TAG = GeneralConfig.class.getSimpleName();

    public final static int DEFAULT_AUDIO_RECORD_MAX_TIME = 60;
    public final static int DEFAULT_VIDEO_RECORD_MAX_TIME = 15;

    private String appCacheDir;
    private int audioRecordMaxTime = DEFAULT_AUDIO_RECORD_MAX_TIME;
    private int videoRecordMaxTime = DEFAULT_VIDEO_RECORD_MAX_TIME;
    private int logLevel = TIMLogLevel.DEBUG;
    private boolean enableLogPrint = true;

    /**
     * 获取是否打印日志
     *
     * @return
     */
    public boolean isLogPrint() {
        return enableLogPrint;
    }

    /**
     * 设置是否打印日志
     *
     * @param enableLogPrint
     */
    public void enableLogPrint(boolean enableLogPrint) {
        this.enableLogPrint = enableLogPrint;
    }

    /**
     * 获取打印的日志级别
     *
     * @return
     */
    public int getLogLevel() {
        return logLevel;
    }

    /**
     * 设置打印的日志级别
     *
     * @param logLevel
     */
    public void setLogLevel(int logLevel) {
        this.logLevel = logLevel;
    }

    /**
     * 设置TUIKit缓存路径
     *
     * @param appCacheDir
     * @return
     */
    public GeneralConfig setAppCacheDir(String appCacheDir) {
        this.appCacheDir = appCacheDir;
        return this;
    }

    /**
     * 录音最大时长
     *
     * @param audioRecordMaxTime
     * @return
     */
    public GeneralConfig setAudioRecordMaxTime(int audioRecordMaxTime) {
        this.audioRecordMaxTime = audioRecordMaxTime;
        return this;
    }

    /**
     * 摄像最大时长
     *
     * @param videoRecordMaxTime
     * @return
     */
    public GeneralConfig setVideoRecordMaxTime(int videoRecordMaxTime) {
        this.videoRecordMaxTime = videoRecordMaxTime;
        return this;
    }

    /**
     * 获取TUIKit缓存路径
     * @return
     */
    public String getAppCacheDir() {
        return appCacheDir;
    }

    /**
     * 获取录音最大时长
     *
     * @return
     */
    public int getAudioRecordMaxTime() {
        return audioRecordMaxTime;
    }

    /**
     * 获取录像最大时长
     * @return
     */
    public int getVideoRecordMaxTime() {
        return videoRecordMaxTime;
    }
}
