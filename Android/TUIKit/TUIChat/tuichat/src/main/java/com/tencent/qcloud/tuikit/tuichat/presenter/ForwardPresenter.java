package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
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

    List<TUIMessageBean> loadedData = new ArrayList<>();

    public ForwardPresenter() {
        TUIChatLog.i(TAG, "ChatPresenter Init");
        provider = new ChatProvider();
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
                        preProcessMessage(mergeMessageData, new IUIKitCallback<List<TUIMessageBean>>() {
                            @Override
                            public void onSuccess(List<TUIMessageBean> data) {
                                onMergeMessageDownloaded(data);
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                onMergeMessageDownloaded(mergeMessageData);
                            }
                        });

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
        // 如果已经在列表中，直接跳转到对应位置
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
}
