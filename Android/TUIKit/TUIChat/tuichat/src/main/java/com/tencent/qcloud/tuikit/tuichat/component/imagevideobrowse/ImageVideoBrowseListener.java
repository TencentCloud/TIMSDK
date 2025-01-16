package com.tencent.qcloud.tuikit.tuichat.component.imagevideobrowse;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

import java.util.List;

public interface ImageVideoBrowseListener {

    void onMessageHasRiskContent(TUIMessageBean messageBean);

    void onCurrentMessageHasRiskContent(TUIMessageBean messageBean);

    void onDataChanged(TUIMessageBean messageBean);

    void setDataSource(List<TUIMessageBean> messageBeans);

    void onDataSourceInserted(int position, int count);

    void onDataSourceChanged();

    void setCurrentItem(int position);
}
