package com.tencent.qcloud.tuikit.tuisearch.interfaces;

import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;

import java.util.List;

public interface ISearchResultAdapter {
    void onDataSourceChanged(List<SearchDataBean> dataSource, int viewType);
    void onIsShowAllChanged(boolean isShowAll);
    void onTotalCountChanged(int totalCount);
}
