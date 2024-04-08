package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;

public class GeneralConfig {
    public static final int DEFAULT_AUDIO_RECORD_MAX_TIME = 60;
    public static final int DEFAULT_VIDEO_RECORD_MAX_TIME = 15;
    public static final int DEFAULT_MESSAGE_RECALL_TIME_INTERVAL = 120;
    public static final int FILE_MAX_SIZE = 100 * 1024 * 1024;
    public static final int VIDEO_MAX_SIZE = 100 * 1024 * 1024;
    public static final int IMAGE_MAX_SIZE = 28 * 1024 * 1024;
    public static final int GIF_IMAGE_MAX_SIZE = 10 * 1024 * 1024;

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
    private boolean enablePoll = true;
    private boolean enableGroupNote = true;
    private boolean enableTakePhoto = true;
    private boolean enableRecordVideo = true;
    private boolean enableFile = true;
    private boolean enableAlbum = true;

    private boolean enableFloatWindowForCall = true;
    private boolean enableMultiDeviceForCall = false;

    private int timeIntervalForMessageRecall = DEFAULT_MESSAGE_RECALL_TIME_INTERVAL;

    private boolean enableMainPageInputBar = true;

    private boolean enableSoundMessageSpeakerMode = true;

    /**
     * Set to enable the floating window for call, default value is true
     */
    public void setEnableFloatWindowForCall(boolean enableFloatWindowForCall) {
        this.enableFloatWindowForCall = enableFloatWindowForCall;
    }

    /**
     * Obtain whether to open the audio and video call floating window
     */
    public boolean isEnableFloatWindowForCall() {
        return enableFloatWindowForCall;
    }

    /**
     * Set whether to enable multi-terminal login function for audio and video calls, default is false
     */
    public void setEnableMultiDeviceForCall(boolean enableMultiDeviceForCall) {
        this.enableMultiDeviceForCall = enableMultiDeviceForCall;
    }

    /**
     * Obtain audio and video calls and enable multi-terminal login function
     */
    public boolean isEnableMultiDeviceForCall() {
        return enableMultiDeviceForCall;
    }

    /**
     *  Set in the chat interface, long press the pop-up box to display the emoji interactive message function or not, the default is true
     */
    public void setEnablePopMenuEmojiReactAction(boolean enablePopMenuEmojiReactAction) {
        this.enablePopMenuEmojiReactAction = enablePopMenuEmojiReactAction;
    }

    /**
     *  Get chat long press whether to display emoji interactive message function
     */
    public boolean isEnablePopMenuEmojiReactAction() {
        return enablePopMenuEmojiReactAction;
    }

    /**
     *  Set chat long press the pop-up box to display the message reply function entry or not, the default is true
     */
    public void setEnablePopMenuReplyAction(boolean enablePopMenuReplyAction) {
        this.enablePopMenuReplyAction = enablePopMenuReplyAction;
    }

    /**
     *  Obtain whether to display the message reply function entry in the chat long press pop-up box
     */
    public boolean isEnablePopMenuReplyAction() {
        return enablePopMenuReplyAction;
    }

    /**
     *  Set chat long press the pop-up box to display the entry of the message reference function or not, the default is true
     */
    public void setEnablePopMenuReferenceAction(boolean enablePopMenuReferenceAction) {
        this.enablePopMenuReferenceAction = enablePopMenuReferenceAction;
    }

    /**
     *  Obtain whether the chat long press pop-up box displays the message reference function entry
     */
    public boolean isEnablePopMenuReferenceAction() {
        return enablePopMenuReferenceAction;
    }

    /**
     *  Set display the video call button or not, if the TUICallKit component is integrated, the default is true
     */
    public void setEnableVideoCall(boolean enableVideoCall) {
        this.enableVideoCall = enableVideoCall;
    }

    /**
     *  Get whether to display the video call button
     */
    public boolean isEnableVideoCall() {
        return enableVideoCall;
    }

    /**
     *  Whether to display the audio call button, if the TUICallKit component is integrated, the default is true
     */
    public void setEnableAudioCall(boolean enableAudioCall) {
        this.enableAudioCall = enableAudioCall;
    }

