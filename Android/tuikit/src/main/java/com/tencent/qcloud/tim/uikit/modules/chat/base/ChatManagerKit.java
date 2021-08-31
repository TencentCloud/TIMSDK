package com.tencent.qcloud.tim.uikit.modules.chat.base;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageListGetOption;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IBaseInfo;
import com.tencent.qcloud.tim.uikit.base.IBaseMessageSender;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.forward.ForwardSelectActivity;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.modules.message.MessageRevokedManager;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ThreadHelper;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static com.tencent.imsdk.v2.V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL;

public abstract class ChatManagerKit extends V2TIMAdvancedMsgListener implements MessageRevokedManager.MessageRevokeHandler, IBaseMessageSender {
    private static final String TAG = ChatManagerKit.class.getSimpleName();

    // 逐条转发 Group 消息发送消息的时间间隔
    private static final int FORWARD_GROUP_INTERVAL = 90; // 单位： 毫秒
    // 逐条转发 C2C 消息发送消息的时间间隔
    private static final int FORWARD_C2C_INTERVAL = 50; // 单位： 毫秒
    // 消息已读上报时间间隔
    private static final int READ_REPORT_INTERVAL = 1000; // 单位： 毫秒

    protected static final int MSG_PAGE_COUNT = 20;
    protected ChatProvider mCurrentProvider;

    protected boolean mIsMore;
    private boolean mIsLoading;
    private boolean mIsChatFragmentShow = false;

    private MessageInfo mLastMessageInfo;

    private long lastReadReportTime = 0L;
    private boolean canReadReport = true;
    private final MessageReadReportHandler readReportHandler = new MessageReadReportHandler();

    protected void init() {
        destroyChat();
        V2TIMManager.getMessageManager().addAdvancedMsgListener(this);
        MessageRevokedManager.getInstance().addHandler(this);
    }

    public void destroyChat() {
        mCurrentProvider = null;
    }

