package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;

public class GeneralConfig {
    public static final int DEFAULT_AUDIO_RECORD_MAX_TIME = 60;
    public static final int DEFAULT_VIDEO_RECORD_MAX_TIME = 15;
    public static final int DEFAULT_MESSAGE_RECALL_TIME_INTERVAL = 120;

    private int audioRecordMaxTime = DEFAULT_AUDIO_RECORD_MAX_TIME;
    private int videoRecordMaxTime = DEFAULT_VIDEO_RECORD_MAX_TIME;

    private boolean useSystemCamera = false;

    private boolean excludedFromUnreadCount;
    private boolean excludedFromLastMessage;

    private boolean enableAndroidPrivateRing;
    private boolean enableTypingStatus = true;

    private boolean msgNeedReadReceipt = false;
    private boolean enablePopMenuEmojiReactAction = true;
    private boolean enablePopMenuReplyAction = true;
    private boolean enablePopMenuReferenceAction = true;

    private boolean enableWelcomeCustomMessage = true;

    private boolean enableAudioCall = true;
    private boolean enableVideoCall = true;
    private boolean enableRoomKit = true;

    private boolean enableFloatWindowForCall = true;
    private boolean enableMultiDeviceForCall = false;

    private int timeIntervalForMessageRecall = DEFAULT_MESSAGE_RECALL_TIME_INTERVAL;

    private boolean enableMainPageInputBar = true;

    private boolean enableSoundMessageSpeakerMode = true;

    /**
     * 设置是否开启音视频通话悬浮窗，默认为开启
     * Set to enable the floating window for call, default value is true
     */
    public void setEnableFloatWindowForCall(boolean enableFloatWindowForCall) {
        this.enableFloatWindowForCall = enableFloatWindowForCall;
    }

    /**
     * 获取是否开启音视频通话悬浮窗
     * Obtain whether to open the audio and video call floating window
     */
    public boolean isEnableFloatWindowForCall() {
        return enableFloatWindowForCall;
    }

    /**
     * 设置音视频通话开启多端登录功能，默认关闭
     * Set whether to enable multi-terminal login function for audio and video calls, default is false
     */
    public void setEnableMultiDeviceForCall(boolean enableMultiDeviceForCall) {
        this.enableMultiDeviceForCall = enableMultiDeviceForCall;
    }

    /**
     * 获取音视频通话开启多端登录功能
     * Obtain audio and video calls and enable multi-terminal login function
     */
    public boolean isEnableMultiDeviceForCall() {
        return enableMultiDeviceForCall;
    }

    /**
     *  设置聊天长按弹框是否展示emoji互动消息功能，默认展示
     *  Set in the chat interface, long press the pop-up box to display the emoji interactive message function or not, the default is true
     */
    public void setEnablePopMenuEmojiReactAction(boolean enablePopMenuEmojiReactAction) {
        this.enablePopMenuEmojiReactAction = enablePopMenuEmojiReactAction;
    }

    /**
     *  获取聊天长按弹框是否展示emoji互动消息功能
     *  Get chat long press whether to display emoji interactive message function
     */
    public boolean isEnablePopMenuEmojiReactAction() {
        return enablePopMenuEmojiReactAction;
    }

    /**
     *  设置聊天长按弹框是否展示 消息回复功能入口，默认展示
     *  Set chat long press the pop-up box to display the message reply function entry or not, the default is true
     */
    public void setEnablePopMenuReplyAction(boolean enablePopMenuReplyAction) {
        this.enablePopMenuReplyAction = enablePopMenuReplyAction;
    }

    /**
     *  获取聊天长按弹框是否展示 消息回复功能入口
     *  Obtain whether to display the message reply function entry in the chat long press pop-up box
     */
    public boolean isEnablePopMenuReplyAction() {
        return enablePopMenuReplyAction;
    }

    /**
     *  设置聊天长按弹框是否展示 消息引用功能入口，默认展示
     *  Set chat long press the pop-up box to display the entry of the message reference function or not, the default is true
     */
    public void setEnablePopMenuReferenceAction(boolean enablePopMenuReferenceAction) {
        this.enablePopMenuReferenceAction = enablePopMenuReferenceAction;
    }

