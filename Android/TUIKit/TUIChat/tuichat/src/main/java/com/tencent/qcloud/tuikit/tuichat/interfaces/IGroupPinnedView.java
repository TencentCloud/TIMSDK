package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

import java.util.List;

public interface IGroupPinnedView {
    void onPinnedListChanged(List<TUIMessageBean> pinnedMessages);
}
