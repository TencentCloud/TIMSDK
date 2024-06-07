package com.tencent.qcloud.tuikit.tuiemojiplugin.presenter;

import android.util.Log;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.TUIEmojiPluginService;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.OnMessageReactionsChangedListener;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.ReactPreviewView;
import com.tencent.qcloud.tuikit.tuiemojiplugin.model.TUIEmojiProvider;

import java.util.HashMap;
import java.util.List;

public class MessageReactionPreviewPresenter {
    private static final String TAG = MessageReactionPreviewPresenter.class.getSimpleName();
    private TUIEmojiProvider provider;
    private ReactPreviewView reactPreviewView;
    private OnMessageReactionsChangedListener reactionsChangedListener;

    public MessageReactionPreviewPresenter() {
        provider = new TUIEmojiProvider();
    }

    public void initListener() {
        reactionsChangedListener = new OnMessageReactionsChangedListener() {
            @Override
            public void onMessageReactionsChanged(MessageReactionBean messageReactionBean) {
                Log.e(TAG, "onMessageReactionsChanged");
            }
        };
        TUIEmojiPluginService.addReactionsChangedListener(reactionsChangedListener);
    }

    public void setReactPreviewView(ReactPreviewView reactPreviewView) {
        this.reactPreviewView = reactPreviewView;
    }

    public void loadData(TUIMessageBean messageBean) {
        reactPreviewView.setMessageBean(messageBean);
        MessageReactionBean messageReactionBean = MessageReactionBeanCache.getMessageReactionBean(messageBean);
        if (messageReactionBean != null) {
            reactPreviewView.setData(messageReactionBean);
        } else {
            if (!MessageReactionBeanCache.contains(messageBean.getId())) {
                MessageReactionBean reactionBean = new MessageReactionBean();
                reactionBean.setMessageID(messageBean.getId());
                reactionBean.setMessageReactionBeanMap(new HashMap<>());
                MessageReactionBeanCache.putMessageReactionBean(messageBean, reactionBean);
            }
        }
    }

}
