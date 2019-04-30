package com.tencent.qcloud.uikit.business.chat.group.presenter;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatInfo;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatProvider;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupChatPanel;
import com.tencent.qcloud.uikit.common.BackgroundTasks;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.common.utils.UIUtils;


public class GroupChatPresenter implements GroupChatManager.GroupNotifyHandler {

    private GroupChatPanel mChatPanel;
    private GroupChatManager mChatManager;

    public GroupChatPresenter(GroupChatPanel chatPanel) {
        mChatPanel = chatPanel;
        mChatManager = GroupChatManager.getInstance();
        mChatManager.setGroupHandler(this);
    }


    public void getGroupChatInfo(String groupId) {
        mChatManager.getGroupChatInfo(groupId, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mChatPanel.onGroupInfoLoaded((GroupChatInfo) data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }


    public void loadChatMessages(final MessageInfo lastMessage) {
        mChatManager.loadChatMessages(lastMessage, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                if (lastMessage == null && data != null)
                    mChatPanel.setDataProvider((GroupChatProvider) data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    public void sendGroupMessage(MessageInfo message) {
        mChatManager.sendGroupMessage(message, new IUIKitCallBack() {
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

    public void deleteMessage(int position, MessageInfo message) {
        mChatManager.deleteMessage(position, message);
    }

    public void revokeMessage(int position, MessageInfo message) {
        mChatManager.revokeMessage(position, message);
    }

    public void loadApplyInfos() {
        //进群先从本地获取
        getLocalApplyInfos();
        //同时拉服务器请求信息，目前先这么处理，后续添加群申请上报后可去除
        mChatManager.loadRemoteApplayInfos(new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                getLocalApplyInfos();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    private void getLocalApplyInfos() {
        int applySize = mChatManager.getGroupApplies(null) == null ? 0 : mChatManager.getGroupApplies(null).size();
        if (applySize > 0)
            mChatPanel.onChatActive(applySize);
    }

    public void exitChat() {
        mChatManager.removeGroupHandler();
    }

    @Override
    public void onGroupForceExit() {
        mChatPanel.forceStopChat();
    }

    @Override
    public void onGroupNameChanged(String newName) {
        mChatPanel.onGroupNameChanged(newName);
    }
}
