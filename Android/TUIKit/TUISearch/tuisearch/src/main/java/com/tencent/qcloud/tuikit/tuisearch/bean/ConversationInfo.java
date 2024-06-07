package com.tencent.qcloud.tuikit.tuisearch.bean;

import androidx.annotation.NonNull;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ConversationInfo implements Serializable, Comparable<ConversationInfo> {

    /**
     * conversation type
     */
    private int type;

    /**
     * unread message number
     */
    private int unRead;
    /**
     * conversation ID
     */
    private String conversationId;
    /**
     * ID, C2C is UserID, Group is group ID
     */
    private String id;
    /**
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
     * "@" message in group
     */
    private String atInfoText;

    /**
     * the conversation item displays the icon of Do Not Disturb
     */
    private boolean showDisturbIcon;

    private DraftInfo draft;
    private String groupType;

    /**
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
     * Get the time of the last message, in seconds
     */
    public long getLastMessageTime() {
        return lastMessageTime;
    }

    /**
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
