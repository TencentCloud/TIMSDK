package com.tencent.qcloud.tuikit.timcommon.component.scroller;

import android.content.Context;
import android.view.View;

import androidx.recyclerview.widget.LinearSmoothScroller;
import androidx.recyclerview.widget.OrientationHelper;
import androidx.recyclerview.widget.RecyclerView;

public class CenteredSmoothScroller extends LinearSmoothScroller {

    public CenteredSmoothScroller(Context context) {
        super(context);
    }

    @Override
    protected void onTargetFound(View targetView, RecyclerView.State state, Action action) {
        RecyclerView.LayoutManager layoutManager = getLayoutManager();
        if (layoutManager == null) {
            return;
        }
        int distance = calculateDistanceToCenter(targetView, layoutManager);
        int time = calculateTimeForDeceleration(distance);
        if (time > 0) {
            action.update(0, distance, time, mDecelerateInterpolator);
        }
    }

    private int calculateDistanceToCenter(View targetView, RecyclerView.LayoutManager layoutManager) {
        OrientationHelper helper = OrientationHelper.createVerticalHelper(layoutManager);
        int childCenter = helper.getDecoratedStart(targetView) + helper.getDecoratedMeasurement(targetView) / 2;
        int containerCenter;
        if (layoutManager.getClipToPadding()) {
            containerCenter = helper.getStartAfterPadding() + helper.getTotalSpace() / 2;
        } else {
            containerCenter = helper.getEnd() / 2;
        }
        return childCenter - containerCenter;
    }
}
