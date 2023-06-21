package com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces;

import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;

import java.util.List;

public interface ICommunityGroupIconList {
    void onJoinedCommunityChanged(List<CommunityBean> communityBeanList);

    void onItemRangeChanged(int index, int count);

    void onItemInserted(int index);

    void onItemChanged(int index);

    void onItemRemoved(int index);
}
