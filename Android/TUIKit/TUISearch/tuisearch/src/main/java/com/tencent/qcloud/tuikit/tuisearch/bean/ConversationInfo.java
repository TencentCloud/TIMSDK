package com.tencent.qcloud.tuikit.tuisearch.bean;

import androidx.annotation.NonNull;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ConversationInfo implements Serializable, Comparable<ConversationInfo> {
    public static final int TYPE_COMMON = 1;
    public static final int TYPE_CUSTOM = 2;

    public static final int TYPE_FORWAR_SELECT = 3;
    public static final int TYPE_RECENT_LABEL = 4;
    /**
     * 会话类型，自定义会话or普通会话
     *
     * conversation type
     */
    private int type;

    /**
     * 消息未读数
     *
     * unread message number
     */
    private int unRead;
    /**
     * 会话ID
     *
     * conversation ID
     */
    private String conversationId;
    /**
     * 会话标识，C2C为对方用户ID，群聊为群组ID
     *
     * ID, C2C is UserID, Group is group ID
     */
    private String id;
    /**
     * 会话头像url
     *
     * conversation avatar url
     */
    private List<Object> iconUrlList = new ArrayList<>();

    public List<Object> getIconUrlList() {
        return iconUrlList;
    }

    public void setIconUrlList(List<Object> iconUrlList) {
        this.iconUrlList = iconUrlList;
    }

    private String title;
    private String iconPath;
    private boolean isGroup;
    private boolean top;
    private long lastMessageTime;
    private MessageInfo lastMessage;

    /**
     * 会话界面显示的@提示消息
     *
     * "@" message in group
     */
    private String atInfoText;

    /**
     * 会话界面显示消息免打扰图标
     *
     * the conversation item displays the icon of Do Not Disturb
     */
    private boolean showDisturbIcon;

    private DraftInfo draft;
    private String groupType;

    /**
     * 会话排序键值
     *
     * conversation sort key
     */
    private long orderKey;

    public ConversationInfo() {}

    public String getConversationId() {
        return conversationId;
    }

    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getUnRead() {
        return unRead;
    }

    public void setUnRead(int unRead) {
        this.unRead = unRead;
    }

    public boolean isGroup() {
        return isGroup;
    }

    public void setGroup(boolean group) {
        isGroup = group;
    }

    public boolean isTop() {
        return top;
    }

    public void setTop(boolean top) {
        this.top = top;
    }

    /**
     * 获得最后一条消息的时间，单位是秒
     *
     * Get the time of the last message, in seconds
     */
    public long getLastMessageTime() {
        return lastMessageTime;
    }

    /**
     * 设置最后一条消息的时间，单位是秒
     *
     * Set the time to the last message, in seconds
     * @param lastMessageTime
     */
    public void setLastMessageTime(long lastMessageTime) {
        this.lastMessageTime = lastMessageTime;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public MessageInfo getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(MessageInfo lastMessage) {
        this.lastMessage = lastMessage;
    }

    public void setAtInfoText(String atInfoText) {
        this.atInfoText = atInfoText;
    }

    public String getAtInfoText() {
        return atInfoText;
    }

    public boolean isShowDisturbIcon() {
        return showDisturbIcon;
    }

    public void setShowDisturbIcon(boolean showDisturbIcon) {
        this.showDisturbIcon = showDisturbIcon;
    }

    public void setDraft(DraftInfo draft) {
        this.draft = draft;
    }

    public DraftInfo getDraft() {
        return this.draft;
    }

    public String getGroupType() {
        return groupType;
    }

    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    public String getIconPath() {
        return iconPath;
    }

    public void setIconPath(String iconPath) {
        this.iconPath = iconPath;
    }

    public void setOrderKey(long orderKey) {
        this.orderKey = orderKey;
    }

    public long getOrderKey() {
        return orderKey;
    }

    @Override
    public int compareTo(@NonNull ConversationInfo other) {
        long thisOrderKey = this.orderKey;
        long otherOrderKey = other.orderKey;
        if (thisOrderKey > otherOrderKey) {
            return -1;
        } else if (thisOrderKey == otherOrderKey) {
            return 0;
        } else {
            return 1;
        }
    }

    @Override
    public String toString() {
        return "ConversationInfo{"
            + "type=" + type + ", unRead=" + unRead + ", conversationId='" + conversationId + '\'' + ", id='" + id + '\'' + ", iconUrl='" + iconUrlList.size()
            + '\'' + ", title='" + title + '\'' + ", iconPath=" + iconPath + ", isGroup=" + isGroup + ", top=" + top + ", lastMessageTime=" + lastMessageTime
            + ", lastMessage=" + lastMessage + ", draftText=" + draft + ", groupType=" + groupType + '}';
    }
}
