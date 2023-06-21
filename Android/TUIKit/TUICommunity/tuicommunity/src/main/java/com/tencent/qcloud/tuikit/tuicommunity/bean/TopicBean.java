package com.tencent.qcloud.tuikit.tuicommunity.bean;

import android.text.Html;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.ITopicBean;
import java.io.Serializable;
import java.util.HashMap;

public class TopicBean implements Serializable, ITopicBean {
    public static final int CHAT_TYPE_GROUP = V2TIMConversation.V2TIM_GROUP;

    public static final int TOPIC_TYPE_TEXT = 1;

    private String id;
    private String topicName;
    private String faceUrl;
    private String draftText;
    private V2TIMMessage lastMessage;
    private V2TIMTopicInfo v2TIMTopicInfo;
    private CharSequence lastMessageAbstract;
    private long unreadCount;
    private String category;
    private int type;
    private boolean isAllMute = false;

    public String getID() {
        return id;
    }

    public void setID(String id) {
        this.id = id;
    }

    public String getTopicName() {
        return topicName;
    }

    public void setTopicName(String topicName) {
        this.topicName = topicName;
    }

    public String getFaceUrl() {
        return faceUrl;
    }

    public void setFaceUrl(String faceUrl) {
        this.faceUrl = faceUrl;
    }

    public void setAllMute(boolean allMute) {
        isAllMute = allMute;
    }

    public boolean isAllMute() {
        return isAllMute;
    }

    public String getDraftText() {
        return draftText;
    }

    public void setDraftText(String draftText) {
        this.draftText = draftText;
    }

    public V2TIMMessage getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(V2TIMMessage lastMessage) {
        this.lastMessage = lastMessage;
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.V2TIMMESSAGE, lastMessage);
        String lastMsgDisplayString = (String) TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_GET_DISPLAY_STRING, param);
        // 获取要显示的字符
        // Get the characters to display
        if (lastMsgDisplayString != null) {
            lastMessageAbstract = Html.fromHtml(lastMsgDisplayString);
        }
    }

    public long getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(long unreadCount) {
        this.unreadCount = unreadCount;
    }

    public CharSequence getLastMsgAbstract() {
        return lastMessageAbstract;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getCategory() {
        return category;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getType() {
        return type;
    }

    public void setV2TIMTopicInfo(V2TIMTopicInfo v2TIMTopicInfo) {
        this.v2TIMTopicInfo = v2TIMTopicInfo;
    }

    public V2TIMTopicInfo getV2TIMTopicInfo() {
        return v2TIMTopicInfo;
    }

    @Override
    public int compareTo(ITopicBean o) {
        if (o instanceof TopicFoldBean) {
            return -1;
        }
        TopicBean topicBean = (TopicBean) o;
        return topicName.compareTo(topicBean.topicName);
    }
}
