package com.tencent.qcloud.tim.uikit.modules.chat.layout.message;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;

import com.tencent.qcloud.tim.uikit.component.action.PopMenuAction;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IMessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IMessageProperties;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.IOnCustomMessageDrawListener;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;

import java.util.ArrayList;
import java.util.List;

public abstract class MessageLayoutUI extends RecyclerView implements IMessageLayout {

    private Properties properties = Properties.getInstance();

    protected MessageLayout.OnItemClickListener mOnItemClickListener;
    protected MessageLayout.OnLoadMoreHandler mHandler;
    protected MessageLayout.OnEmptySpaceClickListener mEmptySpaceClickListener;
    protected MessageListAdapter mAdapter;
    protected List<PopMenuAction> mPopActions = new ArrayList<>();
    protected List<PopMenuAction> mMorePopActions = new ArrayList<>();
    protected MessageLayout.OnPopActionClickListener mOnPopActionClickListener;

    public MessageLayoutUI(Context context) {
        super(context);
        init();
    }

    public MessageLayoutUI(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public MessageLayoutUI(Context context, @Nullable AttributeSet attrs, int defStyle) {
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
    public void setAvatarRadius(int radius) {
        properties.setAvatarRadius(radius);
    }

    @Override
    public int getAvatarRadius() {
        return properties.getAvatarRadius();
    }

    @Override
    public void setAvatarSize(int[] size) {
        properties.setAvatarSize(size);
    }

    @Override
    public int[] getAvatarSize() {
        return properties.avatarSize;
    }

    @Override
    public int getAvatar() {
        return properties.getAvatar();
    }

    @Override
    public void setAvatar(int resId) {
        properties.setAvatar(resId);
    }

    @Override
    public Drawable getRightBubble() {
        return properties.getRightBubble();
    }

    @Override
    public void setRightBubble(Drawable bubble) {
        properties.setRightBubble(bubble);
    }

    @Override
    public Drawable getLeftBubble() {
        return properties.getLeftBubble();
    }

    @Override
    public void setLeftBubble(Drawable bubble) {
        properties.setLeftBubble(bubble);
    }

    @Override
    public int getNameFontSize() {
        return properties.getNameFontSize();
    }

    @Override
    public void setNameFontSize(int size) {
        properties.setNameFontSize(size);
    }

    @Override
    public int getNameFontColor() {
        return properties.getNameFontColor();
    }

    @Override
    public void setLeftNameVisibility(int visibility) {
        properties.setLeftNameVisibility(visibility);
    }

    @Override
    public int getLeftNameVisibility() {
        return properties.getLeftNameVisibility();
    }

    @Override
    public void setRightNameVisibility(int visibility) {
        properties.setRightNameVisibility(visibility);
    }

    @Override
    public int getRightNameVisibility() {
        return properties.getRightNameVisibility();
    }

    @Override
    public void setNameFontColor(int color) {
        properties.setNameFontColor(color);
    }

    @Override
    public int getChatContextFontSize() {
        return properties.getChatContextFontSize();
    }

    @Override
    public void setChatContextFontSize(int size) {
        properties.setChatContextFontSize(size);
    }

    @Override
    public int getRightChatContentFontColor() {
        return properties.getRightChatContentFontColor();
    }

    @Override
    public void setRightChatContentFontColor(int color) {
        properties.setRightChatContentFontColor(color);
    }

    @Override
    public int getLeftChatContentFontColor() {
        return properties.getLeftChatContentFontColor();
    }

    @Override
    public void setLeftChatContentFontColor(int color) {
        properties.setLeftChatContentFontColor(color);
    }

    @Override
    public Drawable getTipsMessageBubble() {
        return properties.getTipsMessageBubble();
    }

    @Override
    public void setTipsMessageBubble(Drawable bubble) {
        properties.setTipsMessageBubble(bubble);
    }

    @Override
    public int getTipsMessageFontSize() {
        return properties.getTipsMessageFontSize();
    }

    @Override
    public void setTipsMessageFontSize(int size) {
        properties.setTipsMessageFontSize(size);
    }

    @Override
    public int getTipsMessageFontColor() {
        return properties.getTipsMessageFontColor();
    }

    @Override
    public void setTipsMessageFontColor(int color) {
        properties.setTipsMessageFontColor(color);
    }

    @Override
    public Drawable getChatTimeBubble() {
        return properties.getChatTimeBubble();
    }

    @Override
    public void setChatTimeBubble(Drawable bubble) {
        properties.setChatTimeBubble(bubble);
    }

    @Override
    public int getChatTimeFontSize() {
        return properties.getChatTimeFontSize();
    }

    @Override
    public void setChatTimeFontSize(int size) {
        properties.setChatTimeFontSize(size);
    }

    @Override
    public int getChatTimeFontColor() {
        return properties.getChatTimeFontColor();
    }

    @Override
    public void setChatTimeFontColor(int color) {
        properties.setChatTimeFontColor(color);
    }

    @Override
    public void setOnCustomMessageDrawListener(IOnCustomMessageDrawListener listener) {
        mAdapter.setOnCustomMessageDrawListener(listener);
    }

    @Override
    public MessageLayout.OnItemClickListener getOnItemClickListener() {
        return mAdapter.getOnItemClickListener();
    }

    @Override
    public void setAdapter(MessageListAdapter adapter) {
        super.setAdapter(adapter);
        mAdapter = adapter;
        postSetAdapter(adapter);
    }

    protected abstract void postSetAdapter(MessageListAdapter adapter);

    @Override
    public void setOnItemClickListener(MessageLayout.OnItemClickListener listener) {
        mOnItemClickListener = listener;
        mAdapter.setOnItemClickListener(listener);
    }

    @Override
    public List<PopMenuAction> getPopActions() {
        return mPopActions;
    }

    @Override
    public void addPopAction(PopMenuAction action) {
        mMorePopActions.add(action);
    }

    public static class Properties implements IMessageProperties {

        private int mAvatarId;
        private int mAvatarRadius;
        private int[] avatarSize = null;

        private int mNameFontSize;
        private int mNameFontColor;
        private int mLeftNameVisibility;
        private int mRightNameVisibility;

        private int mChatContextFontSize;
        private int mMyChatContentFontColor;
        private Drawable mMyBubble;
        private int mFriendChatContentFontColor;
        private Drawable mFriendBubble;

        private int mTipsMessageFontSize;
        private int mTipsMessageFontColor;
        private Drawable mTipsMessageBubble;

        private int mChatTimeFontSize;
        private int mChatTimeFontColor;
        private Drawable mChatTimeBubble;

        private static Properties sP = new Properties();

        public static Properties getInstance() {
            if (sP == null) {
                sP = new Properties();
            }
            return sP;
        }

        private Properties() {

        }

        @Override
        public void setAvatarRadius(int radius) {
            mAvatarRadius = ScreenUtil.getPxByDp(radius);
        }

        @Override
        public int getAvatarRadius() {
            return mAvatarRadius;
        }

        @Override
        public void setAvatarSize(int[] size) {
            if (size != null && size.length == 2) {
                avatarSize = new int[2];
                avatarSize[0] = ScreenUtil.getPxByDp(size[0]);
                avatarSize[1] = ScreenUtil.getPxByDp(size[1]);
            }
        }

        @Override
        public int[] getAvatarSize() {
            return avatarSize;
        }

        @Override
        public int getAvatar() {
            return mAvatarId;
        }

        @Override
        public void setAvatar(int resId) {
            this.mAvatarId = resId;
        }

        @Override
        public Drawable getRightBubble() {
            return mMyBubble;
        }

        @Override
        public void setRightBubble(Drawable bubble) {
            this.mMyBubble = bubble;
        }

        @Override
        public Drawable getLeftBubble() {
            return mFriendBubble;
        }

        @Override
        public void setLeftBubble(Drawable bubble) {
            this.mFriendBubble = bubble;
        }

        @Override
        public int getNameFontSize() {
            return mNameFontSize;
        }

        @Override
        public void setNameFontSize(int size) {
            this.mNameFontSize = size;
        }

        @Override
        public int getNameFontColor() {
            return mNameFontColor;
        }

        @Override
        public void setLeftNameVisibility(int visibility) {
            mLeftNameVisibility = visibility;
        }

        @Override
        public int getLeftNameVisibility() {
            return mLeftNameVisibility;
        }

        @Override
        public void setRightNameVisibility(int visibility) {
            mRightNameVisibility = visibility;
        }

        @Override
        public int getRightNameVisibility() {
            return mRightNameVisibility;
        }

        @Override
        public void setNameFontColor(int color) {
            this.mNameFontColor = color;
        }

        @Override
        public int getChatContextFontSize() {
            return mChatContextFontSize;
        }

        @Override
        public void setChatContextFontSize(int size) {
            this.mChatContextFontSize = size;
        }

        @Override
        public int getRightChatContentFontColor() {
            return mMyChatContentFontColor;
        }

        @Override
        public void setRightChatContentFontColor(int color) {
            this.mMyChatContentFontColor = color;
        }

        @Override
        public int getLeftChatContentFontColor() {
            return mFriendChatContentFontColor;
        }

        @Override
        public void setLeftChatContentFontColor(int color) {
            this.mFriendChatContentFontColor = color;
        }

        @Override
        public Drawable getTipsMessageBubble() {
            return mTipsMessageBubble;
        }

        @Override
        public void setTipsMessageBubble(Drawable bubble) {
            this.mTipsMessageBubble = bubble;
        }

        @Override
        public int getTipsMessageFontSize() {
            return mTipsMessageFontSize;
        }

        @Override
        public void setTipsMessageFontSize(int size) {
            this.mTipsMessageFontSize = size;
        }

        @Override
        public int getTipsMessageFontColor() {
            return mTipsMessageFontColor;
        }

        @Override
        public void setTipsMessageFontColor(int color) {
            this.mTipsMessageFontColor = color;
        }

        @Override
        public Drawable getChatTimeBubble() {
            return mChatTimeBubble;
        }

        @Override
        public void setChatTimeBubble(Drawable bubble) {
            this.mChatTimeBubble = bubble;
        }

        @Override
        public int getChatTimeFontSize() {
            return mChatTimeFontSize;
        }

        @Override
        public void setChatTimeFontSize(int size) {
            this.mChatTimeFontSize = size;
        }

        @Override
        public int getChatTimeFontColor() {
            return mChatTimeFontColor;
        }

        @Override
        public void setChatTimeFontColor(int color) {
            this.mChatTimeFontColor = color;
        }

    }
}
