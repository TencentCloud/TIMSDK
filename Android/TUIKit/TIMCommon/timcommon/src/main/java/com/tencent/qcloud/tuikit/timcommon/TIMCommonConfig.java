package com.tencent.qcloud.tuikit.timcommon;

public class TIMCommonConfig {
    private static boolean enableGroupGridAvatar = true;
    private static int defaultAvatarImage;
    private static int defaultGroupAvatarImage;

    /**
     * Gets whether to display the avatar in the nine-square grid style in the group conversation, the default is true
     */
    public static boolean isEnableGroupGridAvatar() {
        return enableGroupGridAvatar;
    }

    /**
     * Set whether to display the avatar in the nine-square grid style in group conversations
     */
    public static void setEnableGroupGridAvatar(boolean enableGroupGridAvatar) {
        TIMCommonConfig.enableGroupGridAvatar = enableGroupGridAvatar;
    }

    /**
     *
     * Get the default avatar for c2c conversation
     *
     * @return
     */
    public static int getDefaultAvatarImage() {
        return defaultAvatarImage;
    }

    /**
     *
     *Set the default avatar for c2c conversation
     *
     * @return
     */
    public static void setDefaultAvatarImage(int defaultAvatarImage) {
        TIMCommonConfig.defaultAvatarImage = defaultAvatarImage;
    }

    /**
     *
     * Get the default avatar for group conversation
     *
     * @return
     */
    public static int getDefaultGroupAvatarImage() {
        return defaultGroupAvatarImage;
    }

    /**
     *
     *Set the default avatar for group conversation
     *
     * @return
     */
    public static void setDefaultGroupAvatarImage(int defaultGroupAvatarImage) {
        TIMCommonConfig.defaultGroupAvatarImage = defaultGroupAvatarImage;
    }
}
