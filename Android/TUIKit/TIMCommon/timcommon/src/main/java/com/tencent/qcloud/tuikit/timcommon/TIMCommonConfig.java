package com.tencent.qcloud.tuikit.timcommon;

public class TIMCommonConfig {
    private static boolean enableGroupGridAvatar = true;
    private static int defaultAvatarImage;
    private static int defaultGroupAvatarImage;

    /**
     * 获取群组会话否展示九宫格样式的头像，默认为 true
     * Gets whether to display the avatar in the nine-square grid style in the group conversation, the default is true
     */
    public static boolean isEnableGroupGridAvatar() {
        return enableGroupGridAvatar;
    }

    /**
     * 设置群组会话是否展示九宫格样式的头像
     * Set whether to display the avatar in the nine-square grid style in group conversations
     */
    public static void setEnableGroupGridAvatar(boolean enableGroupGridAvatar) {
        TIMCommonConfig.enableGroupGridAvatar = enableGroupGridAvatar;
    }

    /**
     * 获取 c2c 会话的默认头像
     *
     * Get the default avatar for c2c conversation
     *
     * @return
     */
    public static int getDefaultAvatarImage() {
        return defaultAvatarImage;
    }

    /**
     * 设置 c2c 会话的默认头像
     *
     *Set the default avatar for c2c conversation
     *
     * @return
     */
    public static void setDefaultAvatarImage(int defaultAvatarImage) {
        TIMCommonConfig.defaultAvatarImage = defaultAvatarImage;
    }

    /**
     * 获取 group 会话的默认头像
     *
     * Get the default avatar for group conversation
     *
     * @return
     */
    public static int getDefaultGroupAvatarImage() {
        return defaultGroupAvatarImage;
    }

    /**
     * 设置 group 会话的默认头像
     *
     *Set the default avatar for group conversation
     *
     * @return
     */
    public static void setDefaultGroupAvatarImage(int defaultGroupAvatarImage) {
        TIMCommonConfig.defaultGroupAvatarImage = defaultGroupAvatarImage;
    }
}
