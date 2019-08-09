package com.tencent.qcloud.tim.uikit.modules.chat.interfaces;

import android.graphics.drawable.Drawable;

public interface IMessageProperties {

    /// @name 设置头像
    /// @{

    /**
     * 设置默认头像，默认与左边与右边的头像相同
     *
     * @param resId
     */
    void setAvatar(int resId);

    /**
     * 获取默认头像
     *
     * @return
     */
    int getAvatar();


    /**
     * 设置头像圆角
     *
     * @param radius
     */
    void setAvatarRadius(int radius);

    /**
     * 获取头像圆角
     *
     * @return
     */
    int getAvatarRadius();

    /**
     * 设置头像大小
     *
     * @param size
     */
    void setAvatarSize(int[] size);

    /**
     * 获得头像大小
     *
     * @return
     */
    int[] getAvatarSize();

    /// @}
    /// @name 设置昵称样式
    /// @{

    /**
     * 设置昵称文字大小
     *
     * @param size
     */
    void setNameFontSize(int size);

    /**
     * 获得昵称文字大小
     *
     * @return
     */
    int getNameFontSize();

    /**
     * 设置昵称文字颜色
     *
     * @param color
     */
    void setNameFontColor(int color);

    /**
     * 获取昵称文字颜色
     *
     * @return
     */
    int getNameFontColor();

    /**
     * 设置左边昵称是否显示
     *
     * @param visibility
     */
    void setLeftNameVisibility(int visibility);

    /**
     * 获取左边昵称显示状态
     *
     * @return
     */
    int getLeftNameVisibility();

    /**
     * 设置右边昵称是否显示
     *
     * @param visibility
     */
    void setRightNameVisibility(int visibility);

    /**
     * 获取右边昵称显示状态
     *
     * @return
     */
    int getRightNameVisibility();

    /// @}
    /// @name 设置气泡
    /// @{

    /**
     * 设置右边聊天气泡的背景
     *
     * @param drawable
     */
    void setRightBubble(Drawable drawable);

    /**
     * 获取右边聊天气泡的背景
     *
     * @return
     */
    Drawable getRightBubble();

    /**
     * 设置左边聊天气泡的背景
     *
     * @param drawable
     */
    void setLeftBubble(Drawable drawable);

    /**
     * 获取左边聊天气泡的背景
     *
     * @return
     */
    Drawable getLeftBubble();

    /// @}
    /// @name 设置聊天内容
    /// @{

    /**
     * 设置聊天内容字体大小
     *
     * @param size
     */
    void setChatContextFontSize(int size);

    /**
     * 获取聊天内容字体大小
     *
     * @return
     */
    int getChatContextFontSize();

    /**
     * 设置右边聊天内容字体颜色
     *
     * @param color
     */
    void setRightChatContentFontColor(int color);

    /**
     * 获取右边聊天内容字体颜色
     *
     * @return
     */
    int getRightChatContentFontColor();

    /**
     * 获取左边聊天内容字体颜色
     *
     * @return
     */
    int getLeftChatContentFontColor();

    /**
     * 设置左边聊天内容字体颜色
     *
     * @param color
     */
    void setLeftChatContentFontColor(int color);

    /// @}
    /// @name 设置聊天时间
    /// @{

    /**
     * 设置聊天时间的背景
     *
     * @param drawable
     */
    void setChatTimeBubble(Drawable drawable);

    /**
     * 获取聊天时间的背景
     *
     * @return
     */
    Drawable getChatTimeBubble();

    /**
     * 设置聊天时间的字体大小
     *
     * @param size
     */
    void setChatTimeFontSize(int size);

    /**
     * 获取聊天时间的文字大小
     *
     * @return
     */
    int getChatTimeFontSize();

    /**
     * 设置聊天时间的字体颜色
     *
     * @param color
     */
    void setChatTimeFontColor(int color);

    /**
     * 获取聊天时间的字体颜色
     *
     * @return
     */
    int getChatTimeFontColor();

    /// @}
    /// @name 设置聊天的提示信息
    /// @{

    /**
     * 设置聊天提示信息的背景
     *
     * @param drawable
     */
    void setTipsMessageBubble(Drawable drawable);

    /**
     * 获取聊天提示信息的背景
     *
     * @return
     */
    Drawable getTipsMessageBubble();

    /**
     * 设置聊天提示信息的文字大小
     *
     * @param size
     */
    void setTipsMessageFontSize(int size);

    /**
     * 获取聊天提示信息的文字大小
     *
     * @return
     */
    int getTipsMessageFontSize();

    /**
     * 设置聊天提示信息的文字颜色
     *
     * @param color
     */
    void setTipsMessageFontColor(int color);

    /**
     * 获取聊天提示信息的文字颜色
     *
     * @return
     */
    int getTipsMessageFontColor();
}
