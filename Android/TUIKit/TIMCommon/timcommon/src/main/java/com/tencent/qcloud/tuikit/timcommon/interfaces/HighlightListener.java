package com.tencent.qcloud.tuikit.timcommon.interfaces;

public interface HighlightListener {

    void onHighlightStart();

    void onHighlightEnd();

    void onHighlightUpdate(int color);
}