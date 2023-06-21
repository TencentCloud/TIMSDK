package com.tencent.qcloud.tuikit.tuichat.config;

public class GeneralConfig {
    public static final int DEFAULT_AUDIO_RECORD_MAX_TIME = 60;
    public static final int DEFAULT_VIDEO_RECORD_MAX_TIME = 15;
    private int audioRecordMaxTime = DEFAULT_AUDIO_RECORD_MAX_TIME;
    private int videoRecordMaxTime = DEFAULT_VIDEO_RECORD_MAX_TIME;

    /**
     * 拍照和摄像功能是否使用系统自带相机
     * Whether to use the built-in camera of the system to take photos and video
     */
    private boolean useSystemCamera = false;

    private boolean excludedFromUnreadCount;
    private boolean excludedFromLastMessage;

    private boolean isAndroidPrivateRing;
    private boolean isEnableMessageTyping = true;

    private boolean showRead = false;

    private boolean reactEnable = true;
    private boolean replyEnable = true;
    private boolean quoteEnable = true;

    private boolean enableWelcomeCustomMessage = true;

    private boolean enableVoiceCall = true;
    private boolean enableVideoCall = true;
    private boolean enableRoomKit = true;

    private boolean enableFloatWindowForCall = true;
    private boolean enableMultiDeviceForCall = false;

    private int timeIntervalForMessageRecall = 120;

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

    public void setEnableRoomKit(boolean enableRoomKit) {
        this.enableRoomKit = enableRoomKit;
    }

    public boolean isEnableRoomKit() {
        return enableRoomKit;
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
     */
    public boolean isShowRead() {
        return showRead;
    }

    /**
     * 设置对方已读的 view 是否展示
     *
     * Set whether the view read by the other party is displayed
     *
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

    /**
     *  是否展示自定义欢迎消息按钮，默认 YES
     *  Display custom welcome message button, default YES
     */
    public boolean isEnableWelcomeCustomMessage() {
        return enableWelcomeCustomMessage;
    }

    public void setEnableWelcomeCustomMessage(boolean enableWelcomeCustomMessage) {
        this.enableWelcomeCustomMessage = enableWelcomeCustomMessage;
    }

    /**
     * 消息可撤回时间，单位秒，默认 120 秒。如果想调整该配置，请同步修改 IM 控制台设置。
     * The time interval for message recall, in seconds, default is 120 seconds. If you want to adjust this configuration, please modify the IM console settings
     * synchronously.
     *
     * https://cloud.tencent.com/document/product/269/38656#.E6.B6.88.E6.81.AF.E6.92.A4.E5.9B.9E.E8.AE.BE.E7.BD.AE
     */
    public void setTimeIntervalForMessageRecall(int timeIntervalForMessageRecall) {
        this.timeIntervalForMessageRecall = timeIntervalForMessageRecall;
    }

    public int getTimeIntervalForMessageRecall() {
        return timeIntervalForMessageRecall;
    }

    public void setUseSystemCamera(boolean useSystemCamera) {
        this.useSystemCamera = useSystemCamera;
    }

    public boolean isUseSystemCamera() {
        return useSystemCamera;
    }
}
