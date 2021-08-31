package com.tencent.qcloud.tim.uikit.modules.forward;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.tencent.qcloud.tim.uikit.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationListLayout;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.interfaces.IConversationAdapter;

public class ForwardSelectListLayout extends ConversationListLayout {

    private ForwardSelectListAdapter mAdapter;

    public ForwardSelectListLayout(Context context) {
        super(context);
        init();
    }

    public ForwardSelectListLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ForwardSelectListLayout(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    public void init() {
        setLayoutFrozen(false);
        setItemViewCacheSize(0);
        setHasFixedSize(true);
        setFocusableInTouchMode(false);
        CustomLinearLayoutManager linearLayoutManager = new CustomLinearLayoutManager(getContext());
        linearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        setLayoutManager(linearLayoutManager);
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
    public ConversationListLayout getListLayout() {
        return this;
    }

    @Override
    public ForwardSelectListAdapter getAdapter() {
        return mAdapter;
    }

    @Override
    public void setAdapter(IConversationAdapter adapter) {
        super.setAdapter(adapter);
        mAdapter = (ForwardSelectListAdapter) adapter;
    }

    @Override
    public void setOnItemClickListener(ConversationListLayout.OnItemClickListener listener) {
        mAdapter.setOnItemClickListener(listener);
    }

    @Override
    public void setOnItemLongClickListener(ConversationListLayout.OnItemLongClickListener listener) {
        mAdapter.setOnItemLongClickListener(listener);
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position, ConversationInfo messageInfo);
    }

    public interface OnItemLongClickListener {
        void OnItemLongClick(View view, int position, ConversationInfo messageInfo);
    }
}
