package com.tencent.qcloud.tuikit.tuiconversation.presenter;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.model.ConversationProvider;

import java.util.List;

public class ConversationIconPresenter {
    private final ConversationProvider provider;

    public ConversationIconPresenter() {
        provider = new ConversationProvider();
    }

    public void getGroupMemberIconList(String groupId, IUIKitCallback<List<Object>> callback) {
        provider.getGroupMemberIconList(groupId, 9, callback);
    }

}
