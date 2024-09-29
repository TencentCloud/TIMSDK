package com.tencent.qcloud.tuikit.timcommon.config.classicui;

import static com.tencent.qcloud.tuikit.timcommon.util.TUIUtil.newDrawable;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.View;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.highlight.HighlightPresenter;

public class TUIConfigClassic {
    private TUIConfigClassic() {}

    private static final class TUIConfigClassicHolder {
        private static final TUIConfigClassic INSTANCE = new TUIConfigClassic();
    }

    private static TUIConfigClassic getInstance() {
        return TUIConfigClassicHolder.INSTANCE;
    }

    public static final int UNDEFINED = -1;
    // message bubble
    private boolean enableMessageBubbleStyle = true;
    private Drawable sendBubbleBackground;
    private Drawable receiveBubbleBackground;
    private Drawable sendErrorBubbleBackground;
    private Drawable receiveErrorBubbleBackground;

    // message style
    private Drawable chatTimeBubble;
    private int chatTimeFontSize = UNDEFINED;
    private int chatTimeFontColor = UNDEFINED;
    private Drawable defaultAvatarImage;
    private int avatarRadius = UNDEFINED;
    private int avatarSize = UNDEFINED;
    private int receiveNickNameVisibility = UNDEFINED;
    private int receiveNickNameFontSize = UNDEFINED;
    private int receiveNickNameColor = UNDEFINED;

    /**
     *  Set the default app directory.The default dir is "file".
     * @param appDir
     */
    public static void setDefaultAppDir(String appDir) {
        TUIConfig.setDefaultAppDir(appDir);
        TUIConfig.initPath();
    }

    /**
     *  Set whether show the toast prompt built into TUIKit.The default value is true.
     *  @param enableToast
     */
    public static void enableToast(boolean enableToast) {
        ToastUtil.setEnableToast(enableToast);
    }

    /**
     * Set whether to enable language switching.The default value is false.
     * @param enableLanguageSwitch
     */
    public static void enableLanguageSwitch(boolean enableLanguageSwitch) {
        TUIThemeManager.setEnableLanguageSwitch(enableLanguageSwitch);
    }

    /**
     * Switch the language of TUIKit.
     * The currently supported languages are "en", "zh", and "ar".
     * @param context
     * @param targetLanguage
     */
    public static void switchLanguageToTarget(Context context, String targetLanguage) {
        TUIThemeManager.getInstance().changeLanguage(context, targetLanguage);
    }

    /**
     * Switch theme to target.
     * The currently supported themes are THEME_LIGHT, THEME_LIVELY, and THEME_SERIOUS.
     * @param context
     * @param themeID
     */
    public static void switchThemeToTarget(Context context, int themeID) {
        TUIThemeManager.getInstance().changeTheme(context, themeID);
    }

    /**
     * Set whether to enable message bubble style.The default value is true.
     * @param enable
     */
    public static void setEnableMessageBubbleStyle(boolean enable) {
        getInstance().enableMessageBubbleStyle = enable;
    }

    /**
     * Get whether to enable message bubble style.
     * @return true is enable, false is not
     */
    public static boolean isEnableMessageBubbleStyle() {
        return getInstance().enableMessageBubbleStyle;
    }

    /**
     * Set the background of the send message bubble.
     * @param drawable
     */
    public static void setSendBubbleBackground(Drawable drawable) {
        getInstance().sendBubbleBackground = drawable;
    }

    /**
     * Get the background of the send message bubble.
     * @return the background
     */
    public static Drawable getSendBubbleBackground() {
        return newDrawable(getInstance().sendBubbleBackground);
    }

    /**
     * Set the background of the receive message bubble.
     * @param drawable
     */
    public static void setReceiveBubbleBackground(Drawable drawable) {
        getInstance().receiveBubbleBackground = drawable;
    }

    /**
     * Get the background of the receive message bubble.
     * @return the background
     */
    public static Drawable getReceiveBubbleBackground() {
        return newDrawable(getInstance().receiveBubbleBackground);
    }

    /**
     * Set the background of the receive error message bubble.
     * @param receiveErrorBubbleBackground
     */
    public static void setReceiveErrorBubbleBackground(Drawable receiveErrorBubbleBackground) {
        getInstance().receiveErrorBubbleBackground = receiveErrorBubbleBackground;
    }

    /**
     * Get the background of the receive error message bubble.
     * @return the background
     */
    public static Drawable getReceiveErrorBubbleBackground() {
        return newDrawable(getInstance().receiveErrorBubbleBackground);
    }

