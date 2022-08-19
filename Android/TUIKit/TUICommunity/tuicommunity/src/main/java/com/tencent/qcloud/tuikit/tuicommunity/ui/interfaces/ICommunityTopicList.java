package com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces;

import com.tencent.qcloud.tuikit.tuicommunity.bean.TreeNode;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.ITopicBean;

import java.util.List;

public interface ICommunityTopicList {
    void onTopicListChanged(List<TreeNode<ITopicBean>> newData, List<TreeNode<ITopicBean>> oldData);
}
