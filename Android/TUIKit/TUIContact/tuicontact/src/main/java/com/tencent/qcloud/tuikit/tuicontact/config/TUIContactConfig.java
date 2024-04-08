package com.tencent.qcloud.tuikit.tuicontact.config;

public class TUIContactConfig {
    public static final String TAG = TUIContactConfig.class.getSimpleName();
    private static TUIContactConfig instance;
    private boolean isShowUserStatus;

    public static TUIContactConfig getInstance() {
        if (instance == null) {
            instance = new TUIContactConfig();
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
