package com.tencent.qcloud.tim.uikit.modules.chat.base;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.modules.message.MessageRevokedManager;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public abstract class ChatManagerKit extends V2TIMAdvancedMsgListener implements MessageRevokedManager.MessageRevokeHandler {

    protected static final int MSG_PAGE_COUNT = 20;
    protected static final int REVOKE_TIME_OUT = 6223;
    private static final String TAG = ChatManagerKit.class.getSimpleName();
    protected ChatProvider mCurrentProvider;

    protected boolean mIsMore;
    private boolean mIsLoading;

    private MessageInfo mLastMessageInfo;

    protected void init() {
        destroyChat();
        V2TIMManager.getMessageManager().addAdvancedMsgListener(this);
        MessageRevokedManager.getInstance().addHandler(this);
    }

    public void destroyChat() {
        mCurrentProvider = null;
    }

    public abstract ChatInfo getCurrentChatInfo();

    public void setCurrentChatInfo(ChatInfo info) {
        if (info == null) {
            return;
        }
        mCurrentProvider = new ChatProvider();
        mIsMore = true;
        mIsLoading = false;
    }

    public void onReadReport(List<V2TIMMessageReceipt> receiptList) {
        TUIKitLog.i(TAG, "onReadReport:" + receiptList.size());
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "onReadReport unSafetyCall");
            return;
        }
        if (receiptList.size() == 0) {
            return;
        }
        V2TIMMessageReceipt max = receiptList.get(0);
        for (V2TIMMessageReceipt msg : receiptList) {
            if (!TextUtils.equals(msg.getUserID(), getCurrentChatInfo().getId())) {
                continue;
            }
            if (max.getTimestamp() < msg.getTimestamp()) {
                max = msg;
            }
        }
        mCurrentProvider.updateReadMessage(max);
    }

    @Override
    public void onRecvNewMessage(V2TIMMessage msg) {
        TUIKitLog.i(TAG, "onRecvNewMessage msgID:" + msg.getMsgID());
        int elemType = msg.getElemType();
        if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            if (MessageInfoUtil.isTyping(msg.getCustomElem().getData())) {
                notifyTyping();
                return;
            } else if (MessageInfoUtil.isOnlineIgnoredDialing(msg.getCustomElem().getData())) {
                // 这类消息都是音视频通话邀请的在线消息，忽略
                TUIKitLog.i(TAG, "ignore online invitee message");
                return;
            }
        }

        onReceiveMessage(msg);
    }

    private void notifyTyping() {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "notifyTyping unSafetyCall");
            return;
        }
        mCurrentProvider.notifyTyping();
    }

    public void notifyNewFriend(List<V2TIMFriendInfo> timFriendInfoList) {
        if (timFriendInfoList == null || timFriendInfoList.size() == 0) {
            return;
        }
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("已和");
        for (V2TIMFriendInfo v2TIMFriendInfo : timFriendInfoList) {
            stringBuilder.append(v2TIMFriendInfo.getUserID()).append(",");
        }
        stringBuilder.deleteCharAt(stringBuilder.length() - 1);
        stringBuilder.append("成为好友");
        ToastUtil.toastLongMessage(stringBuilder.toString());
    }

    protected void onReceiveMessage(final V2TIMMessage msg) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "onReceiveMessage unSafetyCall");
            return;
        }
        addMessage(msg);
    }

    protected abstract boolean isGroup();

    protected void addMessage(V2TIMMessage msg) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "addMessage unSafetyCall");
            return;
        }
        final List<MessageInfo> list = MessageInfoUtil.TIMMessage2MessageInfo(msg);
        if (list != null && list.size() != 0) {
            ChatInfo chatInfo = getCurrentChatInfo();
            boolean isGroupMessage = false;
            String groupID = null;
            String userID = null;
            if (!TextUtils.isEmpty(msg.getGroupID())) {
                // 群组消息
                if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C
                        || !chatInfo.getId().equals(msg.getGroupID())) {
                    return;
                }
                isGroupMessage = true;
                groupID = msg.getGroupID();
            } else if (!TextUtils.isEmpty(msg.getUserID())) {
                // C2C 消息
                if (chatInfo.getType() == V2TIMConversation.V2TIM_GROUP
                        || !chatInfo.getId().equals(msg.getUserID())) {
                    return;
                }
                userID = msg.getUserID();
            } else {
                return;
            }
            mCurrentProvider.addMessageInfoList(list);
            for (MessageInfo msgInfo : list) {
                msgInfo.setRead(true);
                addGroupMessage(msgInfo);
            }
            if (isGroupMessage) {
                V2TIMManager.getMessageManager().markGroupMessageAsRead(groupID, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.e(TAG, "addMessage() markGroupMessageAsRead failed, code = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TUIKitLog.i(TAG, "addMessage() markGroupMessageAsRead success");
                    }
                });
            } else {
                V2TIMManager.getMessageManager().markC2CMessageAsRead(userID, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.e(TAG, "addMessage() markC2CMessageAsRead failed, code = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TUIKitLog.i(TAG, "addMessage() markC2CMessageAsRead success");
                    }
                });
            }
        }
    }

    protected void addGroupMessage(MessageInfo msgInfo) {
        // GroupChatManagerKit会重写该方法
    }

    public void deleteMessage(final int position, MessageInfo messageInfo) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "deleteMessage unSafetyCall");
            return;
        }
        List<V2TIMMessage> msgs = new ArrayList<>();
        msgs.add(mCurrentProvider.getDataSource().get(position).getTimMessage());
        V2TIMManager.getMessageManager().deleteMessages(msgs, new V2TIMCallback(){

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.w(TAG, "deleteMessages code:" + code + "|desc:" + desc);
            }

            @Override
            public void onSuccess() {
                TUIKitLog.i(TAG, "deleteMessages success");
                mCurrentProvider.remove(position);
                ConversationManagerKit.getInstance().loadConversation(null);
            }
        });
    }

    public void revokeMessage(final int position, final MessageInfo messageInfo) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "revokeMessage unSafetyCall");
            return;
        }
        V2TIMManager.getMessageManager().revokeMessage(messageInfo.getTimMessage(), new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (code == REVOKE_TIME_OUT) {
                    ToastUtil.toastLongMessage("消息发送已超过2分钟");
                } else {
                    ToastUtil.toastLongMessage("撤回失败:" + code + "=" + desc);
                }
            }

            @Override
            public void onSuccess() {
                if (!safetyCall()) {
                    TUIKitLog.w(TAG, "revokeMessage unSafetyCall");
                    return;
                }
                mCurrentProvider.updateMessageRevoked(messageInfo.getId());
                ConversationManagerKit.getInstance().loadConversation(null);
            }
        });
    }

    public void sendMessage(final MessageInfo message, boolean retry, final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "sendMessage unSafetyCall");
            return;
        }
        if (message == null || message.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
            return;
        }
        message.setSelf(true);
        message.setRead(true);
        assembleGroupMessage(message);

        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = message.getExtra().toString();
        entity.sender = message.getFromUser();
        entity.nickname = TUIKitConfigs.getConfigs().getGeneralConfig().getUserNickname();
        entity.faceUrl = TUIKitConfigs.getConfigs().getGeneralConfig().getUserFaceUrl();
        containerBean.entity = entity;

        String userID = "";
        String groupID = "";
        boolean isGroup = false;
        if (getCurrentChatInfo().getType() == V2TIMConversation.V2TIM_GROUP) {
            groupID = getCurrentChatInfo().getId();
            isGroup = true;
            entity.chatType = V2TIMConversation.V2TIM_GROUP;
            entity.sender = groupID;
        } else {
            userID = getCurrentChatInfo().getId();
        }

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");

        V2TIMMessage v2TIMMessage = message.getTimMessage();
        String msgID = V2TIMManager.getMessageManager().sendMessage(v2TIMMessage, isGroup ? null : userID, isGroup ? groupID : null,
                V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, v2TIMOfflinePushInfo, new V2TIMSendCallback<V2TIMMessage>() {
                    @Override
                    public void onProgress(int progress) {

                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.v(TAG, "sendMessage fail:" + code + "=" + desc);
                        if (!safetyCall()) {
                            TUIKitLog.w(TAG, "sendMessage unSafetyCall");
                            return;
                        }
                        if (callBack != null) {
                            callBack.onError(TAG, code, desc);
                        }
                        message.setStatus(MessageInfo.MSG_STATUS_SEND_FAIL);
                        mCurrentProvider.updateMessageInfo(message);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        TUIKitLog.v(TAG, "sendMessage onSuccess:" + v2TIMMessage.getMsgID());
                        if (!safetyCall()) {
                            TUIKitLog.w(TAG, "sendMessage unSafetyCall");
                            return;
                        }
                        if (callBack != null) {
                            callBack.onSuccess(mCurrentProvider);
                        }
                        message.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                        message.setMsgTime(v2TIMMessage.getTimestamp());
                        mCurrentProvider.updateMessageInfo(message);
                    }
                });

        //消息先展示，通过状态来确认发送是否成功
        TUIKitLog.i(TAG, "sendMessage msgID:" + msgID);
        message.setId(msgID);
        if (message.getMsgType() < MessageInfo.MSG_TYPE_TIPS) {
            message.setStatus(MessageInfo.MSG_STATUS_SENDING);
            if (retry) {
                mCurrentProvider.resendMessageInfo(message);
            } else {
                mCurrentProvider.addMessageInfo(message);
            }
        }
    }

    protected void assembleGroupMessage(MessageInfo message) {
        // GroupChatManager会重写该方法
    }

    public void getAtInfoChatMessages(long atInfoMsgSeq, V2TIMMessage lastMessage, final IUIKitCallBack callBack){
        final ChatInfo chatInfo = getCurrentChatInfo();
        if (atInfoMsgSeq == -1 ||  lastMessage == null || lastMessage.getSeq() <= atInfoMsgSeq){
            return;
        }
        if (chatInfo.getType() == V2TIMConversation.V2TIM_GROUP) {
            V2TIMManager.getMessageManager().getGroupHistoryMessageList(chatInfo.getId(),
                    (int)(lastMessage.getSeq() - atInfoMsgSeq), lastMessage, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "loadChatMessages getGroupHistoryMessageList failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    processHistoryMsgs(v2TIMMessages, chatInfo, callBack);
                }
            });
        }
    }

    public void loadChatMessages(MessageInfo lastMessage, final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "loadLocalChatMessages unSafetyCall");
            return;
        }
        if (mIsLoading) {
            return;
        }
        mIsLoading = true;
        if (!mIsMore) {
            mCurrentProvider.addMessageInfo(null);
            callBack.onSuccess(null);
            mIsLoading = false;
            return;
        }

        V2TIMMessage lastTIMMsg = null;
        if (lastMessage == null) {
            mCurrentProvider.clear();
        } else {
            lastTIMMsg = lastMessage.getTimMessage();
        }