    /**
     *  Get whether to display the audio call button
     */
    public boolean isEnableAudioCall() {
        return enableAudioCall;
    }

    /**
     *  Set whether to display the quick meeting button, if the TUIRoomKit component is integrated, it will be displayed by default
     */
    public void setEnableRoomKit(boolean enableRoomKit) {
        this.enableRoomKit = enableRoomKit;
    }

    /**
     * Get whether to display the quick meeting button
     */
    public boolean isEnableRoomKit() {
        return enableRoomKit;
    }

    /**
     *  Set whether to display the group note button. If the TUIGroupNotePlugin is integrated, it is displayed by default.
     */
    public void setEnableGroupNote(boolean enableGroupNote) {
        this.enableGroupNote = enableGroupNote;
    }

    /**
     * Get whether to display the group note button
     */
    public boolean isEnableGroupNote() {
        return enableGroupNote;
    }

    /**
     *  Set whether to display the group voting button. If the TUIPollPlugin component is integrated, it is displayed by default.
     */
    public void setEnablePoll(boolean enablePoll) {
        this.enablePoll = enablePoll;
    }

    /**
     * Get whether to display the group voting button
     */
    public boolean isEnablePoll() {
        return enablePoll;
    }

    /**
     *  Set whether to display the album button. it is displayed by default.
     */
    public void setEnableAlbum(boolean enableAlbum) {
        this.enableAlbum = enableAlbum;
    }

    /**
     * Get whether to display the album button
     */
    public boolean isEnableAlbum() {
        return enableAlbum;
    }

    /**
     *  Set whether to display the file button. it is displayed by default.
     */
    public void setEnableFile(boolean enableFile) {
        this.enableFile = enableFile;
    }

    /**
     * Get whether to display the file button
     */
    public boolean isEnableFile() {
        return enableFile;
    }

    /**
     *  Set whether to display the video recording button. it is displayed by default.
     */
    public void setEnableRecordVideo(boolean enableRecordVideo) {
        this.enableRecordVideo = enableRecordVideo;
    }

    /**
     * Get whether to display the video recording button
     */
    public boolean isEnableRecordVideo() {
        return enableRecordVideo;
    }

    /**
     *  Set whether to display the photo button. it is displayed by default.
     */
    public void setEnableTakePhoto(boolean enableTakePhoto) {
        this.enableTakePhoto = enableTakePhoto;
    }

    /**
     * Get whether to display the photo button
     */
    public boolean isEnableTakePhoto() {
        return enableTakePhoto;
    }

    /**
     * Get the maximum duration of the recording
     */
    public int getAudioRecordMaxTime() {
        return audioRecordMaxTime;
    }

    /**
     * Set the maximum recording time
     */
    public GeneralConfig setAudioRecordMaxTime(int audioRecordMaxTime) {
        this.audioRecordMaxTime = audioRecordMaxTime;
        return this;
    }

    /**
     * Get the maximum duration of the recording
     */
    public int getVideoRecordMaxTime() {
        return videoRecordMaxTime;
    }

    /**
     * Set the maximum recording time
     */
    public GeneralConfig setVideoRecordMaxTime(int videoRecordMaxTime) {
        this.videoRecordMaxTime = videoRecordMaxTime;
        return this;
    }

    /**
     * Whether the view read by the other party is displayed
     */
    public boolean isMsgNeedReadReceipt() {
        return msgNeedReadReceipt;
    }

    /**
     * Set whether the view read by the other party is displayed, not displayed by default
     *
     */
    public void setMsgNeedReadReceipt(boolean msgNeedReadReceipt) {
        this.msgNeedReadReceipt = msgNeedReadReceipt;
    }

    /**
     * Get whether messages are not counted as conversation unread
     */
    public boolean isExcludedFromUnreadCount() {
        return excludedFromUnreadCount;
    }

    /**
     * Set whether messages are not counted as conversation unread: false, need to be counted; true, do not need to be counted
     */
    public void setExcludedFromUnreadCount(boolean excludedFromUnreadCount) {
        this.excludedFromUnreadCount = excludedFromUnreadCount;
    }

