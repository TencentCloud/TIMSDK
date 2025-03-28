

package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.layout;

public class VisibleRange {
    private int minVisibleRange;
    private int maxVisibleRange;

    public int getMinVisibleRange() {
        return minVisibleRange;
    }

    public int getMaxVisibleRange() {
        return maxVisibleRange;
    }

    public void updateRange(int min, int max) {
        minVisibleRange = min;
        maxVisibleRange = max;
    }
}