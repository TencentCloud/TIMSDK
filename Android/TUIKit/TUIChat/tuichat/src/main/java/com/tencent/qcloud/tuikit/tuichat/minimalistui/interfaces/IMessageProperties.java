package com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces;

import android.graphics.drawable.Drawable;

public interface IMessageProperties {

    /// @name 设置头像 Set Avatar
    /// @{

    /**
     * 获取默认头像
     * 
     * Get default avatar
     *
     * @return
     */
    int getAvatar();

    /**
     * 设置默认头像，默认与左边与右边的头像相同
     * 
     * Set the default avatar, the default is the same as the avatar on the left and right
     *
     * @param resId
     */
    void setAvatar(int resId);

    /**
     * 获取头像圆角
     * 
     * Get avatar rounded corners
     *
     * @return
     */
    int getAvatarRadius();

    /**
     * 设置头像圆角
     * 
     * Set avatar rounded corners
     *
     * @param radius
     */
    void setAvatarRadius(int radius);

    /**
     * 获得头像大小
     * 
     * Get avatar size
     *
     * @return
     */
    int[] getAvatarSize();

    /**
     * 设置头像大小
     *
     * Set avatar size
     * 
     * @param size
     */
    void setAvatarSize(int[] size);

    /// @}
    /// @name 设置昵称样式 Set nickname style
    /// @{

    /**
     * 获得昵称文字大小
     * 
     * Get nickname text size
     *
     * @return
     */
    int getNameFontSize();

    /**
     * 设置昵称文字大小
     * 
     * Set nickname text size
     *
     * @param size
     */
    void setNameFontSize(int size);

    /**
     * 获取昵称文字颜色
     * 
     * Get nickname text color
     *
     * @return
     */
    int getNameFontColor();

    /**
     * 设置昵称文字颜色
     * 
     * Set nickname text color
     *
     * @param color
     */
    void setNameFontColor(int color);

    /**
     * 获取左边昵称显示状态
     * 
     * Get the display status of the nickname on the left
     *
     * @return
     */
    int getLeftNameVisibility();

    /**
     * 设置左边昵称是否显示
     * 
     * Set the display status of the nickname on the left
     *
     * @param visibility
     */
    void setLeftNameVisibility(int visibility);

    /**
     * 获取右边昵称显示状态
     * 
     * Get the display status of the nickname on the right
     *
     * @return
     */
    int getRightNameVisibility();

    /**
     * 设置右边昵称是否显示
     * 
     * Set the display status of the nickname on the right
     *
     * @param visibility
     */
    void setRightNameVisibility(int visibility);

    /// @}
    /// @name 设置气泡 set bubbles
    /// @{

    /**
     * 获取右边聊天气泡的背景
     * 
     * Get the background of the chat bubble on the right
     *
     * @return
     */
    Drawable getRightBubble();

    /**
     * 设置右边聊天气泡的背景
     * 
     * Set the background of the chat bubble on the right
     *
     * @param drawable
     */
    void setRightBubble(Drawable drawable);

    /**
     * 获取左边聊天气泡的背景
     * 
     * Get the background of the left chat bubble
     *
     * @return
     */
    Drawable getLeftBubble();

    /**
     * 设置左边聊天气泡的背景
     * 
     * Set the background of the left chat bubble
     *
     * @param drawable
     */
    void setLeftBubble(Drawable drawable);

    /// @}
    /// @name 设置聊天内容 Set chat content
    /// @{

    /**
     * 获取聊天内容字体大小
     * 
     * Get chat content font size
     *
     * @return
     */
    int getChatContextFontSize();

    /**
     * 设置聊天内容字体大小
     * 
     * Set chat content font size
     *
     * @param size
     */
    void setChatContextFontSize(int size);

    /**
     * 获取右边聊天内容字体颜色
     * 
     * Get the font color of the chat content on the right
     *
     * @return
     */
    int getRightChatContentFontColor();

    /**
     * 设置右边聊天内容字体颜色
     * 
     * Set the font color of the chat content on the right
     *
     * @param color
     */
    void setRightChatContentFontColor(int color);

    /**
     * 获取左边聊天内容字体颜色
     * 
     * Get the font color of the chat content on the left
     *
     * @return
     */
    int getLeftChatContentFontColor();

    /**
     * 设置左边聊天内容字体颜色
     * 
     * Set the font color of the chat content on the left
     *
     * @param color
     */
    void setLeftChatContentFontColor(int color);

    /// @}
    /// @name 设置聊天时间 Set chat time
    /// @{

    /**
     * 获取聊天时间的背景
     * 
     * Get the context of the chat time
     *
     * @return
     */
    Drawable getChatTimeBubble();

    /**
     * 设置聊天时间的背景
     * 
     * Set the context of the chat time
     *
     * @param drawable
     */
    void setChatTimeBubble(Drawable drawable);

    /**
     * 获取聊天时间的文字大小
     * 
     * Get the text size of the chat time
     *
     * @return
     */
    int getChatTimeFontSize();

    /**
     * 设置聊天时间的字体大小
     * 
     * Set the text size of the chat time
     *
     * @param size
     */
    void setChatTimeFontSize(int size);

    /**
     * 获取聊天时间的字体颜色
     * 
     * Get the font color of chat time
     *
     * @return
     */
    int getChatTimeFontColor();

    /**
     * 设置聊天时间的字体颜色
     * 
     * Set the font color of chat time
     *
     * @param color
     */
    void setChatTimeFontColor(int color);

    /// @}
    /// @name 设置聊天的提示信息 Set up chat alerts
    /// @{

    /**
     * 获取聊天提示信息的背景
     * 
     * Get context for chat alerts
     *
     * @return
     */
    Drawable getTipsMessageBubble();

    /**
     * 设置聊天提示信息的背景
     * 
     * Set context for chat alerts
     *
     * @param drawable
     */
    void setTipsMessageBubble(Drawable drawable);

    /**
     * 获取聊天提示信息的文字大小
     * 
     * Get the text size of the chat prompt message
     *
     * @return
     */
    int getTipsMessageFontSize();

    /**
     * 设置聊天提示信息的文字大小
     * 
     * Set the text size of the chat prompt message
     *
     * @param size
     */
    void setTipsMessageFontSize(int size);

    /**
     * 获取聊天提示信息的文字颜色
     * 
     * Get the text color of the chat prompt message
     *
     * @return
     */
    int getTipsMessageFontColor();

    /**
     * 设置聊天提示信息的文字颜色
     * 
     * Set the text color of the chat prompt message
     *
     * @param color
     */
    void setTipsMessageFontColor(int color);
}
