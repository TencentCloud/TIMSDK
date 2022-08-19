package com.tencent.qcloud.tuikit.tuiconversation.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;

import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationFoldPresenter;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;
import com.tencent.qcloud.tuikit.tuiconversation.ui.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.ui.interfaces.IConversationListLayout;
import com.tencent.qcloud.tuikit.tuiconversation.ui.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuiconversation.ui.interfaces.OnItemLongClickListener;

public class FoldedConversationListLayout extends RecyclerView implements IConversationListLayout {

    private ConversationListAdapter mAdapter;
    private ConversationFoldPresenter presenter;
    private boolean isFolded = false;

    public FoldedConversationListLayout(Context context) {
        super(context);
        init();
    }

    public FoldedConversationListLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public FoldedConversationListLayout(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    public void setPresenter(ConversationFoldPresenter presenter) {
        this.presenter = presenter;
    }

    public void init() {
        setLayoutFrozen(false);
        setItemViewCacheSize(0);
        setHasFixedSize(true);
        setFocusableInTouchMode(false);
        CustomLinearLayoutManager linearLayoutManager = new CustomLinearLayoutManager(getContext());
        linearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        setLayoutManager(linearLayoutManager);
        SimpleItemAnimator animator = (SimpleItemAnimator) getItemAnimator();
        if (animator != null) {
            animator.setSupportsChangeAnimations(false);
        }
    }

    @Override
    public void setBackground(int resId) {
        setBackgroundColor(resId);
    }

    @Override
    public void disableItemUnreadDot(boolean flag) {
        mAdapter.disableItemUnreadDot(flag);
    }

    @Override
    public void setItemAvatarRadius(int radius) {
        mAdapter.setItemAvatarRadius(radius);
    }

    @Override
    public void setItemTopTextSize(int size) {
        mAdapter.setItemTopTextSize(size);
    }

    @Override
    public void setItemBottomTextSize(int size) {
        mAdapter.setItemBottomTextSize(size);
    }

    @Override
    public void setItemDateTextSize(int size) {
        mAdapter.setItemDateTextSize(size);
    }

    @Override
    public FoldedConversationListLayout getListLayout() {
        return this;
    }

    @Override
    public ConversationListAdapter getAdapter() {
        return mAdapter;
    }

    @Override
    public void setAdapter(IConversationListAdapter adapter) {
        if (adapter instanceof ConversationListAdapter) {
            super.setAdapter((ConversationListAdapter) adapter);
            mAdapter = (ConversationListAdapter) adapter;
        }
    }

    @Override
    public void setOnItemClickListener(OnItemClickListener listener) {
        mAdapter.setOnItemClickListener(listener);
    }

    @Override
    public void setOnItemLongClickListener(OnItemLongClickListener listener) {
        mAdapter.setOnItemLongClickListener(listener);
    }

    public void loadConversation() {
        if (presenter != null) {
            presenter.loadConversation();
        }
    }
}