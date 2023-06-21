package com.tencent.qcloud.tuikit.tuichat.minimalistui;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomEvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.LocationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MessageTypingBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextAtMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomEvaluationMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomLinkReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomOrderMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FaceReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FileReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ImageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.LocationReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.MergeReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ReplyReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.SoundReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.VideoReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.TUIC2CChatMinimalistActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.TUIGroupChatMinimalistActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.FaceReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.FileReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.ImageReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.LocationReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.MergeReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.SoundReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.TextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.VideoReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CallingMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CustomEvaluationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CustomLinkMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CustomOrderMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.FaceMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.FileMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.ImageMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.LocationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MergeMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.QuoteMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.ReplyMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.SoundMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.TextMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.TipsMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.VideoMessageHolder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Internal service for MinimalistUI
 */
public class MinimalistUIService extends ServiceInitializer implements ITUIService, ITUIExtension {
    private static MinimalistUIService instance;

    public static MinimalistUIService getInstance() {
        return instance;
    }

    private final Map<Class<? extends TUIMessageBean>, Integer> messageViewTypeMap = new HashMap<>();
    private final Map<Integer, Class<? extends MessageBaseHolder>> messageViewHolderMap = new HashMap<>();
    private final Set<Integer> emptyViewGroupMessageSet = new HashSet<>();
    private final Map<Class<? extends TUIReplyQuoteBean>, Class<? extends TUIReplyQuoteView>> replyMessageViewMap = new HashMap<>();
    private int viewType = 0;

