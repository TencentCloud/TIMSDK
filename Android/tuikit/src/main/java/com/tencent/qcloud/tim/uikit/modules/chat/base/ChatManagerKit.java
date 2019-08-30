package com.tencent.qcloud.tim.uikit.modules.chat.base;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMMessageListener;
import com.tencent.imsdk.TIMSNSSystemElem;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.modules.message.MessageRevokedManager;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public abstract class ChatManagerKit implements TIMMessageListener, MessageRevokedManager.MessageRevokeHandler {

    private static final String TAG = ChatManagerKit.class.getSimpleName();

    protected static final int MSG_PAGE_COUNT = 20;
    protected static final int REVOKE_TIME_OUT = 6223;

    protected ChatProvider mCurrentProvider;
    protected TIMConversation mCurrentConversation;

    protected boolean mIsMore;
    private boolean mIsLoading;

    protected void init() {
        destroyChat();
        TIMManager.getInstance().addMessageListener(this);
        MessageRevokedManager.getInstance().addHandler(this);
    }

    public void destroyChat() {
        mCurrentConversation = null;
        mCurrentProvider = null;
    }

    public abstract ChatInfo getCurrentChatInfo();

    public void setCurrentChatInfo(ChatInfo info) {
        if (info == null) {
            return;
        }
        mCurrentConversation = TIMManager.getInstance().getConversation(info.getType(), info.getId());
        mCurrentProvider = new ChatProvider();
        mIsMore = true;
        mIsLoading = false;
    }

    @Override
    public boolean onNewMessages(List<TIMMessage> msgs) {
        if (null != msgs && msgs.size() > 0) {
            for (TIMMessage msg : msgs) {
                TIMConversation conversation = msg.getConversation();
                TIMConversationType type = conversation.getType();
                if (type == TIMConversationType.C2C) {
                    onReceiveMessage(conversation, msg);
                    TUIKitLog.i(TAG, "onNewMessages() C2C msg = " + msg);
                } else if (type == TIMConversationType.Group) {
                    onReceiveMessage(conversation, msg);
                    TUIKitLog.i(TAG, "onNewMessages() Group msg = " + msg);
                } else if (type == TIMConversationType.System) {
                    onReceiveSystemMessage(msg);
                    TUIKitLog.i(TAG, "onReceiveSystemMessage() msg = " + msg);
                }
            }
        }
        return false;
    }

    // GroupChatManager会重写该方法
    protected void onReceiveSystemMessage(TIMMessage msg) {
        TIMElem ele = msg.getElement(0);
        TIMElemType eleType = ele.getType();
        // 用户资料修改通知，不需要在聊天界面展示，可以通过 TIMUserConfig 中的 setFriendshipListener 处理
        if (eleType == TIMElemType.ProfileTips) {
            TUIKitLog.i(TAG, "onReceiveSystemMessage eleType is ProfileTips, ignore");
        }
        if (eleType == TIMElemType.SNSTips) {
            TUIKitLog.i(TAG, "onReceiveSystemMessage eleType is SNSTips");
            TIMSNSSystemElem m = (TIMSNSSystemElem) ele;
            if (m.getRequestAddFriendUserList().size() > 0) {
                ToastUtil.toastLongMessage("好友申请通过");
            }
            if (m.getDelFriendAddPendencyList().size() > 0) {
                ToastUtil.toastLongMessage("好友申请被拒绝");
            }
        }
    }

    protected void onReceiveMessage(final TIMConversation conversation, final TIMMessage msg) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
            return;
        }
        if (conversation == null || conversation.getPeer() == null) {
            return;
        }
        addMessage(conversation, msg);
    }

    protected abstract boolean isGroup();

    protected void addMessage(TIMConversation conversation, TIMMessage msg) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
            return;
        }
        final List<MessageInfo> list = MessageInfoUtil.TIMMessage2MessageInfo(msg, isGroup());
        if (list != null && list.size() != 0 && mCurrentConversation.getPeer().equals(conversation.getPeer())) {
            mCurrentProvider.addMessageInfoList(list);
            for (MessageInfo msgInfo : list) {
                msgInfo.setRead(true);
                addGroupMessage(msgInfo);
            }
            mCurrentConversation.setReadMessage(msg, new TIMCallBack() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "addMessage() setReadMessage failed, code = " + code + ", desc = " + desc);
                }

                @Override
                public void onSuccess() {
                    TUIKitLog.d(TAG, "addMessage() setReadMessage success");
                }
            });
        }
    }

    protected void addGroupMessage(MessageInfo msgInfo) {
        // GroupChatManagerKit会重写该方法
    }

    public void deleteMessage(int position, MessageInfo messageInfo) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
            return;
        }
        TIMMessage timMessage = messageInfo.getTIMMessage();
        if (timMessage.remove()) {
            mCurrentProvider.remove(position);
        }
    }

    public void revokeMessage(final int position, final MessageInfo messageInfo) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
            return;
        }
        mCurrentConversation.revokeMessage(messageInfo.getTIMMessage(), new TIMCallBack() {
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
                mCurrentProvider.updateMessageRevoked(messageInfo.getId());
                ConversationManagerKit.getInstance().loadConversation(null);
            }
        });
    }

    public synchronized void sendMessage(final MessageInfo message, boolean retry, final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
            return;
        }
        if (message == null || message.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
            return;
        }
        message.setSelf(true);
        message.setRead(true);
        assembleGroupMessage(message);
        //消息先展示，通过状态来确认发送是否成功
        if (message.getMsgType() < MessageInfo.MSG_TYPE_TIPS) {
            message.setStatus(MessageInfo.MSG_STATUS_SENDING);
            if (retry) {
                mCurrentProvider.updateMessageInfo(message);
            } else {
                mCurrentProvider.addMessageInfo(message);
            }
        }
        new Thread() {
            @Override
            public void run() {
                mCurrentConversation.sendMessage(message.getTIMMessage(), new TIMValueCallBack<TIMMessage>() {
                    @Override
                    public void onError(final int code, final String desc) {
                        TUIKitLog.i(TAG, "sendMessage fail:" + code + "=" + desc);
                        if (callBack != null) {
                            callBack.onError(TAG, code, desc);
                        }
                        if (mCurrentProvider == null) {
                            return;
                        }
                        message.setStatus(MessageInfo.MSG_STATUS_SEND_FAIL);
                        mCurrentProvider.updateMessageInfo(message);

                    }

                    @Override
                    public void onSuccess(TIMMessage timMessage) {
                        TUIKitLog.i(TAG, "sendMessage onSuccess");
                        if (callBack != null) {
                            callBack.onSuccess(mCurrentProvider);
                        }
                        if (mCurrentProvider == null) {
                            return;
                        }
                        message.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                        message.setId(timMessage.getMsgId());
                        mCurrentProvider.updateMessageInfo(message);
                    }
                });
            }
        }.start();

    }

    protected void assembleGroupMessage(MessageInfo message) {
        // GroupChatManager会重写该方法
    }

    public synchronized void loadLocalChatMessages(MessageInfo lastMessage, final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
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

        TIMMessage lastTIMMsg = null;
        if (lastMessage == null) {
            mCurrentProvider.clear();
        } else {
            lastTIMMsg = lastMessage.getTIMMessage();
        }
        final int unread = (int) mCurrentConversation.getUnreadMessageNum();
        mCurrentConversation.getLocalMessage(unread > MSG_PAGE_COUNT ? unread : MSG_PAGE_COUNT
                , lastTIMMsg, new TIMValueCallBack<List<TIMMessage>>() {
                    @Override
                    public void onError(int code, String desc) {
                        mIsLoading = false;
                        callBack.onError(TAG, code, desc);
                        TUIKitLog.e(TAG, "loadChatMessages() getMessage failed, code = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess(List<TIMMessage> timMessages) {
                        mIsLoading = false;
                        if (mCurrentProvider == null) {
                            return;
                        }
                        if (unread > 0) {
                            mCurrentConversation.setReadMessage(null, new TIMCallBack() {
                                @Override
                                public void onError(int code, String desc) {
                                    TUIKitLog.e(TAG, "loadChatMessages() setReadMessage failed, code = " + code + ", desc = " + desc);
                                }

                                @Override
                                public void onSuccess() {
                                    TUIKitLog.d(TAG, "loadChatMessages() setReadMessage success");
                                }
                            });
                        }
                        if (timMessages.size() < MSG_PAGE_COUNT) {
                            mIsMore = false;
                        }
                        ArrayList<TIMMessage> messages = new ArrayList<>(timMessages);
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
                });
    }

    public synchronized void loadChatMessages(MessageInfo lastMessage, final IUIKitCallBack callBack) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
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

        TIMMessage lastTIMMsg = null;
        if (lastMessage == null) {
            mCurrentProvider.clear();
        } else {
            lastTIMMsg = lastMessage.getTIMMessage();
        }
        final int unread = (int) mCurrentConversation.getUnreadMessageNum();
        mCurrentConversation.getMessage(unread > MSG_PAGE_COUNT ? unread : MSG_PAGE_COUNT
                , lastTIMMsg, new TIMValueCallBack<List<TIMMessage>>() {
                    @Override
                    public void onError(int code, String desc) {
                        mIsLoading = false;
                        callBack.onError(TAG, code, desc);
                        TUIKitLog.e(TAG, "loadChatMessages() getMessage failed, code = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess(List<TIMMessage> timMessages) {
                        mIsLoading = false;
                        if (unread > 0) {
                            mCurrentConversation.setReadMessage(null, new TIMCallBack() {
                                @Override
                                public void onError(int code, String desc) {
                                    TUIKitLog.e(TAG, "loadChatMessages() setReadMessage failed, code = " + code + ", desc = " + desc);
                                }

                                @Override
                                public void onSuccess() {
                                    TUIKitLog.d(TAG, "loadChatMessages() setReadMessage success");
                                }
                            });
                        }
                        if (timMessages.size() < MSG_PAGE_COUNT) {
                            mIsMore = false;
                        }
                        ArrayList<TIMMessage> messages = new ArrayList<>(timMessages);
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
                });
    }

    @Override
    public void handleInvoke(TIMMessageLocator locator) {
        if (!safetyCall()) {
            TUIKitLog.w(TAG, "unSafetyCall");
            return;
        }
        if (locator.getConversationId().equals(getCurrentChatInfo().getId())) {
            TUIKitLog.i(TAG, "handleInvoke locator = " + locator);
            mCurrentProvider.updateMessageRevoked(locator);
        }
    }

    protected boolean safetyCall() {
        if (mCurrentConversation == null
                || mCurrentProvider == null
                || getCurrentChatInfo() == null
        ) {
            return false;
        }
        return true;
    }
}
