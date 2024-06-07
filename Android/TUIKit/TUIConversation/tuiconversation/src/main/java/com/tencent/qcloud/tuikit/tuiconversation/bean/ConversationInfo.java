package com.tencent.qcloud.tuikit.tuiconversation.bean;

import androidx.annotation.NonNull;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ConversationInfo implements Serializable, Comparable<ConversationInfo> {
    public static final int TYPE_COMMON = 1;
    public static final int TYPE_CUSTOM = 2;

    public static final int TYPE_FORWAR_SELECT = 3;
    public static final int TYPE_RECENT_LABEL = 4;

    public static final int AT_TYPE_AT_ME = V2TIMGroupAtInfo.TIM_AT_ME;
    public static final int AT_TYPE_AT_ALL = V2TIMGroupAtInfo.TIM_AT_ALL;
    public static final int AT_TYPE_AT_ALL_AND_ME = V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME;
    public static final int AT_TYPE_UNKNOWN = V2TIMGroupAtInfo.TIM_AT_UNKNOWN;

    public static final int USER_STATUS_UNKNOWN = V2TIMUserStatus.V2TIM_USER_STATUS_UNKNOWN;
    public static final int USER_STATUS_ONLINE = V2TIMUserStatus.V2TIM_USER_STATUS_ONLINE;

    public static final int LAST_MSG_STATUS_UNKNOWN = 0;
    public static final int LAST_MSG_STATUS_SENDING = V2TIMMessage.V2TIM_MSG_STATUS_SENDING;
    public static final int LAST_MSG_STATUS_SEND_FAIL = V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL;
    public static final int LAST_MSG_STATUS_HAS_DELETED = V2TIMMessage.V2TIM_MSG_STATUS_HAS_DELETED;
    public static final int LAST_MSG_STATUS_LOCAL_IMPORTED = V2TIMMessage.V2TIM_MSG_STATUS_LOCAL_IMPORTED;
    public static final int LAST_MSG_STATUS_LOCAL_REVOKED = V2TIMMessage.V2TIM_MSG_STATUS_LOCAL_REVOKED;

    /**
     * conversation type
     */
    private int type;

    private int atType = AT_TYPE_UNKNOWN;

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

    private int statusType = USER_STATUS_UNKNOWN;

    private V2TIMConversation conversation;

    private List<Object> iconUrlList = new ArrayList<>();

    public List<Object> getIconUrlList() {
        return iconUrlList;
    }

    public void setIconUrlList(List<Object> iconUrlList) {
        this.iconUrlList = iconUrlList;
    }

    public V2TIMConversation getConversation() {
        return conversation;
    }

    public void setConversation(V2TIMConversation conversation) {
        this.conversation = conversation;
    }

    public String getShowName() {
        if (conversation != null) {
            return conversation.getShowName();
        }
        return null;
    }

    private String title;
    private String iconPath;
    private boolean isGroup;
    private boolean top;
    /**
     *  Is folded conversation or not
     */
    private boolean isMarkFold;
    /**
     *  Is marked conversation unread or not
     */
    private boolean isMarkUnread;
    /**
     *  Is marked conversation hidden or not
     */
    private boolean isMarkHidden;
    /**
     *  Is marked conversation local-unread or not
     */
    private boolean isMarkLocalUnread;

    private boolean isMarkStar;

    private long lastMessageTime;
    private V2TIMMessage lastMessage;

    private TUIMessageBean lastTUIMessageBean;

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

    public boolean isMarkFold() {
        return isMarkFold;
    }

    public void setMarkFold(boolean markFold) {
        isMarkFold = markFold;
    }

    public boolean isMarkUnread() {
        return isMarkUnread;
    }

    public void setMarkUnread(boolean markUnread) {
        isMarkUnread = markUnread;
    }

    public boolean isMarkHidden() {
        return isMarkHidden;
    }

    public void setMarkHidden(boolean markHidden) {
        isMarkHidden = markHidden;
    }

    public boolean isMarkLocalUnread() {
        return isMarkLocalUnread;
    }

    public void setMarkLocalUnread(boolean markLocalUnread) {
        isMarkLocalUnread = markLocalUnread;
    }

    public boolean isMarkStar() {
        return isMarkStar;
    }

    public void setMarkStar(boolean markStar) {
        isMarkStar = markStar;
    }

    public List<Long> getMarkList() {
        if (conversation == null) {
            return null;
        }
        return conversation.getMarkList();
    }

    /**
     * Get the time of the last message, in seconds
     */
    public long getLastMessageTime() {
        return lastMessageTime;
    }

    /**
     * Set the time of the last message, in seconds
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

    public void setAtType(int atType) {
        this.atType = atType;
    }

    public int getAtType() {
        return atType;
    }

    public V2TIMMessage getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(V2TIMMessage lastMessage) {
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

    public List<V2TIMGroupAtInfo> getGroupAtInfoList() {
        if (conversation != null) {
            return conversation.getGroupAtInfoList();
        }

        return null;
    }

    public int getStatusType() {
        return statusType;
    }

    public void setStatusType(int statusType) {
        this.statusType = statusType;
    }

    public List<String> getConversationGroupList() {
        if (conversation != null) {
            return conversation.getConversationGroupList();
        }

        return null;
    }

    public int getLastMessageStatus() {
        if (conversation != null) {
            if (conversation.getLastMessage() != null) {
                return conversation.getLastMessage().getStatus();
            }
        }
        return LAST_MSG_STATUS_UNKNOWN;
    }

    public TUIMessageBean getLastTUIMessageBean() {
        return lastTUIMessageBean;
    }

    public void setLastTUIMessageBean(TUIMessageBean lastTUIMessageBean) {
        this.lastTUIMessageBean = lastTUIMessageBean;
    }

    @Override
    public int compareTo(@NonNull ConversationInfo other) {
        if (this.isTop() && !other.isTop()) {
            return -1;
        } else if (!this.isTop() && other.isTop()) {
            return 1;
        } else {
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
    }

    @Override
    public String toString() {
        return "ConversationInfo{"
            + "type=" + type + ", unRead=" + unRead + ", conversationId='" + conversationId + '\'' + ", id='" + id + '\'' + ", iconUrl='" + iconUrlList.size()
            + '\'' + ", title='" + title + '\'' + ", iconPath=" + iconPath + ", isGroup=" + isGroup + ", top=" + top + ", lastMessageTime=" + lastMessageTime
            + ", lastMessage=" + lastMessage + ", draftText=" + draft + ", groupType=" + groupType + ", statusType=" + statusType + '}';
    }
}
