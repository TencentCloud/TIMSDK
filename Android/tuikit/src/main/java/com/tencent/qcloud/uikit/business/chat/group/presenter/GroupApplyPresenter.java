package com.tencent.qcloud.uikit.business.chat.group.presenter;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupApplyInfo;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupApplyCallback;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

import java.util.List;

public class GroupApplyPresenter {

    private GroupApplyCallback mApplyHandler;
    private GroupChatManager mManager;

    public GroupApplyPresenter(GroupApplyCallback handler) {
        mApplyHandler = handler;
        mManager = GroupChatManager.getInstance();
    }

    public void acceptApply(final int position, final GroupApplyInfo item) {
        mManager.acceptApply(item, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mApplyHandler.onAccept(position, item);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }


    public void refuseApply(final int position, final GroupApplyInfo item) {
        mManager.refuseApply(item, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mApplyHandler.onRefuse(position, item);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errMsg);
            }
        });
    }

    public List<GroupApplyInfo> getApplyInfos() {
        return mManager.getGroupApplies(null);
    }
}
