package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.List;

public class UserRecyclerView extends RecyclerView {
    private final UserRecyclerViewStateHolder          mStateHolder = new UserRecyclerViewStateHolder();
    private final LiveListObserver<UserState.UserInfo> mObserver    = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onDataChanged(List<UserState.UserInfo> list) {
            mAdapter.setDataList(list);
        }

        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            mAdapter.notifyItemChanged(position);
        }

        @Override
        public void onItemInserted(int position, UserState.UserInfo item) {
            mAdapter.notifyItemInserted(position);
        }

        @Override
        public void onItemRemoved(int position, UserState.UserInfo item) {
            mAdapter.notifyItemRemoved(position);
        }

        @Override
        public void onItemMoved(int fromPosition, int toPosition, UserState.UserInfo item) {
            mAdapter.notifyItemMoved(fromPosition, toPosition);
        }
    };

    private final UserRecyclerViewAdapter mAdapter = new UserRecyclerViewAdapter(getContext());

    public UserRecyclerView(@NonNull Context context) {
        this(context, null);
    }

    public UserRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public UserRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setAdapter(mAdapter);
        setLayoutManager(new LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false));
        setHasFixedSize(true);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
    }
}
