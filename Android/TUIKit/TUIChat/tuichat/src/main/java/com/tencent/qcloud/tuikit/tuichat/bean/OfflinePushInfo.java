package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.message.MessageOfflinePushInfo;

import java.io.Serializable;

public class OfflinePushInfo implements Serializable {

    private String title;
    private String description;
    private byte[] extension;
    private String iosSoundFilePath;
    private int pushFlag;
    private int badgeMode;
    private int notifyMode;
    private String oppoChannelID;
    private int vivoClassification = 1;
    private String androidSoundFilePath;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public byte[] getExtension() {
        return extension;
    }

    public void setExtension(byte[] extension) {
        this.extension = extension;
    }

    public String getIOSSoundFilePath() {
        return iosSoundFilePath;
    }

    public int getPushFlag() {
        return pushFlag;
    }

    public void setPushFlag(int pushFlag) {
        this.pushFlag = pushFlag;
    }

    public int getBadgeMode() {
        return badgeMode;
    }

    public void setBadgeMode(int badgeMode) {
        this.badgeMode = badgeMode;
    }

    public int getNotifyMode() {
        return notifyMode;
    }

    public void setNotifyMode(int notifyMode) {
        this.notifyMode = notifyMode;
    }

    public String getOppoChannelID() {
        return oppoChannelID;
    }

    public void setOppoChannelID(String oppoChannelID) {
        this.oppoChannelID = oppoChannelID;
    }

    public int getVivoClassification() {
        return vivoClassification;
    }

    public void setVivoClassification(int vivoClassification) {
        this.vivoClassification = vivoClassification;
    }

    public String getAndroidSound() {
        return androidSoundFilePath;
    }

    /**
     *
     * Whether to disable push (push enabled by default)
     *
     * @param disable   true: disable; false: enable
     */
    public void disablePush(boolean disable) {
        if (disable) {
            setPushFlag(MessageOfflinePushInfo.OFFLINE_PUSH_FLAG_NO_PUSH);
        } else {
            setPushFlag(MessageOfflinePushInfo.OFFLINE_PUSH_FLAG_DEFAULT);
        }
    }

    /**
     *
     * Get the offline push disablement status
     *
     * @return Disabled. true: disabled; false: enabled
     */
    public boolean isDisablePush() {
        if (getPushFlag() == MessageOfflinePushInfo.OFFLINE_PUSH_FLAG_NO_PUSH) {
            return true;
        } else {
            return false;
        }
    }

    /**
     *
     * Offline push sound setting (valid only for iOS)
     * When sound is IOS_OFFLINE_PUSH_NO_SOUND, no sound is played when a message is received.
     * When sound is IOS_OFFLINE_PUSH_DEFAULT_SOUND, the system alert sound is played when a message is received.
     * To customize iOSSound, link the audio file to the Xcode project and set iOSSound to the audio filename (with the extension name).
     *
     * @param sound iOS    Sound path
     */
    public void setIOSSound(String sound) {
        this.iosSoundFilePath = sound;
    }

    /**
     *
     * Offline push sound setting (valid only for Android, supported only in imsdk 6.1 and later versions)
     * Only Huawei and Google phones support setting ringtone. And Xiaomi needs refer to https://dev.mi.com/console/doc/detail?pId=1278%23_3_0 .
     *
     * @param sound: The ringtone file name in the raw directory of the Android project, no suffix is required.
     */
    public void setAndroidSound(String sound) {
        this.androidSoundFilePath = sound;
    }

    /**
     *
     * Whether to ignore the badge count for offline push (valid only for iOS)
     * If this parameter is set to true, the unread message count on the app badge will not increase when the message is received by the iOS device.
     *
     * @param ignoreIOSBadge iOS   Status of the unread message count on the app badge. true: ignore; false: enable
     */
    public void setIgnoreIOSBadge(boolean ignoreIOSBadge) {
        if (ignoreIOSBadge) {
            setBadgeMode(MessageOfflinePushInfo.OFFLINE_APNS_BADGE_MODE_IGNORE);
        } else {
            setBadgeMode(MessageOfflinePushInfo.OFFLINE_APNS_BADGE_MODE_DEFAULT);
        }
    }

    public boolean isIgnoreIOSBadge() {
        return badgeMode == MessageOfflinePushInfo.OFFLINE_APNS_BADGE_MODE_IGNORE;
    }

    /**
     *
     * Offline push channel ID for OPPO phones that run Android 8.0 or later
     *
     * @param channelID    OPPO phone channel ID
     */
    public void setAndroidOPPOChannelID(String channelID) {
        setOppoChannelID(channelID);
    }

    /**
     *
     * Offline push setting for vivo phones
     *
     * @param classification   Offline push message classification for vivo phones. 0: operation message; 1: system message. The default value is 1.
     */
    public void setAndroidVIVOClassification(int classification) {
        setVivoClassification(classification);
    }
}
