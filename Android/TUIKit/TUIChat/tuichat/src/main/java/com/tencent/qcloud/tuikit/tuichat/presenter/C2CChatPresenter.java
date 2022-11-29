package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageFeature;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MessageTypingBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.List;

public class C2CChatPresenter extends ChatPresenter {
    private static final String TAG = C2CChatPresenter.class.getSimpleName();

    private ChatInfo chatInfo;

    private C2CChatEventListener chatEventListener;

    private TypingListener typingListener;

    public C2CChatPresenter() {
        super();
        TUIChatLog.i(TAG, "C2CChatPresenter Init");
    }

    public void initListener() {
        chatEventListener = new C2CChatEventListener() {
            @Override
            public void onReadReport(List<MessageReceiptInfo> receiptList) {
                C2CChatPresenter.this.onReadReport(receiptList);
            }

            @Override
            public void exitC2CChat(String chatId) {
                C2CChatPresenter.this.onExitChat(chatId);
            }

            @Override
            public void handleRevoke(String msgId) {
                C2CChatPresenter.this.handleRevoke(msgId);
            }

            @Override
            public void onRecvNewMessage(TUIMessageBean message) {
                if (chatInfo == null || !TextUtils.equals(message.getUserId(), chatInfo.getId())) {
                    TUIChatLog.i(TAG, "receive a new message , not belong to current chat.");
                } else {
                    if (message instanceof MessageTypingBean) {
                        parseTypingMessage((MessageTypingBean) message);
                        return;
                    }
                    C2CChatPresenter.this.onRecvNewMessage(message);
                }
            }

            @Override
            public void onFriendNameChanged(String userId, String newName) {
                if (chatInfo == null || !TextUtils.equals(userId, chatInfo.getId())) {
                    return;
                }
                C2CChatPresenter.this.onFriendInfoChanged();
            }

            @Override
            public void onFriendFaceUrlChanged(String userId, String newFaceUrl) {
                C2CChatPresenter.this.onFriendFaceUrlChanged(userId, newFaceUrl);
            }

            @Override
            public void onRecvMessageModified(TUIMessageBean messageBean) {
                if (chatInfo == null || !TextUtils.equals(messageBean.getUserId(), chatInfo.getId())) {
                    return;
                }
                C2CChatPresenter.this.onRecvMessageModified(messageBean);
            }

            @Override
            public void addMessage(TUIMessageBean messageBean, String chatId) {
                if (TextUtils.equals(chatId, chatInfo.getId())) {
                    addMessageInfo(messageBean);
                }
            }

            @Override
            public void clearC2CMessage(String userID) {
                if (TextUtils.equals(userID, chatInfo.getId())) {
                    clearMessage();
                }
            }

            @Override
            public void onMessageChanged(TUIMessageBean messageBean) {
                updateMessageInfo(messageBean);
            }
        };
        TUIChatService.getInstance().addC2CChatEventListener(chatEventListener);
        initMessageSender();
    }

    /**
     * 拉取消息
     * @param type 向前，向后或者前后同时拉取
     * @param lastMessageInfo 拉取消息的起始点
     * 
     * 
     * pull message
     * @param type Pull forward, backward, or both
     * @param lastMessageInfo The starting point for pulling messages
     */
    @Override
    public void loadMessage(int type, TUIMessageBean lastMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        if (chatInfo == null || isLoading) {
            return;
        }
        isLoading = true;

        String chatId = chatInfo.getId();
        // 向前拉取更旧的消息
        // Pull older messages forward
        if (type == TUIChatConstants.GET_MESSAGE_FORWARD) {
            provider.loadC2CMessage(chatId, MSG_PAGE_COUNT, lastMessageInfo, new IUIKitCallback<List<TUIMessageBean>>() {

                @Override
                public void onSuccess(List<TUIMessageBean> data) {
                    TUIChatLog.i(TAG, "load c2c message success " + data.size());
                    if (lastMessageInfo == null) {
                        isHaveMoreNewMessage = false;
                    }
                    if (data.size() < MSG_PAGE_COUNT) {
                        isHaveMoreOldMessage = false;
                    }
                    TUIChatUtils.callbackOnSuccess(callback, data);
                    onMessageLoadCompleted(data, type);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatLog.e(TAG, "load c2c message failed " + errCode + "  " + errMsg);
                    TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                }
            });
        } else { 
            // 向后拉更新的消息 或者 前后同时拉消息
            // Pull the updated message backward or pull the message forward and backward at the same time
            loadHistoryMessageList(chatId, false, type, MSG_PAGE_COUNT, lastMessageInfo, callback);
        }
    }

