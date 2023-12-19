package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout.NoticeLayoutConfig;

public class TUIChatConfigs {
    private static final TUIChatConfigs sConfigs = new TUIChatConfigs();

    // 通用配置，例如是否开启未读，是否开启已读回执等
    // General settings, such as enabling unread message notifications, enabling read receipts, etc.
    private final GeneralConfig generalConfig = new GeneralConfig();
    // 设置聊天界面上方的提示信息布局
    // Set the layout of the information displayed above the chat layout.
    private final NoticeLayoutConfig noticeLayoutConfig = new NoticeLayoutConfig();
    // 设置 Chat 事件监听监听，比如点击用户头像事件，长按消息事件等
    // Set up Chat event listeners, such as user avatar click events, long-press message events, etc.
    private final ChatEventConfig chatEventConfig = new ChatEventConfig();

    private TUIChatConfigs() {}

    /**
     * 获取TUIKit的全部配置
     *
     * Get TUIKit configs
     *
     * @return
     */
    @Deprecated
    public static TUIChatConfigs getConfigs() {
        return sConfigs;
    }

    /**
     * 获取TUIKit的通用配置
     *
     * Get TUIKit general configs
     *
     */
    public static GeneralConfig getGeneralConfig() {
        return sConfigs.generalConfig;
    }

    /**
     * 获取聊天界面自定义视图配置
     *
     * Get chat interface custom view configuration
     *
     */
    public static NoticeLayoutConfig getNoticeLayoutConfig() {
        return sConfigs.noticeLayoutConfig;
    }

    /**
     * 获取聊天界面事件监听配置，并向其注册事件监听
     * 例如，在 MainActivity 中调用下面的方法，拦截并处理消息点击和长按事件：
     *
     * Obtain the chat interface event monitoring configuration, such as clicking on the avatar, long pressing on the message, etc.
     * To intercept and handle message click and long-press events in MainActivity, you can call the following methods:
     *
     * TUIChatConfigs.getChatEventConfig().setChatEventListener(new ChatEventListener() {
     *     @Override
     *     public boolean onMessageClicked(View view, TUIMessageBean messageBean) {
     *         // do something
     *         return true;
     *     }
     *
     *     @Override
     *     public boolean onMessageLongClicked(View view, TUIMessageBean messageBean) {
     *         // do something
     *         return true;
     *      }
     * });
     */
    public static ChatEventConfig getChatEventConfig() {
        return sConfigs.chatEventConfig;
    }
}
