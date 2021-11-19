package com.tencent.qcloud.tuikit.tuichat.presenter;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.model.ForwardProvider;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.IMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.List;

public class ForwardPresenter {
    public static final String TAG = ForwardPresenter.class.getSimpleName();

    private IMessageAdapter messageListAdapter;

    private final ForwardProvider provider;
    public ForwardPresenter() {
        TUIChatLog.i(TAG, "ChatPresenter Init");
        provider = new ForwardProvider();
    }

    public void setMessageListAdapter(IMessageAdapter messageListAdapter) {
        this.messageListAdapter = messageListAdapter;
    }

    public void downloadMergerMessage(MergeMessageBean messageBean) {
        if (messageBean != null){
            if (messageBean.isLayersOverLimit()){
                TUIChatLog.e(TAG, "merge message Layers Over Limit");
            } else {
                provider.downloadMergerMessage(messageBean, new IUIKitCallback<List<TUIMessageBean>>() {
                    @Override
                    public void onSuccess(List<TUIMessageBean> data) {
                        if (messageListAdapter != null){
                            messageListAdapter.onDataSourceChanged(data);
                            messageListAdapter.onViewNeedRefresh(MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, data.size());
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        TUIChatLog.e(TAG, "downloadMergerMessage error , code = " + errCode + "  message = " + errMsg);
                    }
                });
            }
        }
    }
}
