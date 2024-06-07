package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.List;

public class ForwardPresenter extends ChatPresenter {
    public static final String TAG = ForwardPresenter.class.getSimpleName();

    private IMessageAdapter messageListAdapter;
    private ChatInfo chatInfo;
    private final ChatProvider provider;

    private List<TUIMessageBean> loadedData = new ArrayList<>();
    private C2CChatEventListener chatEventListener;

    public ForwardPresenter() {
        TUIChatLog.i(TAG, "ChatPresenter Init");
        provider = new ChatProvider();
    }

    public void initListener() {
        chatEventListener = new C2CChatEventListener() {
            @Override
            public void onMessageChanged(TUIMessageBean messageBean, int dataChangeType) {
                ForwardPresenter.this.updateMessageInfo(messageBean, dataChangeType);
            }
        };
        TUIChatService.getInstance().addC2CChatEventListener(chatEventListener);
    }

    public void setMessageListAdapter(IMessageAdapter messageListAdapter) {
        this.messageListAdapter = messageListAdapter;
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
    }

    @Override
    public ChatInfo getChatInfo() {
        return chatInfo;
    }

    public void downloadMergerMessage(MergeMessageBean messageBean) {
        if (messageBean != null) {
            if (messageBean.isLayersOverLimit()) {
                TUIChatLog.e(TAG, "merge message Layers Over Limit");
            } else {
                provider.downloadMergerMessage(messageBean, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> mergeMessageData) {
                        onMergeMessageDownloaded(mergeMessageData);

                        processMessageAsync(mergeMessageData);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        TUIChatLog.e(TAG, "downloadMergerMessage error , code = " + errCode + "  message = " + errMsg);
                    }
                });
            }
        }
    }

    private void onMergeMessageDownloaded(List<TUIMessageBean> mergeMessageData) {
        loadedData.clear();
        loadedData.addAll(mergeMessageData);
        if (messageListAdapter != null) {
            messageListAdapter.onDataSourceChanged(loadedData);
            messageListAdapter.onViewNeedRefresh(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, loadedData.size());
        }
    }

    @Override
    public void locateMessage(String originMsgID, IUIKitCallback<Void> callback) {
        
        // If already in the list, jump directly to the corresponding position
        boolean isFind = false;
        for (TUIMessageBean loadedMessage : loadedData) {
            if (TextUtils.equals(originMsgID, loadedMessage.getId())) {
                isFind = true;
                updateAdapter(IMessageRecyclerView.SCROLL_TO_POSITION, loadedMessage);
                break;
            }
        }
        if (isFind) {
            TUIChatUtils.callbackOnSuccess(callback, null);
        } else {
            TUIChatUtils.callbackOnError(callback, -1, "not find");
        }
    }

    @Override
    protected void updateAdapter(int type, TUIMessageBean locateMessage) {
        if (messageListAdapter != null) {
            messageListAdapter.onViewNeedRefresh(type, locateMessage);
        }
    }

    @Override
    public void updateMessageInfo(TUIMessageBean messageInfo, int dataChangeType) {
        for (int i = 0; i < loadedData.size(); i++) {
            if (loadedData.get(i) == null) {
                continue;
            }
            if (TextUtils.equals(loadedData.get(i).getId(), messageInfo.getId())) {
                loadedData.set(i, messageInfo);
                updateAdapter(dataChangeType, messageInfo);
                return;
            }
        }
    }

    @Override
    public List<TUIMessageBean> getLoadedMessageList() {
        return loadedData;
    }

    @Override
    public TUIMessageBean getLoadedMessage(String msgID) {
        for (TUIMessageBean message : loadedData) {
            if (message.getId().equals(msgID)) {
                return message;
            }
        }
        return null;
    }
}
