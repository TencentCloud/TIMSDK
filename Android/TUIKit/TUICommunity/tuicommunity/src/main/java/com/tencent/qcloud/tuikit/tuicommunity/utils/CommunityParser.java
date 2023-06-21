package com.tencent.qcloud.tuikit.tuicommunity.utils;

import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.COMMUNITY_CUSTOM_INFO_COVER_KEY;
import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY;
import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.TOPIC_CUSTOM_STRING_TOPIC_CATEGORY_KEY;
import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.TOPIC_CUSTOM_STRING_TOPIC_TYPE_KEY;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import com.google.gson.reflect.TypeToken;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityMemberBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CommunityParser {
    private static final String TAG = "CommunityParser";

    public static CommunityBean parseCommunityGroup(V2TIMGroupInfo v2TIMGroupInfo) {
        if (v2TIMGroupInfo == null) {
            return null;
        }
        CommunityBean communityBean = new CommunityBean();

        communityBean.setGroupId(v2TIMGroupInfo.getGroupID());
        communityBean.setGroupFaceUrl(v2TIMGroupInfo.getFaceUrl());
        communityBean.setCommunityName(v2TIMGroupInfo.getGroupName());
        communityBean.setIntroduction(v2TIMGroupInfo.getIntroduction());
        communityBean.setRole(v2TIMGroupInfo.getRole());
        communityBean.setOwner(v2TIMGroupInfo.getOwner());
        communityBean.setLastMessageTime(v2TIMGroupInfo.getLastMessageTime());
        communityBean.setCreateTime(v2TIMGroupInfo.getCreateTime());
        communityBean.setJoinTime(v2TIMGroupInfo.getJoinTime());
        communityBean.setLastInfoTime(v2TIMGroupInfo.getLastInfoTime());

        Map<String, byte[]> customInfo = v2TIMGroupInfo.getCustomInfo();
        byte[] coverUrlBytes = customInfo.get(COMMUNITY_CUSTOM_INFO_COVER_KEY);
        byte[] topicCategoryBytes = customInfo.get(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY);
        String coverUrlStr = null;
        if (coverUrlBytes != null) {
            coverUrlStr = new String(coverUrlBytes);
        }
        List<String> topicCategories = null;
        if (topicCategoryBytes != null) {
            Gson gson = new Gson();
            try {
                topicCategories = gson.fromJson(new String(topicCategoryBytes), List.class);
            } catch (JsonParseException e) {
                TUICommunityLog.e(TAG, "parseCommunityGroup " + e.getMessage());
            }
        }
        communityBean.setTopicCategories(topicCategories);
        communityBean.setCoverUrl(coverUrlStr);
        return communityBean;
    }

    public static List<CommunityBean> parseCommunityGroup(List<V2TIMGroupInfo> v2TIMGroupInfoList) {
        List<CommunityBean> communityBeanList = new ArrayList<>();
        if (v2TIMGroupInfoList == null || v2TIMGroupInfoList.isEmpty()) {
            return communityBeanList;
        }

        for (V2TIMGroupInfo v2TIMGroupInfo : v2TIMGroupInfoList) {
            CommunityBean communityBean = parseCommunityGroup(v2TIMGroupInfo);
            if (communityBean != null) {
                communityBeanList.add(communityBean);
            }
        }
        return communityBeanList;
    }

    public static TopicBean parseTopicBean(V2TIMTopicInfo v2TIMTopicInfo) {
        if (v2TIMTopicInfo == null) {
            return null;
        }
        TopicBean topicBean = new TopicBean();
        topicBean.setID(v2TIMTopicInfo.getTopicID());
        topicBean.setFaceUrl(v2TIMTopicInfo.getTopicFaceUrl());
        topicBean.setTopicName(v2TIMTopicInfo.getTopicName());
        topicBean.setDraftText(v2TIMTopicInfo.getDraftText());
        topicBean.setLastMessage(v2TIMTopicInfo.getLastMessage());
        topicBean.setUnreadCount(v2TIMTopicInfo.getUnreadCount());
        topicBean.setV2TIMTopicInfo(v2TIMTopicInfo);
        topicBean.setAllMute(v2TIMTopicInfo.isAllMute());

        String customString = v2TIMTopicInfo.getCustomString();
        if (!TextUtils.isEmpty(customString)) {
            Gson gson = new Gson();
            try {
                Map<String, Object> map = gson.fromJson(customString, TypeToken.getParameterized(Map.class, String.class, Object.class).getType());
                if (map != null) {
                    Object category = map.get(TOPIC_CUSTOM_STRING_TOPIC_CATEGORY_KEY);
                    if (category instanceof String) {
                        topicBean.setCategory((String) category);
                    }
                    Object type = map.get(TOPIC_CUSTOM_STRING_TOPIC_TYPE_KEY);
                    if (type instanceof Double) {
                        topicBean.setType(((Double) type).intValue());
                    }
                }
            } catch (JsonParseException e) {
                TUICommunityLog.e(TAG, "parseTopicBean json exception: " + e.getMessage());
            }
        }
        return topicBean;
    }

    public static List<TopicBean> parseTopicBeanList(List<V2TIMTopicInfo> v2TIMTopicInfos) {
        List<TopicBean> topicBeanList = new ArrayList<>();
        if (v2TIMTopicInfos == null || v2TIMTopicInfos.isEmpty()) {
            return topicBeanList;
        }

        for (V2TIMTopicInfo v2TIMTopicInfo : v2TIMTopicInfos) {
            TopicBean topicBean = parseTopicBean(v2TIMTopicInfo);
            if (topicBean != null) {
                topicBeanList.add(topicBean);
            }
        }
        return topicBeanList;
    }

    public static CommunityMemberBean parseCommunityMemberBean(V2TIMGroupMemberInfo v2TIMGroupMemberInfo) {
        if (v2TIMGroupMemberInfo == null) {
            return null;
        }
        CommunityMemberBean communityMemberBean = new CommunityMemberBean();
        communityMemberBean.setAccount(v2TIMGroupMemberInfo.getUserID());
        communityMemberBean.setAvatar(v2TIMGroupMemberInfo.getFaceUrl());
        communityMemberBean.setNameCard(v2TIMGroupMemberInfo.getNameCard());
        communityMemberBean.setNickName(v2TIMGroupMemberInfo.getNickName());
        communityMemberBean.setFriendRemark(v2TIMGroupMemberInfo.getFriendRemark());

        return communityMemberBean;
    }

    public static List<CommunityMemberBean> parseCommunityMemberBeanList(List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberInfos) {
        List<CommunityMemberBean> communityMemberBeans = new ArrayList<>();
        if (v2TIMGroupMemberInfos == null || v2TIMGroupMemberInfos.isEmpty()) {
            return communityMemberBeans;
        }

        for (V2TIMGroupMemberFullInfo v2TIMGroupMemberInfo : v2TIMGroupMemberInfos) {
            CommunityMemberBean communityMemberBean = parseCommunityMemberBean(v2TIMGroupMemberInfo);
            if (communityMemberBean != null) {
                communityMemberBeans.add(communityMemberBean);
            }
        }
        return communityMemberBeans;
    }
}
