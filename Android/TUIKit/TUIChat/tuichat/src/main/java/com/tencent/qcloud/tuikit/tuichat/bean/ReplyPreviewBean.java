package com.tencent.qcloud.tuikit.tuichat.bean;

import android.text.TextUtils;

import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.io.Serializable;

public class ReplyPreviewBean implements Serializable {

    public static final int VERSION = 1;

    private String messageID;
    private String messageRootID;
    private String messageAbstract;
    private String messageSender;
    private int messageType;
    private long messageTime;
    private long messageSequence;

    private int version = VERSION;

    private transient TUIMessageBean originalMessageBean;

    public String getMessageID() {
        return messageID;
    }

    public void setMessageID(String messageID) {
        this.messageID = messageID;
    }

    public String getMessageAbstract() {
        return messageAbstract;
    }

    public void setMessageAbstract(String messageAbstract) {
        this.messageAbstract = messageAbstract;
    }

    public String getMessageSender() {
        return messageSender;
    }

    public void setMessageSender(String messageSender) {
        this.messageSender = messageSender;
    }

    public int getMessageType() {
        return messageType;
    }

    public void setMessageType(int messageType) {
        this.messageType = messageType;
    }

    public TUIMessageBean getOriginalMessageBean() {
        return originalMessageBean;
    }

    public void setOriginalMessageBean(TUIMessageBean originalMessageBean) {
        this.originalMessageBean = originalMessageBean;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public int getVersion() {
        return version;
    }

    public long getMessageSequence() {
        return messageSequence;
    }

    public long getMessageTime() {
        return messageTime;
    }

    public void setMessageSequence(long messageSequence) {
        this.messageSequence = messageSequence;
    }

    public void setMessageTime(long messageTime) {
        this.messageTime = messageTime;
    }

    public String getMessageRootID() {
        return messageRootID;
    }

    public void setMessageRootID(String messageRootID) {
        this.messageRootID = messageRootID;
    }

    /**
     * @return true if it's replayMessage, or false it's quoteMessage
     */
    public boolean isReplyMessage() {
        return !TextUtils.isEmpty(messageRootID);
    }
}
