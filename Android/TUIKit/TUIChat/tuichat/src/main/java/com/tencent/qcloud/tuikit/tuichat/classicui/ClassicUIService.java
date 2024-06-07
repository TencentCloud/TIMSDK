package com.tencent.qcloud.tuikit.tuichat.classicui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;

import com.google.auto.service.AutoService;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUIObjectFactory;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonConstants;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingTipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomEvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.EmptyMessageBean;
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
import com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIC2CChatActivity;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIC2CChatFragment;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIGroupChatFragment;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.FaceReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.FileReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.ImageReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.LocationReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.MergeReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.SoundReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.TextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.VideoReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.CallingMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.CustomEvaluationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.CustomLinkMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.CustomOrderMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.FaceMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.FileMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.ImageMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.LocationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.MergeMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.QuoteMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.ReplyMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.SoundMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.TextMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.TipsMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.VideoMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.EmptyMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Internal service for ClassicUI
 */
@AutoService(TUIInitializer.class)
@TUIInitializerDependency("TUIChat")
@TUIInitializerID("TUIChatClassic")
public class ClassicUIService implements TUIInitializer, ITUIExtension, ITUIService, ITUIObjectFactory {
    private static ClassicUIService instance;

    public static ClassicUIService getInstance() {
        return instance;
    }

    private final Map<Class<? extends TUIMessageBean>, Integer> messageViewTypeMap = new HashMap<>();
    private final Map<Integer, Class<? extends RecyclerView.ViewHolder>> messageViewHolderMap = new HashMap<>();
    private final Set<Integer> emptyViewGroupMessageSet = new HashSet<>();
    private final Map<Class<? extends TUIReplyQuoteBean>, Class<? extends TUIReplyQuoteView>> replyMessageViewMap = new HashMap<>();
    private int viewType = 0;

