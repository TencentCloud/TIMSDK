package com.tencent.qcloud.tuikit.tuichat.ui.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;

import java.util.List;

public interface IMessageAdapter {
    void onDataSourceChanged(List<MessageInfo> dataSource);
    void onViewNeedRefresh(int type, int value);
    void onViewNeedRefresh(int type, MessageInfo locateMessage);
    void onScrollToEnd();
}
