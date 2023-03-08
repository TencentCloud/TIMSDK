package com.tencent.qcloud.tuicore.component.swipe;

public interface SwipeAdapterInterface {

    int getSwipeLayoutResourceId(int position);

    void notifyDatasetChanged();

    void notifySwipeItemChanged(int position);

}
