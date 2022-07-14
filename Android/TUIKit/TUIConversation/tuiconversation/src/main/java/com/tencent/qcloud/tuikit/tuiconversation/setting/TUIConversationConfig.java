package com.tencent.qcloud.tuikit.tuiconversation.setting;

public class TUIConversationConfig {
    public static final String TAG = TUIConversationConfig.class.getSimpleName();
    private static TUIConversationConfig instance;
    private boolean isShowUserStatus;

    public static TUIConversationConfig getInstance() {
        if (instance == null) {
            instance = new TUIConversationConfig();
        }

        return instance;
    }

    /**
     * 获取是否显示用户在线状态
     */
    public boolean isShowUserStatus() {
        return isShowUserStatus;
    }

    /**
     * 设置是否显示用户在线状态
     */
    public void setShowUserStatus(boolean showUserStatus) {
        isShowUserStatus = showUserStatus;
    }
}
