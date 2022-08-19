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

    public boolean isShowUserStatus() {
        return isShowUserStatus;
    }

    public void setShowUserStatus(boolean showUserStatus) {
        isShowUserStatus = showUserStatus;
    }
}
