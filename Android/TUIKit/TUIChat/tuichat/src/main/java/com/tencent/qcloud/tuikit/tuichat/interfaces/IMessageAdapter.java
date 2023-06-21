package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

import java.util.List;

public interface IMessageAdapter {
    void onDataSourceChanged(List<TUIMessageBean> dataSource);

    void onViewNeedRefresh(int type, int value);

    void onViewNeedRefresh(int type, TUIMessageBean locateMessage);

    void onScrollToEnd();
}