    /**
     * Set the background of the send error message bubble.
     * @param sendErrorBubbleBackground
     */
    public static void setSendErrorBubbleBackground(Drawable sendErrorBubbleBackground) {
        getInstance().sendErrorBubbleBackground = sendErrorBubbleBackground;
    }

    /**
     * Get the background of the send error message bubble.
     * @return the background
     */
    public static Drawable getSendErrorBubbleBackground() {
        return newDrawable(getInstance().sendErrorBubbleBackground);
    }

    /**
     * Set the light color of the message bubble in highlight status..
     * @param color
     */
    public static void setBubbleHighlightLightColor(int color) {
        HighlightPresenter.setHighlightLightColor(color);
    }

    /**
     * Set the dark color of the message bubble in highlight status..
     * @param color
     */
    public static void setBubbleHighlightDarkColor(int color) {
        HighlightPresenter.setHighlightDarkColor(color);
    }

    /**
     * Set the chat time bubble.
     * @param drawable
     */
    public static void setChatTimeBubble(Drawable drawable) {
        getInstance().chatTimeBubble = drawable;
    }

    /**
     * Get the chat time bubble.
     * @return
     */
    public static Drawable getChatTimeBubble() {
        return newDrawable(getInstance().chatTimeBubble);
    }

    /**
     * Set the font size of the chat time text.
     * @param size
     */
    public static void setChatTimeFontSize(int size) {
        getInstance().chatTimeFontSize = size;
    }

    /**
     * Get the font size of the chat time text.
     * @return
     */
    public static int getChatTimeFontSize() {
        return getInstance().chatTimeFontSize;
    }

    /**
     * Set the font color of the chat time text.
     * @param color
     */
    public static void setChatTimeFontColor(int color) {
        getInstance().chatTimeFontColor = color;
    }

    /**
     * Get the font color of the chat time text.
     * @return
     */
    public static int getChatTimeFontColor() {
        return getInstance().chatTimeFontColor;
    }

    /**
     * Set the default avatar image.
     * @param drawable
     */
    public static void setDefaultAvatarImage(Drawable drawable) {
        getInstance().defaultAvatarImage = drawable;
    }

    /**
     * Get the default avatar image.
     * @return the default avatar image
     */
    public static Drawable getDefaultAvatarImage() {
        return newDrawable(getInstance().defaultAvatarImage);
    }

    /**
     * Set the radius of the avatar in the message list.
     * @param radius
     */
    public static void setMessageListAvatarRadius(int radius) {
        getInstance().avatarRadius = radius;
    }

    /**
     * Get the radius of the avatar in the message list.
     * @return
     */
    public static int getMessageListAvatarRadius() {
        return getInstance().avatarRadius;
    }

    /**
     * Set whether to enable the grid avatar with the group chat.The default value is true.
     * @param enableGroupGridAvatar
     */
    public static void setEnableGroupGridAvatar(boolean enableGroupGridAvatar) {
        TUIConfig.setEnableGroupGridAvatar(enableGroupGridAvatar);
    }

    /**
     * Set the avatar size in the message list.
     * @param size
     */
    public static void setMessageListAvatarSize(int size) {
        getInstance().avatarSize = size;
    }

    /**
     * Get the avatar size in the message list.
     * @return
     */
    public static int getMessageListAvatarSize() {
        return getInstance().avatarSize;
    }

    /**
     * Set whether to hide the nickname of the received message.
     * @param hideReceiveNickName
     */
    public static void setHideReceiveNickName(boolean hideReceiveNickName) {
        getInstance().receiveNickNameVisibility = hideReceiveNickName ? View.GONE : View.VISIBLE;
    }

    /**
     * Get the visibility of the nickname of the received message.
     * @return
     */
    public static int getReceiveNickNameVisibility() {
        return getInstance().receiveNickNameVisibility;
    }

    /**
     * Set the font size of the nickname of the received message.
     * @param size
     */
    public static void setReceiveNickNameFontSize(int size) {
        getInstance().receiveNickNameFontSize = size;
    }

    /**
     * Get the font size of the nickname of the received message.
     * @return
     */
    public static int getReceiveNickNameFontSize() {
        return getInstance().receiveNickNameFontSize;
    }

    /**
     * Set the font color of the nickname of the received message.
     * @param color
     */
    public static void setReceiveNickNameColor(int color) {
        getInstance().receiveNickNameColor = color;
    }

    /**
     * Get the font color of the nickname of the received message.
     * @return
     */
    public static int getReceiveNickNameColor() {
        return getInstance().receiveNickNameColor;
    }
}
