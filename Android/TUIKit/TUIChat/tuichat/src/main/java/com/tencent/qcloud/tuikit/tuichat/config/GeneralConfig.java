package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;

public class GeneralConfig {
    public static final int DEFAULT_AUDIO_RECORD_MAX_TIME = 60;
    public static final int DEFAULT_VIDEO_RECORD_MAX_TIME = 15;
    public static final int FILE_MAX_SIZE = 100 * 1024 * 1024;
    public static final int VIDEO_MAX_SIZE = 100 * 1024 * 1024;
    public static final int IMAGE_MAX_SIZE = 28 * 1024 * 1024;
    public static final int GIF_IMAGE_MAX_SIZE = 10 * 1024 * 1024;

    private int audioRecordMaxTime = DEFAULT_AUDIO_RECORD_MAX_TIME;
    private int videoRecordMaxTime = DEFAULT_VIDEO_RECORD_MAX_TIME;

    private boolean excludedFromUnreadCount;
    private boolean excludedFromLastMessage;
    private boolean enableAndroidPrivateRing;
    private boolean msgNeedReadReceipt = false;
    private boolean enableGroupChatPinMessage = true;
    private boolean enableFloatWindowForCall = true;
    private boolean enableMultiDeviceForCall = false;
    private boolean enableIncomingBanner = true;
    private boolean enableVirtualBackgroundForCall = false;

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
     * Set whether to enable incoming banner when user received audio and video calls, default is false
     */
    public void setEnableIncomingBanner(boolean enableIncomingBanner) {
        this.enableIncomingBanner = enableIncomingBanner;
    }

    /**
     * Obtain whether to enable the audio and video calls incoming banner
     */
    public boolean isEnableIncomingBanner() {
        return enableIncomingBanner;
    }

    /**
     * Set whether to enable the virtual background for audio and video calls, default value is false
     */
    public void setEnableVirtualBackgroundForCall(boolean enableVirtualBackgroundForCall) {
        this.enableVirtualBackgroundForCall = enableVirtualBackgroundForCall;
    }

    /**
     * Obtain whether to enable the virtual background for audio and video calls
     */
    public boolean isEnableVirtualBackgroundForCall() {
        return enableVirtualBackgroundForCall;
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

    public void setEnableGroupChatPinMessage(boolean enableGroupChatPinMessage) {
        this.enableGroupChatPinMessage = enableGroupChatPinMessage;
    }

    public boolean isEnableGroupChatPinMessage() {
        return enableGroupChatPinMessage;
    }
}
