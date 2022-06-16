package com.tencent.qcloud.tuikit.tuichat.presenter;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.GroupMessageReadMembersInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;

import java.util.ArrayList;
import java.util.List;

public class MessageReceiptPresenter {
    public static final int GET_MEMBERS_COUNT = 100;

    private final ChatProvider provider;

    public MessageReceiptPresenter() {
        provider = new ChatProvider();
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