    @Override
    public void init(Context context) {
        instance = this;
        initService();
        initMessage();
        initExtension();
        initReplyMessage();
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TUIChat.Service.MINIMALIST_SERVICE_NAME, this);
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIGroup.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID, this);
    }

    public void initMessage() {
        addMessageType(FaceMessageBean.class, FaceMessageHolder.class);
        addMessageType(FileMessageBean.class, FileMessageHolder.class);
        addMessageType(ImageMessageBean.class, ImageMessageHolder.class);
        addMessageType(LocationMessageBean.class, LocationMessageHolder.class);
        addMessageType(MergeMessageBean.class, MergeMessageHolder.class);
        addMessageType(SoundMessageBean.class, SoundMessageHolder.class);
        addMessageType(TextAtMessageBean.class, TextMessageHolder.class);
        addMessageType(TextMessageBean.class, TextMessageHolder.class);
        addMessageType(TipsMessageBean.class, TipsMessageHolder.class, true);
        addMessageType(VideoMessageBean.class, VideoMessageHolder.class);
        addMessageType(ReplyMessageBean.class, ReplyMessageHolder.class);
        addMessageType(QuoteMessageBean.class, QuoteMessageHolder.class);
        addMessageType(CallingMessageBean.class, CallingMessageHolder.class);
        addMessageType(CustomLinkMessageBean.class, CustomLinkMessageHolder.class);
        addMessageType(CustomEvaluationMessageBean.class, CustomEvaluationMessageHolder.class);
        addMessageType(CustomOrderMessageBean.class, CustomOrderMessageHolder.class);
        addMessageType(MessageTypingBean.class, null);
    }

    public void addMessageType(Class<? extends TUIMessageBean> beanClazz, Class<? extends MessageBaseHolder> holderClazz) {
        addMessageType(beanClazz, holderClazz, false);
    }

    public void addMessageType(Class<? extends TUIMessageBean> beanClazz, Class<? extends MessageBaseHolder> holderClazz, boolean isNeedEmptyViewGroup) {
        viewType++;
        if (isNeedEmptyViewGroup) {
            emptyViewGroupMessageSet.add(viewType);
        }
        messageViewTypeMap.put(beanClazz, viewType);
        messageViewHolderMap.put(viewType, holderClazz);
    }

    private void initReplyMessage() {
        addReplyMessage(CustomEvaluationMessageReplyQuoteBean.class, TextReplyQuoteView.class);
        addReplyMessage(CustomLinkReplyQuoteBean.class, TextReplyQuoteView.class);
        addReplyMessage(CustomOrderMessageReplyQuoteBean.class, TextReplyQuoteView.class);
        addReplyMessage(FaceReplyQuoteBean.class, FaceReplyQuoteView.class);
        addReplyMessage(FileReplyQuoteBean.class, FileReplyQuoteView.class);
        addReplyMessage(ImageReplyQuoteBean.class, ImageReplyQuoteView.class);
        addReplyMessage(LocationReplyQuoteBean.class, LocationReplyQuoteView.class);
        addReplyMessage(MergeReplyQuoteBean.class, MergeReplyQuoteView.class);
        addReplyMessage(ReplyReplyQuoteBean.class, TextReplyQuoteView.class);
        addReplyMessage(SoundReplyQuoteBean.class, SoundReplyQuoteView.class);
        addReplyMessage(TextReplyQuoteBean.class, TextReplyQuoteView.class);
        addReplyMessage(VideoReplyQuoteBean.class, VideoReplyQuoteView.class);
    }

    public void addReplyMessage(Class<? extends TUIReplyQuoteBean> replyQuoteBeanClass, Class<? extends TUIReplyQuoteView> replyQuoteViewClass) {
        replyMessageViewMap.put(replyQuoteBeanClass, replyQuoteViewClass);
    }

    public Class<? extends TUIReplyQuoteView> getReplyMessageViewClass(Class<? extends TUIReplyQuoteBean> replyQuoteBeanType) {
        return replyMessageViewMap.get(replyQuoteBeanType);
    }

    public Class<? extends MessageBaseHolder> getMessageViewHolderClass(int viewType) {
        return messageViewHolderMap.get(viewType);
    }

    public int getViewType(Class<? extends TUIMessageBean> messageBeanClass) {
        Integer viewType = messageViewTypeMap.get(messageBeanClass);
        if (viewType != null) {
            return viewType;
        } else {
            return 0;
        }
    }

    public boolean isNeedEmptyViewGroup(int viewType) {
        return emptyViewGroupMessageSet.contains(viewType);
    }

    @Override
    public int getLightThemeResId() {
        return R.style.TUIChatLightTheme;
    }

    @Override
    public int getLivelyThemeResId() {
        return R.style.TUIChatLivelyTheme;
    }

    @Override
    public int getSeriousThemeResId() {
        return R.style.TUIChatSeriousTheme;
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID)) {
            return getMinimalistFriendProfileExtension(param);
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIGroup.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID)) {
            return getMinimalistGroupProfileExtension(param);
        }
        return null;
    }

    private List<TUIExtensionInfo> getMinimalistFriendProfileExtension(Map<String, Object> param) {
        TUIExtensionInfo chatExtension = new TUIExtensionInfo();
        chatExtension.setWeight(400);
        chatExtension.setIcon(R.drawable.chat_contact_profile_item_extension_message_icon);
        chatExtension.setText(getAppContext().getString(R.string.chat_contact_profile_message));
        String userID = getOrDefault(param, TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, null);
        chatExtension.setExtensionListener(new TUIExtensionEventListener() {
            @Override
            public void onClicked(Map<String, Object> param) {
                Intent intent = new Intent(getAppContext(), TUIC2CChatMinimalistActivity.class);
                intent.putExtra(TUIConstants.TUIChat.CHAT_TYPE, V2TIMConversation.V2TIM_C2C);
                intent.putExtra(TUIConstants.TUIChat.CHAT_ID, userID);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getAppContext().startActivity(intent);
            }
        });
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        extensionInfoList.add(chatExtension);
        return extensionInfoList;
    }

    private List<TUIExtensionInfo> getMinimalistGroupProfileExtension(Map<String, Object> param) {
        TUIExtensionInfo chatExtension = new TUIExtensionInfo();
        chatExtension.setWeight(400);
        chatExtension.setIcon(R.drawable.chat_contact_profile_item_extension_message_icon);
        chatExtension.setText(getAppContext().getString(R.string.chat_contact_profile_message));
        String groupID = getOrDefault(param, TUIConstants.TUIGroup.Extension.GroupProfileItem.GROUP_ID, null);
        chatExtension.setExtensionListener(new TUIExtensionEventListener() {
            @Override
            public void onClicked(Map<String, Object> param) {
                Intent intent = new Intent(getAppContext(), TUIGroupChatMinimalistActivity.class);
                intent.putExtra(TUIConstants.TUIChat.CHAT_TYPE, V2TIMConversation.V2TIM_GROUP);
                intent.putExtra(TUIConstants.TUIChat.CHAT_ID, groupID);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getAppContext().startActivity(intent);
            }
        });
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        extensionInfoList.add(chatExtension);
        return extensionInfoList;
    }

    private <T> T getOrDefault(Map map, Object key, T defaultValue) {
        if (map == null || map.isEmpty()) {
            return defaultValue;
        }
        Object object = map.get(key);
        try {
            if (object != null) {
                return (T) object;
            }
        } catch (ClassCastException e) {
            return defaultValue;
        }
        return defaultValue;
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        if (TextUtils.equals(TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, method)) {
            registerCustomMessage(param);
        }
        return null;
    }

    private void registerCustomMessage(Map<String, Object> param) {
        String businessID = (String) param.get(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID);
        Class<? extends TUIMessageBean> messageBeanClass = getOrDefault(param, TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, null);
        Class messageViewHolderClass = getOrDefault(param, TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, null);
        Class<? extends TUIReplyQuoteBean> messageReplyBeanClass =
            getOrDefault(param, TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, null);
        Class messageReplyViewClass = getOrDefault(param, TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, null);
        boolean isNeedEmptyViewGroup = getOrDefault(param, TUIConstants.TUIChat.Method.RegisterCustomMessage.IS_NEED_EMPTY_VIEW_GROUP, false);
        TUIChatService.getInstance().addCustomMessageType(businessID, messageBeanClass, false);
        if (messageBeanClass != null) {
            MinimalistUIService.getInstance().addMessageType(messageBeanClass, messageViewHolderClass, isNeedEmptyViewGroup);
        }
        if (messageReplyBeanClass != null && messageReplyViewClass != null) {
            MinimalistUIService.getInstance().addReplyMessage(messageReplyBeanClass, messageReplyViewClass);
        }
    }
}
