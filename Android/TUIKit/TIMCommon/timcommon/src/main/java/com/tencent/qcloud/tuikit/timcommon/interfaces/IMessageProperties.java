package com.tencent.qcloud.tuikit.timcommon.interfaces;

import android.graphics.drawable.Drawable;

public interface IMessageProperties {
    
    /**
     * 
     * Get default avatar
     *
     * @return
     */
    int getAvatar();

    /**
     *
     * Set the default avatar, the default is the same as the avatar on the left and right
     *
     * @param resId
     */
    void setAvatar(int resId);

    /**
     *
     * Get avatar rounded corners
     *
     * @return
     */
    int getAvatarRadius();

    /**
     *
     * Set avatar rounded corners
     *
     * @param radius
     */
    void setAvatarRadius(int radius);

    /**
     *
     * Get avatar size
     *
     * @return
     */
    int[] getAvatarSize();

    /**
     *
     * Set avatar size
     *
     * @param size
     */
    void setAvatarSize(int[] size);

    /**
     * 
     *
     * Get nickname text size
     *
     * @return
     */
    int getNameFontSize();

    /**
     *
     * Set nickname text size
     *
     * @param size
     */
    void setNameFontSize(int size);

    /**
     *
     * Get nickname text color
     *
     * @return
     */
    int getNameFontColor();

    /**
     *
     * Set nickname text color
     *
     * @param color
     */
    void setNameFontColor(int color);

    /**
     *
     * Get the display status of the nickname on the left
     *
     * @return
     */
    int getLeftNameVisibility();

    /**
     *
     * Set the display status of the nickname on the left
     *
     * @param visibility
     */
    void setLeftNameVisibility(int visibility);

    /**
     *
     * Get the display status of the nickname on the right
     *
     * @return
     */
    int getRightNameVisibility();

    /**
     *
     * Set the display status of the nickname on the right
     *
     * @param visibility
     */
    void setRightNameVisibility(int visibility);

    /**
     *
     * Get the background of the chat bubble on the right
     *
     * @return
     */
    Drawable getRightBubble();

    /**
     *
     * Set the background of the chat bubble on the right
     *
     * @param drawable
     */
    void setRightBubble(Drawable drawable);

    /**
     *
     * Get the background of the left chat bubble
     *
     * @return
     */
    Drawable getLeftBubble();

    /**
     *
     * Set the background of the left chat bubble
     *
     * @param drawable
     */
    void setLeftBubble(Drawable drawable);

    /**
     *
     * Get chat content font size
     *
     * @return
     */
    int getChatContextFontSize();

    /**
     *
     * Set chat content font size
     *
     * @param size
     */
    void setChatContextFontSize(int size);

    /**
     *
     * Get the font color of the chat content on the right
     *
     * @return
     */
    int getRightChatContentFontColor();

    /**
     *
     * Set the font color of the chat content on the right
     *
     * @param color
     */
    void setRightChatContentFontColor(int color);

    /**
     *
     * Get the font color of the chat content on the left
     *
     * @return
     */
    int getLeftChatContentFontColor();

    /**
     *
     * Set the font color of the chat content on the left
     *
     * @param color
     */
    void setLeftChatContentFontColor(int color);

    /**
     *
     * Get the context of the chat time
     *
     * @return
     */
    Drawable getChatTimeBubble();

    /**
     *
     * Set the context of the chat time
     *
     * @param drawable
     */
    void setChatTimeBubble(Drawable drawable);

    /**
     *
     * Get the text size of the chat time
     *
     * @return
     */
    int getChatTimeFontSize();

    /**
     *
     * Set the text size of the chat time
     *
     * @param size
     */
    void setChatTimeFontSize(int size);

    /**
     *
     * Get the font color of chat time
     *
     * @return
     */
    int getChatTimeFontColor();

    /**
     *
     * Set the font color of chat time
     *
     * @param color
     */
    void setChatTimeFontColor(int color);

    /**
     *
     * Get context for chat alerts
     *
     * @return
     */
    Drawable getTipsMessageBubble();

    /**
     *
     * Set context for chat alerts
     *
     * @param drawable
     */
    void setTipsMessageBubble(Drawable drawable);

    /**
     *
     * Get the text size of the chat prompt message
     *
     * @return
     */
    int getTipsMessageFontSize();

    /**
     *
     * Set the text size of the chat prompt message
     *
     * @param size
     */
    void setTipsMessageFontSize(int size);

    /**
     *
     * Get the text color of the chat prompt message
     *
     * @return
     */
    int getTipsMessageFontColor();

    /**
     *
     * Set the text color of the chat prompt message
     *
     * @param color
     */
    void setTipsMessageFontColor(int color);
}
