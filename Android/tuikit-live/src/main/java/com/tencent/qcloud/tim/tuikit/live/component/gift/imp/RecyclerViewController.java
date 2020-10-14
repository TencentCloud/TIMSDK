package com.tencent.qcloud.tim.tuikit.live.component.gift.imp;

import android.content.Context;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

public class RecyclerViewController {
    private RecyclerView                           mRecycler;
    private GestureDetector                        mGestureDetector;
    private RecyclerView.SimpleOnItemTouchListener mSimpleOnItemTouchListener;
    private OnItemClickListener                    mOnItemClickListener;
    private OnItemLongClickListener                mOnItemLongClickListener;
    private Context mContext;

    public RecyclerViewController(Context context, RecyclerView recyclerView) {
        this.mContext = context;
        this.mRecycler = recyclerView;
        mGestureDetector = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener() {
            //长按事件
            @Override
            public void onLongPress(MotionEvent e) {
                super.onLongPress(e);
                if (mOnItemLongClickListener != null) {
                    View childView = mRecycler.findChildViewUnder(e.getX(), e.getY());
                    if (childView != null) {
                        int position = mRecycler.getChildLayoutPosition(childView);
                        mOnItemLongClickListener.onItemLongClick(position, childView);
                    }
                }
            }

            //单击事件
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (mOnItemClickListener != null) {
                    View childView = mRecycler.findChildViewUnder(e.getX(), e.getY());
                    if (childView != null) {
                        int position = mRecycler.getChildLayoutPosition(childView);
                        mOnItemClickListener.onItemClick(position, childView);
                        return true;
                    }
                }

                return super.onSingleTapUp(e);
            }
        });

        mSimpleOnItemTouchListener = new RecyclerView.SimpleOnItemTouchListener() {
            @Override
            public boolean onInterceptTouchEvent(RecyclerView rv, MotionEvent e) {
                if (mGestureDetector.onTouchEvent(e)) {
                    return true;
                }
                return false;
            }
        };

        mRecycler.addOnItemTouchListener(mSimpleOnItemTouchListener);
    }

    public void setOnItemClickListener(OnItemClickListener l) {
        mOnItemClickListener = l;
    }

    public void setOnItemLongClickListener(OnItemLongClickListener l) {
        mOnItemLongClickListener = l;
    }

    //长按事件接口
    public interface OnItemLongClickListener {
        void onItemLongClick(int position, View view);
    }

    //单击事件接口
    public interface OnItemClickListener {
        void onItemClick(int position, View view);
    }
}
