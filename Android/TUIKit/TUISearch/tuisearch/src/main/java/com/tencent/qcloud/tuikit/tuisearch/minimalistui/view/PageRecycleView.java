package com.tencent.qcloud.tuikit.tuisearch.minimalistui.view;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class PageRecycleView extends RecyclerView {

    protected OnLoadMoreHandler mHandler;

    public PageRecycleView(Context context) {
        super(context);
    }

    public PageRecycleView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public PageRecycleView(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public void setLoadMoreMessageHandler(OnLoadMoreHandler mHandler) {
        this.mHandler = mHandler;
    }

    @Override
    public void onScrollStateChanged(int state) {
        super.onScrollStateChanged(state);
        if (state == RecyclerView.SCROLL_STATE_IDLE) {
            if (mHandler != null) {
                LinearLayoutManager layoutManager = (LinearLayoutManager) getLayoutManager();
                int lastPosition = layoutManager.findLastCompletelyVisibleItemPosition();
                if (lastPosition == getAdapter().getItemCount() -1 && !mHandler.isListEnd(lastPosition)){
                    mHandler.loadMore();
                }
            }
        }
    }

    public interface OnLoadMoreHandler {
        void loadMore();
        boolean isListEnd(int position);
    }
}