    /**
     *  获取聊天长按弹框是否展示 消息引用功能入口
     *  Obtain whether the chat long press pop-up box displays the message reference function entry
     */
    public boolean isEnablePopMenuReferenceAction() {
        return enablePopMenuReferenceAction;
    }

    /**
     *  设置是否展示视频通话按钮，如果集成了 TUICallKit 组件，默认展示
     *  Set display the video call button or not, if the TUICallKit component is integrated, the default is true
     */
    public void setEnableVideoCall(boolean enableVideoCall) {
        this.enableVideoCall = enableVideoCall;
    }

    /**
     *  获取是否展示视频通话按钮
     *  Get whether to display the video call button
     */
    public boolean isEnableVideoCall() {
        return enableVideoCall;
    }

    /**
     *  设置是否展示音频通话按钮，如果集成了 TUICallKit 组件，默认展示
     *  Whether to display the audio call button, if the TUICallKit component is integrated, the default is true
     */
    public void setEnableAudioCall(boolean enableAudioCall) {
        this.enableAudioCall = enableAudioCall;
    }

    /**
     *  获取是否展示音频通话按钮
     *  Get whether to display the audio call button
     */
    public boolean isEnableAudioCall() {
        return enableAudioCall;
    }

    /**
     *  设置是否展示快速会议按钮，如果集成了 TUIRoomKit 组件，默认展示
     *  Set whether to display the quick meeting button, if the TUIRoomKit component is integrated, it will be displayed by default
     */
    public void setEnableRoomKit(boolean enableRoomKit) {
        this.enableRoomKit = enableRoomKit;
    }

    /**
     * 获取是否展示快速会议按钮
     * Get whether to display the quick meeting button
     */
    public boolean isEnableRoomKit() {
        return enableRoomKit;
    }

    /**
     * 获取录音最大时长
     * Get the maximum duration of the recording
     */
    public int getAudioRecordMaxTime() {
        return audioRecordMaxTime;
    }

    /**
     * 设置录音最大时长
     * Set the maximum recording time
     */
    public GeneralConfig setAudioRecordMaxTime(int audioRecordMaxTime) {
        this.audioRecordMaxTime = audioRecordMaxTime;
        return this;
    }

    /**
     * 获取录像最大时长
     * Get the maximum duration of the recording
     */
    public int getVideoRecordMaxTime() {
        return videoRecordMaxTime;
    }

    /**
     * 设置摄像最大时长
     * Set the maximum recording time
     */
    public GeneralConfig setVideoRecordMaxTime(int videoRecordMaxTime) {
        this.videoRecordMaxTime = videoRecordMaxTime;
        return this;
    }

    /**
     * 对方已读的 view 是否展示
     * Whether the view read by the other party is displayed
     */
    public boolean isMsgNeedReadReceipt() {
        return msgNeedReadReceipt;
    }

    /**
     * 设置对方已读的 view 是否展示，默认不展示
     * Set whether the view read by the other party is displayed, not displayed by default
     *
     */
    public void setMsgNeedReadReceipt(boolean msgNeedReadReceipt) {
        this.msgNeedReadReceipt = msgNeedReadReceipt;
    }

    /**
     * 获取消息是否不计入会话未读数
     * Get whether messages are not counted as conversation unread
     */
    public boolean isExcludedFromUnreadCount() {
        return excludedFromUnreadCount;
    }

    /**
     * 设置消息是否不计入会话未读数：默认为 false，表明需要计入会话未读数，设置为 true，表明不需要计入会话未读数
     * Set whether messages are not counted as conversation unread: false, need to be counted; true, do not need to be counted
     */
    public void setExcludedFromUnreadCount(boolean excludedFromUnreadCount) {
        this.excludedFromUnreadCount = excludedFromUnreadCount;
    }

    /**
     * 获取消息是否不计入会话 lastMsg
     * Get whether the message does not count as the last message of the session
     */
    public boolean isExcludedFromLastMessage() {
        return excludedFromLastMessage;
    }

