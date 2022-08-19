package com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces;

import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityMemberBean;

import java.util.List;

public interface ICommunityMemberList {
    void onMemberListChanged(List<CommunityMemberBean> memberBeanList, long seq);
}
