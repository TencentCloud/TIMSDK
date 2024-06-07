package com.tencent.qcloud.tuikit.tuicontact.bean;

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

    private String title;
    private String iconPath;
    private boolean isGroup;
    private boolean top;
    private long lastMessageTime;

    /**
     * "@" message in group
     */
    private String atInfoText;

    /**
     * the conversation item displays the icon of Do Not Disturb
     */
    private boolean showDisturbIcon;

    private String groupType;

    /**
     * conversation sort key
     */
    private long orderKey;

    public ConversationInfo() {}

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

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getGroupType() {
        return groupType;
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
            + ", groupType=" + groupType + '}';
    }
}