    @Override
    public void init(Context context) {
        instance = this;
        initTheme();
        initService();
        initMessage();
        initExtension();
        initObjectFactory();
        initReplyMessage();
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TUIChat.Service.CLASSIC_SERVICE_NAME, this);
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.FriendProfileItem.CLASSIC_EXTENSION_ID, this);
    }

    private void initObjectFactory() {
        TUICore.registerObjectFactory(TUIConstants.TUIChat.ObjectFactory.OBJECT_FACTORY_NAME, this);
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
        addMessageType(CallingTipsMessageBean.class, TipsMessageHolder.class, true);
        addMessageType(CustomLinkMessageBean.class, CustomLinkMessageHolder.class);
        addMessageType(CustomEvaluationMessageBean.class, CustomEvaluationMessageHolder.class);
        addMessageType(CustomOrderMessageBean.class, CustomOrderMessageHolder.class);
        addMessageType(MessageTypingBean.class, null);
        addMessageType(EmptyMessageBean.class, EmptyMessageHolder.class, true);
    }

    public void addMessageType(Class<? extends TUIMessageBean> beanClazz, Class<? extends RecyclerView.ViewHolder> holderClazz) {
        addMessageType(beanClazz, holderClazz, false);
    }

    /**
     *  register custom message and the ViewHolder
     * @param beanClazz 
     * @param holderClazz  custom message's ViewHolder
     * @param isNeedEmptyViewGroup 
     */
    public void addMessageType(Class<? extends TUIMessageBean> beanClazz, Class<? extends RecyclerView.ViewHolder> holderClazz, boolean isNeedEmptyViewGroup) {
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

    public Class<? extends RecyclerView.ViewHolder> getMessageViewHolderClass(int viewType) {
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

    private void initTheme() {
        TUIThemeManager.addLightTheme(R.style.TUIChatLightTheme);
        TUIThemeManager.addLivelyTheme(R.style.TUIChatLivelyTheme);
        TUIThemeManager.addSeriousTheme(R.style.TUIChatSeriousTheme);
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIContact.Extension.FriendProfileItem.CLASSIC_EXTENSION_ID)) {
            return getClassicFriendProfileExtension(param);
        }
        return null;
    }

    private List<TUIExtensionInfo> getClassicFriendProfileExtension(Map<String, Object> param) {
        TUIExtensionInfo chatExtension = new TUIExtensionInfo();
        chatExtension.setWeight(400);
        chatExtension.setText(getAppContext().getString(R.string.chat_contact_profile_message));
        String userID = getOrDefault(param, TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, null);
        chatExtension.setExtensionListener(new TUIExtensionEventListener() {
            @Override
            public void onClicked(Map<String, Object> param) {
                Intent intent = new Intent(getAppContext(), TUIC2CChatActivity.class);
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
            addMessageType(messageBeanClass, messageViewHolderClass, isNeedEmptyViewGroup);
        }
        if (messageReplyBeanClass != null && messageReplyViewClass != null) {
            addReplyMessage(messageReplyBeanClass, messageReplyViewClass);
        }
    }

    @Override
    public Object onCreateObject(String objectName, Map<String, Object> param) {
        if (TextUtils.equals(objectName, TUIConstants.TUIChat.ObjectFactory.ChatFragment.OBJECT_NAME)) {
            return createChatFragmentObject(param);
        }
        return null;
    }

    @Nullable
    private Fragment createChatFragmentObject(Map<String, Object> param) {
        if (param != null && !param.isEmpty()) {
            String chatID = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_ID, "");
            String chatTitle = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_TITLE, null);
            int chatType =
                getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_TYPE, TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_TYPE_GROUP);
            if (TextUtils.isEmpty(chatID)) {
                return null;
            }
            SPUtils.getInstance(TIMCommonConstants.CHAT_SETTINGS_SP_NAME).put(TIMCommonConstants.CHAT_REPLY_GUIDE_SHOW_SP_KEY, false);
            boolean enableRoom = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_ROOM, true);
            boolean enableAudioCall = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_AUDIO_CALL, true);
            boolean enableVideoCall = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_VIDEO_CALL, true);
            boolean enableCustomHelloMessage = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_CUSTOM_HELLO_MESSAGE, false);
            boolean enablePollMessage = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_POLL, false);
            boolean enableGroupNoteMessage = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_GROUP_NOTE, false);
            boolean enableTakePhoto = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_TAKE_PHOTO, true);
            boolean enableRecordVideo = getOrDefault(param, TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_RECORD_VIDEO, true);

            if (chatType == TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_TYPE_GROUP) {
                GroupInfo groupInfo = new GroupInfo();
                groupInfo.setId(chatID);
                groupInfo.setChatName(chatTitle);
                groupInfo.setEnableRoom(enableRoom);
                groupInfo.setEnableAudioCall(enableAudioCall);
                groupInfo.setEnableVideoCall(enableVideoCall);
                groupInfo.setEnableCustomHelloMessage(enableCustomHelloMessage);
                groupInfo.setEnableGroupNote(enableGroupNoteMessage);
                groupInfo.setEnablePoll(enablePollMessage);
                groupInfo.setEnableTakePhoto(enableTakePhoto);
                groupInfo.setEnableRecordVideo(enableRecordVideo);
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIChatConstants.CHAT_INFO, groupInfo);
                TUIGroupChatFragment tuiGroupChatFragment = new TUIGroupChatFragment();
                tuiGroupChatFragment.setArguments(bundle);
                GroupChatPresenter presenter = new GroupChatPresenter();
                presenter.initListener();
                tuiGroupChatFragment.setPresenter(presenter);
                return tuiGroupChatFragment;
            } else {
                ChatInfo chatInfo = new ChatInfo();
                chatInfo.setId(chatID);
                chatInfo.setChatName(chatTitle);
                chatInfo.setEnableAudioCall(enableAudioCall);
                chatInfo.setEnableVideoCall(enableVideoCall);
                chatInfo.setEnableTakePhoto(enableTakePhoto);
                chatInfo.setEnableRecordVideo(enableRecordVideo);
                chatInfo.setEnableCustomHelloMessage(enableCustomHelloMessage);
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIChatConstants.CHAT_INFO, chatInfo);
                TUIC2CChatFragment tuic2CChatFragment = new TUIC2CChatFragment();
                tuic2CChatFragment.setArguments(bundle);
                C2CChatPresenter presenter = new C2CChatPresenter();
                presenter.initListener();
                tuic2CChatFragment.setPresenter(presenter);
                return tuic2CChatFragment;
            }
        }
        return null;
    }

    public static Context getAppContext() {
        return TUIChatService.getAppContext();
    }
}
