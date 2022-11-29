package com.tencent.qcloud.tuikit.tuichat.minimalistui.component;

import android.graphics.drawable.Drawable;

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.IMessageProperties;

public class MessageProperties implements IMessageProperties {
    private static MessageProperties sP = new MessageProperties();
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

    private MessageProperties() {

    }

    public static MessageProperties getInstance() {
        if (sP == null) {
            sP = new MessageProperties();
        }
        return sP;
    }

    @Override
    public int getAvatarRadius() {
        return mAvatarRadius;
    }

    @Override
    public void setAvatarRadius(int radius) {
        mAvatarRadius = ScreenUtil.getPxByDp(radius);
    }

    @Override
    public int[] getAvatarSize() {
        return avatarSize;
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
    public void setNameFontColor(int color) {
        this.mNameFontColor = color;
    }

    @Override
    public int getLeftNameVisibility() {
        return mLeftNameVisibility;
    }

    @Override
    public void setLeftNameVisibility(int visibility) {
        mLeftNameVisibility = visibility;
    }

    @Override
    public int getRightNameVisibility() {
        return mRightNameVisibility;
    }

    @Override
    public void setRightNameVisibility(int visibility) {
        mRightNameVisibility = visibility;
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
