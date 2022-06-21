package com.tencent.qcloud.tuikit.tuichat.bean;

import android.text.TextUtils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class MessageRepliesBean implements Serializable {
    public static final int VERSION = 1;

    public static class ReplyBean implements Serializable {
        private String messageID;
        private String messageAbstract;
        private String messageSender;

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
    }

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
}
