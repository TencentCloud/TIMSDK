package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.google.gson.Gson;
import com.tencent.imsdk.BaseConstants;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.push.OfflinePushExtInfo;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflinePushInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.UserStatusBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IBaseMessageSender;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.model.AIDenoiseSignatureManager;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.OfflinePushInfoUtils;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CountDownLatch;

public abstract class ChatPresenter {
    private static final String TAG = ChatPresenter.class.getSimpleName();

    // Time interval for forwarding Group messages one by one
    private static final int FORWARD_GROUP_INTERVAL = 90;

    // Time interval for forwarding C2C messages one by one
    private static final int FORWARD_C2C_INTERVAL = 50;
    private static final int FORWARD_MSG_ABSTRACT_LENGTH = 98;

    // Message read reporting interval
    private static final int READ_REPORT_INTERVAL = 1000;

    protected static final int MSG_PAGE_COUNT = 20;

    protected final ChatProvider provider;
    protected List<TUIMessageBean> loadedMessageInfoList = new ArrayList<>();

    protected IMessageAdapter messageListAdapter;

    private IMessageRecyclerView messageRecyclerView;
    private int currentChatUnreadCount = 0;
    private TUIMessageBean mCacheNewMessage = null;

    protected ChatNotifyHandler chatNotifyHandler;

    private final MessageReadReportHandler readReportHandler = new MessageReadReportHandler();

    // Whether the current chat interface is displayed, used to determine whether the received message is set to read
    private boolean isChatFragmentShow = false;

    // Used to locate the location of the message when searching for a message
    private TUIMessageBean locateMessage;

    // Message sending interface exposed to other modules
    private IBaseMessageSender baseMessageSender;

    // Identifies whether there is an updated message that has not been updated
    protected boolean isHaveMoreNewMessage = true;

    // Identifies if there are older messages that have not been updated
    protected boolean isHaveMoreOldMessage = true;

    protected boolean isLoading = false;

    // Whether to display the translated content. The merged-forwarded message details activity does not display the bottom content.
    protected boolean isNeedShowBottom = true;

    private final Handler loadApplyHandler = new Handler();

    public ChatPresenter() {
        TUIChatLog.i(TAG, "ChatPresenter Init");

        provider = new ChatProvider();
        AIDenoiseSignatureManager.getInstance().updateSignature();
    }

    protected void initMessageSender() {
        baseMessageSender = new IBaseMessageSender() {
            @Override
            public String sendMessage(TUIMessageBean message, String receiver, boolean isGroup, boolean onlineUserOnly) {
                return ChatPresenter.this.sendMessage(message, receiver, isGroup, onlineUserOnly);
            }
        };
        TUIChatService.getInstance().setMessageSender(baseMessageSender);
    }

