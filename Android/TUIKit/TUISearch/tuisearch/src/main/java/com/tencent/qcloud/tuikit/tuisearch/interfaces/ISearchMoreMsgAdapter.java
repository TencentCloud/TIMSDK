package com.tencent.qcloud.tuikit.tuisearch.interfaces;

import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;

import java.util.List;

public interface ISearchMoreMsgAdapter {
    void onDataSourceChanged(List<SearchDataBean> searchDataBeanList);

    void onTotalCountChanged(int totalCount);
}
