package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ThreadHelper;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflineMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflineMessageContainerBean;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflinePushInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.GroupMessageReadMembersInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IBaseMessageSender;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.IMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.OfflinePushInfoUtils;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CountDownLatch;

public abstract class ChatPresenter {
    private static final String TAG = ChatPresenter.class.getSimpleName();
    // 逐条转发 Group 消息发送消息的时间间隔
    private static final int FORWARD_GROUP_INTERVAL = 90; // 单位： 毫秒
    // 逐条转发 C2C 消息发送消息的时间间隔
    private static final int FORWARD_C2C_INTERVAL = 50; // 单位： 毫秒
    // 消息已读上报时间间隔
    private static final int READ_REPORT_INTERVAL = 1000; // 单位： 毫秒

    protected static final int MSG_PAGE_COUNT = 20;

    protected final ChatProvider provider;
    protected List<TUIMessageBean> loadedMessageInfoList = new ArrayList<>();

    protected IMessageAdapter messageListAdapter;

    private MessageRecyclerView messageRecyclerView;
    private int currentChatUnreadCount = 0;
    private TUIMessageBean mCacheNewMessage = null;

    protected ChatNotifyHandler chatNotifyHandler;

    private long lastReadReportTime = 0L;
    private boolean canReadReport = true;
    private final MessageReadReportHandler readReportHandler = new MessageReadReportHandler();

    // 当前聊天界面是否显示，用来判断接收到消息是否设置已读
    private boolean isChatFragmentShow = false;

    // 用来定位消息搜索时消息的位置
    private TUIMessageBean locateMessage;

//    // 对其他模块暴露的消息发送接口
    private IBaseMessageSender baseMessageSender;

    // 标识是否有 更新的 消息没有更新下来
    protected boolean isHaveMoreNewMessage = false;

    protected boolean isLoading = false;

    public ChatPresenter() {
        TUIChatLog.i(TAG, "ChatPresenter Init");

        provider = new ChatProvider();
    }

    protected void initMessageSender() {
        baseMessageSender = new IBaseMessageSender() {

            @Override
            public void sendMessage(TUIMessageBean message, String receiver, boolean isGroup) {
                ChatPresenter.this.sendMessage(message, receiver, isGroup);
            }
        };
        TUIChatService.getInstance().setMessageSender(baseMessageSender);
    }

    public void loadMessage(int type, TUIMessageBean locateMessage) {
        loadMessage(type, locateMessage, null);
    }

    public void loadMessage(int type, TUIMessageBean locateMessage, IUIKitCallback<List<TUIMessageBean>> callback) {};

    public void clearMessage() {
        loadedMessageInfoList.clear();
        messageListAdapter.onViewNeedRefresh(MessageRecyclerView.DATA_CHANGE_TYPE_REFRESH, 0);
    }

    public void clearMessageAndReLoad() {
        if (!isHaveMoreNewMessage) {
            messageListAdapter.onScrollToEnd();
            return;
        }
        loadedMessageInfoList.clear();
        messageListAdapter.onViewNeedRefresh(MessageRecyclerView.DATA_CHANGE_TYPE_REFRESH, 0);
        loadMessage(TUIChatConstants.GET_MESSAGE_FORWARD, null);
    }

