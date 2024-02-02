package com.tencent.qcloud.tuikit.tuiemojiplugin.bean;

import java.util.LinkedHashMap;
import java.util.Map;

public class MessageReactionBean {
    private String messageID;
    private final Map<String, ReactionBean> reactionBeanMap = new LinkedHashMap<>();

    public void setMessageID(String messageID) {
        this.messageID = messageID;
    }

    public String getMessageID() {
        return messageID;
    }

    public void setMessageReactionBeanMap(Map<String, ReactionBean> reactionBeanMap) {
        this.reactionBeanMap.clear();
        this.reactionBeanMap.putAll(reactionBeanMap);
    }

    public Map<String, ReactionBean> getMessageReactionBeanMap() {
        return reactionBeanMap;
    }

    public ReactionBean getReactionBean(String reactionID) {
        return reactionBeanMap.get(reactionID);
    }

    public int getReactionCount() {
        if (reactionBeanMap.isEmpty()) {
            return 0;
        }
        return reactionBeanMap.size();
    }
}