    public void loadMessage(int type, TUIMessageBean locateMessage) {
        if (type == TUIChatConstants.GET_MESSAGE_BACKWARD && !isHaveMoreNewMessage) {
            updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_ADD_FRONT, 0);
            return;
        }
        if (type == TUIChatConstants.GET_MESSAGE_FORWARD && !isHaveMoreOldMessage) {
            updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_ADD_FRONT, 0);
            return;
        }
        loadMessage(type, locateMessage, null);
    }

    public void loadMessage(int type, TUIMessageBean locateMessage, IUIKitCallback<List<TUIMessageBean>> callback) {}

    public void locateLastMessage(String chatID, boolean isGroup, IUIKitCallback<Void> callback) {
        provider.loadLastMessage(chatID, isGroup, true, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean lastMessage) {
                locateMessage(lastMessage.getId(), callback);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void clearMessage() {
        loadedMessageInfoList.clear();
        updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_REFRESH, 0);
    }

    public void scrollToNewestMessage() {
        if (!isHaveMoreNewMessage) {
            messageRecyclerView.scrollToEnd();
            return;
        }
        loadedMessageInfoList.clear();
        updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_REFRESH, 0);
        isHaveMoreOldMessage = true;
        loadMessage(TUIChatConstants.GET_MESSAGE_FORWARD, null);
    }

    public void locateMessageBySeq(String chatId, long seq, IUIKitCallback<Void> callback) {
        if (seq < 0) {
            TUIChatUtils.callbackOnError(callback, -1, "invalid param");
            return;
        }

        provider.getGroupMessageBySeq(chatId, seq, new IUIKitCallback<Pair<List<TUIMessageBean>, Integer>>() {
            @Override
            public void onSuccess(Pair<List<TUIMessageBean>, Integer> dataPair) {
                List<TUIMessageBean> data = dataPair.first;
                if (data == null || data.size() == 0) {
                    TUIChatUtils.callbackOnError(callback, -1, "null message");
                    return;
                }
                TUIMessageBean messageBean = data.get(0);
                if (messageBean.getMsgSeq() != seq) {
                    TUIChatUtils.callbackOnError(callback, -1, "can't find origin message");
                    return;
                }
                if (messageBean.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                    TUIChatUtils.callbackOnError(callback, -1, "origin msg is revoked");
                    return;
                }

                locateMessage(messageBean.getId(), new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {}

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void locateMessage(String originMsgId, IUIKitCallback<Void> callback) {
        // If it is already in the list, jump directly to the corresponding position, otherwise clear and reload
        for (TUIMessageBean loadedMessage : loadedMessageInfoList) {
            if (TextUtils.equals(originMsgId, loadedMessage.getId())) {
                updateAdapter(IMessageRecyclerView.SCROLL_TO_POSITION, loadedMessage);
                return;
            }
        }

        findMessage(originMsgId, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                if (data.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                    TUIChatUtils.callbackOnError(callback, -1, "origin msg is revoked");
                    return;
                }
                loadedMessageInfoList.clear();
                updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, 0);
                loadMessage(TUIChatConstants.GET_MESSAGE_LOCATE, data, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> data) {}

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public ChatInfo getChatInfo() {
        return null;
    }

    protected void c2cReadReport(String userId) {
        provider.c2cReadReport(userId);
    }

    protected void groupReadReport(String groupId) {
        provider.groupReadReport(groupId);
    }

    public void setMessageListAdapter(IMessageAdapter messageListAdapter) {
        this.messageListAdapter = messageListAdapter;
    }

    public void setMessageRecycleView(IMessageRecyclerView recycleView) {
        this.messageRecyclerView = recycleView;
        this.currentChatUnreadCount = 0;
        this.mCacheNewMessage = null;
    }

    public RecyclerView getMessageRecyclerView() {
        return (RecyclerView) this.messageRecyclerView;
    }

    private void loadToWayMessageAsync(
        String chatId, boolean isGroup, int getType, int loadCount, TUIMessageBean locateMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        List<TUIMessageBean> firstLoadedData = new ArrayList<>();
        List<TUIMessageBean> secondLoadedData = new ArrayList<>();
        firstLoadedData.add(locateMessageInfo);
        ChatPresenter.this.locateMessage = locateMessageInfo;
        CountDownLatch latch = new CountDownLatch(2);
        final boolean[] isFailed = {false};
        Runnable forwardRunnable = new Runnable() {
            @Override
            public void run() {
                provider.loadHistoryMessageList(chatId, isGroup, loadCount / 2, locateMessageInfo, TUIChatConstants.GET_MESSAGE_BACKWARD,
                    new IUIKitCallback<Pair<List<TUIMessageBean>, Integer>>() {
                        @Override
                        public void onSuccess(Pair<List<TUIMessageBean>, Integer> firstDataPair) {
                            List<TUIMessageBean> firstData = firstDataPair.first;
                            if (firstDataPair.second >= loadCount / 2) {
                                isHaveMoreNewMessage = true;
                            } else {
                                isHaveMoreNewMessage = false;
                            }
                            firstLoadedData.addAll(firstData);
                            latch.countDown();
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                            isFailed[0] = true;
                            latch.countDown();
                        }
                    });
            }
        };

        Runnable backwardRunnable = new Runnable() {
            @Override
            public void run() {
                // LastMsg will not be returned when pulling historical messages, you need to add it manually
                provider.loadHistoryMessageList(chatId, isGroup, loadCount / 2, locateMessageInfo, TUIChatConstants.GET_MESSAGE_FORWARD,
                    new IUIKitCallback<Pair<List<TUIMessageBean>, Integer>>() {
                        @Override
                        public void onSuccess(Pair<List<TUIMessageBean>, Integer> secondDataPair) {
                            List<TUIMessageBean> secondData = secondDataPair.first;
                            if (secondDataPair.second < loadCount / 2) {
                                isHaveMoreOldMessage = false;
                            }
                            secondLoadedData.addAll(secondData);
                            latch.countDown();
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            isFailed[0] = true;
                            latch.countDown();
                        }
                    });
            }
        };

        Runnable mergeRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    latch.await();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                if (isFailed[0]) {
                    TUIChatUtils.callbackOnError(callback, -1, "load failed");
                    return;
                }
                Collections.reverse(firstLoadedData);
                secondLoadedData.addAll(0, firstLoadedData);
                ThreadUtils.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onMessageLoadCompleted(secondLoadedData, getType);
                    }
                });
                TUIChatUtils.callbackOnSuccess(callback, secondLoadedData);
            }
        };

        ThreadUtils.execute(forwardRunnable);
        ThreadUtils.execute(backwardRunnable);
        ThreadUtils.execute(mergeRunnable);
    }

    public void loadHistoryMessageList(
        String chatId, boolean isGroup, int getType, int loadCount, TUIMessageBean locateMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        // If you are pulling messages before and after the same time, you need to pull twice, the first time to pull back,
        // the second time to pull forward
        if (getType == TUIChatConstants.GET_MESSAGE_TWO_WAY || getType == TUIChatConstants.GET_MESSAGE_LOCATE) {
            loadToWayMessageAsync(chatId, isGroup, getType, loadCount, locateMessageInfo, callback);
            return;
        }

        provider.loadHistoryMessageList(chatId, isGroup, loadCount, locateMessageInfo, getType, new IUIKitCallback<Pair<List<TUIMessageBean>, Integer>>() {
            @Override
            public void onSuccess(Pair<List<TUIMessageBean>, Integer> firstDataPair) {
                List<TUIMessageBean> firstData = firstDataPair.first;
                if (getType == TUIChatConstants.GET_MESSAGE_BACKWARD) {
                    if (firstDataPair.second >= loadCount) {
                        isHaveMoreNewMessage = true;
                    } else {
                        isHaveMoreNewMessage = false;
                    }
                }
                onMessageLoadCompleted(firstData, getType);
                TUIChatUtils.callbackOnSuccess(callback, firstData);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    protected void onMessageLoadCompleted(List<TUIMessageBean> data, int getType) {}

    protected void processLoadedMessage(List<TUIMessageBean> data, int type) {
        onLoadedMessageUpdate(data, type);
        processMessageAsync(data);
    }

    public void getMessageReadReceipt(List<TUIMessageBean> messageBeanList, IUIKitCallback<List<MessageReceiptInfo>> callback) {
        provider.getMessageReadReceipt(messageBeanList, callback);
    }

    // This method is called after the message is loaded successfully
    protected void getMessageReadReceipt(List<TUIMessageBean> data, int getType) {
        getMessageReadReceipt(data, new IUIKitCallback<List<MessageReceiptInfo>>() {
            @Override
            public void onSuccess(List<MessageReceiptInfo> receiptInfoList) {
                for (MessageReceiptInfo messageReceiptInfo : receiptInfoList) {
                    for (TUIMessageBean messageBean : data) {
                        if (TextUtils.equals(messageBean.getId(), messageReceiptInfo.getMsgID())) {
                            messageBean.setMessageReceiptInfo(messageReceiptInfo);
                        }
                    }
                }
                processLoadedMessage(data, getType);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                processLoadedMessage(data, getType);
            }
        });
    }

    private void removeDuplication(List<TUIMessageBean> messageBeans) {
        onMessageListDeleted(messageBeans);
    }

    private void onMessageListDeleted(List<TUIMessageBean> messageBeanList) {
        if (messageBeanList == null || messageBeanList.isEmpty()) {
            return;
        }
        for (TUIMessageBean messageBean : messageBeanList) {
            onMessageDeleted(messageBean);
        }
    }

    private void onMessageDeleted(TUIMessageBean messageBean) {
        if (messageBean == null) {
            return;
        }
        Iterator<TUIMessageBean> iterator = loadedMessageInfoList.listIterator();
        while (iterator.hasNext()) {
            TUIMessageBean loadedMessageBean = iterator.next();
            if (TextUtils.equals(loadedMessageBean.getId(), messageBean.getId())) {
                int index = loadedMessageInfoList.indexOf(loadedMessageBean);
                iterator.remove();
                updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_DELETE, index);
            }
        }
    }

    private void onLoadedMessageUpdate(List<TUIMessageBean> data, int type) {
        boolean isForward = type == TUIChatConstants.GET_MESSAGE_FORWARD;
        boolean isTwoWay = type == TUIChatConstants.GET_MESSAGE_TWO_WAY;
        boolean isLocate = type == TUIChatConstants.GET_MESSAGE_LOCATE;
        if (isForward || isTwoWay || isLocate) {
            Collections.reverse(data);
        }
        if (isForward || isTwoWay || isLocate) {
            removeDuplication(data);
            loadedMessageInfoList.addAll(0, data);
            if (isForward) {
                // If it is the first load, force jump to the bottom
                if (loadedMessageInfoList.size() == data.size()) {
                    updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_LOAD, data.size());
                } else {
                    updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_ADD_FRONT, data.size());
                }
            } else if (isTwoWay) {
                updateAdapter(IMessageRecyclerView.DATA_CHANGE_LOCATE_TO_POSITION, locateMessage);
            } else {
                updateAdapter(IMessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION, locateMessage);
            }
        } else {
            removeDuplication(data);
            loadedMessageInfoList.addAll(data);
            updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_ADD_BACK, data.size());
        }

        isLoading = false;
    }

    protected void processMessageAsync(List<TUIMessageBean> data) {
        TUIChatUtils.notifyProcessMessage(data);
        processQuoteMessage(data);
    }

    protected void processQuoteMessage(List<TUIMessageBean> data) {
        List<String> msgIdList = new ArrayList<>();
        List<QuoteMessageBean> quoteMessageList = new ArrayList<>();
        for (TUIMessageBean messageBean : data) {
            if (messageBean instanceof QuoteMessageBean) {
                quoteMessageList.add((QuoteMessageBean) messageBean);
                msgIdList.add(((QuoteMessageBean) messageBean).getOriginMsgId());
            }
        }
        Set<TUIMessageBean> updateSet = new HashSet<>();
        updateSet.addAll(quoteMessageList);
        CountDownLatch latch = new CountDownLatch(2);
        Runnable findMessageRunnable = new Runnable() {
            @Override
            public void run() {
                if (msgIdList.isEmpty()) {
                    latch.countDown();
                    return;
                }
                List<TUIMessageBean> originMessageBeans = new ArrayList<>();
                Iterator<String> iterator = msgIdList.iterator();
                List<TUIMessageBean> loadedData = getLoadedMessageList();
                while (iterator.hasNext()) {
                    String msgID = iterator.next();
                    for (TUIMessageBean messageBean : loadedData) {
                        if (TextUtils.equals(messageBean.getId(), msgID)) {
                            originMessageBeans.add(messageBean);
                            iterator.remove();
                            break;
                        }
                    }
                }
                findMessage(msgIdList, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> originData) {
                        setQuoteMessageAbstractEnable();
                        originMessageBeans.addAll(originData);
                        setOriginMessageBean();
                        latch.countDown();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        setQuoteMessageAbstractEnable();
                        setOriginMessageBean();
                        latch.countDown();
                    }

                    private void setOriginMessageBean() {
                        for (int i = 0; i < originMessageBeans.size(); i++) {
                            TUIMessageBean originMessageBean = originMessageBeans.get(i);
                            if (originMessageBean == null) {
                                continue;
                            }
                            for (QuoteMessageBean messageBean : quoteMessageList) {
                                if (TextUtils.equals(messageBean.getOriginMsgId(), originMessageBean.getId())) {
                                    messageBean.setOriginMessageBean(originMessageBean);
                                }
                            }
                        }
                    }

                    private void setQuoteMessageAbstractEnable() {
                        for (QuoteMessageBean quoteMessageBean : quoteMessageList) {
                            quoteMessageBean.setAbstractEnable(true);
                        }
                    }
                });
            }
        };
        ThreadUtils.execute(findMessageRunnable);

        Runnable requestForAdditionalUserBean = new Runnable() {
            @Override
            public void run() {
                Map<TUIMessageBean, Set<String>> requestAdditionalUserBeanMap = new HashMap<>();
                Set<String> allUserIdSet = new HashSet<>();
                for (TUIMessageBean messageBean : data) {
                    Set<String> userIdSet = messageBean.getAdditionalUserIDList();
                    if (!userIdSet.isEmpty()) {
                        requestAdditionalUserBeanMap.put(messageBean, userIdSet);
                        allUserIdSet.addAll(userIdSet);
                        updateSet.add(messageBean);
                    }
                }
                if (allUserIdSet.isEmpty()) {
                    latch.countDown();
                    return;
                }
                getUserBean(allUserIdSet, new IUIKitCallback<Map<String, UserBean>>() {
                    @Override
                    public void onSuccess(Map<String, UserBean> userBeanMap) {
                        for (Map.Entry<TUIMessageBean, Set<String>> entry : requestAdditionalUserBeanMap.entrySet()) {
                            Set<String> userIDSet = entry.getValue();
                            TUIMessageBean messageBean = entry.getKey();
                            for (String userID : userIDSet) {
                                UserBean userBean = userBeanMap.get(userID);
                                messageBean.setUserBean(userID, userBean);
                            }
                        }
                        latch.countDown();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        latch.countDown();
                    }
                });
            }
        };
        ThreadUtils.execute(requestForAdditionalUserBean);

        Runnable mergeRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    latch.await();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                Runnable runnable = new Runnable() {
                    @Override
                    public void run() {
                        for (TUIMessageBean messageBean : updateSet) {
                            updateMessageInfo(messageBean, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                        }
                    }
                };
                ThreadUtils.runOnUiThread(runnable);
            }
        };
        ThreadUtils.execute(mergeRunnable);
    }

    protected void addMessageInfo(TUIMessageBean messageInfo) {
        ThreadUtils.runOnUiThread(() -> {
            if (messageInfo == null) {
                return;
            }
            if (checkExist(messageInfo)) {
                return;
            }
            loadedMessageInfoList.add(messageInfo);
            updateAdapter(IMessageRecyclerView.DATA_CHANGE_NEW_MESSAGE, 1);
        });
    }

    protected void onRecvNewMessage(TUIMessageBean msg) {
        TUIChatLog.i(TAG, "onRecvNewMessage msgID:" + msg.getId());
        if (!isHaveMoreNewMessage) {
            msg.setMessageSource(TUIMessageBean.MSG_SOURCE_ONLINE_PUSH);
            addMessage(msg);
        }
    }

    protected void addMessage(TUIMessageBean messageInfo) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "addMessage unSafetyCall");
            return;
        }
        addMessageAfterPreProcess(messageInfo);

        processMessageAsync(Collections.singletonList(messageInfo));
    }

    private void addMessageAfterPreProcess(TUIMessageBean messageInfo) {
        if (messageInfo != null) {
            boolean isGroupMessage = false;
            String groupID = null;
            String userID = null;
            if (!TextUtils.isEmpty(messageInfo.getGroupId())) {
                isGroupMessage = true;
                groupID = messageInfo.getGroupId();
            } else if (!TextUtils.isEmpty(messageInfo.getUserId())) {
                userID = messageInfo.getUserId();
            } else {
                return;
            }

            addMessageInfo(messageInfo);

            if (isChatFragmentShow()) {
                if (messageRecyclerView != null && messageRecyclerView.isDisplayJumpMessageLayout()) {
                    if (messageInfo.getStatus() != TUIMessageBean.MSG_STATUS_REVOKE) {
                        currentChatUnreadCount++;
                        if (mCacheNewMessage == null) {
                            mCacheNewMessage = messageInfo;
                        }
                        messageRecyclerView.displayBackToNewMessage(true, mCacheNewMessage.getId(), currentChatUnreadCount);
                    } else if (messageInfo.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                        currentChatUnreadCount--;
                        if (currentChatUnreadCount == 0) {
                            messageRecyclerView.displayBackToNewMessage(false, "", 0);
                            mCacheNewMessage = null;
                        } else {
                            messageRecyclerView.displayBackToNewMessage(true, mCacheNewMessage.getId(), currentChatUnreadCount);
                        }
                    }
                } else {
                    mCacheNewMessage = null;
                    currentChatUnreadCount = 0;
                }
                if (isGroupMessage) {
                    limitReadReport(groupID, true);
                } else {
                    limitReadReport(userID, false);
                }
            }
        }
    }

    public void resetNewMessageCount() {
        currentChatUnreadCount = 0;
        mCacheNewMessage = null;
    }

    public void sendMessageReadReceipt(List<TUIMessageBean> messageBeanList, IUIKitCallback<Void> callback) {
        List<TUIMessageBean> messageBeans = new ArrayList<>();
        for (TUIMessageBean messageBean : messageBeanList) {
            if (messageBean.isNeedReadReceipt()) {
                messageBeans.add(messageBean);
            }
        }
        if (messageBeans.isEmpty()) {
            return;
        }
        provider.sendMessageReadReceipt(messageBeans, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUIChatUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.e(TAG, "sendMessageReadReceipt failed, errCode " + errCode + " errMsg " + errMsg);
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void markCallingMsgRead(List<CallingMessageBean> messageBeanList) {
        for (CallingMessageBean messageBean : messageBeanList) {
            if (messageBean.isShowUnreadPoint()) {
                messageBean.setShowUnreadPoint(false);
                messageBean.getV2TIMMessage().setLocalCustomInt(1);
            }
        }
    }

    public void onMessageReadReceiptUpdated(List<TUIMessageBean> messageBeanList, List<MessageReceiptInfo> data) {
        for (MessageReceiptInfo receiptInfo : data) {
            for (int i = 0; i < messageBeanList.size(); i++) {
                TUIMessageBean messageBean = loadedMessageInfoList.get(i);
                if (TextUtils.equals(messageBean.getId(), receiptInfo.getMsgID())) {
                    messageBean.setMessageReceiptInfo(receiptInfo);
                    updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, i);
                }
            }
        }
    }

    public void resetCurrentChatUnreadCount() {
        this.currentChatUnreadCount = 0;
        this.mCacheNewMessage = null;
    }

    public boolean isChatFragmentShow() {
        return isChatFragmentShow;
    }

    public void setChatFragmentShow(boolean isChatFragmentShow) {
        this.isChatFragmentShow = isChatFragmentShow;
    }

    public boolean isNeedShowBottom() {
        return isNeedShowBottom;
    }

    public void setNeedShowBottom(boolean needShowBottom) {
        isNeedShowBottom = needShowBottom;
    }

    public String sendMessage(final TUIMessageBean messageInfo, String receiver, boolean isGroup, boolean onlineUserOnly) {
        if (!TextUtils.isEmpty(receiver)) {
            if (!TextUtils.equals(getChatInfo().getId(), receiver) || isGroup != TUIChatUtils.isGroupChat(getChatInfo().getType())) {
                return null;
            }
        }
        return sendMessage(messageInfo, false, onlineUserOnly, null);
    }

    public String sendMessage(final TUIMessageBean message, boolean retry, boolean onlineUserOnly, final IUIKitCallback<TUIMessageBean> callBack) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "sendMessage unSafetyCall");
            return null;
        }
        if (message == null || message.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            return null;
        }
        if (TUIChatConfigs.getGeneralConfig().isMsgNeedReadReceipt() && getChatInfo() != null && getChatInfo().isNeedReadReceipt()) {
            message.setNeedReadReceipt(true);
        } else {
            message.setNeedReadReceipt(false);
        }
        assembleGroupMessage(message);
        notifyConversationInfo(getChatInfo());

        if (messageRecyclerView != null) {
            messageRecyclerView.scrollToEnd();
        }

        String msgId = provider.sendMessage(message, getChatInfo(), onlineUserOnly, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                ProgressPresenter.updateProgress(data.getId(), 100);
                TUIChatLog.v(TAG, "sendMessage onSuccess:" + data.getId());
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }
                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
                TUIChatUtils.callbackOnSuccess(callBack, data);
                updateMessageInfo(message, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                Map<String, Object> param = new HashMap<>();
                param.put(TUIChatConstants.MESSAGE_BEAN, data);
                TUICore.notifyEvent(TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND, param);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.v(TAG, "sendMessage fail:" + errCode + "=" + errMsg);
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }

                TUIChatUtils.callbackOnError(callBack, TAG, errCode, errMsg);
                if (errCode == TUIChatConstants.ERR_SVR_COMM_SENSITIVE_IMAGE || errCode == TUIChatConstants.ERR_SVR_COMM_SENSITIVE_TEXT
                    || errCode == TUIChatConstants.ERR_LOCAL_COMM_SENSITIVE_TEXT) {
                    message.setHasRiskContent(true);
                }
                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_FAIL);
                updateMessageInfo(message, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
            }

            @Override
            public void onProgress(Object data) {
                ProgressPresenter.updateProgress(message.getId(), (Integer) data);
                TUIChatUtils.callbackOnProgress(callBack, data);
            }
        });

        // The message is displayed first, and the status is used to confirm whether the sending is successful
        TUIChatLog.i(TAG, "sendMessage msgID:" + msgId);
        message.setId(msgId);
        message.setStatus(TUIMessageBean.MSG_STATUS_SENDING);
        if (retry) {
            resendMessageInfo(message);
        } else {
            addMessageInfo(message);
        }

        return msgId;
    }

    private void notifyConversationInfo(ChatInfo chatInfo) {
        String conversationId;
        if (ChatInfo.TYPE_GROUP == chatInfo.getType()) {
            conversationId = "group_" + chatInfo.getId();
        } else {
            conversationId = "c2c_" + chatInfo.getId();
        }

        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIConversation.CONVERSATION_ID, conversationId);
        TUICore.notifyEvent(TUIConstants.TUIConversation.EVENT_KEY_MESSAGE_SEND_FOR_CONVERSATION,
            TUIConstants.TUIConversation.EVENT_SUB_KEY_MESSAGE_SEND_FOR_CONVERSATION, param);
    }

    public void sendTypingStatusMessage(TUIMessageBean message, String receiver, IUIKitCallback<TUIMessageBean> callBack) {}

    public boolean isSupportTyping(long time) {
        return false;
    }

    public void updateMessageInfo(TUIMessageBean messageInfo, int dataChangeType) {
        for (int i = 0; i < loadedMessageInfoList.size(); i++) {
            if (loadedMessageInfoList.get(i) == null) {
                continue;
            }
            if (loadedMessageInfoList.get(i).getId().equals(messageInfo.getId())) {
                loadedMessageInfoList.set(i, messageInfo);
                updateAdapter(dataChangeType, messageInfo);
                return;
            }
        }
    }

    private void resendMessageInfo(TUIMessageBean messageInfo) {
        onMessageDeleted(messageInfo);
        addMessageInfo(messageInfo);
    }

    public void deleteMessage(TUIMessageBean messageInfo) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "deleteMessage unSafetyCall");
            return;
        }

        List<TUIMessageBean> msgs = new ArrayList<>();
        msgs.add(messageInfo);

        provider.deleteMessages(msgs, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                onMessageDeleted(messageInfo);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                Log.e(TAG, "delete message failed, errCode " + errCode + ", " + errMsg);
            }
        });
    }

    public void handleRevoke(String msgId, UserBean revoker) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "handleInvoke unSafetyCall");
            return;
        }
        processQuoteReplyRevoke(msgId);
        TUIChatLog.i(TAG, "handleInvoke msgID = " + msgId);
        for (int i = 0; i < loadedMessageInfoList.size(); i++) {
            TUIMessageBean messageInfo = loadedMessageInfoList.get(i);

            // A message containing multiple elements, when withdrawn, will withdraw all elements,
            // so the following judgment cannot return even if the conditions are met
            if (messageInfo.getId().equals(msgId)) {
                messageInfo.setRevoker(revoker);
                messageInfo.setStatus(TUIMessageBean.MSG_STATUS_REVOKE);
                updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, i);

                if (isChatFragmentShow()) {
                    if (messageRecyclerView != null && messageRecyclerView.isDisplayJumpMessageLayout()) {
                        if (messageInfo.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                            if (revoker != null) {
                                currentChatUnreadCount--;
                            }
                            if (currentChatUnreadCount <= 0) {
                                messageRecyclerView.displayBackToNewMessage(false, "", 0);
                                mCacheNewMessage = null;
                                currentChatUnreadCount = 0;
                            } else {
                                boolean isNeedRefreshCacheNewMessage = false;
                                ChatInfo chatInfo = getChatInfo();
                                if (chatInfo != null) {
                                    if (chatInfo.getType() == ChatInfo.TYPE_GROUP) {
                                        isNeedRefreshCacheNewMessage =
                                            messageInfo.getV2TIMMessage().getSeq() <= mCacheNewMessage.getV2TIMMessage().getSeq() ? true : false;
                                    } else {
                                        isNeedRefreshCacheNewMessage =
                                            messageInfo.getV2TIMMessage().getTimestamp() <= mCacheNewMessage.getV2TIMMessage().getTimestamp() ? true : false;
                                    }
                                }

                                if (!isNeedRefreshCacheNewMessage) {
                                    messageRecyclerView.displayBackToNewMessage(true, mCacheNewMessage.getId(), currentChatUnreadCount);
                                    return;
                                }

                                if ((i + 1) < loadedMessageInfoList.size()) {
                                    mCacheNewMessage = loadedMessageInfoList.get(i + 1);
                                    messageRecyclerView.displayBackToNewMessage(true, mCacheNewMessage.getId(), currentChatUnreadCount);
                                } else {
                                    messageRecyclerView.displayBackToNewMessage(false, "", 0);
                                    mCacheNewMessage = null;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private void processQuoteReplyRevoke(String messageID) {
        List<QuoteMessageBean> quoteMessages = new ArrayList<>();
        for (TUIMessageBean messageBean : loadedMessageInfoList) {
            if (messageBean instanceof QuoteMessageBean) {
                if (TextUtils.equals(((QuoteMessageBean) messageBean).getOriginMsgId(), messageID)) {
                    quoteMessages.add((QuoteMessageBean) messageBean);
                }
            }
        }
        if (quoteMessages.isEmpty()) {
            return;
        }
        findMessage(messageID, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                for (QuoteMessageBean quoteMessageBean : quoteMessages) {
                    quoteMessageBean.setOriginMessageBean(data);
                    updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, quoteMessageBean);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.e(TAG, "errorCode " + errCode + ", errMsg " + errMsg);
            }
        });
    }

    protected boolean safetyCall() {
        if (getChatInfo() == null) {
            return false;
        }
        return true;
    }

    public void markMessageAsRead(ChatInfo chatInfo) {
        if (chatInfo == null) {
            TUIChatLog.i(TAG, "markMessageAsRead() chatInfo is null");
            return;
        }
        boolean isGroup = chatInfo.getType() != ChatInfo.TYPE_C2C;
        String chatId = chatInfo.getId();
        limitReadReport(chatId, isGroup);
    }

    /**
     * Receive a message and report that it has been read and add frequency limit
     */
    private void limitReadReport(final String chatId, boolean isGroup) {
        readReportHandler.removeCallbacksAndMessages(null);
        readReportHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                readReport(chatId, isGroup);
            }
        }, READ_REPORT_INTERVAL);
    }

    private void readReport(String userId, boolean isGroup) {
        if (!isGroup) {
            TUIChatLog.i(TAG, "C2C message ReadReport userId is " + userId);
            c2cReadReport(userId);
        } else {
            TUIChatLog.i(TAG, "Group message ReadReport groupId is " + userId);
            groupReadReport(userId);
        }
    }

    protected void updateAdapter(int type, int value) {
        if (messageListAdapter != null) {
            messageListAdapter.onDataSourceChanged(loadedMessageInfoList);
            messageListAdapter.onViewNeedRefresh(type, value);
        }
    }

    protected void updateAdapter(int type, TUIMessageBean locateMessage) {
        if (messageListAdapter != null) {
            messageListAdapter.onDataSourceChanged(loadedMessageInfoList);
            messageListAdapter.onViewNeedRefresh(type, locateMessage);
        }
    }

    protected boolean checkExist(TUIMessageBean msg) {
        if (msg != null) {
            String msgId = msg.getId();
            for (int i = loadedMessageInfoList.size() - 1; i >= 0; i--) {
                if (loadedMessageInfoList.get(i).getId().equals(msgId)) {
                    return true;
                }
            }
        }
        return false;
    }

    public void deleteMessageInfos(final List<TUIMessageBean> messageInfos) {
        if (!safetyCall() || messageInfos == null || messageInfos.isEmpty()) {
            TUIChatLog.w(TAG, "deleteMessages unSafetyCall");
            return;
        }

        provider.deleteMessages(messageInfos, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                onMessageListDeleted(messageInfos);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void deleteMessages(final List<Integer> positions) {
        if (!safetyCall() || positions == null || positions.isEmpty()) {
            TUIChatLog.w(TAG, "deleteMessages unSafetyCall");
            return;
        }
        List<TUIMessageBean> msgs = new ArrayList<>();
        for (int i = 0; i < positions.size(); i++) {
            msgs.add(loadedMessageInfoList.get(positions.get(i)));
        }

        provider.deleteMessages(msgs, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                onMessageListDeleted(msgs);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public boolean checkFailedMessageInfos(final List<TUIMessageBean> messageInfos) {
        if (!safetyCall() || messageInfos == null || messageInfos.isEmpty()) {
            TUIChatLog.w(TAG, "checkFailedMessagesById unSafetyCall");
            return false;
        }

        boolean failed = false;
        for (int i = 0; i < messageInfos.size(); i++) {
            if (provider.checkFailedMessageInfo(messageInfos.get(i))) {
                failed = true;
                break;
            }
        }

        return failed;
    }

    public void revokeMessage(final TUIMessageBean message) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "revokeMessage unSafetyCall");
            return;
        }
        provider.revokeMessage(message, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                if (message instanceof ReplyMessageBean) {
                    modifyRootMessageToRemoveReplyInfo((ReplyMessageBean) message, new IUIKitCallback<Void>() {
                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastShortMessage("modify message failed code = " + errCode + " message = " + errMsg);
                        }
                    });
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                if (errCode == ChatProvider.ERR_REVOKE_TIME_LIMIT_EXCEED || errCode == ChatProvider.ERR_REVOKE_TIME_LIMIT_SVR_GROUP
                    || errCode == ChatProvider.ERR_REVOKE_TIME_LIMIT_SVR_MESSAGE) {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.send_two_mins));
                } else {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.revoke_fail) + errCode + "=" + errMsg);
                }
            }
        });
    }

    public void forwardMessage(List<TUIMessageBean> msgInfos, boolean isGroup, String id, String offlineTitle, int forwardMode, boolean selfConversation,
        final IUIKitCallback callBack) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "sendMessage unSafetyCall");
            return;
        }

        for (TUIMessageBean messageBean : msgInfos) {
            if (messageBean instanceof TextMessageBean) {
                TUIChatLog.d(TAG, "chatprensetor forwardMessage onTextSelected selectedText = " + ((TextMessageBean) messageBean).getSelectText());
            }
        }

        // If forwarding is selected, no special treatment will be performed for the time being, and the original message will be forwarded.
        // List<TUIMessageBean> forwardMsgInfos = forwardTextMessageForSelected(msgInfos);
        if (forwardMode == TUIChatConstants.FORWARD_MODE_ONE_BY_ONE) {
            forwardMessageOneByOne(msgInfos, isGroup, id, offlineTitle, selfConversation, callBack);
        } else if (forwardMode == TUIChatConstants.FORWARD_MODE_MERGE) {
            forwardMessageMerge(msgInfos, isGroup, id, offlineTitle, selfConversation, callBack);
        } else if (forwardMode == TUIChatConstants.FORWARD_MODE_NEW_MESSAGE) {
            TUIMessageBean messageBean = msgInfos.get(0);
            OfflinePushInfo offlinePushInfo = getOfflinePushInfo(messageBean, isGroup, id, offlineTitle);
            forwardMessageInternal(messageBean, isGroup, id, offlinePushInfo, callBack);
        } else {
            TUIChatLog.d(TAG, "invalid forwardMode");
        }
    }

    public void forwardMessageOneByOne(final List<TUIMessageBean> msgInfos, final boolean isGroup, final String id, final String offlineTitle,
        final boolean selfConversation, final IUIKitCallback callBack) {
        if (msgInfos == null || msgInfos.isEmpty()) {
            return;
        }

        Runnable forwardMessageRunnable = new Runnable() {
            @Override
            public void run() {
                int timeInterval = isGroup ? FORWARD_GROUP_INTERVAL : FORWARD_C2C_INTERVAL;
                for (int j = 0; j < msgInfos.size(); j++) {
                    TUIMessageBean info = msgInfos.get(j);
                    TUIMessageBean message = ChatMessageBuilder.buildForwardMessage(info.getV2TIMMessage());

                    if (selfConversation) {
                        sendMessage(message, false, false, callBack);
                        try {
                            Thread.sleep(timeInterval);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        continue;
                    }

                    if (message == null || message.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
                        continue;
                    }
                    if (isGroup) {
                        filterGroupMessageReceipt(message, id);
                    }
                    OfflinePushInfo offlinePushInfo = getOfflinePushInfo(message, isGroup, id, offlineTitle);

                    forwardMessageInternal(message, isGroup, id, offlinePushInfo, callBack);
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
        ThreadUtils.execute(forwardThread);
    }

    @NonNull
    private static OfflinePushInfo getOfflinePushInfo(TUIMessageBean message, boolean isGroup, String id, String offlineTitle) {
        OfflinePushExtInfo containerBean = new OfflinePushExtInfo();
        containerBean.getBusinessInfo().setDesc(FaceManager.emojiJudge(message.getExtra()));
        containerBean.getBusinessInfo().setSenderId(message.getSender());
        containerBean.getBusinessInfo().setSenderNickName(TUIConfig.getSelfNickName());
        containerBean.getBusinessInfo().setFaceUrl(TUIConfig.getSelfFaceUrl());

        if (isGroup) {
            containerBean.getBusinessInfo().setChatType(ChatInfo.TYPE_GROUP);
            containerBean.getBusinessInfo().setSenderId(id);
        }

        OfflinePushInfo offlinePushInfo = new OfflinePushInfo();
        offlinePushInfo.setExtension(new Gson().toJson(containerBean).getBytes());
        offlinePushInfo.setDescription(offlineTitle);

        // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
        offlinePushInfo.setAndroidOPPOChannelID("tuikit");
        if (TUIChatConfigs.getConfigs().getGeneralConfig().isEnableAndroidPrivateRing()) {
            offlinePushInfo.setAndroidSound(OfflinePushInfoUtils.PRIVATE_RING_NAME);
        }
        return offlinePushInfo;
    }

    public void sendMessages(List<TUIMessageBean> messageBeans) {
        if (messageBeans == null || messageBeans.isEmpty()) {
            return;
        }
        Runnable sendMessagesRunnable = () -> {
            int timeInterval = FORWARD_GROUP_INTERVAL;
            if (getChatInfo().getType() == ChatInfo.TYPE_C2C) {
                timeInterval = FORWARD_C2C_INTERVAL;
            }

            for (int j = 0; j < messageBeans.size(); j++) {
                TUIMessageBean messageBean = messageBeans.get(j);
                sendMessage(messageBean, false, false, null);
                try {
                    Thread.sleep(timeInterval);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        };
        Thread forwardThread = new Thread(sendMessagesRunnable);
        forwardThread.setName("SendMessagesThread");
        ThreadUtils.execute(forwardThread);
    }

    private void filterGroupMessageReceipt(TUIMessageBean messageBean, String groupID) {
        if (TUIChatUtils.isCommunityGroup(groupID)) {
            messageBean.setNeedReadReceipt(false);
        }
    }

    protected void assembleGroupMessage(TUIMessageBean message) {}

    public void forwardMessageMerge(
        List<TUIMessageBean> msgInfos, boolean isGroup, String id, String offlineTitle, boolean selfConversation, final IUIKitCallback callBack) {
        if (msgInfos == null || msgInfos.isEmpty()) {
            return;
        }

        Context context = TUIChatService.getAppContext();
        if (context == null) {
            TUIChatLog.d(TAG, "context == null");
            return;
        }
        // abstractList
        List<String> abstractList = new ArrayList<>();
        for (int j = 0; j < msgInfos.size() && j < 3; j++) {
            TUIMessageBean messageBean = msgInfos.get(j);
            String userName = ChatMessageParser.getDisplayName(messageBean.getV2TIMMessage());
            String messageAbstract = messageBean.getExtra();
            if (messageBean instanceof FaceMessageBean) {
                messageAbstract = context.getString(R.string.custom_emoji);
            } else if (messageBean instanceof SoundMessageBean) {
                messageAbstract = context.getString(R.string.audio_extra);
            } else if (messageBean instanceof ImageMessageBean) {
                messageAbstract = context.getString(R.string.picture_extra);
            } else if (messageBean instanceof VideoMessageBean) {
                messageAbstract = context.getString(R.string.video_extra);
            } else if (messageBean instanceof FileMessageBean) {
                messageAbstract = context.getString(R.string.file_extra);
            } else if (messageBean instanceof MergeMessageBean) {
                messageAbstract = context.getString(R.string.forward_extra);
            }
            messageAbstract = alignEmojiString(userName, messageAbstract);
            abstractList.add(String.format(Locale.US, "%1$s\u202C:%2$s", userName, messageAbstract));
        }

        // createMergerMessage
        TUIMessageBean msgInfo = ChatMessageBuilder.buildMergeMessage(
            msgInfos, offlineTitle, abstractList, TUIChatService.getAppContext().getString(R.string.forward_compatible_text));

        if (selfConversation) {
            sendMessage(msgInfo, false, false, callBack);
            return;
        }
        if (isGroup) {
            filterGroupMessageReceipt(msgInfo, id);
        }

        OfflinePushInfo offlinePushInfo = getOfflinePushInfo(msgInfo, isGroup, id, offlineTitle);

        forwardMessageInternal(msgInfo, isGroup, id, offlinePushInfo, callBack);
    }

    private String alignEmojiString(String userName, String text) {
        List<String> textList = FaceManager.splitEmojiText(text);
        StringBuilder sb = new StringBuilder();
        int length = userName.length();
        for (String textItem : textList) {
            boolean isFaceChar = FaceManager.isFaceChar(textItem);
            if (isFaceChar) {
                if (length + textItem.length() < FORWARD_MSG_ABSTRACT_LENGTH) {
                    sb.append(textItem);
                    length += textItem.length();
                } else {
                    sb.append("...");
                    break;
                }
            } else {
                if (length + textItem.length() < FORWARD_MSG_ABSTRACT_LENGTH) {
                    sb.append(textItem);
                    length += textItem.length();
                } else {
                    sb.append(textItem);
                    break;
                }
            }
        }
        return sb.toString();
    }

    public void forwardMessageInternal(
        final TUIMessageBean message, boolean isGroup, String id, OfflinePushInfo offlinePushInfo, final IUIKitCallback callBack) {
        if (message == null) {
            TUIChatLog.e(TAG, "forwardMessageInternal null message!");
            return;
        }

        boolean isNeedReadReceipt = TUIChatConfigs.getConfigs().getGeneralConfig().isMsgNeedReadReceipt();
        message.setNeedReadReceipt(isNeedReadReceipt);
        if (isGroup) {
            message.setGroup(true);
            if (TUIChatUtils.isCommunityGroup(id)) {
                message.setNeedReadReceipt(false);
            }
        }

        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.CHAT_ID, id);
        param.put(TUIConstants.TUIChat.MESSAGE_BEAN, message);
        param.put(TUIConstants.TUIChat.IS_GROUP_CHAT, isGroup);
        TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_ADD_MESSAGE_TO_CHAT, param);

        String msgId = provider.sendMessage(message, isGroup, id, offlinePushInfo, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                ProgressPresenter.updateProgress(data.getId(), 100);

                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }

                TUIChatUtils.callbackOnSuccess(callBack, data);
                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
                updateMessageInfo(message, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                Map<String, Object> param = new HashMap<>();
                param.put(TUIChatConstants.MESSAGE_BEAN, data);
                TUICore.notifyEvent(TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND, param);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ProgressPresenter.updateProgress(message.getId(), 100);

                TUIChatLog.v(TAG, "sendMessage fail:" + errCode + "=" + errMsg);
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }
                TUIChatUtils.callbackOnError(callBack, errCode, errMsg);
                if (errCode == TUIChatConstants.ERR_SVR_COMM_SENSITIVE_IMAGE || errCode == TUIChatConstants.ERR_SVR_COMM_SENSITIVE_TEXT
                    || errCode == TUIChatConstants.ERR_LOCAL_COMM_SENSITIVE_TEXT) {
                    message.setHasRiskContent(true);
                }
                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_FAIL);
                updateMessageInfo(message, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                Map<String, Object> param = new HashMap<>();
                param.put(TUIChatConstants.MESSAGE_BEAN, message);
                TUICore.notifyEvent(TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND, param);
            }

            @Override
            public void onProgress(Object data) {
                ProgressPresenter.updateProgress(message.getId(), (Integer) data);
            }
        });

        // The message is displayed first, and the status is used to confirm whether the sending is successful
        TUIChatLog.i(TAG, "sendMessage msgID:" + msgId);
        message.setId(msgId);
        message.setStatus(TUIMessageBean.MSG_STATUS_SENDING);
    }

    class LoadApplyListRunnable implements Runnable {
        private static final int TRY_DELAY = 500;
        private IUIKitCallback<List<GroupApplyInfo>> callback;

        @Override
        public void run() {
            provider.loadApplyInfo(new IUIKitCallback<List<GroupApplyInfo>>() {
                @Override
                public void onSuccess(List<GroupApplyInfo> data) {
                    if (!(getChatInfo() instanceof GroupInfo)) {
                        return;
                    }
                    String groupId = getChatInfo().getId();
                    List<GroupApplyInfo> applyInfos = new ArrayList<>();
                    for (int i = 0; i < data.size(); i++) {
                        GroupApplyInfo applyInfo = data.get(i);
                        if (groupId.equals(applyInfo.getGroupApplication().getGroupID()) && !applyInfo.isStatusHandled()) {
                            applyInfos.add(applyInfo);
                        }
                    }
                    TUIChatUtils.callbackOnSuccess(callback, applyInfos);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    if (errCode == BaseConstants.ERR_IN_PROGESS) {
                        loadApplyHandler.removeCallbacksAndMessages(null);
                        loadApplyHandler.postDelayed(LoadApplyListRunnable.this, TRY_DELAY);
                    }
                    TUIChatUtils.callbackOnError(callback, module, errCode, errMsg);
                }
            });
        }
    }

    public void loadApplyList(IUIKitCallback<List<GroupApplyInfo>> callBack) {
        loadApplyHandler.removeCallbacksAndMessages(null);
        LoadApplyListRunnable runnable = new LoadApplyListRunnable();
        runnable.callback = callBack;
        loadApplyHandler.post(runnable);
    }

    public void setDraft(String draft) {
        ChatInfo chatInfo = getChatInfo();
        if (chatInfo == null) {
            return;
        }
        String conversationId = TUIChatUtils.getConversationIdByChatId(chatInfo.getId(), TUIChatUtils.isGroupChat(chatInfo.getType()));
        provider.setDraft(conversationId, draft);
    }

    public void findMessage(String msgId, IUIKitCallback<TUIMessageBean> callback) {
        for (TUIMessageBean messageBean : loadedMessageInfoList) {
            if (TextUtils.equals(msgId, messageBean.getId())) {
                TUIChatUtils.callbackOnSuccess(callback, messageBean);
                return;
            }
        }
        List<String> msgList = new ArrayList<>();
        msgList.add(msgId);
        provider.findMessage(msgList, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                if (data != null && !data.isEmpty()) {
                    TUIChatUtils.callbackOnSuccess(callback, data.get(0));
                } else {
                    TUIChatUtils.callbackOnError(callback, -1, "can't find message");
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void findMessage(List<String> msgList, IUIKitCallback<List<TUIMessageBean>> callback) {
        provider.findMessage(msgList, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                if (data != null && !data.isEmpty()) {
                    TUIChatUtils.callbackOnSuccess(callback, data);
                } else {
                    TUIChatUtils.callbackOnError(callback, 0, "");
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void setChatNotifyHandler(ChatNotifyHandler chatNotifyHandler) {
        this.chatNotifyHandler = chatNotifyHandler;
    }

    public void onExitChat(String chatId) {
        if (chatNotifyHandler != null) {
            chatNotifyHandler.onExitChat(chatId);
        }
    }

    protected void onRecvMessageModified(TUIMessageBean messageBean) {
        int size = loadedMessageInfoList.size();
        boolean isFound = false;
        for (int i = 0; i < size; i++) {
            TUIMessageBean replacedMessage = loadedMessageInfoList.get(i);
            if (TextUtils.equals(replacedMessage.getId(), messageBean.getId())) {
                if (replacedMessage.customReloadWithNewMsg(messageBean.getV2TIMMessage())) {
                    return;
                }
                loadedMessageInfoList.set(i, messageBean);
                isFound = true;
                break;
            }
        }
        if (!isFound) {
            return;
        }
        getReadReceiptAndRefresh(messageBean);

        processMessageAsync(Collections.singletonList(messageBean));
    }

    private void getReadReceiptAndRefresh(TUIMessageBean messageBean) {
        List<TUIMessageBean> list = new ArrayList<>();
        list.add(messageBean);
        getMessageReadReceipt(list, new IUIKitCallback<List<MessageReceiptInfo>>() {
            @Override
            public void onSuccess(List<MessageReceiptInfo> data) {
                messageBean.setMessageReceiptInfo(data.get(0));
                updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, messageBean);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                updateAdapter(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, messageBean);
            }
        });
    }

    public void modifyRootMessageToRemoveReplyInfo(ReplyMessageBean replyMessageBean, IUIKitCallback<Void> callback) {
        String messageRootId = replyMessageBean.getMsgRootId();
        findMessage(messageRootId, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                modifyRootMessageToRemoveReplyInfo(data, replyMessageBean);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    private void modifyRootMessageToRemoveReplyInfo(TUIMessageBean rootMessage, ReplyMessageBean replyMessage) {
        IUIKitCallback<TUIMessageBean> callback = new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                // do nothing, when modifyRootMessage successfully ,you can receive onRecvMessageModified callback in TUIChatService.java
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("modifyRootMessageRemoveReply failed code=" + errCode + " msg=" + errMsg);
            }
        };
        ChatModifyMessageHelper.ModifyMessageTask task = new ChatModifyMessageHelper.ModifyMessageTask(rootMessage, callback) {
            @Override
            public TUIMessageBean packageMessage(TUIMessageBean originMessage) {
                MessageRepliesBean repliesBean = originMessage.getMessageRepliesBean();
                if (repliesBean == null) {
                    return originMessage;
                }
                repliesBean.removeReplyMessage(replyMessage.getId());
                originMessage.setMessageRepliesBean(repliesBean);
                return originMessage;
            }
        };
        ChatModifyMessageHelper.enqueueTask(task);
    }

    public void modifyRootMessageToAddReplyInfo(ReplyMessageBean replyMessageBean, IUIKitCallback<Void> callback) {
        String messageRootId = replyMessageBean.getMsgRootId();
        findMessage(messageRootId, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                modifyRootMessageToAddReplyInfo(data, replyMessageBean);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    private void modifyRootMessageToAddReplyInfo(TUIMessageBean rootMessage, ReplyMessageBean replyMessage) {
        IUIKitCallback<TUIMessageBean> callback = new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                // do nothing, when modifyRootMessage successfully ,you can receive onRecvMessageModified callback in TUIChatService.java
                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIChat.CHAT_ID, rootMessage.getGroupId());
                TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_REPLY_MESSAGE_SUCCESS, param);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("modifyRootMessageAddReply failed code=" + errCode + " msg=" + errMsg);
            }
        };
        ChatModifyMessageHelper.ModifyMessageTask task = new ChatModifyMessageHelper.ModifyMessageTask(rootMessage, callback) {
            @Override
            public TUIMessageBean packageMessage(TUIMessageBean originMessage) {
                MessageRepliesBean repliesBean = originMessage.getMessageRepliesBean();
                if (repliesBean == null) {
                    repliesBean = new MessageRepliesBean();
                }
                repliesBean.addReplyMessage(replyMessage.getId(), replyMessage.getContentMessageBean().getExtra(), replyMessage.getSender());
                originMessage.setMessageRepliesBean(repliesBean);
                return originMessage;
            }
        };
        ChatModifyMessageHelper.enqueueTask(task);
    }

    public void getChatName(String chatID, IUIKitCallback<String> callback) {}

    public void getChatFaceUrl(String chatID, IUIKitCallback<List<Object>> callback) {}

    public void getUserBean(Set<String> userIds, IUIKitCallback<Map<String, UserBean>> callback) {
        Map<String, UserBean> userBeanHashMap = new HashMap<>();
        for (String id : userIds) {
            userBeanHashMap.put(id, null);
        }
        ChatInfo chatInfo = getChatInfo();
        if (chatInfo instanceof GroupInfo) {
            provider.getGroupMembersInfo(chatInfo.getId(), new ArrayList<>(userIds), new IUIKitCallback<List<GroupMemberInfo>>() {
                @Override
                public void onSuccess(List<GroupMemberInfo> data) {
                    for (GroupMemberInfo memberInfo : data) {
                        UserBean userBean = new UserBean();
                        userBean.setUserId(memberInfo.getAccount());
                        userBean.setFriendRemark(memberInfo.getFriendRemark());
                        userBean.setNameCard(memberInfo.getNameCard());
                        userBean.setNikeName(memberInfo.getNickName());
                        userBean.setFaceUrl(memberInfo.getIconUrl());
                        userBeanHashMap.put(userBean.getUserId(), userBean);
                    }
                    TUIChatUtils.callbackOnSuccess(callback, userBeanHashMap);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                }
            });
        } else {
            provider.getUserBean(new ArrayList<>(userIds), new IUIKitCallback<List<UserBean>>() {
                @Override
                public void onSuccess(List<UserBean> data) {
                    for (UserBean userBean : data) {
                        userBeanHashMap.put(userBean.getUserId(), userBean);
                    }
                    TUIChatUtils.callbackOnSuccess(callback, userBeanHashMap);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                }
            });
        }
    }

    public void loadUserStatus(List<String> userIDs, IUIKitCallback<Map<String, UserStatusBean>> callback) {
        provider.loadUserStatus(userIDs, callback);
    }

    public List<TUIMessageBean> getLoadedMessageList() {
        return loadedMessageInfoList;
    }

    public TUIMessageBean getLoadedMessage(String msgID) {
        for (TUIMessageBean message : loadedMessageInfoList) {
            if (message.getId().equals(msgID)) {
                return message;
            }
        }
        return null;
    }

    static class MessageReadReportHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    }

    public interface TypingListener {
        void onTyping(int status);
    }

    public interface ChatNotifyHandler {
        default void onGroupForceExit() {}

        default void onGroupNameChanged(String newName) {}

        default void onFriendNameChanged(String newName) {}

        default void onApplied(int size) {}

        default void onFriendFaceUrlChanged(String faceUrl) {}

        default void onGroupFaceUrlChanged(String faceUrl) {}

        void onExitChat(String chatId);
    }
}