    /**
     * Get whether the message does not count as the last message of the session
     */
    public boolean isExcludedFromLastMessage() {
        return excludedFromLastMessage;
    }

    /**
     * Set whether the message does not count as the last message of the session: false, need to be counted; true, do not need to be counted
     */
    public void setExcludedFromLastMessage(boolean excludedFromLastMessage) {
        this.excludedFromLastMessage = excludedFromLastMessage;
    }

    /**
     * Get whether the offline push notification ringtone is a custom ringtone
     */
    public boolean isEnableAndroidPrivateRing() {
        return enableAndroidPrivateRing;
    }

    /**
     * Set whether the offline push notification ringtone is a custom ringtone
     */
    public void setEnableAndroidPrivateRing(boolean ring) {
        this.enableAndroidPrivateRing = ring;
    }

    /**
     * Set whether the "Typing..." function is enabled
     */
    public void setEnableTypingStatus(boolean enableTypingStatus) {
        this.enableTypingStatus = enableTypingStatus;
    }

    /**
     * Get whether the "Typing..." function is enabled
     */
    public boolean isEnableTypingStatus() {
        return enableTypingStatus;
    }

    /**
     *  Whether to display a custom welcome message button
     */
    public boolean isEnableWelcomeCustomMessage() {
        return enableWelcomeCustomMessage;
    }

    /**
     *  Display custom welcome message button, default true
     */
    public void setEnableWelcomeCustomMessage(boolean enableWelcomeCustomMessage) {
        this.enableWelcomeCustomMessage = enableWelcomeCustomMessage;
    }

    /**
     * The time interval for message recall, in seconds, default is 120 seconds. If you want to adjust this configuration, please modify the IM console settings
     * synchronously.
     *
     * https://cloud.tencent.com/document/product/269/38656#.E6.B6.88.E6.81.AF.E6.92.A4.E5.9B.9E.E8.AE.BE.E7.BD.AE
     */
    public void setTimeIntervalForMessageRecall(int timeIntervalForMessageRecall) {
        this.timeIntervalForMessageRecall = timeIntervalForMessageRecall;
    }

    /**
     * Get the time interval for message recall, in seconds
     */
    public int getTimeIntervalForMessageRecall() {
        return timeIntervalForMessageRecall;
    }

    /**
     * Whether to use the built-in camera of the system to take photos and video
     */
    public void setUseSystemCamera(boolean useSystemCamera) {
        this.useSystemCamera = useSystemCamera;
    }

    /**
     * Obtain whether to use the system's built-in camera for the camera and video functions
     */
    public boolean isUseSystemCamera() {
        return useSystemCamera;
    }

    /**
     *  Whether the chat page displays "InputBar", the default is true
     */
    public void setEnableMainPageInputBar(boolean enableMainPageInputBar) {
        this.enableMainPageInputBar = enableMainPageInputBar;
    }

    /**
     *  Get whether to display the input box in the chat page
     */
    public boolean isEnableMainPageInputBar() {
        return enableMainPageInputBar;
    }

    /**
     * Set whether to use the speaker to play the voice message or use the earpiece to play, set it to true to use the speaker to play,
     * false to use the earpiece to play. By default, the speaker is used for playback.
     */
    public void setEnableSoundMessageSpeakerMode(boolean enableSoundMessageSpeakerMode) {
        this.enableSoundMessageSpeakerMode = enableSoundMessageSpeakerMode;
        SPUtils.getInstance(TUIChatConstants.CHAT_SETTINGS_SP_NAME).put(TUIChatConstants.CHAT_SP_KEY_SPEAKER_MODE_ON, enableSoundMessageSpeakerMode);
    }

    /**
     * Gets whether the voice message is played on the speaker. True to use the speaker, false to use the earpiece.
     */
    public boolean isEnableSoundMessageSpeakerMode() {
        return SPUtils.getInstance(TUIChatConstants.CHAT_SETTINGS_SP_NAME)
                .getBoolean(TUIChatConstants.CHAT_SP_KEY_SPEAKER_MODE_ON, enableSoundMessageSpeakerMode);
        }
}
