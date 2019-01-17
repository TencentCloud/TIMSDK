package com.tencent.qcloud.uikit.business.chat.view;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.uikit.business.chat.view.widget.ChatAdapter;

/**
 * Created by valexhuang on 2018/9/29.
 */

public class ChatListView extends RecyclerView {
    public static final int DATA_CHANGE_TYPE_REFRESH = 0;
    public static final int DATA_CHANGE_TYPE_LOAD = 1;
    public static final int DATA_CHANGE_TYPE_ADD_FRONT = 2;
    public static final int DATA_CHANGE_TYPE_ADD_BACK = 3;
    public static final int DATA_CHANGE_TYPE_UPDATE = 4;
    public static final int DATA_CHANGE_TYPE_DELETE = 5;
    public static final int DATA_CHANGE_TYPE_CLEAR = 6;


    private DynamicChatUserIconView mChatIcon;
    private Drawable mSelfBubble, mOppositeBubble, mTipsMessageBubble, mChatTimeBubble;
    private int mNameSize, mContextSize, mTipsMessageSize, mChatTimeSize;
    private int mNameColor, mSelfContentColor, mOppositeContentColor, mTipsMessageColor, mChatTimeColor;

    private boolean divided = true;

    private OnLoadMoreHandler mHandler;
    private OnEmptySpaceClickListener mEmptySpaceClickListener;


    public ChatListView(Context context) {

        super(context);
        init();
    }

    public ChatListView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ChatListView(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    private void init() {
        setLayoutFrozen(false);
        setItemViewCacheSize(0);
        setHasFixedSize(true);
        setFocusableInTouchMode(false);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getContext());
        linearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        setLayoutManager(linearLayoutManager);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent e) {
        if (e.getAction() == MotionEvent.ACTION_UP) {
            View child = findChildViewUnder(e.getX(), e.getY());
            if (child == null) {
                if (mEmptySpaceClickListener != null)
                    mEmptySpaceClickListener.onClick();
            } else if (child instanceof ViewGroup) {
                ViewGroup group = (ViewGroup) child;
                final int count = group.getChildCount();
                float x = e.getRawX();
                float y = e.getRawY();
                View touchChild = null;
                for (int i = count - 1; i >= 0; i--) {
                    final View innerChild = group.getChildAt(i);
                    int position[] = new int[2];
                    innerChild.getLocationOnScreen(position);
                    if (x >= position[0]
                            && x <= position[0] + innerChild.getMeasuredWidth()
                            && y >= position[1]
                            && y <= position[1] + innerChild.getMeasuredHeight()) {
                        touchChild = innerChild;
                        break;
                    }
                }
                if (touchChild == null)
                    if (mEmptySpaceClickListener != null)
                        mEmptySpaceClickListener.onClick();
            }
        }
        return super.onInterceptTouchEvent(e);
    }

    public DynamicChatUserIconView getUserChatIcon() {
        return mChatIcon;
    }

    public void setUserChatIcon(DynamicChatUserIconView mUserIcon) {
        this.mChatIcon = mChatIcon;
    }

    public Drawable getSelfBubble() {
        return mSelfBubble;
    }

    public void setSelfBubble(Drawable mSelfBubble) {
        this.mSelfBubble = mSelfBubble;
    }

    public Drawable getOppositeBubble() {
        return mOppositeBubble;
    }

    public void setOppositeBubble(Drawable mOppositeBubble) {
        this.mOppositeBubble = mOppositeBubble;
    }

    public int getNameSize() {
        return mNameSize;
    }

    public void setNameSize(int mSelfNameSize) {
        this.mNameSize = mSelfNameSize;
    }

    public int getNameColor() {
        return mNameColor;
    }

    public void setNameColor(int mSelfNameColor) {
        this.mNameColor = mSelfNameColor;
    }


    public int getContextSize() {
        return mContextSize;
    }

    public void setContextSize(int mSelfContextSize) {
        this.mContextSize = mSelfContextSize;
    }


    public int getSelfContentColor() {
        return mSelfContentColor;
    }

    public void setSelfContentColor(int mSelfContentColor) {
        this.mSelfContentColor = mSelfContentColor;
    }

    public int getOppositeContentColor() {
        return mOppositeContentColor;
    }

    public void setOppositeContentColor(int mOppositeContentColor) {
        this.mOppositeContentColor = mOppositeContentColor;
    }

    public static int getDataChangeTypeRefresh() {
        return DATA_CHANGE_TYPE_REFRESH;
    }

    public Drawable getTipsMessageBubble() {
        return mTipsMessageBubble;
    }

    public void setTipsMessageBubble(Drawable mTipsMessageBubble) {
        this.mTipsMessageBubble = mTipsMessageBubble;
    }

    public int getTipsMessageSize() {
        return mTipsMessageSize;
    }

    public void setTipsMessageSize(int mTipsMessageSize) {
        this.mTipsMessageSize = mTipsMessageSize;
    }

    public int getTipsMessageColor() {
        return mTipsMessageColor;
    }

    public void setTipsMessageColor(int mTipsMessageColor) {
        this.mTipsMessageColor = mTipsMessageColor;
    }

    public static int getDataChangeTypeLoad() {
        return DATA_CHANGE_TYPE_LOAD;
    }

    public Drawable getChatTimeBubble() {
        return mChatTimeBubble;
    }

    public void setChatTimeBubble(Drawable mChatTimeBubble) {
        this.mChatTimeBubble = mChatTimeBubble;
    }

    public int getChatTimeSize() {
        return mChatTimeSize;
    }

    public void setChatTimeSize(int mChatTimeSize) {
        this.mChatTimeSize = mChatTimeSize;
    }

    public int getChatTimeColor() {
        return mChatTimeColor;
    }

    public void setChatTimeColor(int mChatTimeColor) {
        this.mChatTimeColor = mChatTimeColor;
    }


    public boolean isDivided() {
        return divided;
    }

    public void setDivided(boolean divided) {
        this.divided = divided;
    }

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);
    }

    @Override
    public void onScrollStateChanged(int state) {
        super.onScrollStateChanged(state);
        if (state == RecyclerView.SCROLL_STATE_IDLE) {
            if (mHandler != null) {
                LinearLayoutManager layoutManager = (LinearLayoutManager) getLayoutManager();
                int firstPosition = layoutManager.findFirstCompletelyVisibleItemPosition();
                int lastPosition = layoutManager.findLastCompletelyVisibleItemPosition();
                if (firstPosition == 0 && ((lastPosition - firstPosition + 1) < getAdapter().getItemCount())) {
                    if (getAdapter() instanceof ChatAdapter) {
                        ((ChatAdapter) getAdapter()).showLoading();
                    }
                    mHandler.loadMore();
                }
            }
        }
    }


    public void scrollToEnd() {
        if (getAdapter() != null)
            scrollToPosition(getAdapter().getItemCount() - 1);
    }

    public OnLoadMoreHandler getLoadMoreHandler() {
        return mHandler;
    }

    public void setMLoadMoreHandler(OnLoadMoreHandler mHandler) {
        this.mHandler = mHandler;
    }

    public OnEmptySpaceClickListener getEmptySpaceClickListener() {
        return mEmptySpaceClickListener;
    }

    public void setEmptySpaceClickListener(OnEmptySpaceClickListener mEmptySpaceClickListener) {
        this.mEmptySpaceClickListener = mEmptySpaceClickListener;
    }

    @Override
    public void setAdapter(Adapter adapter) {
        super.setAdapter(adapter);
    }

    public interface OnLoadMoreHandler {
        void loadMore();
    }

    public interface OnEmptySpaceClickListener {
        void onClick();
    }

}
