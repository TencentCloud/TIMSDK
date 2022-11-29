package com.tencent.qcloud.tuikit.tuiconversation;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.ConversationEventListener;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TUIConversationService extends ServiceInitializer implements ITUIConversationService {
    public static final String TAG = TUIConversationService.class.getSimpleName();
    private static TUIConversationService instance;

    public static TUIConversationService getInstance() {
        return instance;
    }
    private boolean syncFinished = false;

    private WeakReference<ConversationEventListener> conversationEventListener;
    private final List<WeakReference<ConversationEventListener>> conversationEventListenerList = new ArrayList<>();

    @Override
    public void init(Context context) {
        instance = this;
        initService();
        initEvent();
        initIMListener();
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TUIConversation.SERVICE_NAME, this);
    }

    private void initEvent() {
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE, this);
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE, this);
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_USER, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE, this);
        TUICore.registerEvent(TUIConstants.TUIChat.EVENT_KEY_RECEIVE_MESSAGE, TUIConstants.TUIChat.EVENT_SUB_KEY_CONVERSATION_ID, this);
        TUICore.registerEvent(TUIConstants.TUIConversation.EVENT_KEY_MESSAGE_SEND_FOR_CONVERSATION, TUIConstants.TUIConversation.EVENT_SUB_KEY_MESSAGE_SEND_FOR_CONVERSATION, this);
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        Bundle result = new Bundle();

        ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
        if (conversationEventListener == null) {
            TUIConversationLog.e(TAG, "execute " + method + " failed , conversationEvent listener is null");
            return result;
        }
        if (TextUtils.equals(TUIConstants.TUIConversation.METHOD_IS_TOP_CONVERSATION, method)) {
            String chatId = (String) param.get(TUIConstants.TUIConversation.CHAT_ID);
            if (!TextUtils.isEmpty(chatId)) {
                boolean isTop = conversationEventListener.isTopConversation(chatId);
                result.putBoolean(TUIConstants.TUIConversation.IS_TOP, isTop);
            }
        } else if (TextUtils.equals(TUIConstants.TUIConversation.METHOD_SET_TOP_CONVERSATION, method)) {
            String chatId = (String) param.get(TUIConstants.TUIConversation.CHAT_ID);
            boolean isTop = (boolean) param.get(TUIConstants.TUIConversation.IS_SET_TOP);
            if (!TextUtils.isEmpty(chatId)) {
                conversationEventListener.setConversationTop(chatId, isTop, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                    }
                });
            }
        } else if (TextUtils.equals(TUIConstants.TUIConversation.METHOD_GET_TOTAL_UNREAD_COUNT, method)) {
            return conversationEventListener.getUnreadTotal();
        } else if (TextUtils.equals(TUIConstants.TUIConversation.METHOD_UPDATE_TOTAL_UNREAD_COUNT, method)) {
            HashMap<String, Object> unreadMap = new HashMap<>();
            long totalUnread = conversationEventListener.getUnreadTotal();
            unreadMap.put(TUIConstants.TUIConversation.TOTAL_UNREAD_COUNT, totalUnread);
            TUICore.notifyEvent(TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, unreadMap);
        } else if (TextUtils.equals(TUIConstants.TUIConversation.METHOD_DELETE_CONVERSATION, method)) {
            String conversationId = (String) param.get(TUIConstants.TUIConversation.CONVERSATION_ID);
            conversationEventListener.clearFoldMarkAndDeleteConversation(conversationId);

            List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
            for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                conversationEventObserver.clearFoldMarkAndDeleteConversation(conversationId);
            }
        }
        return result;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUIGroup.EVENT_GROUP)) {
            if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP)
                    || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS)
                    || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE)) {
                ConversationEventListener eventListener = getConversationEventListener();
                String groupId = null;
                if (param != null) {
                    groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
                }
                if (eventListener != null) {
                    eventListener.deleteConversation(groupId, true);
                }
                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.deleteConversation(groupId, true);
                }
            } else if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP)) {
                if (param == null) {
                    return;
                }
                String groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
                ArrayList<String> memberList = (ArrayList<String>) param.get(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST);
                if (TextUtils.isEmpty(groupId) || memberList == null || memberList.isEmpty()) {
                    return;
                }
                for (String id : memberList) {
                    if (TextUtils.equals(id, TUILogin.getLoginUser())) {
                        ConversationEventListener eventListener = getConversationEventListener();
                        if (eventListener != null) {
                            eventListener.deleteConversation(groupId, true);
                        }
                        List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                        for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                            conversationEventObserver.deleteConversation(groupId, true);
                        }
                        break;
                    }
                }
            } else if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE)) {
                String groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
                ConversationEventListener eventListener = getConversationEventListener();
                if (eventListener != null) {
                    eventListener.clearConversationMessage(groupId, true);
                }
                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.clearConversationMessage(groupId, true);
                }
            }
        } else if (key.equals(TUIConstants.TUIContact.EVENT_USER)) {
            if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE)) {
                if (param == null || param.isEmpty()) {
                    return;
                }
                String userID = (String) getOrDefault(param.get(TUIConstants.TUIContact.FRIEND_ID), "");
                ConversationEventListener eventListener = getConversationEventListener();
                if (eventListener != null) {
                    eventListener.clearConversationMessage(userID, false);
                }
                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.clearConversationMessage(userID, false);
                }
            }
        } else if (key.equals(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED)) {
            if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED)) {
                if (param == null || param.isEmpty()) {
                    return;
                }
                ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
                if (conversationEventListener == null) {
                    return;
                }
                String id = (String) param.get(TUIConstants.TUIContact.FRIEND_ID);
                String remark = (String) param.get(TUIConstants.TUIContact.FRIEND_REMARK);
                conversationEventListener.onFriendRemarkChanged(id ,remark);

                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.onFriendRemarkChanged(id, remark);
                }
            }
        } else if (key.equals(TUIConstants.TUIChat.EVENT_KEY_RECEIVE_MESSAGE)) {
            if (subKey.equals(TUIConstants.TUIChat.EVENT_SUB_KEY_CONVERSATION_ID)) {
                if (param == null || param.isEmpty()) {
                    return;
                }
                String conversationID = (String) param.get(TUIConstants.TUIChat.CONVERSATION_ID);
                boolean isTypingMessage = false;
                if (param.containsKey(TUIConstants.TUIChat.IS_TYPING_MESSAGE)) {
                    isTypingMessage = (Boolean) param.get(TUIConstants.TUIChat.IS_TYPING_MESSAGE);
                }
                ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
                if (conversationEventListener != null) {
                    conversationEventListener.onReceiveMessage(conversationID, isTypingMessage);
                }
                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.onReceiveMessage(conversationID, isTypingMessage);
                }
            }

        } else if (TextUtils.equals(key, TUIConstants.TUIConversation.EVENT_KEY_MESSAGE_SEND_FOR_CONVERSATION)) {
            if (TextUtils.equals(subKey, TUIConstants.TUIConversation.EVENT_SUB_KEY_MESSAGE_SEND_FOR_CONVERSATION)) {
                if (param == null || param.isEmpty()) {
                    return;
                }
                String conversationID = (String) param.get(TUIConstants.TUIConversation.CONVERSATION_ID);
                ConversationEventListener eventListener = getConversationEventListener();
                if (eventListener != null) {
                    eventListener.onMessageSendForHideConversation(conversationID);
                }
            }
        }
    }

    private Object getOrDefault(Object value, Object defaultValue) {
        if (value != null) {
            return value;
        }
        return defaultValue;
    }

    private void initIMListener() {
        V2TIMManager.getConversationManager().addConversationListener(new V2TIMConversationListener() {
            @Override
            public void onSyncServerStart() {
                syncFinished = false;
            }

            @Override
            public void onSyncServerFinish() {
                ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
                if (conversationEventListener != null) {
                    conversationEventListener.onSyncServerFinish();
                }

                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.onSyncServerFinish();
                }

                syncFinished = true;
            }

            @Override
            public void onSyncServerFailed() {
                syncFinished = false;
            }

            @Override
            public void onNewConversation(List<V2TIMConversation> conversationList) {
                ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
                List<ConversationInfo> conversationInfoList = ConversationUtils.convertV2TIMConversationList(conversationList);
                if (conversationEventListener != null) {
                    conversationEventListener.onNewConversation(conversationInfoList);
                }

                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.onNewConversation(conversationInfoList);
                }
            }

            @Override
            public void onConversationChanged(List<V2TIMConversation> conversationList) {
                ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
                List<ConversationInfo> conversationInfoList = ConversationUtils.convertV2TIMConversationList(conversationList);
                if (conversationEventListener != null) {
                    conversationEventListener.onConversationChanged(conversationInfoList);
                }

                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.onConversationChanged(conversationInfoList);
                }
            }

            @Override
            public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
                ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
                if (conversationEventListener != null) {
                    conversationEventListener.updateTotalUnreadMessageCount(totalUnreadCount);
                }
                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.updateTotalUnreadMessageCount(totalUnreadCount);
                }

                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIConversation.TOTAL_UNREAD_COUNT, totalUnreadCount);
                TUICore.notifyEvent(TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, param);
            }
        });

        V2TIMSDKListener v2TIMSDKListener = new V2TIMSDKListener() {
            @Override
            public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList) {
                ConversationEventListener conversationEventListener = getInstance().getConversationEventListener();
                if (conversationEventListener != null) {
                    conversationEventListener.onUserStatusChanged(userStatusList);
                }
                List<ConversationEventListener> conversationEventObserverList = getConversationEventListenerList();
                for(ConversationEventListener conversationEventObserver : conversationEventObserverList) {
                    conversationEventObserver.onUserStatusChanged(userStatusList);
                }
            }
        };
        V2TIMManager.getInstance().addIMSDKListener(v2TIMSDKListener);
    }

    public void addConversationEventListener(ConversationEventListener conversationEventListener) {
        if (conversationEventListener == null) {
            return;
        }
        for (WeakReference<ConversationEventListener> listenerWeakReference : conversationEventListenerList) {
            if (listenerWeakReference.get() == conversationEventListener) {
                return;
            }
        }
        conversationEventListenerList.add(new WeakReference<>(conversationEventListener));
    }

    public List<ConversationEventListener> getConversationEventListenerList() {
        List<ConversationEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<ConversationEventListener>> iterator = conversationEventListenerList.listIterator();
        while(iterator.hasNext()) {
            WeakReference<ConversationEventListener> listenerWeakReference = iterator.next();
            ConversationEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public void setConversationEventListener(ConversationEventListener conversationManagerKit) {
        this.conversationEventListener = new WeakReference<>(conversationManagerKit);
        if (syncFinished) {
            conversationManagerKit.onSyncServerFinish();
        }
    }

    public ConversationEventListener getConversationEventListener() {
        if (conversationEventListener != null) {
            return conversationEventListener.get();
        }
        return null;
    }

    public void addMessageListener() {

    }
}
