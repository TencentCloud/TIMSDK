package com.tencent.qcloud.tuikit.tuiemojiplugin.presenter;

import android.text.TextUtils;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuiemojiplugin.TUIEmojiPluginService;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.OnMessageReactionsChangedListener;

import java.util.WeakHashMap;

public class MessageReactionBeanCache {

    private static final MessageReactionBeanCache instance = new MessageReactionBeanCache();

    private final WeakHashMap<TUIMessageBean, MessageReactionBean> cacheMap = new WeakHashMap<>();

    private OnMessageReactionsChangedListener messageReactionsChangedListener;

    private MessageReactionBeanCache() {
        messageReactionsChangedListener = new OnMessageReactionsChangedListener() {
            @Override
            public void onMessageReactionsChanged(MessageReactionBean messageReactionBean) {
                for (TUIMessageBean messageBean : instance.cacheMap.keySet()) {
                    if (TextUtils.equals(messageBean.getId(), messageReactionBean.getMessageID())) {
                        instance.cacheMap.put(messageBean, messageReactionBean);
                        TUIChatService.getInstance().refreshMessage(messageBean);
                    }
                }
            }
        };
        TUIEmojiPluginService.addReactionsChangedListener(messageReactionsChangedListener);
    }

    public static void putMessageReactionBean(TUIMessageBean messageBean, MessageReactionBean messageReactionBean) {
        if (messageBean == null || messageReactionBean == null) {
            return;
        }

        instance.cacheMap.put(messageBean, messageReactionBean);
    }

    public static void putMessageReactionBean(String messageID, MessageReactionBean messageReactionBean) {
        if (TextUtils.isEmpty(messageID) || messageReactionBean == null) {
            return;
        }
        for (TUIMessageBean messageBean : instance.cacheMap.keySet()) {
            if (TextUtils.equals(messageBean.getId(), messageID)) {
                instance.cacheMap.put(messageBean, messageReactionBean);
            }
        }
    }

    public static MessageReactionBean getMessageReactionBean(TUIMessageBean messageBean) {
        return instance.cacheMap.get(messageBean);
    }

    public static MessageReactionBean getMessageReactionBean(String messageID) {
        for (TUIMessageBean messageBean : instance.cacheMap.keySet()) {
            if (TextUtils.equals(messageBean.getId(), messageID)) {
                return instance.cacheMap.get(messageBean);
            }
        }
        return null;
    }

    public static boolean contains(String messageID) {
        for (TUIMessageBean messageBean : instance.cacheMap.keySet()) {
            if (TextUtils.equals(messageBean.getId(), messageID)) {
                return true;
            }
        }
        return false;
    }

    public static void clear() {
        instance.cacheMap.clear();
    }
}
