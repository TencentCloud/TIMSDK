package com.tencent.qcloud.tuikit.tuichat;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.LocationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextAtMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IBaseMessageSender;
import com.tencent.qcloud.tuikit.tuichat.interfaces.NetworkConnectionListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.TotalUnreadCountListener;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.CallingMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.CustomLinkMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.FaceMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.FileMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MergeMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.ImageMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.LocationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MessageBaseHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.QuoteMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.ReplyMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.SoundMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.TextMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.TipsMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.VideoMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
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

    private static TUIChatConfigs chatConfig;

    private final List<WeakReference<GroupChatEventListener>> groupChatEventListenerList = new ArrayList<>();

    private final List<WeakReference<C2CChatEventListener>> c2CChatEventListenerList = new ArrayList<>();

    private WeakReference<IBaseMessageSender> messageSender;

    private final List<WeakReference<TotalUnreadCountListener>> unreadCountListenerList = new ArrayList<>();

    private final Map<String, Class<? extends TUIMessageBean>> messageBusinessIdMap = new HashMap<>();

    private final Map<Class<? extends TUIMessageBean>, Integer> messageViewTypeMap = new HashMap<>();

    private final Map<Integer, Class<? extends MessageBaseHolder>> messageViewHolderMap = new HashMap<>();

    private final List<WeakReference<NetworkConnectionListener>> connectListenerList = new ArrayList<>();

    private int viewType = 0;

    @Override
    public void init(Context context) {
        instance = this;
        initDefaultMessageType();
        initMessageType();
        initService();
        initEvent();
        initIMListener();
        FaceManager.loadFaceFiles();
    }

    // 初始化自定义消息类型
    private void initMessageType() {
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_HELLO, CustomLinkMessageBean.class, CustomLinkMessageHolder.class);
    }

    /**
     * 注册自定义消息类型
     * @param businessId 自定义消息唯一标识（注意不能重复）
     * @param beanClass 消息 MessageBean 类型
     * @param holderClass 消息 MessageBaseHolder 类型
     */
    private void addCustomMessageType(String businessId, Class<? extends TUIMessageBean> beanClass,
                                      Class<? extends MessageBaseHolder> holderClass) {
        viewType++;
        messageBusinessIdMap.put(businessId, beanClass);
        messageViewTypeMap.put(beanClass, viewType);
        messageViewHolderMap.put(viewType, holderClass);
    }

    public Class<? extends TUIMessageBean> getMessageBeanClass(String businessId) {
        return messageBusinessIdMap.get(businessId);
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

    private void initDefaultMessageType() {
        addDefaultMessageType(FaceMessageBean.class, FaceMessageHolder.class);
        addDefaultMessageType(FileMessageBean.class, FileMessageHolder.class);
        addDefaultMessageType(ImageMessageBean.class, ImageMessageHolder.class);
        addDefaultMessageType(LocationMessageBean.class, LocationMessageHolder.class);
        addDefaultMessageType(MergeMessageBean.class, MergeMessageHolder.class);
        addDefaultMessageType(SoundMessageBean.class, SoundMessageHolder.class);
        addDefaultMessageType(TextAtMessageBean.class, TextMessageHolder.class);
        addDefaultMessageType(TextMessageBean.class, TextMessageHolder.class);
        addDefaultMessageType(TipsMessageBean.class, TipsMessageHolder.class);
        addDefaultMessageType(VideoMessageBean.class, VideoMessageHolder.class);
        addDefaultMessageType(ReplyMessageBean.class, ReplyMessageHolder.class);
        addDefaultMessageType(QuoteMessageBean.class, QuoteMessageHolder.class);
        addDefaultMessageType(CallingMessageBean.class, CallingMessageHolder.class);
    }

    private void addDefaultMessageType(Class<? extends TUIMessageBean> beanClazz, Class<? extends MessageBaseHolder> holderClazz) {
        viewType++;
        messageViewTypeMap.put(beanClazz, viewType);
        messageViewHolderMap.put(viewType, holderClazz);
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TUIChat.SERVICE_NAME, this);
    }

    private void initEvent() {
        // 群信息更改通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED, this);
        // 退群通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP, this);
        // 群成员被踢通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP, this);
        // 群解散通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS, this);
        // 加群通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_JOIN_GROUP, this);
        // 被邀请进群通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_INVITED_GROUP, this);
        // 群被回收通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE, this);
        // 好友备注修改通知
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, this);
        // 清空群消息通知
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE, this);        // 清空群消息通知
        // 总未读数改变通知
        TUICore.registerEvent(TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, this);
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

                if (TextUtils.isEmpty(newGroupName) || TextUtils.isEmpty(groupId)) {
                    return;
                }
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for(GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onGroupNameChanged(groupId, newGroupName);
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
                // 通话信令存在发送 null 的情况，此处加下判断
                if (message == null) {
                    return;
                }
                if (TextUtils.isEmpty(msg.getGroupID())) {
                    List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                    for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                        c2CChatEventListener.onRecvNewMessage(message);
                    }
                } else {
                    List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onRecvNewMessage(message);
                    }
                }
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

    public static TUIChatConfigs getChatConfig() {
        if (chatConfig == null) {
            chatConfig = TUIChatConfigs.getConfigs();
        }
        return chatConfig;
    }

    public List<GroupChatEventListener> getGroupChatEventListenerList() {
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

    public List<C2CChatEventListener> getC2CChatEventListenerList() {
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


    public List<TotalUnreadCountListener> getUnreadCountListenerList() {
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

    public IBaseMessageSender getMessageSender() {
        if (messageSender != null) {
            return messageSender.get();
        }
        return null;
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
}
