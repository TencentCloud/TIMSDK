package com.tencent.qcloud.tuikit.tuisearch.bean;

import java.util.List;

public class SearchMessageBean {
    private String conversationId;
    private int messageCount;
    private List<MessageInfo> messageInfoList;

    public void setMessageCount(int messageCount) {
        this.messageCount = messageCount;
    }

    public void setMessageInfoList(List<MessageInfo> messageInfoList) {
        this.messageInfoList = messageInfoList;
    }

    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }

    public int getMessageCount() {
        return messageCount;
    }

    public List<MessageInfo> getMessageInfoList() {
        return messageInfoList;
    }

    public String getConversationId() {
        return conversationId;
    }
}
