package com.tencent.qcloud.tuikit.tuisearch.bean;

import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMMessageSearchResultItem;
import com.tencent.qcloud.tuikit.tuisearch.util.MessageInfoUtil;

import java.util.ArrayList;
import java.util.List;

public class SearchDataBeanUtil {
    public static SearchDataBean convertFriendInfo2SearchDataBean(V2TIMFriendInfoResult v2TIMFriendInfoResult) {
        if (v2TIMFriendInfoResult == null) {
            return null;
        }
        V2TIMFriendInfo friendInfo = v2TIMFriendInfoResult.getFriendInfo();
        SearchDataBean dataBean = new SearchDataBean();
        dataBean.setUserID(friendInfo.getUserID());
        dataBean.setNickName(friendInfo.getUserProfile().getNickName());
        dataBean.setRemark(friendInfo.getFriendRemark());
        dataBean.setIconPath(friendInfo.getUserProfile().getFaceUrl());
        return dataBean;
    }

    public static List<SearchDataBean> convertFriendInfos2SearchDataBeans(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
        List<SearchDataBean> searchDataBeanList = new ArrayList<>();
        for(V2TIMFriendInfoResult v2TIMFriendInfoResult : v2TIMFriendInfoResults) {
            SearchDataBean bean = convertFriendInfo2SearchDataBean(v2TIMFriendInfoResult);
            if (bean == null) {
                continue;
            }
            searchDataBeanList.add(bean);
        }
        return searchDataBeanList;
    }

    public static SearchMessageBean convertSearchResultItem2SearchMessageBean(V2TIMMessageSearchResultItem v2TIMMessageSearchResultItem) {
        if (v2TIMMessageSearchResultItem == null) {
            return null;
        }
        SearchMessageBean searchMessageBean = new SearchMessageBean();
        searchMessageBean.setConversationId(v2TIMMessageSearchResultItem.getConversationID());
        searchMessageBean.setMessageCount(v2TIMMessageSearchResultItem.getMessageCount());
        searchMessageBean.setMessageInfoList(MessageInfoUtil.convertTIMMessages2MessageInfos(v2TIMMessageSearchResultItem.getMessageList()));
        return searchMessageBean;
    }


    public static List<SearchMessageBean> convertSearchResultItems2SearchMessageBeans(List<V2TIMMessageSearchResultItem> v2TIMMessageSearchResultItems) {
        List<SearchMessageBean> searchMessageBeanList = new ArrayList<>();
        for (V2TIMMessageSearchResultItem v2TIMMessageSearchResultItem : v2TIMMessageSearchResultItems) {
            SearchMessageBean bean = convertSearchResultItem2SearchMessageBean(v2TIMMessageSearchResultItem);
            if (bean == null) {
                continue;
            }
            searchMessageBeanList.add(bean);
        }
        return searchMessageBeanList;
    }


}