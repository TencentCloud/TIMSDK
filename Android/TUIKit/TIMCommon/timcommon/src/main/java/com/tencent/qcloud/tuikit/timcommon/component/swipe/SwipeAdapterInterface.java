package com.tencent.qcloud.tuikit.timcommon.component.swipe;

public interface SwipeAdapterInterface {
    int getSwipeLayoutResourceId(int position);

    void notifyDatasetChanged();

    void notifySwipeItemChanged(int position);
}
