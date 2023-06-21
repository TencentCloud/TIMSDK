package com.tencent.qcloud.tuikit.tuicontact.bean;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;

import java.io.Serializable;
import java.util.List;

public class ChatInfo implements Serializable {
    public static final int TYPE_C2C = V2TIMConversation.V2TIM_C2C;
    public static final int TYPE_GROUP = V2TIMConversation.V2TIM_GROUP;
    public static final int TYPE_INVALID = V2TIMConversation.CONVERSATION_TYPE_INVALID;

    private static List<V2TIMGroupAtInfo> atInfoList;

    private String chatName;
    private int type = V2TIMConversation.V2TIM_C2C;
    private String id;
    private String groupType;
    private boolean isTopChat;

    public ChatInfo() {}

    /**
     * 获取聊天的标题，单聊一般为对方名称，群聊为群名字
     *
     * Get the title of the chat, usually the name of the other party for a single chat, and the group name for a group chat
     *
     * @return
     */
    public String getChatName() {
        return chatName;
    }

    /**
     * 设置聊天的标题，单聊一般为对方名称，群聊为群名字
     *
     * Set the title of the chat, usually the name of the other party for a single chat, and the group name for a group chat
     *
     * @param chatName
     */
    public void setChatName(String chatName) {
        this.chatName = chatName;
    }

    /**
     * 获取聊天类型，C2C为单聊，Group为群聊
     *
     * Get the chat type, C2C is a single chat, Group is a group chat
     *
     * @return
     */
    public int getType() {
        return type;
    }

    /**
     * 设置聊天类型，C2C为单聊，Group为群聊
     *
     * Set the chat type, C2C is a single chat, Group is a group chat
     *
     * @param type
     */
    public void setType(int type) {
        this.type = type;
    }

    /**
     * 获取聊天唯一标识
     *
     * Get chat unique ID
     *
     * @return
     */
    public String getId() {
        return id;
    }

    /**
     * 设置聊天唯一标识
     *
     * Set chat unique ID
     *
     * @param id
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     * 获取群组类型
     *
     * Get the group type
     */
    public String getGroupType() {
        return groupType;
    }

    /**
     * 设置群组类型
     *
     * Set the group type
     */
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    /**
     * 是否为置顶的会话
     *
     * Is it a pinned conversation
     *
     * @return
     */
    public boolean isTopChat() {
        return isTopChat;
    }

    /**
     * 设置会话是否置顶
     *
     * Set as a pinned conversation
     *
     * @param topChat
     */
    public void setTopChat(boolean topChat) {
        isTopChat = topChat;
    }

    public List<V2TIMGroupAtInfo> getAtInfoList() {
        return atInfoList;
    }
}
