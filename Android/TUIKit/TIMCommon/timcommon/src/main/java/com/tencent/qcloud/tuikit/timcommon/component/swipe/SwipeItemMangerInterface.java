package com.tencent.qcloud.tuikit.timcommon.component.swipe;

import java.util.List;

public interface SwipeItemMangerInterface {
    void openItem(int position);

    void closeItem(int position);

    void closeAllExcept(SwipeLayout layout);

    void closeAllSwipeItems();

    List<Integer> getOpenItems();

    List<SwipeLayout> getOpenLayouts();

    void removeShownLayouts(SwipeLayout layout);

    boolean isOpen(int position);

    Attributes.Mode getMode();

    void setMode(Attributes.Mode mode);

    void switchAllSwipeEnable(boolean enable);
}
