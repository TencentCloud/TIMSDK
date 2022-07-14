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
