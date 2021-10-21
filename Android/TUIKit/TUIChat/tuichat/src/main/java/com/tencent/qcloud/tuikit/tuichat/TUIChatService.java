package com.tencent.qcloud.tuikit.tuichat;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFace;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFaceConfig;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFaceGroup;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IBaseMessageSender;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageInfoUtil;
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

    @Override
    public void init(Context context) {
        instance = this;
        appContext = context;
        initService();
        initEvent();
        initIMListener();
        initCustomFace();
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
                MessageInfo messageInfo = ChatMessageInfoUtil.buildCustomMessage(content, description, extension.getBytes());
                messageSender.sendMessage(messageInfo, chatId, TUIChatUtils.isGroupChat(chatType));
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
                MessageInfo messageInfo = ChatMessageInfoUtil.convertTIMMessage2MessageInfo(msg);
                // 通话信令存在发送 null 的情况，此处加下判断
                if (messageInfo == null) {
                    return;
                }
                if (TextUtils.isEmpty(msg.getGroupID())) {
                    C2CChatEventListener c2CChatEventListener = getInstance().getC2CChatEventListener();
                    if (c2CChatEventListener != null) {
                        c2CChatEventListener.onRecvNewMessage(messageInfo);
                    }
                } else {
                    GroupChatEventListener groupChatListener = getInstance().getGroupChatEventListener();
                    if (groupChatListener != null) {
                        groupChatListener.onRecvNewMessage(messageInfo);
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

    private void initCustomFace() {
        chatConfig = TUIChatConfigs.getConfigs();
        CustomFaceConfig config = new CustomFaceConfig();
        chatConfig.setCustomFaceConfig(config);
        FaceManager.loadFaceFiles();
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