    /**
     * 设置消息是否不计入会话 lastMsg：默认为 false，表明需要计入会话 lastMsg，设置为 true，表明不需要计入会话 lastMessage
     * Set whether the message does not count as the last message of the session: false, need to be counted; true, do not need to be counted
     */
    public void setExcludedFromLastMessage(boolean excludedFromLastMessage) {
        this.excludedFromLastMessage = excludedFromLastMessage;
    }

    /**
     * 获取离线推送提示铃音是否为自定义铃音
     * Get whether the offline push notification ringtone is a custom ringtone
     */
    public boolean isEnableAndroidPrivateRing() {
        return enableAndroidPrivateRing;
    }

    /**
     * 设置离线推送提示铃音是否为自定义铃音
     * Set whether the offline push notification ringtone is a custom ringtone
     */
    public void setEnableAndroidPrivateRing(boolean ring) {
        this.enableAndroidPrivateRing = ring;
    }

    /**
     * 设置 "对方正在输入..." 功能是否打开
     * Set whether the "Typing..." function is enabled
     */
    public void setEnableTypingStatus(boolean enableTypingStatus) {
        this.enableTypingStatus = enableTypingStatus;
    }

    /**
     * 获取 "对方正在输入..." 功能是否打开
     * Get whether the "Typing..." function is enabled
     */
    public boolean isEnableTypingStatus() {
        return enableTypingStatus;
    }

    /**
     *  是否展示自定义欢迎消息按钮
     *  Whether to display a custom welcome message button
     */
    public boolean isEnableWelcomeCustomMessage() {
        return enableWelcomeCustomMessage;
    }

    /**
     *  设置是否展示自定义欢迎消息按钮，默认 true
     *  Display custom welcome message button, default true
     */
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

    /**
     * 获取消息可撤回时间，单位秒
     * Get the time interval for message recall, in seconds
     */
    public int getTimeIntervalForMessageRecall() {
        return timeIntervalForMessageRecall;
    }

    /**
     * 设置拍照和摄像功能是否使用系统自带相机
     * Whether to use the built-in camera of the system to take photos and video
     */
    public void setUseSystemCamera(boolean useSystemCamera) {
        this.useSystemCamera = useSystemCamera;
    }

    /**
     * 获取拍照和摄像功能是否使用系统自带相机
     * Obtain whether to use the system's built-in camera for the camera and video functions
     */
    public boolean isUseSystemCamera() {
        return useSystemCamera;
    }

    /**
     *  设置聊天对话框是否展示 输入框 默认展示
     *  Whether the chat page displays "InputBar", the default is true
     */
    public void setEnableMainPageInputBar(boolean enableMainPageInputBar) {
        this.enableMainPageInputBar = enableMainPageInputBar;
    }

    /**
     *  获取聊天对话框是否展示 输入框
     *  Get whether to display the input box in the chat page
     */
    public boolean isEnableMainPageInputBar() {
        return enableMainPageInputBar;
    }

    /**
     * 设置语音消息使用扬声器播放还是使用听筒播放，设置为 true 使用扬声器播放，false 则为听筒播放。默认使用扬声器播放。
     * Set whether to use the speaker to play the voice message or use the earpiece to play, set it to true to use the speaker to play,
     * false to use the earpiece to play. By default, the speaker is used for playback.
     */
    public void setEnableSoundMessageSpeakerMode(boolean enableSoundMessageSpeakerMode) {
        this.enableSoundMessageSpeakerMode = enableSoundMessageSpeakerMode;
        SPUtils.getInstance(TUIChatConstants.CHAT_SETTINGS_SP_NAME).put(TUIChatConstants.CHAT_SP_KEY_SPEAKER_MODE_ON, enableSoundMessageSpeakerMode);
    }

    /**
     * 获取语音消息是否使用扬声器播放。结果为 true 使用扬声器播放，结果为 false 则使用听筒播放。
     * Gets whether the voice message is played on the speaker. True to use the speaker, false to use the earpiece.
     */
    public boolean isEnableSoundMessageSpeakerMode() {
        return SPUtils.getInstance(TUIChatConstants.CHAT_SETTINGS_SP_NAME)
                .getBoolean(TUIChatConstants.CHAT_SP_KEY_SPEAKER_MODE_ON, enableSoundMessageSpeakerMode);
        }
}
