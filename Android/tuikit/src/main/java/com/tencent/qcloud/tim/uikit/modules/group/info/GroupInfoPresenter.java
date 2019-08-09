package com.tencent.qcloud.tim.uikit.modules.group.info;

import android.app.Activity;

import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;


public class GroupInfoPresenter {

    private GroupInfoLayout mInfoLayout;
    private GroupInfoProvider mProvider;

    public GroupInfoPresenter(GroupInfoLayout layout) {
        this.mInfoLayout = layout;
        mProvider = new GroupInfoProvider();
    }

    public void loadGroupInfo(String groupId, final IUIKitCallBack callBack) {
        mProvider.loadGroupInfo(groupId, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                callBack.onSuccess(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.e("loadGroupInfo", errCode + ":" + errMsg);
                callBack.onError(module, errCode, errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void modifyGroupName(final String name) {
        mProvider.modifyGroupInfo(name, TUIKitConstants.Group.MODIFY_GROUP_NAME, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mInfoLayout.onGroupInfoModified(name, TUIKitConstants.Group.MODIFY_GROUP_NAME);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.e("modifyGroupName", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void modifyGroupNotice(final String notice) {
        mProvider.modifyGroupInfo(notice, TUIKitConstants.Group.MODIFY_GROUP_NOTICE, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mInfoLayout.onGroupInfoModified(notice, TUIKitConstants.Group.MODIFY_GROUP_NOTICE);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.e("modifyGroupNotice", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }


    public String getNickName() {
        String nickName = "";
        if (mProvider.getSelfGroupInfo() != null) {
            if (mProvider.getSelfGroupInfo().getDetail() != null) {
                nickName = mProvider.getSelfGroupInfo().getDetail().getNameCard();
            }
        }
        return nickName == null ? "" : nickName;
    }

    public void modifyMyGroupNickname(final String nickname) {
        mProvider.modifyMyGroupNickname(nickname, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mInfoLayout.onGroupInfoModified(nickname, TUIKitConstants.Group.MODIFY_MEMBER_NAME);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.e("modifyMyGroupNickname", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void deleteGroup() {
        mProvider.deleteGroup(new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                ((Activity) mInfoLayout.getContext()).finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.e("deleteGroup", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void setTopConversation(boolean flag) {
        mProvider.setTopConversation(flag);
    }

    public void quitGroup() {
        mProvider.quitGroup(new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                ((Activity) mInfoLayout.getContext()).finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ((Activity) mInfoLayout.getContext()).finish();
                TUIKitLog.e("quitGroup", errCode + ":" + errMsg);
            }
        });
    }

    public void modifyGroupInfo(int value, int type) {
        mProvider.modifyGroupInfo(value, type, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mInfoLayout.onGroupInfoModified(data, TUIKitConstants.Group.MODIFY_GROUP_JOIN_TYPE);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage("modifyGroupInfo fail :" + errCode + "=" + errMsg);
            }
        });
    }
}
