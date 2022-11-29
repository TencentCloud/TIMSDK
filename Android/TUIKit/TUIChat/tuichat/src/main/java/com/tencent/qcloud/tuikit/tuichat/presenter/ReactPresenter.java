package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;

import java.util.Collections;
import java.util.List;


public class ReactPresenter {
    private ChatProvider provider;
    private ChatPresenter chatPresenter;
    private ChatInfo chatInfo;
    private OnMessageChangedListener onMessageChangedListener;
    private GroupChatEventListener groupChatEventListener;
    private C2CChatEventListener c2CChatEventListener;
    private String messageId;

    public interface OnMessageChangedListener {
        void onMessageChanged(TUIMessageBean messageBean);
    }

    public ReactPresenter() {
        provider = new ChatProvider();
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
        if (chatInfo.getType() == ChatInfo.TYPE_C2C) {
            chatPresenter = new C2CChatPresenter();
            ((C2CChatPresenter) chatPresenter).setChatInfo(chatInfo);
        } else {
            chatPresenter = new GroupChatPresenter();
            ((GroupChatPresenter) chatPresenter).setGroupInfo((GroupInfo) chatInfo);
        }

    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public void setChatEventListener() {
        if (chatPresenter instanceof C2CChatPresenter) {
            c2CChatEventListener = new C2CChatEventListener() {

                @Override
                public void onRecvMessageModified(TUIMessageBean messageBean) {
                    if (TextUtils.equals(messageBean.getId(), messageId)) {
                        ReactPresenter.this.onMessageChanged(messageBean);
                    }
                }
            };
            TUIChatService.getInstance().addC2CChatEventListener(c2CChatEventListener);
        } else {
            groupChatEventListener = new GroupChatEventListener() {

                @Override
                public void onRecvMessageModified(TUIMessageBean messageBean) {
                    if (TextUtils.equals(messageBean.getId(), messageId)) {
                        ReactPresenter.this.onMessageChanged(messageBean);
                    }
                }
            };
            TUIChatService.getInstance().addGroupChatEventListener(groupChatEventListener);
        }
    }

    private void onMessageChanged(TUIMessageBean messageBean) {
        chatPresenter.preProcessMessage(Collections.singletonList(messageBean), new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                if (onMessageChangedListener != null) {
                    onMessageChangedListener.onMessageChanged(data.get(0));
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                if (onMessageChangedListener != null) {
                    onMessageChangedListener.onMessageChanged(messageBean);
                }
            }
        });
    }

    public void setMessageListener(OnMessageChangedListener listener) {
        this.onMessageChangedListener = listener;
    }

}
