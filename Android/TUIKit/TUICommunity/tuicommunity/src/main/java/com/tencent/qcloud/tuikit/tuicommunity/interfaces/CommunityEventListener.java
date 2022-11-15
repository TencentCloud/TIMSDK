package com.tencent.qcloud.tuikit.tuicommunity.interfaces;

import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityChangeBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;

import java.util.List;
import java.util.Map;

public abstract class CommunityEventListener {
    public void onCommunityCreated(String groupID) {}
    public void onCommunityDeleted(String groupID) {}
    public void onTopicCreated(String groupID, String topicID) {}
    public void onTopicDeleted(String groupID, List<String> topicIDs) {}
    public void onTopicChanged(String groupID, TopicBean topicBean) {}
    public void onGroupAttrChanged(String groupID, Map<String, String> groupAttributeMap) {}
    public void onCommunityInfoChanged(String groupID, List<CommunityChangeBean> communityChangeBeans) {}
    public void onJoinedCommunity(String groupID) {}
    public void onCommunityExperienceChanged(String experienceName) {}
    public void onNetworkStateChanged(int state) {}
    public void onSelfFaceChanged(String newFaceUrl) {}
}
