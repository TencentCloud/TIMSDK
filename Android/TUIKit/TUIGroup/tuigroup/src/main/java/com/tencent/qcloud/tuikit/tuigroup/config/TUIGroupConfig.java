package com.tencent.qcloud.tuikit.tuigroup.config;

import androidx.annotation.IntDef;

import com.tencent.imsdk.v2.V2TIMGroupInfo;

import java.util.ArrayList;
import java.util.List;

public class TUIGroupConfig {

    private static final TUIGroupConfig instance = new TUIGroupConfig();

    private static TUIGroupConfig getInstance() {
        return instance;
    }

    private TUIGroupConfig() {}

    public static final int MUTE_AND_PIN = 1;
    public static final int MANAGE = 2;
    public static final int ALIAS = 3;
    public static final int BACKGROUND = 4;
    public static final int MEMBERS = 5;
    public static final int CLEAR_CHAT_HISTORY = 6;
    public static final int DELETE_AND_LEAVE = 7;
    public static final int TRANSFER = 8;
    public static final int DISMISS = 9;

    @IntDef({MUTE_AND_PIN, MANAGE, ALIAS, BACKGROUND, MEMBERS, CLEAR_CHAT_HISTORY, DELETE_AND_LEAVE, TRANSFER, DISMISS})
    public @interface Items {}

    private boolean showMuteAndPin = true;
    private boolean showManage = true;
    private boolean showAlias = true;
    private boolean showBackground = true;
    private boolean showMembers = true;
    private boolean showClearChatHistory = true;
    private boolean showDeleteAndLeave = true;
    private boolean showTransfer = true;
    private boolean showDismiss = true;

    /**
     * Hide items in group config interface.
     * @param items The items to be hidden.
     */
    public static void hideItemsInGroupConfig(@Items int... items) {
        for (int itemType : items) {
            switch (itemType) {
                case MUTE_AND_PIN: {
                    getInstance().showMuteAndPin = false;
                    break;
                }
                case MANAGE: {
                    getInstance().showManage = false;
                    break;
                }
                case ALIAS: {
                    getInstance().showAlias = false;
                    break;
                }
                case BACKGROUND: {
                    getInstance().showBackground = false;
                    break;
                }
                case MEMBERS: {
                    getInstance().showMembers = false;
                    break;
                }
                case CLEAR_CHAT_HISTORY: {
                    getInstance().showClearChatHistory = false;
                    break;
                }
                case DELETE_AND_LEAVE: {
                    getInstance().showDeleteAndLeave = false;
                    break;
                }
                case TRANSFER: {
                    getInstance().showTransfer = false;
                    break;
                }
                case DISMISS: {
                    getInstance().showDismiss = false;
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }

    /**
     * Get whether to show the mute and pin setting.
     * @return
     */
    public static boolean isShowMuteAndPin() {
        return getInstance().showMuteAndPin;
    }

    /**
     * Get whether to show the manage group item.
     * @return
     */
    public static boolean isShowManage() {
        return getInstance().showManage;
    }

    /**
     * Get whether to show the alias setting.
     * @return
     */
    public static boolean isShowAlias() {
        return getInstance().showAlias;
    }

    /**
     * Get whether to show the chat background setting.
     * @return
     */
    public static boolean isShowBackground() {
        return getInstance().showBackground;
    }

    /**
     * Get whether to show the group members widget.
     * @return
     */
    public static boolean isShowMembers() {
        return getInstance().showMembers;
    }

    /**
     * Get whether to show the clear chat history button.
     * @return
     */
    public static boolean isShowClearChatHistory() {
        return getInstance().showClearChatHistory;
    }

    /**
     * Get whether to show the delete and leave button.
     * @return
     */
    public static boolean isShowDeleteAndLeave() {
        return getInstance().showDeleteAndLeave;
    }

    /**
     * Get whether to show the transfer button.
     * @return
     */
    public static boolean isShowTransfer() {
        return getInstance().showTransfer;
    }

    /**
     * Get whether to show the dismiss button.
     * @return
     */
    public static boolean isShowDismiss() {
        return getInstance().showDismiss;
    }

}
