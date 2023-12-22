package com.tencent.qcloud.tuikit.tuichat.config;

import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout.NoticeLayoutConfig;
import java.util.HashMap;
import java.util.Map;

public class TUIChatConfigs {
    public static final int STYLE_TYPE_CLASSIC = 1;
    public static final int STYLE_TYPE_MINIMALIST = 2;

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

    /**
     * 注册自定义消息 默认向经典版 UI 注册，不使用空布局
     * 如果需要更多定制需求，可以使用 {@link #registerCustomMessage(String, Class, Class, int, boolean)}
     * @param businessID 自定义消息 businessID（注意不能重复）
     * @param messageBeanClass 自定义消息 MessageBean 类型
     * @param messageViewHolderClass 自定义消息 MessageViewHolder 类型
     *
     * Register custom message, by default, register to the classic UI and do not use an empty layout.
     * If more customization is needed, you can use {@link #registerCustomMessage(String, Class, Class, int, boolean)}
     * @param businessID Custom message businessID (note that it must be unique)
     * @param messageBeanClass Custom message MessageBean type
     * @param messageViewHolderClass Custom message MessageViewHolder type
     */
    public static void registerCustomMessage(
        String businessID, Class<? extends TUIMessageBean> messageBeanClass, Class<? extends RecyclerView.ViewHolder> messageViewHolderClass) {
        registerCustomMessage(businessID, messageBeanClass, messageViewHolderClass, STYLE_TYPE_CLASSIC, false);
    }

    /**
     * 注册自定义消息
     * @param businessID 自定义消息 businessID（注意不能重复）
     * @param messageBeanClass 自定义消息 MessageBean 类型
     * @param messageViewHolderClass 自定义消息 MessageViewHolder 类型
     * @param styleType 此自定义消息对应的 UI 风格，例如 {@link STYLE_TYPE_CLASSIC}
     * @param isUseEmptyViewGroup 设置是否使用空布局。默认不使用空布局。如果设置了使用空布局，自定义消息不会显示用户头像、消息气泡等内容
     *
     * Register custom message
     * @param businessID Custom message businessID (note that it must be unique)
     * @param messageBeanClass Custom message MessageBean type
     * @param messageViewHolderClass Custom message MessageViewHolder type
     * @param styleType UI style corresponding to this custom message, for example {@link STYLE_TYPE_CLASSIC}
     * @param isUseEmptyViewGroup Set whether to use an empty layout. By default, an empty layout is not used. If set to use an empty layout, the custom message
     *     will not display user avatars, message bubbles, and other content.
     */
    public static void registerCustomMessage(String businessID, Class<? extends TUIMessageBean> messageBeanClass,
        Class<? extends RecyclerView.ViewHolder> messageViewHolderClass, int styleType, boolean isUseEmptyViewGroup) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID, businessID);
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, messageBeanClass);
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, messageViewHolderClass);
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.IS_NEED_EMPTY_VIEW_GROUP, isUseEmptyViewGroup);
        String serviceName;
        if (styleType == STYLE_TYPE_CLASSIC) {
            serviceName = TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME;
        } else {
            serviceName = TUIConstants.TUIChat.Method.RegisterCustomMessage.MINIMALIST_SERVICE_NAME;
        }
        TUICore.callService(serviceName, TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, param);
    }
}
