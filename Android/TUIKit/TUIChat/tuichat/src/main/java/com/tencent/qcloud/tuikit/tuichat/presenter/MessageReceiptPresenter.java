package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMessageReadMembersInfo;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageDetailListener;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MessageReceiptPresenter {
    public static final int GET_MEMBERS_COUNT = 100;

    private final ChatProvider provider;
    private ChatPresenter chatPresenter;
    private ChatInfo chatInfo;
    private C2CChatEventListener chatEventListener;
    private TUIMessageBean messageBean;
    private IMessageDetailListener messageDetailListener;

    public MessageReceiptPresenter() {
        provider = new ChatProvider();
    }

    public void initChatEventListener() {
        chatEventListener = new C2CChatEventListener() {
            @Override
            public void onMessageChanged(TUIMessageBean changedMessage, int dataChangeType) {
                if (changedMessage != null && messageBean != null && TextUtils.equals(changedMessage.getId(), messageBean.getId())) {
                    updateMessage(changedMessage);
                }
            }
        };
        TUIChatService.getInstance().addC2CChatEventListener(chatEventListener);
    }

    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
        TUIChatUtils.notifyProcessMessage(Collections.singletonList(messageBean));
    }

    public void setMessageDetailListener(IMessageDetailListener messageDetailListener) {
        this.messageDetailListener = messageDetailListener;
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
        if (chatInfo.getType() == C2CChatInfo.TYPE_C2C) {
            chatPresenter = new C2CChatPresenter();
            ((C2CChatPresenter) chatPresenter).setChatInfo((C2CChatInfo) chatInfo);
        } else {
            chatPresenter = new GroupChatPresenter();
            ((GroupChatPresenter) chatPresenter).setGroupInfo((GroupChatInfo) chatInfo);
        }
    }

    public void setMessageReplyBean(TUIMessageBean message, IUIKitCallback<Void> callback) {
        if (message == null || message.getMessageRepliesBean() == null) {
            TUIChatUtils.callbackOnSuccess(callback, null);
            return;
        }
        Set<String> userIds = new HashSet<>(message.getAdditionalUserIDList());
        chatPresenter.getUserBean(userIds, new IUIKitCallback<Map<String, UserBean>>() {
            @Override
            public void onSuccess(Map<String, UserBean> data) {
                for (UserBean userBean : data.values()) {
                    message.setUserBean(userBean.getUserId(), userBean);
                }
                TUIChatUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    private void updateMessage(TUIMessageBean messageBean) {
        if (messageDetailListener != null) {
            messageDetailListener.updateMessage(messageBean);
        }
    }

    public void getGroupMessageReadMembers(TUIMessageBean messageBean, boolean isRead, long nextSeq, IUIKitCallback<GroupMessageReadMembersInfo> callback) {
        provider.getGroupMessageReadMembers(messageBean, isRead, GET_MEMBERS_COUNT, nextSeq, callback);
    }

    public void getGroupMessageReadReceipt(TUIMessageBean messageBean, IUIKitCallback<List<MessageReceiptInfo>> callback) {
        List<TUIMessageBean> messageBeanList = new ArrayList<>();
        messageBeanList.add(messageBean);
        provider.getMessageReadReceipt(messageBeanList, callback);
    }
}
