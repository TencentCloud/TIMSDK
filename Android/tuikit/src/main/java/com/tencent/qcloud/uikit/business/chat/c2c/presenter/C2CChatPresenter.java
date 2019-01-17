package com.tencent.qcloud.uikit.business.chat.c2c.presenter;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatInfo;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatManager;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatProvider;
import com.tencent.qcloud.uikit.business.chat.c2c.view.C2CChatPanel;
import com.tencent.qcloud.uikit.common.BackgroundTasks;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

/**
 * Created by valxehuang on 2018/7/18.
 */

public class C2CChatPresenter {
    C2CChatPanel mChatPanel;
    C2CChatManager mChatManager;

    public C2CChatPresenter(C2CChatPanel chatPanel) {
        this.mChatPanel = chatPanel;
        mChatManager = C2CChatManager.getInstance();
    }


    public C2CChatInfo getC2CChatInfo(String peer) {
        C2CChatInfo chatInfo = mChatManager.getC2CChatInfo(peer);
        mChatManager.setCurrentChatInfo(chatInfo);
        return chatInfo;
    }

    public void loadChatMessages(final MessageInfo lastMessage) {
        mChatManager.loadChatMessages(lastMessage, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                if (lastMessage == null && data != null)
                    mChatPanel.setDataProvider((C2CChatProvider) data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    public void sendC2CMessage(MessageInfo message, boolean reSend) {
        mChatManager.sendC2CMessage(message, reSend, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mChatPanel.scrollToEnd();
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    public void deleteC2CMessage(int position, MessageInfo message) {
        mChatManager.deleteMessage(position, message);
    }

    public void revokeC2CMessage(int position, MessageInfo message) {
        mChatManager.revokeMessage(position, message);
    }

    public void exitC2CChat() {

    }
}
