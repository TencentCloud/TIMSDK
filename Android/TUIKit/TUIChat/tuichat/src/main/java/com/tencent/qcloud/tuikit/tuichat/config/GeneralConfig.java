package com.tencent.qcloud.tuikit.tuichat.config;

public class GeneralConfig {

    public final static int DEFAULT_AUDIO_RECORD_MAX_TIME = 60;
    public final static int DEFAULT_VIDEO_RECORD_MAX_TIME = 15;
    private String appCacheDir;
    private int audioRecordMaxTime = DEFAULT_AUDIO_RECORD_MAX_TIME;
    private int videoRecordMaxTime = DEFAULT_VIDEO_RECORD_MAX_TIME;
    private String userNickname = "";
    private boolean excludedFromUnreadCount;
    private boolean excludedFromLastMessage;

    private boolean isAndroidPrivateRing;
    private boolean isEnableMessageTyping = true;

    private boolean showRead = false;

    private boolean reactEnable = true;
    private boolean replyEnable = true;
    private boolean quoteEnable = true;

    private boolean enableVoiceCall = true;
    private boolean enableVideoCall = true;

    private boolean enableFloatWindowForCall = true;
    private boolean enableMultiDeviceForCall = false;

    private boolean enableTextTranslation = false;

    public boolean isEnableTextTranslation() {
        return enableTextTranslation;
    }

    public void setEnableTextTranslation(boolean enableTextTranslation) {
        this.enableTextTranslation = enableTextTranslation;
    }

    /**
     * 是否开启音视频通话悬浮窗
     * Set to enable the floating window for call
     */
    public void setEnableFloatWindowForCall(boolean enableFloatWindowForCall) {
        this.enableFloatWindowForCall = enableFloatWindowForCall;
    }

    public boolean isEnableFloatWindowForCall() {
        return enableFloatWindowForCall;
    }

    public void setEnableMultiDeviceForCall(boolean enableMultiDeviceForCall) {
        this.enableMultiDeviceForCall = enableMultiDeviceForCall;
    }

    public boolean isEnableMultiDeviceForCall() {
        return enableMultiDeviceForCall;
    }

    public void setReactEnable(boolean reactEnable) {
        this.reactEnable = reactEnable;
    }

    public boolean isReactEnable() {
        return reactEnable;
    }

    public void setReplyEnable(boolean replyEnable) {
        this.replyEnable = replyEnable;
    }

    public boolean isReplyEnable() {
        return replyEnable;
    }

    public void setQuoteEnable(boolean quoteEnable) {
        this.quoteEnable = quoteEnable;
    }

    public boolean isQuoteEnable() {
        return quoteEnable;
    }

    public void setEnableVideoCall(boolean enableVideoCall) {
        this.enableVideoCall = enableVideoCall;
    }

    public void setEnableVoiceCall(boolean enableVoiceCall) {
        this.enableVoiceCall = enableVoiceCall;
    }

    public boolean isEnableVideoCall() {
        return enableVideoCall;
    }

    public boolean isEnableVoiceCall() {
        return enableVoiceCall;
    }

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
     * Get TUIKit cache path
     *
     * @return
     */
    public String getAppCacheDir() {
        return appCacheDir;
    }

    /**
     * 设置TUIKit缓存路径
     * 
     * Set TUIKit cache path
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
     * Get the maximum duration of the recording
     *
     * @return
     */
    public int getAudioRecordMaxTime() {
        return audioRecordMaxTime;
    }

    /**
     * 录音最大时长
     * 
     * Maximum recording time
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
     * Get the maximum duration of the recording
     *
     * @return
     */
    public int getVideoRecordMaxTime() {
        return videoRecordMaxTime;
    }

    /**
     * 摄像最大时长
     * 
     * Maximum camera time
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
     * Whether the view read by the other party is displayed
     *
     * @return
     */
    public boolean isShowRead() {
        return showRead;
    }

    /**
     * 设置对方已读的 view 是否展示
     * 
     * Set whether the view read by the other party is displayed
     *
     * @return
     */
    public void setShowRead(boolean showRead) {
        this.showRead = showRead;
    }

    /**
     * 获取消息是否不计入会话未读数：默认为 false，表明需要计入会话未读数，设置为 true，表明不需要计入会话未读数
     * 
     * Get whether messages are not counted as conversation unread: false, need to be counted; true, do not need to be counted
     */
    public boolean isExcludedFromUnreadCount() {
        return excludedFromUnreadCount;
    }

    /**
     * 设置消息是否不计入会话未读数：默认为 false，表明需要计入会话未读数，设置为 true，表明不需要计入会话未读数
     * 
     * Set whether messages are not counted as conversation unread: false, need to be counted; true, do not need to be counted
     */
    public void setExcludedFromUnreadCount(boolean excludedFromUnreadCount) {
        this.excludedFromUnreadCount = excludedFromUnreadCount;
    }

    /**
     * 获取消息是否不计入会话 lastMsg：默认为 false，表明需要计入会话 lastMsg，设置为 true，表明不需要计入会话 lastMessage
     * 
     * Get whether the message does not count as the last message of the session: false, need to be counted; true, do not need to be counted
     */
    public boolean isExcludedFromLastMessage() {
        return excludedFromLastMessage;
    }

    /**
     * 设置消息是否不计入会话 lastMsg：默认为 false，表明需要计入会话 lastMsg，设置为 true，表明不需要计入会话 lastMessage
     * 
     * Set whether the message does not count as the last message of the session: false, need to be counted; true, do not need to be counted
     */
    public void setExcludedFromLastMessage(boolean excludedFromLastMessage) {
        this.excludedFromLastMessage = excludedFromLastMessage;
    }

    /**
     * 获取离线推送提示铃音是否为自定义铃音
     * 
     * Get whether the offline push notification ringtone is a custom ringtone
     */
    public boolean isAndroidPrivateRing() {
        return isAndroidPrivateRing;
    }

    /**
     * 设置离线推送提示铃音是否为自定义铃音
     * 
     * Set whether the offline push notification ringtone is a custom ringtone
     */
    public void setAndroidPrivateRing(boolean ring) {
        this.isAndroidPrivateRing = ring;
    }

    /**
     * 获取 "对方正在输入..." 功能是否打开
     *
     * Get whether the "Typing..." function is enabled
     */
    public boolean isEnableMessageTyping() {
        return isEnableMessageTyping;
    }

    /**
     * 设置 "对方正在输入..." 功能是否打开
     *
     * Set whether the "Typing..." function is enabled
     */
    public void setEnableMessageTyping(boolean enableMessageTyping) {
        isEnableMessageTyping = enableMessageTyping;
    }
}
