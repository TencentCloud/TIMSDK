package com.tencent.qcloud.tim.uikit.base;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class TUIKitListenerManager {
    private static final TUIKitListenerManager INSTANCE = new TUIKitListenerManager();

    private final List<TUIChatControllerListener> mTUIChatControllerListeners = new ArrayList<>();

    private final List<TUIConversationControllerListener> mTUIConversationControllerListeners = new ArrayList<>();

    private WeakReference<IBaseMessageSender> messageSender;

    public static TUIKitListenerManager getInstance() {
        return INSTANCE;
    }

    public void addChatListener(TUIChatControllerListener chatListener) {
        if (chatListener == null) {
            return;
        }
        mTUIChatControllerListeners.add(chatListener);
    }

    public void removeChatListener(TUIChatControllerListener chatListener) {
        if (chatListener == null) {
            return;
        }
        mTUIChatControllerListeners.remove(chatListener);
    }

    public void addConversationListener(TUIConversationControllerListener conversationListener) {
        if (conversationListener == null) {
            return;
        }
        mTUIConversationControllerListeners.add(conversationListener);
    }

    public void removeMessageListener(TUIConversationControllerListener conversationListener) {
        if (conversationListener == null) {
            return;
        }
        mTUIConversationControllerListeners.remove(conversationListener);
    }

    public List<TUIChatControllerListener> getTUIChatListeners() {
        return mTUIChatControllerListeners;
    }

    public List<TUIConversationControllerListener> getTUIConversationListeners() {
        return mTUIConversationControllerListeners;
    }

    public void setMessageSender(IBaseMessageSender baseMessageSender) {
        messageSender = new WeakReference<>(baseMessageSender);
    }

    public IBaseMessageSender getMessageSender() {
        if (messageSender != null) {
            return messageSender.get();
        }
        return null;
    }
}
