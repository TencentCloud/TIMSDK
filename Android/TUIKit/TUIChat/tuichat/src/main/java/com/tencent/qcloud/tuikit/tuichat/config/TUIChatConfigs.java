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

    
    // General settings, such as enabling unread message notifications, enabling read receipts, etc.
    private final GeneralConfig generalConfig = new GeneralConfig();
    
    // Set the layout of the information displayed above the chat layout.
    private final NoticeLayoutConfig noticeLayoutConfig = new NoticeLayoutConfig();
    
    // Set up Chat event listeners, such as user avatar click events, long-press message events, etc.
    private final ChatEventConfig chatEventConfig = new ChatEventConfig();

    private TUIChatConfigs() {}

    /**
     * TUIKit
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
     * TUIKit
     *
     * Get TUIKit general configs
     *
     */
    public static GeneralConfig getGeneralConfig() {
        return sConfigs.generalConfig;
    }

    /**
     *
     * Get chat interface custom view configuration
     *
     */
    public static NoticeLayoutConfig getNoticeLayoutConfig() {
        return sConfigs.noticeLayoutConfig;
    }

    /**
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
