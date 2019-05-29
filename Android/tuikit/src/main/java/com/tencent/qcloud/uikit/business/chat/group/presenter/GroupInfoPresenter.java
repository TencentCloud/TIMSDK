package com.tencent.qcloud.uikit.business.chat.group.presenter;

import android.app.Activity;

import com.tencent.imsdk.log.QLog;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupInfoUtils;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupInfoPanel;
import com.tencent.qcloud.uikit.common.utils.UIUtils;


public class GroupInfoPresenter {

    private GroupInfoPanel mInfoPanel;
    private GroupChatManager mChatManager;

    public GroupInfoPresenter(GroupInfoPanel chatPanel) {
        this.mInfoPanel = chatPanel;
        mChatManager = GroupChatManager.getInstance();
    }

    public void modifyGroupName(final String name) {
        mChatManager.modifyGroupInfo(name, GroupInfoUtils.MODIFY_GROUP_NAME, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mInfoPanel.onGroupInfoModified(name, GroupInfoUtils.MODIFY_GROUP_NAME);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                QLog.e("modifyGroupName", errCode + ":" + errMsg);
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    public void modifyGroupNotice(final String notice) {
        mChatManager.modifyGroupInfo(notice, GroupInfoUtils.MODIFY_GROUP_NOTICE, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mInfoPanel.onGroupInfoModified(notice, GroupInfoUtils.MODIFY_GROUP_NOTICE);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                QLog.e("modifyGroupNotice", errCode + ":" + errMsg);
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }


    public String getNickName() {
        String nickName = "";
        if (mChatManager.getSelfGroupInfo() != null) {
            if (mChatManager.getSelfGroupInfo().getDetail() != null) {
                nickName = mChatManager.getSelfGroupInfo().getDetail().getNameCard();
            }
        }
        return nickName == null ? "" : nickName;
    }

    public void modifyGroupNickname(final String nickname) {
        mChatManager.modifyGroupNickname(nickname, GroupInfoUtils.MODIFY_MEMBER_NAME, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mInfoPanel.onMemberInfoModified(nickname, GroupInfoUtils.MODIFY_MEMBER_NAME);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                QLog.e("modifyGroupNickname", errCode + ":" + errMsg);
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    public void deleteGroup() {
        mChatManager.deleteGroup(null, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                ((Activity) mInfoPanel.getContext()).finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                QLog.e("deleteGroup", errCode + ":" + errMsg);
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    public void setTopSession(boolean flag) {
        mChatManager.setTopSession(flag);
    }

    public void quiteGroup() {
        mChatManager.quiteGroup(new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                ((Activity) mInfoPanel.getContext()).finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ((Activity) mInfoPanel.getContext()).finish();
                QLog.e("quiteGroup", errCode + ":" + errMsg);
            }
        });
    }
}
