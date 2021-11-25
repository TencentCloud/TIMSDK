package com.tencent.qcloud.tuikit.tuichat;

import android.content.Context;
import android.text.TextUtils;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.LocationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextAtMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFace;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFaceConfig;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFaceGroup;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IBaseMessageSender;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.CustomLinkMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.FaceMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.FileMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MergeMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.ImageMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.LocationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MessageBaseHolder;
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
import java.util.List;
import java.util.Map;

public class TUIChatService extends ServiceInitializer implements ITUIChatService {
    public static final String TAG = TUIChatService.class.getSimpleName();
    private static TUIChatService instance;

    public static TUIChatService getInstance() {
        return instance;
    }

    private static TUIChatConfigs chatConfig;

    private static Context appContext;

    private WeakReference<GroupChatEventListener> groupChatEventListener;

    private WeakReference<C2CChatEventListener> c2CChatEventListener;

    private WeakReference<IBaseMessageSender> messageSender;

    private final Map<String, Class<? extends TUIMessageBean>> messageBusinessIdMap = new HashMap<>();

    private final Map<Class<? extends TUIMessageBean>, Integer> messageViewTypeMap = new HashMap<>();

    private final Map<Integer, Class<? extends MessageBaseHolder>> messageViewHolderMap = new HashMap<>();

    private int viewType = 0;

    @Override
    public void init(Context context) {
        instance = this;
        appContext = context;
        initDefaultMessageType();
        initMessageType();
        initService();
        initEvent();
        initIMListener();
        FaceManager.loadFaceFiles();
    }

    // 初始化自定义消息类型
    private void initMessageType() {
        addCustomMessageType("text_link", CustomLinkMessageBean.class, CustomLinkMessageHolder.class);
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
                GroupChatEventListener groupChatEventListener = getGroupChatEventListener();
                if (groupChatEventListener != null) {
                    groupChatEventListener.exitGroupChat(chatId);
                }
            } else {
                C2CChatEventListener c2CChatEventListener = getC2CChatEventListener();
                if (c2CChatEventListener != null) {
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
        }
        return null;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUIGroup.EVENT_GROUP)) {
            if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP)
                    || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS)
                    || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE)) {
                GroupChatEventListener groupChatEventListener = getGroupChatEventListener();
                String groupId = null;
                if (param != null) {
                    groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
                }
                if (groupChatEventListener != null) {
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
                GroupChatEventListener groupChatEventListener = getGroupChatEventListener();
                if (groupChatEventListener != null) {
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
                    GroupChatEventListener groupChatEventListener = getGroupChatEventListener();
                    if (groupChatEventListener != null) {
                        groupChatEventListener.onGroupForceExit(groupId);
                    }
                }
            }
        } else if (key.equals(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED)) {
            if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED)) {
                if (param == null || param.isEmpty()) {
                    return;
                }
                String id = (String) param.get(TUIConstants.TUIContact.FRIEND_ID);
                String remark = (String) param.get(TUIConstants.TUIContact.FRIEND_REMARK);
                C2CChatEventListener c2CChatEventListener = getC2CChatEventListener();
                if (c2CChatEventListener != null) {
                    c2CChatEventListener.onFriendNameChanged(id, remark);
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
                    C2CChatEventListener c2CChatEventListener = getInstance().getC2CChatEventListener();
                    if (c2CChatEventListener != null) {
                        c2CChatEventListener.onRecvNewMessage(message);
                    }
                } else {
                    GroupChatEventListener groupChatListener = getInstance().getGroupChatEventListener();
                    if (groupChatListener != null) {
                        groupChatListener.onRecvNewMessage(message);
                    }
                }
            }

            @Override
            public void onRecvC2CReadReceipt(List<V2TIMMessageReceipt> receiptList) {
                C2CChatEventListener c2CChatManagerKit = getInstance().getC2CChatEventListener();
                if (c2CChatManagerKit != null) {
                    List<MessageReceiptInfo> messageReceiptInfoList = new ArrayList<>();
                    for(V2TIMMessageReceipt messageReceipt : receiptList) {
                        MessageReceiptInfo messageReceiptInfo = new MessageReceiptInfo();
                        messageReceiptInfo.setMessageReceipt(messageReceipt);
                        messageReceiptInfoList.add(messageReceiptInfo);
                    }
                    c2CChatManagerKit.onReadReport(messageReceiptInfoList);
                }
            }

            @Override
            public void onRecvMessageRevoked(String msgId) {
                C2CChatEventListener c2CChatManagerKit = getInstance().getC2CChatEventListener();
                if (c2CChatManagerKit != null) {
                    c2CChatManagerKit.handleRevoke(msgId);
                }
                GroupChatEventListener groupChatManagerKit = getInstance().getGroupChatEventListener();
                if (groupChatManagerKit != null) {
                    groupChatManagerKit.handleRevoke(msgId);
                }
            }

            @Override
            public void onRecvMessageModified(V2TIMMessage msg) {
                TUIChatLog.i(TAG, "onRecvMessageModified msgID:" + msg.getMsgID());
            }
        });

        V2TIMManager.getFriendshipManager().addFriendListener(new V2TIMFriendshipListener() {
            @Override
            public void onFriendInfoChanged(List<V2TIMFriendInfo> infoList) {
                C2CChatEventListener c2CChatEventListener = getInstance().getC2CChatEventListener();
                if (c2CChatEventListener != null) {
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
    }

    public static TUIChatConfigs getChatConfig() {
        if (chatConfig == null) {
            chatConfig = TUIChatConfigs.getConfigs();
        }
        return chatConfig;
    }


    public GroupChatEventListener getGroupChatEventListener() {
        if (groupChatEventListener != null) {
            return groupChatEventListener.get();
        }
        return null;
    }

    public void setGroupChatEventListener(GroupChatEventListener groupChatListener) {
        this.groupChatEventListener = new WeakReference<>(groupChatListener);
    }

    public C2CChatEventListener getC2CChatEventListener() {
        if (c2CChatEventListener != null) {
            return c2CChatEventListener.get();
        }
        return null;
    }

    public void setChatEventListener(C2CChatEventListener c2CChatEventListener) {
        this.c2CChatEventListener = new WeakReference<>(c2CChatEventListener);
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

    public static Context getAppContext() {
        return appContext;
    }
}