    public static void markMessageAsRead(ChatInfo chatInfo) {
        if (chatInfo == null) {
            TUIKitLog.i(TAG, "markMessageAsRead() chatInfo is null");
            return;
        }

        boolean isGroup = false;
        if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
            isGroup = false;
        } else {
            isGroup = true;
        }
        String chatId = chatInfo.getId();
        if (isGroup) {
            groupReadReport(chatId);
        } else {
            c2cReadReport(chatId);
        }
    }

    public boolean isChatFragmentShow() {
        return mIsChatFragmentShow;
    }

    public void setChatFragmentShow(boolean isChatFragmentShow) {
        this.mIsChatFragmentShow = isChatFragmentShow;
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
            } else if (MessageInfoUtil.isOnlineIgnored(msg)) {
                // 这类消息都是音视频通话邀请的在线消息，忽略
                TUIKitLog.i(TAG, "ignore online invitee message");
                return;
            }
        }

        onReceiveMessage(msg, false);
    }

    @Override
    public void onRecvMessageModified(V2TIMMessage msg) {
        onReceiveMessage(msg, true);
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
        stringBuilder.append(TUIKit.getAppContext().getString(R.string.and_and));
        for (V2TIMFriendInfo v2TIMFriendInfo : timFriendInfoList) {
            stringBuilder.append(v2TIMFriendInfo.getUserID()).append(",");
        }
        stringBuilder.deleteCharAt(stringBuilder.length() - 1);
        stringBuilder.append(TUIKit.getAppContext().getString(R.string.be_friend));
        ToastUtil.toastLongMessage(stringBuilder.toString());
    }

    protected void onReceiveMessage(final V2TIMMessage msg, boolean isModifiedByServer) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "onReceiveMessage unSafetyCall");
            return;
        }
        addMessage(msg, isModifiedByServer);
    }

    protected abstract boolean isGroup();

    protected void addMessage(V2TIMMessage msg, boolean isModifiedByServer) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "addMessage unSafetyCall");
            return;
        }
        final MessageInfo messageInfo = MessageInfoUtil.TIMMessage2MessageInfo(msg);
        if (messageInfo != null) {
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
            mCurrentProvider.addMessageInfo(messageInfo, isModifiedByServer);
            if (isChatFragmentShow()) {
                messageInfo.setRead(true);
            }
            addGroupMessage(messageInfo);

            if (isChatFragmentShow()) {
                if (isGroupMessage) {
                    limitReadReport(null, groupID);
                } else {
                    limitReadReport(userID, null);
                }
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
        if (position >= mCurrentProvider.getDataSource().size()){
            TUIKitLog.w(TAG, "deleteMessage invalid position");
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
            }
        });
    }

    public void deleteMessageInfos(final List<MessageInfo> messageInfos) {
        if (!safetyCall() || messageInfos == null || messageInfos.isEmpty()) {
            TUIKitLog.w(TAG, "deleteMessages unSafetyCall");
            return;
        }

        List<V2TIMMessage> v2TIMDeleteMessages = new ArrayList<>();
        for (int i = 0; i < messageInfos.size(); i++) {
            v2TIMDeleteMessages.add(messageInfos.get(i).getTimMessage());
        }
        V2TIMManager.getMessageManager().deleteMessages(v2TIMDeleteMessages, new V2TIMCallback(){

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.w(TAG, "deleteMessages code:" + code + "|desc:" + desc);
            }

            @Override
            public void onSuccess() {
                TUIKitLog.i(TAG, "deleteMessages success");
                mCurrentProvider.deleteMessageList(messageInfos);
            }
        });
    }

    public void deleteMessages(final List<Integer> positions) {
        if (!safetyCall() || positions == null || positions.isEmpty()) {
            TUIKitLog.w(TAG, "deleteMessages unSafetyCall");
            return;
        }
        List<V2TIMMessage> msgs = new ArrayList<>();
        for(int i = 0; i < positions.size(); i++) {
            msgs.add(mCurrentProvider.getDataSource().get(positions.get(i)).getTimMessage());
        }
        V2TIMManager.getMessageManager().deleteMessages(msgs, new V2TIMCallback(){

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.w(TAG, "deleteMessages code:" + code + "|desc:" + desc);
            }

            @Override
            public void onSuccess() {
                TUIKitLog.i(TAG, "deleteMessages success");
                for(int i = positions.size() -1 ; i >= 0; i--) {
                    mCurrentProvider.remove(positions.get(i));
                }
            }
        });
    }

    public boolean checkFailedMessages(final List<Integer> positions){
        if (!safetyCall() || positions == null || positions.isEmpty()) {
            TUIKitLog.w(TAG, "checkFailedMessages unSafetyCall");
            return false;
        }

        boolean failed = false;
        for(int i = 0; i < positions.size(); i++) {
            V2TIMMessage v2TIMMessage = mCurrentProvider.getDataSource().get(positions.get(i)).getTimMessage();
            if (v2TIMMessage.getStatus() == V2TIM_MSG_STATUS_SEND_FAIL) {
                failed = true;
                break;
            }
        }

        return failed;
    }

    public boolean checkFailedMessageInfos(final List<MessageInfo> messageInfos){
        if (!safetyCall() || messageInfos == null || messageInfos.isEmpty()) {
            TUIKitLog.w(TAG, "checkFailedMessagesById unSafetyCall");
            return false;
        }

        boolean failed = false;
        for (int i = 0; i < messageInfos.size(); i++) {
            if (messageInfos.get(i).getTimMessage().getStatus() == V2TIM_MSG_STATUS_SEND_FAIL) {
                failed = true;
                break;
            }
        }

        return failed;
    }

    public List<MessageInfo> getSelectPositionMessage(final List<Integer> positions){
        if (!safetyCall() || positions == null || positions.isEmpty()) {
            TUIKitLog.w(TAG, "deleteMessages unSafetyCall");
            return null;
        }

        List<MessageInfo> msgs = new ArrayList<>();
        for(int i = 0; i < positions.size(); i++) {
            if (positions.get(i) < mCurrentProvider.getDataSource().size()) {
                msgs.add(mCurrentProvider.getDataSource().get(positions.get(i)));
            } else {
                TUIKitLog.d(TAG, "mCurrentProvider not include SelectPosition ");
            }
        }
        return msgs;
    }

    public List<MessageInfo> getSelectPositionMessageById(final List<String> msgIds){
        if (!safetyCall() || msgIds == null || msgIds.isEmpty()) {
            TUIKitLog.w(TAG, "deleteMessages unSafetyCall");
            return null;
        }

        List<MessageInfo> messageInfos = mCurrentProvider.getDataSource();
        if (messageInfos == null || messageInfos.size() <= 0) {
            return null;
        }

        final List<MessageInfo> msgSelectedMsgInfos = new ArrayList<>();
        for (int i = 0; i < msgIds.size(); i++) {
            for (int j = 0; j < messageInfos.size(); j++) {
                if (msgIds.get(i).equals(messageInfos.get(j).getId())) {
                    msgSelectedMsgInfos.add(messageInfos.get(j));
                    break;
                }
            }
        }

        return msgSelectedMsgInfos;
    }

    public void revokeMessage(final int position, final MessageInfo messageInfo) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "revokeMessage unSafetyCall");
            return;
        }
        V2TIMManager.getMessageManager().revokeMessage(messageInfo.getTimMessage(), new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (code == BaseConstants.ERR_SVR_MSG_REVOKE_TIME_LIMIT || code == BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT) {
                    ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.send_two_mins));
                } else {
                    ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.revoke_fail) + code + "=" + desc);
                }
            }

            @Override
            public void onSuccess() {
                if (!safetyCall()) {
                    TUIKitLog.w(TAG, "revokeMessage unSafetyCall");
                    return;
                }
                mCurrentProvider.updateMessageRevoked(messageInfo.getId());
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
        entity.nickname = getCurrentChatInfo().getChatName();
        entity.faceUrl = TUIKitConfigs.getConfigs().getGeneralConfig().getUserFaceUrl();
        containerBean.entity = entity;

        String userID = "";
        String groupID = "";
        boolean isGroup = false;
        if (getCurrentChatInfo().getType() == V2TIMConversation.V2TIM_GROUP) {
            ChatInfo chatInfo = getCurrentChatInfo();
            groupID = chatInfo.getId();
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

        final V2TIMMessage v2TIMMessage = message.getTimMessage();
        v2TIMMessage.setExcludedFromUnreadCount(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
        v2TIMMessage.setExcludedFromLastMessage(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());

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
                        if (message.getMsgType() == MessageInfo.MSG_TYPE_FILE) {
                            message.setDownloadStatus(MessageInfo.MSG_STATUS_DOWNLOADED);
                        }
                        message.setMsgTime(v2TIMMessage.getTimestamp());
                        mCurrentProvider.updateMessageInfo(message);
                    }
                });

        //消息先展示，通过状态来确认发送是否成功
        TUIKitLog.i(TAG, "sendMessage msgID:" + msgID);
        message.setId(msgID);
        if (message.getMsgType() < MessageInfo.MSG_TYPE_TIPS || message.getMsgType() > MessageInfo.MSG_STATUS_REVOKE) {
            message.setStatus(MessageInfo.MSG_STATUS_SENDING);
            if (retry) {
                mCurrentProvider.resendMessageInfo(message);
            } else {
                mCurrentProvider.addMessageInfo(message, false);
            }
        }
    }

    public void forwardMessageInternal(final MessageInfo message, boolean isGroup, String id, V2TIMOfflinePushInfo v2TIMOfflinePushInfo, boolean retry, final IUIKitCallBack callBack) {
        if (message == null) {
            TUIKitLog.e(TAG, "forwardMessageInternal null message!");
            return;
        }

        V2TIMMessage forwardMessage = message.getTimMessage();
        forwardMessage.setExcludedFromUnreadCount(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
        forwardMessage.setExcludedFromLastMessage(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());

        String msgID = V2TIMManager.getMessageManager().sendMessage(forwardMessage, isGroup ? null : id, isGroup ? id : null,
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
                //mCurrentProvider.addMessageInfo(message);
            }
        }
    }

    private List<V2TIMMessage> MessgeInfo2TIMMessage(List<MessageInfo> msgInfos){
        if (msgInfos == null || msgInfos.isEmpty()){
            return null;
        }
        List<V2TIMMessage> msgList = new ArrayList<>();
        for(int i = 0; i < msgInfos.size(); i++){
            msgList.add(msgInfos.get(i).getTimMessage());
        }
        return msgList;
    }

    public void forwardMessageMerge(List<MessageInfo> msgInfos, boolean isGroup, String id, String offlineTitle, boolean selfConversation, boolean retry, final IUIKitCallBack callBack) {
        if (msgInfos == null || msgInfos.isEmpty()){
            return;
        }

        Context context = TUIKit.getAppContext();
        if (context == null) {
            TUIKitLog.d(TAG, "context == null");
            return;
        }
        //abstractList
        List<String> abstractList = new ArrayList<>();
        for(int j = 0; j < msgInfos.size() && j < 3; j++){
            V2TIMMessage v2TIMMessage = msgInfos.get(j).getTimMessage();
            int type = v2TIMMessage.getElemType();
            String userid = v2TIMMessage.getSender();
            if (type == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
                V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
                abstractList.add(userid + ":" + customElem.getDescription());
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
                V2TIMTextElem txtEle = v2TIMMessage.getTextElem();
                abstractList.add(userid + ":" + txtEle.getText());
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
                abstractList.add(userid + ":" + context.getString(R.string.custom_emoji));
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
                abstractList.add(userid + ":" + context.getString(R.string.audio_extra));
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
                abstractList.add(userid + ":" + context.getString(R.string.picture_extra));
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
                abstractList.add(userid + ":" + context.getString(R.string.video_extra));
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FILE) {
                abstractList.add(userid + ":" + context.getString(R.string.file_extra));
            } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_MERGER) {
                // 合并转发消息
                abstractList.add(userid + ":" + context.getString(R.string.forward_extra));
            }
        }

        //createMergerMessage
        List<V2TIMMessage> msgList = MessgeInfo2TIMMessage(msgInfos);
        V2TIMMessage mergeMsg = V2TIMManager.getMessageManager().createMergerMessage(msgList, offlineTitle, abstractList, TUIKit.getAppContext().getString(R.string.forward_compatible_text));
        MessageInfo msgInfo = MessageInfoUtil.buildMergeMessage(mergeMsg);

        if (selfConversation) {
            sendMessage(msgInfo, false, callBack);
            return;
        }

        msgInfo.setSelf(true);
        msgInfo.setRead(true);
        assembleGroupMessage(msgInfo);

        //V2TIMOfflinePushInfo
        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = msgInfo.getExtra().toString();
        entity.sender = msgInfo.getFromUser();
        entity.nickname = TUIKitConfigs.getConfigs().getGeneralConfig().getUserNickname();
        entity.faceUrl = TUIKitConfigs.getConfigs().getGeneralConfig().getUserFaceUrl();
        containerBean.entity = entity;

        if (isGroup) {
            entity.chatType = V2TIMConversation.V2TIM_GROUP;
            entity.sender = id;
        }

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        v2TIMOfflinePushInfo.setDesc(offlineTitle);
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");

        forwardMessageInternal(msgInfo, isGroup, id, v2TIMOfflinePushInfo, retry, callBack);
    }

    public void forwardMessageOneByOne(final List<MessageInfo> msgInfos, final boolean isGroup, final String id, final String offlineTitle, final boolean selfConversation, final boolean retry, final IUIKitCallBack callBack) {
        if (msgInfos == null || msgInfos.isEmpty()){
            return;
        }

        Runnable forwardMessageRunnable = new Runnable() {
            @Override
            public void run() {
                int timeInterval = isGroup ? FORWARD_GROUP_INTERVAL : FORWARD_C2C_INTERVAL;
                for(int j = 0; j < msgInfos.size(); j++){
                    MessageInfo info = msgInfos.get(j);
                    MessageInfo msgInfo = MessageInfoUtil.buildForwardMessage(info.getTimMessage());

                    if (selfConversation) {
                        sendMessage(msgInfo, false, callBack);
                        try {
                            Thread.sleep(timeInterval);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        continue;
                    }

                    if (msgInfo == null || msgInfo.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
                        continue;
                    }
                    msgInfo.setSelf(true);
                    msgInfo.setRead(true);
                    assembleGroupMessage(msgInfo);

                    OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
                    OfflineMessageBean entity = new OfflineMessageBean();
                    entity.content = msgInfo.getExtra().toString();
                    entity.sender = msgInfo.getFromUser();
                    entity.nickname = TUIKitConfigs.getConfigs().getGeneralConfig().getUserNickname();
                    entity.faceUrl = TUIKitConfigs.getConfigs().getGeneralConfig().getUserFaceUrl();
                    containerBean.entity = entity;

                    if (isGroup) {
                        entity.chatType = V2TIMConversation.V2TIM_GROUP;
                        entity.sender = id;
                    }

                    V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
                    v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
                    // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
                    v2TIMOfflinePushInfo.setDesc(offlineTitle);
                    v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");

                    forwardMessageInternal(msgInfo, isGroup, id, v2TIMOfflinePushInfo, retry, callBack);
                    try {
                        Thread.sleep(timeInterval);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        };
        Thread forwardThread = new Thread(forwardMessageRunnable);
        forwardThread.setName("ForwardMessageThread");
        ThreadHelper.INST.execute(forwardThread);
    }

    public void forwardMessage(List<MessageInfo> msgInfos, boolean isGroup, String id, String offlineTitle, int forwardMode, boolean selfConversation, boolean retry, final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "sendMessage unSafetyCall");
            return;
        }

        if (forwardMode == ForwardSelectActivity.FORWARD_MODE_ONE_BY_ONE) {
            forwardMessageOneByOne(msgInfos, isGroup, id, offlineTitle, selfConversation, retry, callBack);
        } else if (forwardMode == ForwardSelectActivity.FORWARD_MODE_MERGE) {
            forwardMessageMerge(msgInfos, isGroup, id, offlineTitle, selfConversation, retry, callBack);
        } else {
            TUIKitLog.d(TAG, "invalid forwardMode");
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
                    processHistoryMsgs(v2TIMMessages, chatInfo, true, callBack);
                }
            });
        }
    }

    public void loadChatMessages(int getMessageType, V2TIMMessage lastMessage, final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "loadLocalChatMessages unSafetyCall");
            return;
        }
        if (mIsLoading) {
            return;
        }
        mIsLoading = true;
        if (!mIsMore) {
            mCurrentProvider.addMessageInfo(null, false);
            callBack.onSuccess(null);
            mIsLoading = false;
            return;
        }

        V2TIMMessage lastTIMMsg = null;
        if (lastMessage == null) {
            mCurrentProvider.clear();
        } else {
            lastTIMMsg = lastMessage;
        }
