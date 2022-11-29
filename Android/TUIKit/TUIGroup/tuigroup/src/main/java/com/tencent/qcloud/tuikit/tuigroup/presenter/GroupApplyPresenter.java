package com.tencent.qcloud.tuikit.tuigroup.presenter;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupApplyLayout;
import com.tencent.qcloud.tuikit.tuigroup.model.GroupInfoProvider;

import java.util.List;

public class GroupApplyPresenter {
    private final IGroupApplyLayout layout;
    private final GroupInfoProvider provider;

    private GroupInfo groupInfo;

    public GroupApplyPresenter(IGroupApplyLayout layout) {
        this.layout = layout;
        provider = new GroupInfoProvider();
    }

    public void setGroupInfo(GroupInfo groupInfo) {
        this.groupInfo = groupInfo;
    }

    public void loadGroupApplies() {
        provider.loadGroupApplies(groupInfo, new IUIKitCallback<List<GroupApplyInfo>>() {
            @Override
            public void onSuccess(List<GroupApplyInfo> data) {
                layout.onGroupApplyInfoListChanged(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    public void acceptApply(GroupApplyInfo item) {
        provider.acceptApply(item, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                item.setStatus(GroupApplyInfo.APPLIED);
                layout.onDataSetChanged();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void refuseApply(final GroupApplyInfo item) {
        provider.refuseApply(item, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                item.setStatus(GroupApplyInfo.REFUSED);
                layout.onDataSetChanged();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);

            }
        });
    }

}
