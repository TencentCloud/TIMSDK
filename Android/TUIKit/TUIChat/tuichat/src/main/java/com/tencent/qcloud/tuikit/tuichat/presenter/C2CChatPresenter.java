package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import android.util.Pair;

import com.tencent.qcloud.tuikit.timcommon.bean.MessageFeature;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MessageTypingBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class C2CChatPresenter extends ChatPresenter {
    private static final String TAG = C2CChatPresenter.class.getSimpleName();

    private C2CChatInfo c2CChatInfo;

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
            public void onRecvMessageRevoked(String msgID, UserBean userBean, String reason) {
                C2CChatPresenter.this.handleRevoke(msgID, userBean);
            }

            @Override
            public void onRecvNewMessage(TUIMessageBean message) {
                if (c2CChatInfo == null || !TextUtils.equals(message.getUserId(), c2CChatInfo.getId())) {
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
                if (c2CChatInfo == null || !TextUtils.equals(userId, c2CChatInfo.getId())) {
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
                if (c2CChatInfo == null || !TextUtils.equals(messageBean.getUserId(), c2CChatInfo.getId())) {
                    return;
                }
                C2CChatPresenter.this.onRecvMessageModified(messageBean);
            }

            @Override
            public void addMessage(TUIMessageBean messageBean, String chatId) {
                if (TextUtils.equals(chatId, c2CChatInfo.getId())) {
                    addMessageInfo(messageBean);
                }
            }

            @Override
            public void clearC2CMessage(String userID) {
                if (TextUtils.equals(userID, c2CChatInfo.getId())) {
                    clearMessage();
                }
            }

            @Override
            public void onMessageChanged(TUIMessageBean messageBean, int dataChangeType) {
                updateMessageInfo(messageBean, dataChangeType);
            }
        };
        TUIChatService.getInstance().addC2CChatEventListener(chatEventListener);
        initMessageSender();
    }

    public void removeC2CChatEventListener() {
        TUIChatService.getInstance().removeC2CChatEventListener(chatEventListener);
    }

    /**
     *
     * pull message
     * @param type Pull forward, backward, or both
     * @param lastMessageInfo The starting point for pulling messages
     */
    @Override
    public void loadMessage(int type, TUIMessageBean lastMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        if (c2CChatInfo == null || isLoading) {
            return;
        }
        isLoading = true;

        String chatId = c2CChatInfo.getId();
        
        // Pull older messages forward
        if (type == TUIChatConstants.GET_MESSAGE_FORWARD) {
            provider.loadC2CMessage(chatId, MSG_PAGE_COUNT, lastMessageInfo, new IUIKitCallback<Pair<List<TUIMessageBean>, Integer>>() {
                @Override
                public void onSuccess(Pair<List<TUIMessageBean>, Integer> dataPair) {
                    List<TUIMessageBean> data = dataPair.first;
                    TUIChatLog.i(TAG, "load c2c message success " + data.size());
                    if (lastMessageInfo == null) {
                        isHaveMoreNewMessage = false;
                    }
                    if (dataPair.second < MSG_PAGE_COUNT) {
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
            
            // Pull the updated message backward or pull the message forward and backward at the same time
            loadHistoryMessageList(chatId, false, type, MSG_PAGE_COUNT, lastMessageInfo, callback);
        }
    }

    
    // This method is called after the message is loaded successfully
    @Override
    protected void onMessageLoadCompleted(List<TUIMessageBean> data, int getType) {
        c2cReadReport(c2CChatInfo.getId());
        getMessageReadReceipt(data, getType);
    }

    public void setChatInfo(C2CChatInfo c2CChatInfo) {
        this.c2CChatInfo = c2CChatInfo;
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
    public C2CChatInfo getChatInfo() {
        return c2CChatInfo;
    }

    public void onFriendNameChanged(String newName) {
        if (chatNotifyHandler != null) {
            chatNotifyHandler.onFriendNameChanged(newName);
        }
    }

    public void onFriendFaceUrlChanged(String userID, String faceUrl) {
        if (TextUtils.equals(userID, c2CChatInfo.getId())) {
            if (chatNotifyHandler != null) {
                chatNotifyHandler.onFriendFaceUrlChanged(faceUrl);
            }
        }
    }

    public void onReadReport(List<MessageReceiptInfo> receiptList) {
        if (c2CChatInfo != null) {
            List<MessageReceiptInfo> processReceipts = new ArrayList<>();
            for (MessageReceiptInfo messageReceiptInfo : receiptList) {
                if (!TextUtils.equals(messageReceiptInfo.getUserID(), c2CChatInfo.getId())) {
                    continue;
                }
                processReceipts.add(messageReceiptInfo);
            }
            onMessageReadReceiptUpdated(loadedMessageInfoList, processReceipts);
        }
    }

    public void onFriendInfoChanged() {
        provider.getFriendName(c2CChatInfo.getId(), new IUIKitCallback<String[]>() {
            @Override
            public void onSuccess(String[] data) {
                String displayName = c2CChatInfo.getId();
                if (!TextUtils.isEmpty(data[0])) {
                    displayName = data[0];
                } else if (!TextUtils.isEmpty(data[1])) {
                    displayName = data[1];
                }
                onFriendNameChanged(displayName);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
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
        
        TUIChatLog.i(TAG, "sendTypingStatusMessage msgID:" + msgId);
        message.setId(msgId);
        message.setStatus(TUIMessageBean.MSG_STATUS_SENDING);
    }

    public boolean isSupportTyping(long time) {
        if (loadedMessageInfoList == null || loadedMessageInfoList.size() == 0) {
            return false;
        }

        int size = loadedMessageInfoList.size();
        for (int i = size - 1; i >= 0; i--) {
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

    @Override
    public void getChatName(String chatID, IUIKitCallback<String> callback) {
        if (!TextUtils.isEmpty(chatID)) {
            provider.getChatName(chatID, false, new IUIKitCallback<String>() {
                @Override
                public void onSuccess(String data) {
                    TUIChatUtils.callbackOnSuccess(callback, data);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnSuccess(callback, chatID);
                }
            });
        }
    }

    @Override
    public void getChatFaceUrl(String chatID, IUIKitCallback<List<Object>> callback) {
        if (!TextUtils.isEmpty(chatID)) {
            provider.getChatFaceUrl(chatID, false, new IUIKitCallback<String>() {
                @Override
                public void onSuccess(String data) {
                    TUIChatUtils.callbackOnSuccess(callback, Collections.singletonList(data));
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                }
            });
        }
    }
}