//        final int unread = (int) mCurrentConversation.getUnreadMessageNum();
        final ChatInfo chatInfo = getCurrentChatInfo();
        if (getMessageType == TUIKitConstants.GET_MESSAGE_FORWARD) {
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
                        processHistoryMsgs(v2TIMMessages, chatInfo, true, callBack);
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
                        processHistoryMsgs(v2TIMMessages, chatInfo, true, callBack);
                    }
                });
            }
        } else if (getMessageType == TUIKitConstants.GET_MESSAGE_TWO_WAY){
            //older
            V2TIMMessageListGetOption optionForward = new V2TIMMessageListGetOption();
            optionForward.setCount(MSG_PAGE_COUNT);
            optionForward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_CLOUD_OLDER_MSG);
            optionForward.setLastMsg(lastTIMMsg);
            if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
                optionForward.setUserID(chatInfo.getId());
            } else {
                optionForward.setGroupID(chatInfo.getId());
            }

            final V2TIMMessage finalLastTIMMsg = lastTIMMsg;
            V2TIMManager.getMessageManager().getHistoryMessageList(optionForward, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onError(int code, String desc) {
                    mIsLoading = false;
                    callBack.onError(TAG, code, desc);
                    TUIKitLog.e(TAG, "loadChatMessages getHistoryMessageList optionForward failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    if (v2TIMMessages == null) {
                        v2TIMMessages = new ArrayList<>();
                    }
                    v2TIMMessages.add(0, finalLastTIMMsg);
                    processTwoWayHistoryMsgs(v2TIMMessages, chatInfo, true, false, callBack);

                    //newer
                    V2TIMMessageListGetOption optionBackward = new V2TIMMessageListGetOption();
                    optionBackward.setCount(MSG_PAGE_COUNT);
                    optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_CLOUD_NEWER_MSG);
                    optionBackward.setLastMsg(finalLastTIMMsg);
                    if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
                        optionBackward.setUserID(chatInfo.getId());
                    } else {
                        optionBackward.setGroupID(chatInfo.getId());
                    }

                    V2TIMManager.getMessageManager().getHistoryMessageList(optionBackward, new V2TIMValueCallback<List<V2TIMMessage>>() {
                        @Override
                        public void onError(int code, String desc) {
                            mIsLoading = false;
                            callBack.onError(TAG, code, desc);
                            TUIKitLog.e(TAG, "loadChatMessages getHistoryMessageList optionBackward failed, code = " + code + ", desc = " + desc);
                        }

                        @Override
                        public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                            processTwoWayHistoryMsgs(v2TIMMessages, chatInfo, false, true, callBack);
                        }
                    });
                }
            });
        } else if (getMessageType == TUIKitConstants.GET_MESSAGE_BACKWARD){
            //newer
            V2TIMMessageListGetOption optionBackward = new V2TIMMessageListGetOption();
            optionBackward.setCount(MSG_PAGE_COUNT);
            optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_CLOUD_NEWER_MSG);
            optionBackward.setLastMsg(lastTIMMsg);
            if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
                optionBackward.setUserID(chatInfo.getId());
            } else {
                optionBackward.setGroupID(chatInfo.getId());
            }

            V2TIMManager.getMessageManager().getHistoryMessageList(optionBackward, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onError(int code, String desc) {
                    mIsLoading = false;
                    callBack.onError(TAG, code, desc);
                    TUIKitLog.e(TAG, "loadChatMessages getHistoryMessageList optionBackward failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    processHistoryMsgs(v2TIMMessages, chatInfo, false, callBack);
                }
            });
        } else {
            TUIKitLog.e(TAG, "loadChatMessages getMessageType is invalid");
        }
    }

    private void processTwoWayHistoryMsgs(List<V2TIMMessage> v2TIMMessages, ChatInfo chatInfo, boolean front, boolean calllback, IUIKitCallBack callBack) {
        // 两者不一致说明加载到的消息已经不是当前聊天的消息
        if (chatInfo != getCurrentChatInfo()) {
            return;
        }
        mIsLoading = false;
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "getLocalMessage unSafetyCall");
            return;
        }

        if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
            c2cReadReport(chatInfo.getId());
        } else {
            groupReadReport(chatInfo.getId());
        }

       /* if (v2TIMMessages.size() < MSG_PAGE_COUNT) {
            mIsMore = false;
        }*/
        ArrayList<V2TIMMessage> messages = new ArrayList<>(v2TIMMessages);
        if (front) {
            Collections.reverse(messages);
        }

        List<MessageInfo> msgInfos = MessageInfoUtil.TIMMessages2MessageInfos(messages, isGroup());
        mCurrentProvider.addMessageList(msgInfos, front);
        for (int i = 0; i < msgInfos.size(); i++) {
            MessageInfo info = msgInfos.get(i);
            if (info.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
                sendMessage(info, true, null);
            }
        }

        if (calllback) {
            callBack.onSuccess(mCurrentProvider);
        }
    }

    private void processHistoryMsgs(List<V2TIMMessage> v2TIMMessages, ChatInfo chatInfo, boolean front, IUIKitCallBack callBack) {
        // 两者不一致说明加载到的消息已经不是当前聊天的消息
        if (chatInfo != getCurrentChatInfo()) {
            return;
        }
        mIsLoading = false;
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "getLocalMessage unSafetyCall");
            return;
        }

        if (chatInfo.getType() == V2TIMConversation.V2TIM_C2C) {
            c2cReadReport(chatInfo.getId());
        } else {
            groupReadReport(chatInfo.getId());
        }

        if (v2TIMMessages.size() < MSG_PAGE_COUNT) {
            mIsMore = false;
        }
        ArrayList<V2TIMMessage> messages = new ArrayList<>(v2TIMMessages);
        if (front) {
            Collections.reverse(messages);
        }

        List<MessageInfo> msgInfos = MessageInfoUtil.TIMMessages2MessageInfos(messages, isGroup());
        mCurrentProvider.addMessageList(msgInfos, front);
        for (int i = 0; i < msgInfos.size(); i++) {
            MessageInfo info = msgInfos.get(i);
            if (info.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
                sendMessage(info, true, null);
            }
        }
        callBack.onSuccess(mCurrentProvider);
    }

    /**
     * 收到消息上报已读加频率限制
     * @param userId 如果是 C2C 消息， userId 不为空， groupId 为空
     * @param groupId 如果是 Group 消息， groupId 不为空， userId 为空
     */
    private void limitReadReport(final String userId, final String groupId) {
        final long currentTime = System.currentTimeMillis();
        long timeDifference = currentTime - lastReadReportTime;
        if (timeDifference >= READ_REPORT_INTERVAL) {
            readReport(userId, groupId);
            lastReadReportTime = currentTime;
        } else {
            if (!canReadReport) {
                TUIKitLog.d(TAG, "limitReadReport : Reporting , please wait.");
                return;
            }
            long delay = READ_REPORT_INTERVAL - timeDifference;
            TUIKitLog.d(TAG, "limitReadReport : Please retry after " + delay + " ms.");
            canReadReport = false;
            readReportHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    readReport(userId, groupId);
                    lastReadReportTime = System.currentTimeMillis();
                    canReadReport = true;
                }
            }, delay);
        }
    }

    private static void c2cReadReport(String userId) {
        V2TIMManager.getMessageManager().markC2CMessageAsRead(userId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "markC2CMessageAsRead setReadMessage failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess() {
                TUIKitLog.d(TAG, "markC2CMessageAsRead setReadMessage success");
            }
        });
    }

    private static void groupReadReport(String groupId) {
        V2TIMManager.getMessageManager().markGroupMessageAsRead(groupId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "markGroupMessageAsRead failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess() {
                TUIKitLog.d(TAG, "markGroupMessageAsRead success");
            }
        });
    }

    private static void readReport(String userId, String groupId) {
        if (!TextUtils.isEmpty(userId)) {
            TUIKitLog.i(TAG, "C2C message ReadReport userId is " + userId);
            c2cReadReport(userId);
        } else if (!TextUtils.isEmpty(groupId)) {
            TUIKitLog.i(TAG, "Group message ReadReport groupId is " + groupId);
            groupReadReport(groupId);
        } else {
            TUIKitLog.e(TAG, "ReadReport failed : userId and groupId are both empty.");
        }
    }

    @Override
    public void handleRevoke(String msgID) {
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

    @Override
    public void sendMessage(IBaseInfo baseInfo, V2TIMOfflinePushInfo pushInfo, String receiver, boolean isGroup,boolean onlineUserOnly,  final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "sendMessage unSafetyCall ,baseInfo : " + baseInfo);
            return;
        }
        if (baseInfo instanceof MessageInfo) {
            final MessageInfo message = (MessageInfo) baseInfo;

            message.getTimMessage().setExcludedFromUnreadCount(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
            message.getTimMessage().setExcludedFromLastMessage(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());
            message.setSelf(true);
            message.setRead(true);
            assembleGroupMessage(message);
            TUIKitLog.i(TAG, "sendMessage to " + receiver);

            final V2TIMMessage v2TIMMessage = ((MessageInfo) baseInfo).getTimMessage();
            if (!onlineUserOnly) {
                v2TIMMessage.setExcludedFromUnreadCount(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
                v2TIMMessage.setExcludedFromLastMessage(TUIKitConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());
            }

            String msgID = V2TIMManager.getMessageManager().sendMessage(v2TIMMessage,
                    isGroup ? null : receiver, isGroup ? receiver : null, V2TIMMessage.V2TIM_PRIORITY_DEFAULT,
                    onlineUserOnly, pushInfo, new V2TIMSendCallback<V2TIMMessage>() {

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

                        @Override
                        public void onProgress(int progress) {

                        }
                    });
            //消息先展示，通过状态来确认发送是否成功
            TUIKitLog.i(TAG, "sendMessage msgID:" + msgID);
            if (message.getIsIgnoreShow()) {
                return;
            }
            message.setId(msgID);
            if (message.getMsgType() < MessageInfo.MSG_TYPE_TIPS || message.getMsgType() > MessageInfo.MSG_STATUS_REVOKE) {
                message.setStatus(MessageInfo.MSG_STATUS_SENDING);
                mCurrentProvider.addMessageInfo(message, false);
            }
        }
    }

    static class MessageReadReportHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    }
}
