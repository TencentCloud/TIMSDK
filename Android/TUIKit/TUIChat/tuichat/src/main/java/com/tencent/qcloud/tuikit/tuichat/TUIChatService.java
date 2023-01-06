package com.tencent.qcloud.tuikit.tuichat;

import android.content.Context;
import android.text.TextUtils;

import androidx.datastore.preferences.core.Preferences;
import androidx.datastore.preferences.rxjava3.RxPreferenceDataStoreBuilder;
import androidx.datastore.rxjava3.RxDataStore;

import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomEvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MessageTypingBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.AudioRecordEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IBaseMessageSender;
import com.tencent.qcloud.tuikit.tuichat.interfaces.NetworkConnectionListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.TotalUnreadCountListener;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.DataStoreUtil;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TUIChatService extends ServiceInitializer implements ITUIChatService {
    public static final String TAG = TUIChatService.class.getSimpleName();
    private static TUIChatService instance;

    public static TUIChatService getInstance() {
        return instance;
    }

    private final List<WeakReference<GroupChatEventListener>> groupChatEventListenerList = new ArrayList<>();

    private final List<WeakReference<C2CChatEventListener>> c2CChatEventListenerList = new ArrayList<>();

    private WeakReference<IBaseMessageSender> messageSender;

    private final List<WeakReference<TotalUnreadCountListener>> unreadCountListenerList = new ArrayList<>();

    private final List<WeakReference<NetworkConnectionListener>> connectListenerList = new ArrayList<>();

    private final Map<String, Class<? extends TUIMessageBean>> customMessageMap = new HashMap<>();
    private final List<WeakReference<AudioRecordEventListener>> audioRecordEventListenerList = new ArrayList<>();

    private RxDataStore<Preferences> mChatDataStore = null;

    @Override
    public void init(Context context) {
        instance = this;
        initMessageType();
        initService();
        initEvent();
        initIMListener();
        initDataStore();
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TUIChat.SERVICE_NAME, this);
    }

    private void initDataStore() {
        if (mChatDataStore == null) {
            mChatDataStore = new RxPreferenceDataStoreBuilder(getAppContext(), TUIChatConstants.DataStore.DATA_STORE_NAME).build();
        }
        DataStoreUtil.getInstance().setDataStore(mChatDataStore);
    }
    
    public RxDataStore<Preferences> getChatDataStore() {
        return mChatDataStore;
    }

    private void initEvent() {
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_JOIN_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_INVITED_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE, this);
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE, this);
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_USER, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE, this);
        TUICore.registerEvent(TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        TUICore.registerEvent(TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND, this);
        TUICore.registerEvent(TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START, this);
        TUICore.registerEvent(TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_STOP, this);
        TUICore.registerEvent(TUIChatConstants.EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING, TUIChatConstants.EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING, this);
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        if (TextUtils.equals(TUIConstants.TUIChat.METHOD_SEND_MESSAGE, method)) {
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            int chatType = (int) getOrDefault(param.get(TUIConstants.TUIChat.CHAT_TYPE), 0);
            String content = (String) getOrDefault(param.get(TUIConstants.TUIChat.MESSAGE_CONTENT), "");
            String description = (String) getOrDefault(param.get(TUIConstants.TUIChat.MESSAGE_DESCRIPTION), "");
            String extension = (String) getOrDefault(param.get(TUIConstants.TUIChat.MESSAGE_EXTENSION), "");
            IBaseMessageSender messageSender = getMessageSender();
            if (messageSender != null) {
                TUIMessageBean message = ChatMessageBuilder.buildCustomMessage(content, description, extension.getBytes());
                messageSender.sendMessage(message, chatId, TUIChatUtils.isGroupChat(chatType));
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_EXIT_CHAT, method)) {
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            boolean isGroupChat = (boolean) param.get(TUIConstants.TUIChat.IS_GROUP_CHAT);
            if (isGroupChat) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.exitGroupChat(chatId);
                }
            } else {
                List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.exitC2CChat(chatId);
                }
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_GET_DISPLAY_STRING, method)) {
            if (param != null) {
                V2TIMMessage v2TIMMessage = (V2TIMMessage) param.get(TUIConstants.TUIChat.V2TIMMESSAGE);
                if (v2TIMMessage != null) {
                    return ChatMessageParser.getDisplayString(v2TIMMessage);
                }
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_ADD_MESSAGE_TO_CHAT, method)) {
            TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIConstants.TUIChat.MESSAGE_BEAN);
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            boolean isGroupChat = (boolean) param.get(TUIConstants.TUIChat.IS_GROUP_CHAT);
            if (isGroupChat) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.addMessage(messageBean, chatId);
                }
            } else {
                List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.addMessage(messageBean, chatId);
                }
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_GROUP_APPLICAITON_PROCESSED, method)) {
            int number = (int) param.get(TUIConstants.TUIChat.GROUP_APPLY_NUM);
            boolean isGroupChat = (boolean) param.get(TUIConstants.TUIChat.IS_GROUP_CHAT);
            if (isGroupChat) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onApplied(number);
                }
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_UPDATE_DATA_STORE_CHAT_URI, method)) {
            String uri = (String) param.get(TUIConstants.TUIChat.CHAT_BACKGROUND_URI);
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            if (!TextUtils.isEmpty(uri)) {
                DataStoreUtil.getInstance().putValue(chatId, uri);
            }
        }
        return null;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUIGroup.EVENT_GROUP)) {
            if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP)
                    || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS)
                    || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE)) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                String groupId = null;
                if (param != null) {
                    groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
                }
                for(GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onGroupForceExit(groupId);
                }
            } else if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED)) {
                if (param == null) {
                    return;
                }
                String newGroupName = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_NAME), null);
                String groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
                String groupFaceUrl = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_FACE_URL), null);


                if (TextUtils.isEmpty(groupId)) {
                    return;
                }
                if (!TextUtils.isEmpty(newGroupName)) {
                    List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onGroupNameChanged(groupId, newGroupName);
                    }
                }
                if (!TextUtils.isEmpty(groupFaceUrl)) {
                    List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onGroupFaceUrlChanged(groupId, groupFaceUrl);
                    }
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
                String selfId = TUILogin.getLoginUser();
                if (memberList.contains(selfId)) {
                    List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                    for(GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onGroupForceExit(groupId);
                    }
                }
            } else if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE)) {
                String groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for(GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.clearGroupMessage(groupId);
                }
            }
        } else if (key.equals(TUIConstants.TUIContact.EVENT_USER)) {
            if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE)) {
                if (param == null || param.isEmpty()) {
                    return;
                }
                String userID = (String) getOrDefault(param.get(TUIConstants.TUIContact.FRIEND_ID), "");
                List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                for(C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.clearC2CMessage(userID);
                }
            }
        } else if (key.equals(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED)) {
            if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED)) {
                if (param == null || param.isEmpty()) {
                    return;
                }
                String id = (String) param.get(TUIConstants.TUIContact.FRIEND_ID);
                String remark = (String) param.get(TUIConstants.TUIContact.FRIEND_REMARK);
                List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                for(C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.onFriendNameChanged(id, remark);
                }
            }
        } else if (key.equals(TUIConstants.TUIConversation.EVENT_UNREAD)) {
            if (subKey.equals(TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED)) {
                long unreadCount = (long) param.get(TUIConstants.TUIConversation.TOTAL_UNREAD_COUNT);
                List<TotalUnreadCountListener> totalUnreadCountListenerList = getUnreadCountListenerList();
                for (TotalUnreadCountListener totalUnreadCountListener : totalUnreadCountListenerList) {
                    totalUnreadCountListener.onTotalUnreadCountChanged(unreadCount);
                }
            }
        } else if (TextUtils.equals(key, TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED)) {
            if (TextUtils.equals(subKey, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS)) {
                // 加载默认 emoji 小表情
                // load default emojis
                FaceManager.loadEmojis();
                // 设置音视频通话的悬浮窗是否开启
                // Set whether to open the floating window for voice and video calls
                Map<String, Object> enableFloatWindowParam = new HashMap<>();
                enableFloatWindowParam.put(TUIConstants.TUICalling.PARAM_NAME_ENABLE_FLOAT_WINDOW, TUIChatConfigs.getConfigs().getGeneralConfig().isEnableFloatWindowForCall());
                TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_ENABLE_FLOAT_WINDOW, enableFloatWindowParam);

                // 设置音视频通话开启多端登录功能
                // Set Whether to enable multi-terminal login function for audio and video calls
                Map<String, Object> enableMultiDeviceParam = new HashMap<>();
                enableMultiDeviceParam.put(TUIConstants.TUICalling.PARAM_NAME_ENABLE_MULTI_DEVICE, TUIChatConfigs.getConfigs().getGeneralConfig().isEnableMultiDeviceForCall());
                TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_ENABLE_MULTI_DEVICE, enableMultiDeviceParam);
            }
        } else if (TextUtils.equals(key, TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED)) {
            if (TextUtils.equals(subKey, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND)) {
                Object msgBeanObj = param.get(TUIChatConstants.MESSAGE_BEAN);
                if (msgBeanObj instanceof TUIMessageBean) {
                    List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onMessageChanged((TUIMessageBean) msgBeanObj);
                    }
                    List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                    for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                        c2CChatEventListener.onMessageChanged((TUIMessageBean) msgBeanObj);
                    }
                }
            }
        } else if (TextUtils.equals(key, TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE)) {
            if (param == null) {
                return;
            }

            int errorCode = (int) getOrDefault(param.get("errorCode"), TUIConstants.TUICalling.ERROR_INVALID_PARAM);
            String path = (String) getOrDefault(param.get(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH), "");
            for (AudioRecordEventListener audioRecordEventListener : getAudioRecordEventListenerList()) {
                if (TextUtils.equals(subKey, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START)) {
                    audioRecordEventListener.onRecordBegin(errorCode, path);
                } else if (TextUtils.equals(subKey, TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_STOP)) {
                    audioRecordEventListener.onRecordComplete(errorCode, path);
                }
            }
        } else if (TextUtils.equals(key, TUIChatConstants.EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING)) {
            if (TextUtils.equals(subKey, TUIChatConstants.EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING)) {
                Boolean isPrivateRing = (Boolean) param.get(TUIChatConstants.OFFLINE_MESSAGE_PRIVATE_RING);
                TUIChatConfigs.getConfigs().getGeneralConfig().setAndroidPrivateRing(isPrivateRing);
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
        V2TIMManager.getMessageManager().addAdvancedMsgListener(new V2TIMAdvancedMsgListener() {
            @Override
            public void onRecvNewMessage(V2TIMMessage msg) {
                TUIMessageBean message = ChatMessageParser.parseMessage(msg);
                if (message == null) {
                    return;
                }

                HashMap<String, Object> param = new HashMap<>();
                String conversationID;
                if (TextUtils.isEmpty(msg.getGroupID())) {
                    List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                    for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                        c2CChatEventListener.onRecvNewMessage(message);
                    }
                    conversationID = TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX + msg.getUserID();
                    if (message instanceof MessageTypingBean) {
                        param.put(TUIConstants.TUIChat.IS_TYPING_MESSAGE, true);
                    } else {
                        param.put(TUIConstants.TUIChat.IS_TYPING_MESSAGE, false);
                    }
                } else {
                    List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onRecvNewMessage(message);
                    }
                    conversationID = TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX + msg.getGroupID();
                }

                param.put(TUIConstants.TUIChat.CONVERSATION_ID, conversationID);
                TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_RECEIVE_MESSAGE, TUIConstants.TUIChat.EVENT_SUB_KEY_CONVERSATION_ID, param);
            }

            @Override
            public void onRecvMessageReadReceipts(List<V2TIMMessageReceipt> receiptList) {
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();

                List<MessageReceiptInfo> messageReceiptInfos = new ArrayList<>();
                for (V2TIMMessageReceipt messageReceipt : receiptList) {
                    MessageReceiptInfo messageReceiptInfo = new MessageReceiptInfo();
                    messageReceiptInfo.setMessageReceipt(messageReceipt);
                    messageReceiptInfos.add(messageReceiptInfo);
                }
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onReadReport(messageReceiptInfos);
                }
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.onReadReport(messageReceiptInfos);
                }
            }

            @Override
            public void onRecvMessageRevoked(String msgId) {
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.handleRevoke(msgId);
                }
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.handleRevoke(msgId);
                }
            }

            @Override
            public void onRecvMessageModified(V2TIMMessage msg) {
                TUIMessageBean message = ChatMessageParser.parseMessage(msg);
                if (message == null) {
                    return;
                }
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.onRecvMessageModified(message);
                }
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onRecvMessageModified(message);
                }
                TUIChatLog.i(TAG, "onRecvMessageModified msgID:" + msg.getMsgID());
            }
        });

        V2TIMManager.getFriendshipManager().addFriendListener(new V2TIMFriendshipListener() {
            @Override
            public void onFriendInfoChanged(List<V2TIMFriendInfo> infoList) {
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    for (V2TIMFriendInfo info : infoList) {
                        if (TextUtils.isEmpty(info.getFriendRemark())) {
                            String nickName = info.getUserProfile().getNickName();
                            if (TextUtils.isEmpty(nickName)) {
                                c2CChatEventListener.onFriendNameChanged(info.getUserID(), info.getUserID());
                            } else {
                                c2CChatEventListener.onFriendNameChanged(info.getUserID(), nickName);
                            }
                        } else {
                            c2CChatEventListener.onFriendNameChanged(info.getUserID(), info.getFriendRemark());
                        }
                        c2CChatEventListener.onFriendFaceUrlChanged(info.getUserID(), info.getUserProfile().getFaceUrl());
                    }
                }
            }
        });

        V2TIMManager.getInstance().addIMSDKListener(new V2TIMSDKListener() {
            @Override
            public void onConnectSuccess() {
                for (WeakReference<NetworkConnectionListener> listenerWeakReference : connectListenerList) {
                    NetworkConnectionListener listener = listenerWeakReference.get();
                    if (listener != null) {
                        listener.onConnected();
                    }
                }
            }
        });
    }

    public void registerNetworkListener(NetworkConnectionListener listener) {
        if (listener == null) {
            return;
        }

        for (WeakReference<NetworkConnectionListener> weakReference : connectListenerList) {
            NetworkConnectionListener networkConnectionListener = weakReference.get();
            if (networkConnectionListener == listener) {
                return;
            }
        }

        WeakReference<NetworkConnectionListener> weakReference = new WeakReference<>(listener);
        connectListenerList.add(weakReference);
    }

    // 初始化自定义消息类型
    // Initialize custom message types
    private void initMessageType() {
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_HELLO, CustomLinkMessageBean.class);
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_EVALUATION, CustomEvaluationMessageBean.class);
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_ORDER, CustomOrderMessageBean.class);
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_TYPING, MessageTypingBean.class);
    }

    /**
     * 注册自定义消息类型
     * @param businessId 自定义消息唯一标识（注意不能重复）
     * @param beanClass 消息 MessageBean 类型
     *
     * Register a custom message type
     * @param businessId Custom message unique identifier（cannot be repeated）
     * @param beanClass  MessageBean type
     */
    private void addCustomMessageType(String businessId, Class<? extends TUIMessageBean> beanClass) {
        customMessageMap.put(businessId, beanClass);
    }

    public Class<? extends TUIMessageBean> getMessageBeanClass(String businessId) {
        return customMessageMap.get(businessId);
    }

    private List<GroupChatEventListener> getGroupChatEventListenerList() {
        List<GroupChatEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<GroupChatEventListener>> iterator = groupChatEventListenerList.listIterator();
        while(iterator.hasNext()) {
            WeakReference<GroupChatEventListener> listenerWeakReference = iterator.next();
            GroupChatEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public void addGroupChatEventListener(GroupChatEventListener groupChatListener) {
        if (groupChatListener == null) {
            return;
        }
        for (WeakReference<GroupChatEventListener> listenerWeakReference : groupChatEventListenerList) {
            if (listenerWeakReference.get() == groupChatListener) {
                return;
            }
        }
        groupChatEventListenerList.add(new WeakReference<>(groupChatListener));
    }

    private List<C2CChatEventListener> getC2CChatEventListenerList() {
        List<C2CChatEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<C2CChatEventListener>> iterator = c2CChatEventListenerList.listIterator();
        while(iterator.hasNext()) {
            WeakReference<C2CChatEventListener> listenerWeakReference = iterator.next();
            C2CChatEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public void addC2CChatEventListener(C2CChatEventListener c2cChatEventListener) {
        if (c2cChatEventListener == null) {
            return;
        }
        for (WeakReference<C2CChatEventListener> listenerWeakReference : c2CChatEventListenerList) {
            if (listenerWeakReference.get() == c2cChatEventListener) {
                return;
            }
        }
        c2CChatEventListenerList.add(new WeakReference<>(c2cChatEventListener));    }

    public void setMessageSender(IBaseMessageSender baseMessageSender) {
        messageSender = new WeakReference<>(baseMessageSender);
    }

    public void addUnreadCountListener(TotalUnreadCountListener unreadCountListener) {
        if (unreadCountListener == null) {
            return;
        }
        for (WeakReference<TotalUnreadCountListener> listenerWeakReference : unreadCountListenerList) {
            if (listenerWeakReference.get() == unreadCountListener) {
                return;
            }
        }
        unreadCountListenerList.add(new WeakReference<>(unreadCountListener));
    }


    private List<TotalUnreadCountListener> getUnreadCountListenerList() {
        List<TotalUnreadCountListener> listeners = new ArrayList<>();
        Iterator<WeakReference<TotalUnreadCountListener>> iterator = unreadCountListenerList.listIterator();
        while(iterator.hasNext()) {
            WeakReference<TotalUnreadCountListener> listenerWeakReference = iterator.next();
            TotalUnreadCountListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public void addAudioRecordEventListener(AudioRecordEventListener audioRecordEventListener) {
        if (audioRecordEventListener == null) {
            return;
        }

        for (WeakReference<AudioRecordEventListener> listenerWeakReference : audioRecordEventListenerList) {
            if (listenerWeakReference.get() == audioRecordEventListener) {
                return;
            }
        }
        audioRecordEventListenerList.add(new WeakReference<>(audioRecordEventListener));
    }

    public List<AudioRecordEventListener> getAudioRecordEventListenerList() {
        List<AudioRecordEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<AudioRecordEventListener>> iterator = audioRecordEventListenerList.listIterator();
        while(iterator.hasNext()) {
            WeakReference<AudioRecordEventListener> listenerWeakReference = iterator.next();
            AudioRecordEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    private IBaseMessageSender getMessageSender() {
        if (messageSender != null) {
            return messageSender.get();
        }
        return null;
    }
}
