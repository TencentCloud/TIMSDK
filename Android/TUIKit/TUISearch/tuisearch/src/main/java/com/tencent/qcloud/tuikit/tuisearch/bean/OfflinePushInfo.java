package com.tencent.qcloud.tuikit.tuisearch.bean;

import com.tencent.imsdk.message.MessageOfflinePushInfo;

import java.io.Serializable;

public class OfflinePushInfo implements Serializable{

    public static final String IOS_OFFLINE_PUSH_NO_SOUND = "push.no_sound";
    public static final String IOS_OFFLINE_PUSH_DEFAULT_SOUND = "default";

    private String title;
    private String description;
    private byte[] extension;
    private String soundFilePath;
    private int pushFlag;
    private int badgeMode;
    private int notifyMode;
    private String oppoChannelID;
    private int vivoClassification = 1;

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

    public String getSoundFilePath() {
        return soundFilePath;
    }

    public void setSoundFilePath(String soundFilePath) {
        this.soundFilePath = soundFilePath;
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


    /**
     * 是否关闭推送（默认开启推送）。
     *
     * @param disable true：关闭；false：打开
     * 
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
     * 获取是否关闭离线推送状态。
     *
     * @return 关闭状态。true：关闭；false：打开
     * 
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
     * 离线推送声音设置（仅对 iOS 生效）。
     * 当 sound = IOS_OFFLINE_PUSH_NO_SOUND，表示接收时不会播放声音。
     * 当 sound = IOS_OFFLINE_PUSH_DEFAULT_SOUND，表示接收时播放系统声音。
     * 如果要自定义 iOSSound，需要先把语音文件链接进 Xcode 工程，然后把语音文件名（带后缀）设置给 iOSSound。
     *
     * @param sound iOS 声音路径
     * 
     * 
     * Offline push sound setting (valid only for iOS)
     * When sound is IOS_OFFLINE_PUSH_NO_SOUND, no sound is played when a message is received.
     * When sound is IOS_OFFLINE_PUSH_DEFAULT_SOUND, the system alert sound is played when a message is received.
     * To customize iOSSound, link the audio file to the Xcode project and set iOSSound to the audio filename (with the extension name).
     *
     * @param sound iOS    Sound path
     */
    public void setIOSSound(String sound) {
        setSoundFilePath(sound);
    }

    /**
     * 离线推送忽略 badge 计数（仅对 iOS 生效），
     * 如果设置为 true，在 iOS 接收端，这条消息不会使 APP 的应用图标未读计数增加。
     *
     * @param ignoreIOSBadge iOS 应用图标未读计数状态。true：忽略；false：开启
     * 
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
     * 离线推送设置 OPPO 手机 8.0 系统及以上的渠道 ID。
     *
     * @param channelID OPPO 手机的渠道 ID
     * 
     * 
     * Offline push channel ID for OPPO phones that run Android 8.0 or later
     *
     * @param channelID    OPPO phone channel ID
     */
    public void setAndroidOPPOChannelID(String channelID) {
        setOppoChannelID(channelID);
    }

    /**
     * 离线推送设置 VIVO 手机
     *
     * @param classification VIVO 手机离线推送消息分类，0：运营消息 1：系统消息，默认取值为 1
     * 
     * 
     * Offline push setting for vivo phones
     *
     * @param classification   Offline push message classification for vivo phones. 0: operation message; 1: system message. The default value is 1.
     */
    public void setAndroidVIVOClassification(int classification) {
        setVivoClassification(classification);
    }

}
