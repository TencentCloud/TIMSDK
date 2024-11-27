package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import android.content.Context;
import android.database.DataSetObserver;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.HorizontalScrollView;
import com.tencent.imsdk.base.ThreadUtils;
import com.tencent.liteav.base.util.LiteavLog;

public class TUIHorizontalScrollView extends HorizontalScrollView {

    private final String TAG = TUIHorizontalScrollView.class + "_" + hashCode();

    private DataSetObserver mObserver;
    private TUIMultimediaScrollViewAdapter mAdapter;

    public TUIHorizontalScrollView(Context context) {
        super(context);
        initialize();
    }

    public TUIHorizontalScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initialize();
    }

    public TUIHorizontalScrollView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize();
    }

    public void setAdapter(TUIMultimediaScrollViewAdapter adapter) {
        LiteavLog.i(TAG, "set Adapter adapter = " + adapter);
        if (mAdapter != null) {
            mAdapter.unregisterDataSetObserver(mObserver);
        }
        mAdapter = adapter;
        mAdapter.registerDataSetObserver(mObserver);
        updateAdapter();
        ThreadUtils.getUiThreadHandler().post(this::scrollToSelectView);
    }

    private void updateAdapter() {
        ViewGroup group = (ViewGroup) getChildAt(0);
        group.removeAllViews();
        for (int i = 0; i < mAdapter.getCount(); i++) {
            View view = mAdapter.getView(i, null, group);
            group.addView(view);
        }
    }

    void initialize() {
        mObserver = new DataSetObserver() {
            @Override
            public void onChanged() {
                super.onChanged();
                updateAdapter();
            }

            @Override
            public void onInvalidated() {
                super.onInvalidated();
                ((ViewGroup) getChildAt(0)).removeAllViews();
            }
        };
    }

    public void setClicked(int position) {
        LiteavLog.i(TAG, "setClicked position = " + position + " old position = " + mAdapter.getSelectPosition());
        if (position == mAdapter.getSelectPosition()) {
            return;
        }
        View itemView = ((ViewGroup) getChildAt(0)).getChildAt(position);
        if (itemView != null) {
            itemView.performClick();
        }
        scrollToSelectView();
    }

    private void scrollToSelectView() {
        View view = ((ViewGroup) getChildAt(0)).getChildAt(mAdapter.getSelectPosition());
        if (view == null) {
            return;
        }

        Rect scrollBounds = new Rect();
        getHitRect(scrollBounds);

        int scrollX = getScrollX();
        int itemViewLeft = view.getLeft();
        int itemViewWidth = view.getWidth();

        int visibleZoomLeft = scrollBounds.left + scrollX + TUIMultimediaResourceUtils.dip2px(getContext(), 20);
        int visibleZoomRight = scrollBounds.right + scrollX - TUIMultimediaResourceUtils.dip2px(getContext(), 20);

        int newScrollX = scrollX;
        if (itemViewLeft < visibleZoomLeft) {
            newScrollX = scrollX - ((visibleZoomLeft - itemViewLeft));
        }

        if (itemViewLeft + itemViewWidth > visibleZoomRight) {
            newScrollX = scrollX + (itemViewLeft + itemViewWidth - visibleZoomRight);
        }

        if (newScrollX < 0) {
            newScrollX = 0;
        }

        scrollTo(newScrollX, 0);
    }
}