package com.tencent.qcloud.tuikit.tuichat.config;

/**
 * TUIKit的通用配置，比如可以设置日志打印、音视频录制时长等
 */
public class GeneralConfig {

    public final static int DEFAULT_AUDIO_RECORD_MAX_TIME = 60;
    public final static int DEFAULT_VIDEO_RECORD_MAX_TIME = 15;
    private String appCacheDir;
    private int audioRecordMaxTime = DEFAULT_AUDIO_RECORD_MAX_TIME;
    private int videoRecordMaxTime = DEFAULT_VIDEO_RECORD_MAX_TIME;
    private boolean showRead = false;
    private String userNickname = "";
    private boolean excludedFromUnreadCount;
    private boolean excludedFromLastMessage;

    private boolean isAndroidPrivateRing;

    public String getUserNickname() {
        return userNickname;
    }

    public void setUserNickname(String userNickname) {
        this.userNickname = userNickname;
    }

    public String getUserFaceUrl() {
        return userFaceUrl;
    }

    public void setUserFaceUrl(String userFaceUrl) {
        this.userFaceUrl = userFaceUrl;
    }

    private String userFaceUrl = "";

    /**
     * 获取TUIKit缓存路径
     *
     * @return
     */
    public String getAppCacheDir() {
        return appCacheDir;
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
     * 获取录音最大时长
     *
     * @return
     */
    public int getAudioRecordMaxTime() {
        return audioRecordMaxTime;
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
     * 获取录像最大时长
     *
     * @return
     */
    public int getVideoRecordMaxTime() {
        return videoRecordMaxTime;
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
     * 对方已读的 view 是否展示
     *
     * @return
     */
    public boolean isShowRead() {
        return showRead;
    }

    /**
     * 设置对方已读的 view 是否展示
     *
     * @return
     */
    public void setShowRead(boolean showRead) {
        this.showRead = showRead;
    }

    public boolean isExcludedFromUnreadCount() {
        return excludedFromUnreadCount;
    }

    public void setExcludedFromUnreadCount(boolean excludedFromUnreadCount) {
        this.excludedFromUnreadCount = excludedFromUnreadCount;
    }

    public boolean isExcludedFromLastMessage() {
        return excludedFromLastMessage;
    }

    public void setExcludedFromLastMessage(boolean excludedFromLastMessage) {
        this.excludedFromLastMessage = excludedFromLastMessage;
    }

    public boolean isAndroidPrivateRing() {
        return isAndroidPrivateRing;
    }

    public void setAndroidPrivateRing(boolean ring) {
        this.isAndroidPrivateRing = ring;
    }
}
