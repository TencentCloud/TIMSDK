package com.tencent.qcloud.tuikit.tuiconversation.config.classicui;

import static com.tencent.qcloud.tuikit.timcommon.util.TUIUtil.newDrawable;

import android.graphics.drawable.Drawable;

import androidx.annotation.IntDef;

import com.tencent.qcloud.tuikit.timcommon.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationPopMenuItem;
import com.tencent.qcloud.tuikit.tuiconversation.config.TUIConversationConfig;

import java.util.ArrayList;
import java.util.List;

public class TUIConversationConfigClassic {
    public static final int UNDEFINED = -1;

    private TUIConversationConfigClassic() {}

    private static final class TUIConversationConfigClassicHolder {
        private static final TUIConversationConfigClassic INSTANCE = new TUIConversationConfigClassic();
    }

    private static TUIConversationConfigClassic getInstance() {
        return TUIConversationConfigClassicHolder.INSTANCE;
    }

    public static final int HIDE = 1;
    public static final int DELETE = 2;

    @IntDef({HIDE, DELETE})
    public @interface ConversationMenuItem {}

    private Drawable listBackground;
    private Drawable cellBackground;
    private Drawable pinnedCellBackground;
    private int cellTitleLabelFontSize = UNDEFINED;
    private int cellSubtitleLabelFontSize = UNDEFINED;
    private int cellTimeLabelFontSize = UNDEFINED;
    private int avatarCornerRadius = UNDEFINED;
    private boolean showCellUnreadCount = true;
    private ConversationMenuItemDataSource conversationMenuItemDataSource;

    /**
     * Set the background of the conversation list
     * @param listBackground
     */
    public static void setListBackground(Drawable listBackground) {
        getInstance().listBackground = listBackground;
    }

    /**
     * Get the background of the conversation list
     * @return
     */
    public static Drawable getListBackground() {
        return newDrawable(getInstance().listBackground);
    }

    /**
     * Set the background of the conversation cell
     * @param cellBackground
     */
    public static void setCellBackground(Drawable cellBackground) {
        getInstance().cellBackground = cellBackground;
    }

    /**
     * Get the background of the conversation cell
     * @return
     */
    public static Drawable getCellBackground() {
        return newDrawable(getInstance().cellBackground);
    }

    /**
     * Set the background of the pinned conversation cell
     * @param pinnedCellBackground
     */
    public static void setPinnedCellBackground(Drawable pinnedCellBackground) {
        getInstance().pinnedCellBackground = pinnedCellBackground;
    }

    /**
     * Get the background of the pinned conversation cell
     * @return
     */
    public static Drawable getPinnedCellBackground() {
        return newDrawable(getInstance().pinnedCellBackground);
    }

    /**
     * Set the font size of the conversation cell title label
     * @param cellTitleLabelFontSize
     */
    public static void setCellTitleLabelFontSize(int cellTitleLabelFontSize) {
        getInstance().cellTitleLabelFontSize = cellTitleLabelFontSize;
    }

    /**
     * Get the font size of the conversation cell title label
     * @return
     */
    public static int getCellTitleLabelFontSize() {
        return getInstance().cellTitleLabelFontSize;
    }

    /**
     * Set the font size of the conversation cell subtitle label
     * @param cellSubtitleLabelFontSize
     */
    public static void setCellSubtitleLabelFontSize(int cellSubtitleLabelFontSize) {
        getInstance().cellSubtitleLabelFontSize = cellSubtitleLabelFontSize;
    }

    /**
     * Get the font size of the conversation cell subtitle label
     * @return
     */
    public static int getCellSubtitleLabelFontSize() {
        return getInstance().cellSubtitleLabelFontSize;
    }

    /**
     * Set the font size of the conversation cell time label
     * @param cellTimeLabelFontSize
     */
    public static void setCellTimeLabelFontSize(int cellTimeLabelFontSize) {
        getInstance().cellTimeLabelFontSize = cellTimeLabelFontSize;
    }

    /**
     * Get the font size of the conversation cell time label
     * @return
     */
    public static int getCellTimeLabelFontSize() {
        return getInstance().cellTimeLabelFontSize;
    }

    /**
     * Set the corner radius of the conversation cell avatar
     * @param avatarCornerRadius
     */
    public static void setAvatarCornerRadius(int avatarCornerRadius) {
        getInstance().avatarCornerRadius = avatarCornerRadius;
    }

    /**
     * Get the corner radius of the conversation cell avatar
     * @return
     */
    public static int getAvatarCornerRadius() {
        return getInstance().avatarCornerRadius;
    }

    /**
     * Set whether to show the user online status icon
     * @param showUserOnlineStatusIcon
     */
    public static void setShowUserOnlineStatusIcon(boolean showUserOnlineStatusIcon) {
        TUIConversationConfig.getInstance().setShowUserStatus(showUserOnlineStatusIcon);
    }

    /**
     * Get whether to show the user online status icon on the conversation cell
     * @return
     */
    public static boolean isShowUserOnlineStatusIcon() {
        return TUIConversationConfig.getInstance().isShowUserStatus();
    }

    /**
     * Set whether to show the unread count of the conversation cell
     * @param showCellUnreadCount
     */
    public static void setShowCellUnreadCount(boolean showCellUnreadCount) {
        getInstance().showCellUnreadCount = showCellUnreadCount;
    }

    /**
     * Get whether to show the unread count of the conversation cell
     * @return
     */
    public static boolean isShowCellUnreadCount() {
        return getInstance().showCellUnreadCount;
    }

    /**
     * Set the data source of the conversation long-press menu item
     * @param conversationMenuItemDataSource
     * @see ConversationMenuItemDataSource
     */
    public static void setConversationMenuItemDataSource(ConversationMenuItemDataSource conversationMenuItemDataSource) {
        getInstance().conversationMenuItemDataSource = conversationMenuItemDataSource;
    }

    /**
     * Get the data source of the conversation long-press menu item
     * @return the data source
     * @see ConversationMenuItemDataSource
     */
    public static ConversationMenuItemDataSource getConversationMenuItemDataSource() {
        return getInstance().conversationMenuItemDataSource;
    }

    public interface ConversationMenuItemDataSource {
        /**
         * Implement this method to add new items.
         * @param conversationInfo
         * @return the items to be added
         */
        default List<PopMenuAction> conversationShouldAddNewItemsToMoreMenu(ConversationInfo conversationInfo) {
            return new ArrayList<>();
        }

        /**
         * Implement this method to hide items in more menu.
         * @param conversationInfo
         * @return the items to be hidden
         */
        default @ConversationMenuItem List<Integer> conversationShouldHideItemsInMoreMenu(ConversationInfo conversationInfo) {
            return new ArrayList<>();
        }
    }
}