//        final int unread = (int) mCurrentConversation.getUnreadMessageNum();
        final ChatInfo chatInfo = getCurrentChatInfo();
        if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
            V2TIMManager.getMessageManager().getC2CHistoryMessageList(chatInfo.getId(), MSG_PAGE_COUNT, lastTIMMsg, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onError(int code, String desc) {
                    mIsLoading = false;
                    callBack.onError(TAG, code, desc);
                    TUIKitLog.e(TAG, "loadChatMessages getC2CHistoryMessageList failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    processHistoryMsgs(v2TIMMessages, chatInfo, callBack);
                }
            });
        } else {
            V2TIMManager.getMessageManager().getGroupHistoryMessageList(chatInfo.getId(), MSG_PAGE_COUNT, lastTIMMsg, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onError(int code, String desc) {
                    mIsLoading = false;
                    callBack.onError(TAG, code, desc);
                    TUIKitLog.e(TAG, "loadChatMessages getGroupHistoryMessageList failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    processHistoryMsgs(v2TIMMessages, chatInfo, callBack);
                }
            });
        }
    }

    private void processHistoryMsgs(List<V2TIMMessage> v2TIMMessages, ChatInfo chatInfo, IUIKitCallBack callBack) {
        mIsLoading = false;
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "getLocalMessage unSafetyCall");
            return;
        }
        if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
            V2TIMManager.getMessageManager().markC2CMessageAsRead(chatInfo.getId(), new V2TIMCallback() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "processHistoryMsgs setReadMessage failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess() {
                    TUIKitLog.d(TAG, "processHistoryMsgs setReadMessage success");
                }
            });
        } else {
            V2TIMManager.getMessageManager().markGroupMessageAsRead(chatInfo.getId(), new V2TIMCallback() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "processHistoryMsgs markC2CMessageAsRead failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess() {
                    TUIKitLog.d(TAG, "processHistoryMsgs markC2CMessageAsRead success");
                }
            });
        }


        if (v2TIMMessages.size() < MSG_PAGE_COUNT) {
            mIsMore = false;
        }
        ArrayList<V2TIMMessage> messages = new ArrayList<>(v2TIMMessages);
        Collections.reverse(messages);

        List<MessageInfo> msgInfos = MessageInfoUtil.TIMMessages2MessageInfos(messages, isGroup());
        mCurrentProvider.addMessageList(msgInfos, true);
        for (int i = 0; i < msgInfos.size(); i++) {
            MessageInfo info = msgInfos.get(i);
            if (info.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
                sendMessage(info, true, null);
            }
        }
        callBack.onSuccess(mCurrentProvider);
    }

    @Override
    public void handleInvoke(String msgID) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "handleInvoke unSafetyCall");
            return;
        }
        TUIKitLog.i(TAG, "handleInvoke msgID = " + msgID);
        mCurrentProvider.updateMessageRevoked(msgID);
    }

    protected boolean safetyCall() {
        if (mCurrentProvider == null
                || getCurrentChatInfo() == null) {
            return false;
        }
        return true;
    }

    public void setLastMessageInfo(MessageInfo mLastMessageInfo) {
        this.mLastMessageInfo = mLastMessageInfo;
    }

    public MessageInfo getLastMessageInfo() {
        return mLastMessageInfo;
    }
}
