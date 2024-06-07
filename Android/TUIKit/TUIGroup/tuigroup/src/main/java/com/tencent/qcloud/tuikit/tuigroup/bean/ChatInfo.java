package com.tencent.qcloud.tuikit.tuigroup.bean;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;

import java.io.Serializable;
import java.util.List;

public class ChatInfo implements Serializable {
    public static final int TYPE_C2C = V2TIMConversation.V2TIM_C2C;
    public static final int TYPE_GROUP = V2TIMConversation.V2TIM_GROUP;
    public static final int TYPE_INVALID = V2TIMConversation.CONVERSATION_TYPE_INVALID;


    private String chatName;
    private int type = V2TIMConversation.V2TIM_C2C;
    private String id;
    private String groupType;
    private boolean isTopChat;
    private boolean isFolded;

    public ChatInfo() {}

    /**
     * Get the title of the chat, usually the name of the other party for a single chat, and the group name for a group chat
     *
     * @return
     */
    public String getChatName() {
        return chatName;
    }

    /**
     * Set the title of the chat, usually the name of the other party for a single chat, and the group name for a group chat
     *
     * @param chatName
     */
    public void setChatName(String chatName) {
        this.chatName = chatName;
    }

    /**
     * Get the chat type, C2C is a single chat, Group is a group chat
     *
     * @return
     */
    public int getType() {
        return type;
    }

    /**
     * Set the chat type, C2C is a single chat, Group is a group chat
     *
     * @param type
     */
    public void setType(int type) {
        this.type = type;
    }

    /**
     * Get chat id
     *
     * @return
     */
    public String getId() {
        return id;
    }

    /**
     * Set chat id
     *
     * @param id
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     * Get group type
     */
    public String getGroupType() {
        return groupType;
    }

    /**
     * Set group type
     */
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    /**
     * Is it a pinned conversation
     *
     * @return
     */
    public boolean isTopChat() {
        return isTopChat;
    }

    /**
     * Set whether the conversation is sticky
     *
     * @param topChat
     */
    public void setTopChat(boolean topChat) {
        isTopChat = topChat;
    }

    public boolean isFolded() {
        return isFolded;
    }

    public void setFolded(boolean folded) {
        isFolded = folded;
    }

}
