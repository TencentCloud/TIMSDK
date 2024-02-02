package com.tencent.qcloud.tuikit.timcommon.bean;

import android.text.TextUtils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class MessageRepliesBean implements Serializable {
    public static final int VERSION = 1;
    private List<ReplyBean> replies;
    private int version = VERSION;

    public void addReplyMessage(String messageId, String messageAbstract, String sender) {
        if (replies == null) {
            replies = new ArrayList<>();
        }
        for (ReplyBean replyBean : replies) {
            if (TextUtils.equals(replyBean.messageID, messageId)) {
                return;
            }
        }
        ReplyBean replyBean = new ReplyBean();
        replyBean.messageID = messageId;
        replyBean.messageAbstract = messageAbstract;
        replyBean.messageSender = sender;
        replies.add(replyBean);
    }

    public void removeReplyMessage(String messageID) {
        if (replies == null) {
            return;
        }
        for (ReplyBean replyBean : replies) {
            if (TextUtils.equals(replyBean.messageID, messageID)) {
                replies.remove(replyBean);
                return;
            }
        }
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public int getVersion() {
        return version;
    }

    public List<ReplyBean> getReplies() {
        return replies;
    }

    public void setReplies(List<ReplyBean> replies) {
        this.replies = replies;
    }

    public int getRepliesSize() {
        if (replies != null) {
            return replies.size();
        }
        return 0;
    }


    public static class ReplyBean implements Serializable {
        private String messageID;
        private String messageAbstract;
        private String messageSender;
        private transient String senderFaceUrl;
        private transient String senderShowName;

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

        public void setSenderFaceUrl(String senderFaceUrl) {
            this.senderFaceUrl = senderFaceUrl;
        }

        public String getSenderFaceUrl() {
            return senderFaceUrl;
        }

        public void setSenderShowName(String senderShowName) {
            this.senderShowName = senderShowName;
        }

        public String getSenderShowName() {
            if (TextUtils.isEmpty(senderShowName)) {
                return messageSender;
            }
            return senderShowName;
        }
    }

}
