package com.tencent.qcloud.tim.uikit.modules.group.info;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseFragment;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberDeleteFragment;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInviteFragment;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberManagerFragment;
import com.tencent.qcloud.tim.uikit.modules.group.member.IGroupMemberRouter;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;


public class GroupInfoFragment extends BaseFragment {

    private View mBaseView;
    private GroupInfoLayout mGroupInfoLayout;
    private GroupMemberManagerFragment groupMemberManagerFragment;
    private IUIKitCallBack mIUIKitCallBack;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.group_info_fragment, container, false);
        initView();
        return mBaseView;
    }

    private void initView() {
        mIUIKitCallBack = new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(module + ", Error code = " + errCode + ", desc = " + errMsg);
            }
        };
        mGroupInfoLayout = mBaseView.findViewById(R.id.group_info_layout);
        mGroupInfoLayout.setGroupId(getArguments().getString(TUIKitConstants.Group.GROUP_ID));
        mGroupInfoLayout.setUICallback(mIUIKitCallBack);
        mGroupInfoLayout.setRouter(new IGroupMemberRouter() {
            @Override
            public void forwardListMember(GroupInfo info) {
                groupMemberManagerFragment = new GroupMemberManagerFragment();
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIKitConstants.Group.GROUP_INFO, info);
                groupMemberManagerFragment.setArguments(bundle);
                forward(groupMemberManagerFragment, false);

                groupMemberManagerFragment.setGroupMembersListener(new GroupMembersListener() {
                    @Override
                    public void loadMoreGroupMember(long nextSeq) {
                        mGroupInfoLayout.getGroupMembers(nextSeq);
                    }
                });
            }

            @Override
            public void forwardAddMember(GroupInfo info) {
                GroupMemberInviteFragment fragment = new GroupMemberInviteFragment();
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIKitConstants.Group.GROUP_INFO, info);
                fragment.setArguments(bundle);
                forward(fragment, false);
            }

            @Override
            public void forwardDeleteMember(GroupInfo info) {
                GroupMemberDeleteFragment fragment = new GroupMemberDeleteFragment();
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIKitConstants.Group.GROUP_INFO, info);
                fragment.setArguments(bundle);
                forward(fragment, false);
            }
        });
    }

    public interface GroupMembersListener {
        void loadMoreGroupMember(long nextSeq);
    }
}
