package com.tencent.qcloud.tuikit.tuichat.presenter;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.tuichat.bean.ReactUserBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.GroupMessageReadMembersInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
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
    public MessageReceiptPresenter() {
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

    public void setMessageReplyBean(TUIMessageBean message, IUIKitCallback<Void> callback) {
        if (message == null || message.getMessageRepliesBean() == null) {
            TUIChatUtils.callbackOnSuccess(callback, null);
            return;
        }
        Set<String> userIds = new HashSet<>(chatPresenter.getReplyUserNames(Collections.singletonList(message)));
        chatPresenter.getReactUserBean(userIds, new IUIKitCallback<Map<String, ReactUserBean>>() {
            @Override
            public void onSuccess(Map<String, ReactUserBean> data) {
                MessageRepliesBean repliesBean = message.getMessageRepliesBean();
                chatPresenter.setMessageReplyBean(repliesBean, data);
                TUIChatUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
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