    // 加载消息成功之后会调用此方法
    // This method is called after the message is loaded successfully
    @Override
    protected void onMessageLoadCompleted(List<TUIMessageBean> data, int getType) {
        c2cReadReport(chatInfo.getId());
        getMessageReadReceipt(data, getType);
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
    }

    public void setTypingListener(TypingListener typingListener) {
        this.typingListener = typingListener;
    }

    private void parseTypingMessage(MessageTypingBean messageTypingBean) {
        if (typingListener == null) {
            TUIChatLog.e(TAG, "parseTypingMessage typingListener is null");
            return;
        }
        typingListener.onTyping(messageTypingBean.getTypingStatus());
    }

    @Override
    public ChatInfo getChatInfo() {
        return chatInfo;
    }

    public void onFriendNameChanged(String newName) {
        if (chatNotifyHandler != null) {
            chatNotifyHandler.onFriendNameChanged(newName);
        }
    }

    public void onFriendFaceUrlChanged(String userID, String faceUrl) {
        if (TextUtils.equals(userID, chatInfo.getId())) {
            if (chatNotifyHandler != null) {
                chatNotifyHandler.onFriendFaceUrlChanged(faceUrl);
            }
        }
    }


    public void onReadReport(List<MessageReceiptInfo> receiptList) {
        if (chatInfo != null) {
            List<MessageReceiptInfo> processReceipts = new ArrayList<>();
            for (MessageReceiptInfo messageReceiptInfo : receiptList) {
                if (!TextUtils.equals(messageReceiptInfo.getUserID(), chatInfo.getId())) {
                    continue;
                }
                processReceipts.add(messageReceiptInfo);
            }
            onMessageReadReceiptUpdated(loadedMessageInfoList, processReceipts);
        }
    }

    public void onFriendInfoChanged() {
        provider.getFriendName(chatInfo.getId(), new IUIKitCallback<String[]>() {
            @Override
            public void onSuccess(String[] data) {
                String displayName = chatInfo.getId();
                if (!TextUtils.isEmpty(data[0])) {
                    displayName = data[0];
                } else if (!TextUtils.isEmpty(data[1])) {
                    displayName = data[1];
                }
                onFriendNameChanged(displayName);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    public void sendTypingStatusMessage(TUIMessageBean message, String receiver, IUIKitCallback<TUIMessageBean> callBack) {
        if (!safetyCall()) {
            TUIChatLog.e(TAG, "sendTypingStatusMessage unSafetyCall");
            return;
        }
        if (message == null || message.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            TUIChatLog.e(TAG, "message is null");
            return;
        }

        String msgId = provider.sendTypingStatusMessage(message, receiver, new IUIKitCallback<TUIMessageBean>() {
                    @Override
                    public void onSuccess(TUIMessageBean data) {
                        TUIChatLog.v(TAG, "sendTypingStatusMessage onSuccess:" + data.getId());
                        if (!safetyCall()) {
                            TUIChatLog.w(TAG, "sendTypingStatusMessage unSafetyCall");
                            return;
                        }
                        message.setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
                        TUIChatUtils.callbackOnSuccess(callBack, data);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        TUIChatLog.v(TAG, "sendTypingStatusMessage fail:" + errCode + "=" + errMsg);
                        if (!safetyCall()) {
                            TUIChatLog.w(TAG, "sendTypingStatusMessage unSafetyCall");
                            return;
                        }

                        TUIChatUtils.callbackOnError(callBack, TAG, errCode, errMsg);
                        message.setStatus(TUIMessageBean.MSG_STATUS_SEND_FAIL);
                    }

                    @Override
                    public void onProgress(Object data) {
                        TUIChatUtils.callbackOnProgress(callBack, data);
                    }
                });
        //消息先展示，通过状态来确认发送是否成功
        TUIChatLog.i(TAG, "sendTypingStatusMessage msgID:" + msgId);
        message.setId(msgId);
        message.setStatus(TUIMessageBean.MSG_STATUS_SENDING);
    }

    public boolean isSupportTyping(long time) {
        if (loadedMessageInfoList == null || loadedMessageInfoList.size() == 0) {
            return false;
        }

        int size = loadedMessageInfoList.size();
        for (int i = size - 1; i >= 0 ; i--) {
            TUIMessageBean tuiMessageBean = loadedMessageInfoList.get(i);
            if (!tuiMessageBean.isSelf()) {
                MessageFeature messageFeature = tuiMessageBean.isSupportTyping();
                if (messageFeature != null && messageFeature.getNeedTyping() == 1) {
                    int diff = (int) (time - tuiMessageBean.getMessageTime());
                    if (diff < TUIChatConstants.TYPING_TRIGGER_CHAT_TIME) {
                        return true;
                    }

                    return false;
                }
                break;
            }
        }
        return false;
    }
}