    public void locateMessageBySeq(String chatId, long seq, IUIKitCallback<Void> callback) {
        if (seq < 0) {
            TUIChatUtils.callbackOnError(callback, -1, "invalid param");
            return;
        }

        provider.getGroupMessageBySeq(chatId, seq, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                if (data == null || data.size() == 0) {
                    TUIChatUtils.callbackOnError(callback, -1, "null message");
                    return;
                }
                TUIMessageBean messageBean = data.get(0);
                if (messageBean.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                    TUIChatUtils.callbackOnError(callback, -1, "origin msg is revoked");
                    return;
                }

                locateMessage(messageBean.getId(), new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {

                    }

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
        // 如果已经在列表中，直接跳转到对应位置，否则清空重新加载
        for (TUIMessageBean loadedMessage : loadedMessageInfoList) {
            if (TextUtils.equals(originMsgId, loadedMessage.getId())) {
                if (loadedMessage.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                    TUIChatUtils.callbackOnError(callback, -1, "origin msg is revoked");
                    return;
                }
                updateAdapter(MessageRecyclerView.SCROLL_TO_POSITION, loadedMessage);
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
                loadMessage(TUIChatConstants.GET_MESSAGE_LOCATE, data, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> data) {

                    }

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
    };

    protected void groupReadReport(String groupId) {
        provider.groupReadReport(groupId);
    };

    public void setMessageListAdapter(IMessageAdapter messageListAdapter) {
        this.messageListAdapter = messageListAdapter;
    }

    public void setMessageRecycleView(MessageRecyclerView recycleView) {
        this.messageRecyclerView = recycleView;
        this.currentChatUnreadCount = 0;
        this.mCacheNewMessage = null;
    }

    private void loadToWayMessageAsync(String chatId, boolean isGroup, int getType, int loadCount,
                                       TUIMessageBean locateMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        List<TUIMessageBean> firstLoadedData = new ArrayList<>();
        List<TUIMessageBean> secondLoadedData = new ArrayList<>();
        firstLoadedData.add(locateMessageInfo);
        ChatPresenter.this.locateMessage = locateMessageInfo;
        CountDownLatch latch = new CountDownLatch(2);
        final boolean[] isFailed = {false};
        Runnable forwardRunnable = new Runnable() {
            @Override
            public void run() {
                provider.loadHistoryMessageList(chatId, isGroup, loadCount / 2, locateMessageInfo, TUIChatConstants.GET_MESSAGE_BACKWARD, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> firstData) {
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
                // 拉取历史消息的时候不会把 lastMsg 返回，需要手动添加上
                provider.loadHistoryMessageList(chatId, isGroup, loadCount / 2, locateMessageInfo, TUIChatConstants.GET_MESSAGE_FORWARD, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> secondData) {
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
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onMessageLoadCompleted(secondLoadedData, getType);
                    }
                });
                TUIChatUtils.callbackOnSuccess(callback, secondLoadedData);
            }
        };

        ThreadHelper.INST.execute(forwardRunnable);
        ThreadHelper.INST.execute(backwardRunnable);
        ThreadHelper.INST.execute(mergeRunnable);

    }

    public void loadHistoryMessageList(String chatId, boolean isGroup, int getType, int loadCount,
                                          TUIMessageBean locateMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        // 如果是前后同时拉取消息，需要拉取两次，第一次向后拉取，第二次向前拉取
        // 例如现在有消息 1,2,3,4,5,6,7  locateMessageInfo 是 4
        // 如果 getType 为 GET_MESSAGE_FORWARD， 就会拉取到消息 1,2,3
        // 如果 getType 为 GET_MESSAGE_BACKWARD， 就会拉取到消息 5,6,7
        // 如果 getType 为 GET_MESSAGE_TWO_WAY， 就会拉取到消息 1,2,3,5,6,7 ， 4 要手动加上

        if (getType == TUIChatConstants.GET_MESSAGE_TWO_WAY || getType == TUIChatConstants.GET_MESSAGE_LOCATE) {
            loadToWayMessageAsync(chatId, isGroup, getType, loadCount, locateMessageInfo, callback);
            return;
        }

        provider.loadHistoryMessageList(chatId, isGroup, loadCount, locateMessageInfo, getType, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> firstData) {
                if (getType == TUIChatConstants.GET_MESSAGE_BACKWARD) {
                    if (firstData.size() >= loadCount) {
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

    protected void onMessageLoadCompleted(List<TUIMessageBean> data, int getType) {};

    protected void processLoadedMessage(List<TUIMessageBean> data, int type) {

        List<TUIMessageBean> list = new ArrayList<>();
        for (int i = 0; i < data.size(); i++) {
            TUIMessageBean info = data.get(i);
            if (checkExist(info)) {
                continue;
            }
            list.add(info);
        }

        preProcessReplyMessage(list, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> processedData) {
                onLoadedMessageProcessed(processedData, type);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                onLoadedMessageProcessed(data, type);
            }
        });
    }

    public void getGroupMessageReadReceipt(List<TUIMessageBean> messageBeanList, IUIKitCallback<List<GroupMessageReceiptInfo>> callback) {}

    private void onLoadedMessageProcessed(List<TUIMessageBean> data, int type) {

        boolean isForward = type == TUIChatConstants.GET_MESSAGE_FORWARD;
        boolean isTwoWay = type == TUIChatConstants.GET_MESSAGE_TWO_WAY;
        boolean isLocate = type == TUIChatConstants.GET_MESSAGE_LOCATE;
        if (isForward || isTwoWay || isLocate) {
            Collections.reverse(data);
        }
        if (isForward || isTwoWay || isLocate) {
            loadedMessageInfoList.addAll(0, data);
            if (isForward) {
                // 如果是初次加载，要强制跳转到底部
                if (loadedMessageInfoList.size() == data.size()) {
                    updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_LOAD, data.size());
                } else {
                    updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_ADD_FRONT, data.size());
                }
            } else if (isTwoWay) {
                updateAdapter(MessageRecyclerView.DATA_CHANGE_LOCATE_TO_POSITION, locateMessage);
            } else {
                updateAdapter(MessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION, locateMessage);
            }
        } else {
            loadedMessageInfoList.addAll(data);
            updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_ADD_BACK, data.size());
        }

        isLoading = false;
    }

    private void preProcessReplyMessage(TUIMessageBean messageBean, IUIKitCallback<TUIMessageBean> callback) {
        List<TUIMessageBean> messageBeans = new ArrayList<>();
        messageBeans.add(messageBean);
        preProcessReplyMessage(messageBeans, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                if (data != null && data.size() == 1) {
                    TUIChatUtils.callbackOnSuccess(callback, data.get(0));
                } else {
                    TUIChatUtils.callbackOnError(callback, -1 , "preProcessReplyMessage failed");
                }

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode , "preProcessReplyMessage failed");
            }
        });
    }

    /**
     * 预查找回复消息，成功说明成功查找到原始消息，否则未查找到原始消息
     */
    protected void preProcessReplyMessage(List<TUIMessageBean> data, IUIKitCallback<List<TUIMessageBean>> callback) {
        List<String> msgIdList = new ArrayList<>();
        for (TUIMessageBean messageBean : data) {
            if (messageBean instanceof ReplyMessageBean) {
                msgIdList.add(((ReplyMessageBean) messageBean).getOriginMsgId());
            }
        }
        CountDownLatch latch = new CountDownLatch(1);
        Runnable findMessageRunnable = new Runnable() {
            @Override
            public void run() {
                findMessage(msgIdList, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> originData) {
                        for (int i = 0; i < originData.size(); i++) {
                            TUIMessageBean originMessageBean = originData.get(i);
                            if (originMessageBean == null) {
                                continue;
                            }
                            for (TUIMessageBean messageBean : data) {
                                if (messageBean instanceof ReplyMessageBean) {
                                    if (TextUtils.equals(((ReplyMessageBean) messageBean).getOriginMsgId(), originMessageBean.getId())) {
                                        ((ReplyMessageBean) messageBean).setOriginMessageBean(originMessageBean);
                                    }
                                }
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
        ThreadHelper.INST.execute(findMessageRunnable);

        Runnable mergeRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    latch.await();
                } catch (InterruptedException e) {
                    TUIChatUtils.callbackOnError(callback, -1, "mergeRunnable error");

                    e.printStackTrace();
                }
                Runnable runnable = new Runnable() {
                    @Override
                    public void run() {
                        TUIChatUtils.callbackOnSuccess(callback, data);
                    }
                };
                BackgroundTasks.getInstance().runOnUiThread(runnable);
            }
        };
        ThreadHelper.INST.execute(mergeRunnable);

    }

    protected void addMessageInfo(TUIMessageBean messageInfo) {
        if (messageInfo == null) {
            return;
        }
        if (checkExist(messageInfo)) {
            return;
        }
        loadedMessageInfoList.add(messageInfo);
        updateAdapter(MessageRecyclerView.DATA_CHANGE_NEW_MESSAGE, 1);
    }

    protected void onRecvNewMessage(TUIMessageBean msg) {
        TUIChatLog.i(TAG, "onRecvNewMessage msgID:" + msg.getId());
        if (!isHaveMoreNewMessage) {
            addMessage(msg);
        }
    }

    protected void addMessage(TUIMessageBean messageInfo) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "addMessage unSafetyCall");
            return;
        }

        preProcessReplyMessage(messageInfo, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                addMessageAfterPreProcess(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                addMessageAfterPreProcess(messageInfo);
            }
        });
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
                        currentChatUnreadCount ++;
                        if (mCacheNewMessage == null) {
                            mCacheNewMessage = messageInfo;
                        }
                        messageRecyclerView.displayBackToNewMessage(true, mCacheNewMessage.getId(), currentChatUnreadCount);
                    } else if (messageInfo.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE){
                        currentChatUnreadCount --;
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
                    if (isGroupMessage) {
                        limitReadReport(groupID, true);
                    } else {
                        limitReadReport(userID, false);
                    }
                }
            }
        }
    }

    public void sendGroupMessageReadReceipt(List<TUIMessageBean> messageBeanList, IUIKitCallback<Void> callback) {}

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

    private void notifyTyping() {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "notifyTyping unSafetyCall");
            return;
        }
    }

    public void sendMessage(final TUIMessageBean messageInfo, String receiver, boolean isGroup) {
        if (!TextUtils.isEmpty(receiver)) {
            if (!TextUtils.equals(getChatInfo().getId(), receiver) || isGroup != TUIChatUtils.isGroupChat(getChatInfo().getType())) {
                return;
            }
        }
        sendMessage(messageInfo, false, null);
    }

    public void sendMessage(final TUIMessageBean message, boolean retry, final IUIKitCallback callBack) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "sendMessage unSafetyCall");
            return;
        }
        if (message == null || message.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            return;
        }
        assembleGroupMessage(message);

        String msgId = provider.sendMessage(message, getChatInfo(), new IUIKitCallback<TUIMessageBean>() {

            @Override
            public void onSuccess(TUIMessageBean data) {
                TUIChatLog.v(TAG, "sendMessage onSuccess:" + data.getId());
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }
                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
                if (message instanceof FileMessageBean) {
                    message.setDownloadStatus(FileMessageBean.MSG_STATUS_DOWNLOADED);
                }
                TUIChatUtils.callbackOnSuccess(callBack, data);
                updateMessageInfo(message);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.v(TAG, "sendMessage fail:" + errCode + "=" + errMsg);
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }

                TUIChatUtils.callbackOnError(callBack, TAG, errCode, errMsg);

                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_FAIL);
                updateMessageInfo(message);
            }

            @Override
            public void onProgress(Object data) {
                TUIChatUtils.callbackOnProgress(callBack, data);
            }
        });
        //消息先展示，通过状态来确认发送是否成功
        TUIChatLog.i(TAG, "sendMessage msgID:" + msgId);
        message.setId(msgId);
        message.setStatus(TUIMessageBean.MSG_STATUS_SENDING);
        if (retry) {
            resendMessageInfo(message);
        } else {
            addMessageInfo(message);
        }
    }

    private void updateMessageInfo(TUIMessageBean messageInfo) {
        for (int i = 0; i < loadedMessageInfoList.size(); i++) {
            if (loadedMessageInfoList.get(i).getId().equals(messageInfo.getId())) {
                loadedMessageInfoList.set(i, messageInfo);
                updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, i);
                return;
            }
        }
    }

    private void resendMessageInfo(TUIMessageBean messageInfo) {
        boolean found = false;
        for (int i = 0; i < loadedMessageInfoList.size(); i++) {
            if (loadedMessageInfoList.get(i).getId().equals(messageInfo.getId())) {
                loadedMessageInfoList.remove(i);
                updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_DELETE, i);
                found = true;
                break;
            }
        }
        if (!found) {
            return;
        }
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
                int index = loadedMessageInfoList.indexOf(messageInfo);
                loadedMessageInfoList.remove(messageInfo);
                updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_DELETE, index);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });

    }


    public void handleRevoke(String msgId) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "handleInvoke unSafetyCall");
            return;
        }
        TUIChatLog.i(TAG, "handleInvoke msgID = " + msgId);
        for (int i = 0; i < loadedMessageInfoList.size(); i++) {
            TUIMessageBean messageInfo = loadedMessageInfoList.get(i);
            // 一条包含多条元素的消息，撤回时，会把所有元素都撤回，所以下面的判断即使满足条件也不能return
            if (messageInfo.getId().equals(msgId)) {
                messageInfo.setStatus(TUIMessageBean.MSG_STATUS_REVOKE);
                updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, i);

                if (isChatFragmentShow()) {
                    if (messageRecyclerView != null && messageRecyclerView.isDisplayJumpMessageLayout()) {
                        if (messageInfo.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE){
                            currentChatUnreadCount --;
                            if (currentChatUnreadCount <= 0) {
                                messageRecyclerView.displayBackToNewMessage(false, "", 0);
                                mCacheNewMessage = null;
                            } else {
                                boolean isNeedRefreshCacheNewMessage = false;
                                ChatInfo chatInfo = getChatInfo();
                                if (chatInfo != null) {
                                    if (chatInfo.getType() == V2TIMConversation.V2TIM_GROUP) {
                                        isNeedRefreshCacheNewMessage = messageInfo.getV2TIMMessage().getSeq() <= mCacheNewMessage.getV2TIMMessage().getSeq() ? true : false;
                                    } else {
                                        isNeedRefreshCacheNewMessage = messageInfo.getV2TIMMessage().getTimestamp() <= mCacheNewMessage.getV2TIMMessage().getTimestamp() ? true : false;
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

        boolean isGroup;
        if (chatInfo.getType() == ChatInfo.TYPE_C2C) {
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

    /**
     * 收到消息上报已读加频率限制
     * @param chatId 如果是 C2C 消息， chatId 是 userId, 如果是 Group 消息 chatId 是 groupId
     * @param isGroup 是否为 Group 消息
     */
    private void limitReadReport(final String chatId, boolean isGroup) {
        final long currentTime = System.currentTimeMillis();
        long timeDifference = currentTime - lastReadReportTime;
        if (timeDifference >= READ_REPORT_INTERVAL) {
            readReport(chatId, isGroup);
            lastReadReportTime = currentTime;
        } else {
            if (!canReadReport) {
                TUIChatLog.d(TAG, "limitReadReport : Reporting , please wait.");
                return;
            }
            long delay = READ_REPORT_INTERVAL - timeDifference;
            TUIChatLog.d(TAG, "limitReadReport : Please retry after " + delay + " ms.");
            canReadReport = false;
            readReportHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    readReport(chatId, isGroup);
                    lastReadReportTime = System.currentTimeMillis();
                    canReadReport = true;
                }
            }, delay);
        }
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
                for (int i = loadedMessageInfoList.size() -1; i >= 0 ; i--) {
                    for (int j = messageInfos.size() -1; j >= 0; j--) {
                        if (loadedMessageInfoList.get(i).getId().equals(messageInfos.get(j).getId())) {
                            loadedMessageInfoList.remove(i);
                            updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_DELETE, i);
                            break;
                        }
                    }
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    public void deleteMessages(final List<Integer> positions) {
        if (!safetyCall() || positions == null || positions.isEmpty()) {
            TUIChatLog.w(TAG, "deleteMessages unSafetyCall");
            return;
        }
        List<TUIMessageBean> msgs = new ArrayList<>();
        for(int i = 0; i < positions.size(); i++) {
            msgs.add(loadedMessageInfoList.get(positions.get(i)));
        }

        provider.deleteMessages(msgs, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                for(int i = positions.size() -1 ; i >= 0; i--) {
                    loadedMessageInfoList.remove(positions.get(i));
                    updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_DELETE, i);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    public boolean checkFailedMessages(final List<Integer> positions){
        if (!safetyCall() || positions == null || positions.isEmpty()) {
            TUIChatLog.w(TAG, "checkFailedMessages unSafetyCall");
            return false;
        }

        boolean failed = false;
        for(int i = 0; i < positions.size(); i++) {
            TUIMessageBean messageInfo = loadedMessageInfoList.get(positions.get(i));
            if (provider.checkFailedMessageInfo(messageInfo)) {
                failed = true;
                break;
            }
        }

        return failed;
    }

    public boolean checkFailedMessageInfos(final List<TUIMessageBean> messageInfos){
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

    public List<TUIMessageBean> getSelectPositionMessage(final List<Integer> positions){
        if (!safetyCall() || positions == null || positions.isEmpty()) {
            TUIChatLog.w(TAG, "getSelectPositionMessage unSafetyCall");
            return null;
        }

        List<TUIMessageBean> msgs = new ArrayList<>();
        for(int i = 0; i < positions.size(); i++) {
            if (positions.get(i) < loadedMessageInfoList.size()) {
                msgs.add(loadedMessageInfoList.get(positions.get(i)));
            } else {
                TUIChatLog.d(TAG, "mCurrentProvider not include SelectPosition ");
            }
        }
        return msgs;
    }

    public List<TUIMessageBean> getSelectPositionMessageById(final List<String> msgIds){
        if (!safetyCall() || msgIds == null || msgIds.isEmpty()) {
            TUIChatLog.w(TAG, "getSelectPositionMessageById unSafetyCall");
            return null;
        }

        List<TUIMessageBean> messageInfos = loadedMessageInfoList;
        if (messageInfos == null || messageInfos.size() <= 0) {
            return null;
        }

        final List<TUIMessageBean> msgSelectedMsgInfos = new ArrayList<>();
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

    public void revokeMessage(final TUIMessageBean message) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "revokeMessage unSafetyCall");
            return;
        }
        provider.revokeMessage(message, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "revokeMessage unSafetyCall");
                    return;
                }
                updateMessageRevoked(message.getId());
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                if (errCode == ChatProvider.ERR_REVOKE_TIME_LIMIT_EXCEED) {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.send_two_mins));
                } else {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.revoke_fail) + errCode + "=" + errMsg);
                }
            }
        });
    }

    public boolean updateMessageRevoked(String msgId) {
        for (int i = 0; i < loadedMessageInfoList.size(); i++) {
            TUIMessageBean messageInfo = loadedMessageInfoList.get(i);
            // 一条包含多条元素的消息，撤回时，会把所有元素都撤回，所以下面的判断即使满足条件也不能return
            if (messageInfo.getId().equals(msgId)) {
                messageInfo.setStatus(TUIMessageBean.MSG_STATUS_REVOKE);
                updateAdapter(MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, i);
            }
        }
        return false;
    }

    public List<TUIMessageBean> forwardTextMessageForSelected(List<TUIMessageBean> msgInfos) {
        // 选择文字转发只能是一条消息的操作
        if (msgInfos != null && msgInfos.size() >1) {
            return msgInfos;
        }

        List<TUIMessageBean> forwardMsgInfos = new ArrayList<>();
        TUIMessageBean messageBean = msgInfos.get(0);
        if (messageBean instanceof TextMessageBean) {
            TextMessageBean textMessageBean = (TextMessageBean) messageBean;
            if (textMessageBean.getText().equals(textMessageBean.getSelectText())) {
                return msgInfos;
            } else {
                TUIMessageBean selectedMessageBean = ChatMessageBuilder.buildTextMessage(textMessageBean.getSelectText());
                forwardMsgInfos.add(selectedMessageBean);
                return forwardMsgInfos;
            }
        } else {
            return msgInfos;
        }
    }
    public void forwardMessage(List<TUIMessageBean> msgInfos, boolean isGroup, String id, String offlineTitle, int forwardMode, boolean selfConversation, final IUIKitCallback callBack) {
        if (!safetyCall()) {
            TUIChatLog.w(TAG, "sendMessage unSafetyCall");
            return;
        }

        for (TUIMessageBean messageBean : msgInfos) {
            if (messageBean instanceof  TextMessageBean) {
                TUIChatLog.d(TAG, "chatprensetor forwardMessage onTextSelected selectedText = " + ((TextMessageBean) messageBean).getSelectText());
            }
        }

        // 选中转发暂不做特殊处理，转发原消息
        //List<TUIMessageBean> forwardMsgInfos = forwardTextMessageForSelected(msgInfos);
        if (forwardMode == TUIChatConstants.FORWARD_MODE_ONE_BY_ONE) {
            forwardMessageOneByOne(msgInfos, isGroup, id, offlineTitle, selfConversation, callBack);
        } else if (forwardMode == TUIChatConstants.FORWARD_MODE_MERGE) {
            forwardMessageMerge(msgInfos, isGroup, id, offlineTitle, selfConversation, callBack);
        } else {
            TUIChatLog.d(TAG, "invalid forwardMode");
        }
    }

    public void forwardMessageOneByOne(final List<TUIMessageBean> msgInfos, final boolean isGroup,
                                       final String id, final String offlineTitle, final boolean selfConversation,
                                       final IUIKitCallback callBack) {
        if (msgInfos == null || msgInfos.isEmpty()){
            return;
        }

        Runnable forwardMessageRunnable = new Runnable() {
            @Override
            public void run() {
                int timeInterval = isGroup ? FORWARD_GROUP_INTERVAL : FORWARD_C2C_INTERVAL;
                for(int j = 0; j < msgInfos.size(); j++){
                    TUIMessageBean info = msgInfos.get(j);
                    TUIMessageBean message = ChatMessageBuilder.buildForwardMessage(info.getV2TIMMessage());

                    if (selfConversation) {
                        sendMessage(message, false, callBack);
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
                    assembleGroupMessage(message);

                    OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
                    OfflineMessageBean entity = new OfflineMessageBean();
                    entity.content = message.getExtra().toString();
                    entity.sender = message.getSender();
                    entity.nickname = TUIChatConfigs.getConfigs().getGeneralConfig().getUserNickname();
                    entity.faceUrl = TUIChatConfigs.getConfigs().getGeneralConfig().getUserFaceUrl();
                    containerBean.entity = entity;

                    if (isGroup) {
                        entity.chatType = ChatInfo.TYPE_GROUP;
                        entity.sender = id;
                    }

                    OfflinePushInfo offlinePushInfo = new OfflinePushInfo();
                    offlinePushInfo.setExtension(new Gson().toJson(containerBean).getBytes());
                    offlinePushInfo.setDescription(offlineTitle);
                    // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
                    offlinePushInfo.setAndroidOPPOChannelID("tuikit");
                    if (TUIChatConfigs.getConfigs().getGeneralConfig().isAndroidPrivateRing()) {
                        offlinePushInfo.setAndroidSound(OfflinePushInfoUtils.PRIVATE_RING_NAME);
                    }

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
        ThreadHelper.INST.execute(forwardThread);
    }

    protected void assembleGroupMessage(TUIMessageBean message) {
    }

    public void forwardMessageMerge(List<TUIMessageBean> msgInfos, boolean isGroup, String id, String offlineTitle, boolean selfConversation, final IUIKitCallback callBack) {
        if (msgInfos == null || msgInfos.isEmpty()){
            return;
        }

        Context context = TUIChatService.getAppContext();
        if (context == null) {
            TUIChatLog.d(TAG, "context == null");
            return;
        }
        //abstractList
        List<String> abstractList = new ArrayList<>();
        for(int j = 0; j < msgInfos.size() && j < 3; j++){
            TUIMessageBean messageBean = msgInfos.get(j);
            String userid = ChatMessageParser.getDisplayName(messageBean.getV2TIMMessage());
            if (messageBean instanceof TipsMessageBean) {
                // do nothing
            } else if (messageBean instanceof TextMessageBean) {
                abstractList.add(userid + ":" + messageBean.getExtra());
            } else if (messageBean instanceof FaceMessageBean) {
                abstractList.add(userid + ":" + context.getString(R.string.custom_emoji));
            } else if (messageBean instanceof SoundMessageBean) {
                abstractList.add(userid + ":" + context.getString(R.string.audio_extra));
            } else if (messageBean instanceof ImageMessageBean) {
                abstractList.add(userid + ":" + context.getString(R.string.picture_extra));
            } else if (messageBean instanceof VideoMessageBean) {
                abstractList.add(userid + ":" + context.getString(R.string.video_extra));
            } else if (messageBean instanceof FileMessageBean) {
                abstractList.add(userid + ":" + context.getString(R.string.file_extra));
            } else if (messageBean instanceof MergeMessageBean) {
                // 合并转发消息
                abstractList.add(userid + ":" + context.getString(R.string.forward_extra));
            } else {
                // 其他自定义消息等
                abstractList.add(userid + ":" + messageBean.getExtra());
            }
        }

        //createMergerMessage
        TUIMessageBean msgInfo = ChatMessageBuilder.buildMergeMessage(msgInfos, offlineTitle, abstractList,
                TUIChatService.getAppContext().getString(R.string.forward_compatible_text));

        if (selfConversation) {
            sendMessage(msgInfo, false, callBack);
            return;
        }

        assembleGroupMessage(msgInfo);

        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = msgInfo.getExtra().toString();
        entity.sender = msgInfo.getSender();
        entity.nickname = TUIChatConfigs.getConfigs().getGeneralConfig().getUserNickname();
        entity.faceUrl = TUIChatConfigs.getConfigs().getGeneralConfig().getUserFaceUrl();
        containerBean.entity = entity;

        if (isGroup) {
            entity.chatType = ChatInfo.TYPE_GROUP;
            entity.sender = id;
        }

        OfflinePushInfo offlinePushInfo = new OfflinePushInfo();
        offlinePushInfo.setExtension(new Gson().toJson(containerBean).getBytes());
        offlinePushInfo.setDescription(offlineTitle);
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        offlinePushInfo.setAndroidOPPOChannelID("tuikit");
        if (TUIChatConfigs.getConfigs().getGeneralConfig().isAndroidPrivateRing()) {
            offlinePushInfo.setAndroidSound(OfflinePushInfoUtils.PRIVATE_RING_NAME);
        }

        forwardMessageInternal(msgInfo, isGroup, id, offlinePushInfo, callBack);
    }

    public void forwardMessageInternal(final TUIMessageBean message, boolean isGroup, String id, OfflinePushInfo offlinePushInfo, final IUIKitCallback callBack) {
        if (message == null) {
            TUIChatLog.e(TAG, "forwardMessageInternal null message!");
            return;
        }

        String msgId = provider.sendMessage(message, isGroup, id, offlinePushInfo, new IUIKitCallback<TUIMessageBean>() {

            @Override
            public void onSuccess(TUIMessageBean data) {
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }

                if (callBack != null) {
                    callBack.onSuccess(data);
                }

                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
                updateMessageInfo(message);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.v(TAG, "sendMessage fail:" + errCode + "=" + errMsg);
                if (!safetyCall()) {
                    TUIChatLog.w(TAG, "sendMessage unSafetyCall");
                    return;
                }
                if (callBack != null) {
                    callBack.onError(TAG, errCode, errMsg);
                }
                message.setStatus(TUIMessageBean.MSG_STATUS_SEND_FAIL);
                updateMessageInfo(message);
            }
        });
        //消息先展示，通过状态来确认发送是否成功
        TUIChatLog.i(TAG, "sendMessage msgID:" + msgId);
        message.setId(msgId);
        message.setStatus(TUIMessageBean.MSG_STATUS_SENDING);
    }

    public void loadApplyList(IUIKitCallback<List<GroupApplyInfo>> callBack) {
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
                    if (groupId.equals(applyInfo.getGroupApplication().getGroupID())
                            && !applyInfo.isStatusHandled()) {
                        applyInfos.add(applyInfo);
                    }
                }
                TUIChatUtils.callbackOnSuccess(callBack, applyInfos);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callBack, module, errCode, errMsg);
            }
        });

    }

    public void setDraft(String draft) {
        ChatInfo chatInfo = getChatInfo();
        if (chatInfo == null) {
            return;
        }
        String conversationId = TUIChatUtils.getConversationIdByUserId(chatInfo.getId(), TUIChatUtils.isGroupChat(chatInfo.getType()));
        provider.setDraft(conversationId, draft);
    }

    public void getConversationLastMessage(String conversationId, IUIKitCallback<TUIMessageBean> callback) {
        provider.getConversationLastMessage(conversationId, callback);
    }

    public void findMessage(String msgId, IUIKitCallback<TUIMessageBean> callback) {
        List<String> msgList = new ArrayList<>();
        msgList.add(msgId);
        provider.findMessage(msgList, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                if (data != null && !data.isEmpty()) {
                    TUIChatUtils.callbackOnSuccess(callback, data.get(0));
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

    static class MessageReadReportHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    }

    public interface TypingListener {
        void onTyping();
    }


    public interface ChatNotifyHandler {

        default void onGroupForceExit() {}

        default void onGroupNameChanged(String newName) {}

        default void onFriendNameChanged(String newName) {}

        default void onApplied(int size) {}

        void onExitChat(String chatId);
    }
}
