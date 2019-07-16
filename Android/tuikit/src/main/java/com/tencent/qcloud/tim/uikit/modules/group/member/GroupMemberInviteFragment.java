package com.tencent.qcloud.tim.uikit.modules.group.member;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseFragment;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;


public class GroupMemberInviteFragment extends BaseFragment {

    private GroupMemberInviteLayout mInviteLayout;
    private View mBaseView;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.group_fragment_invite_members, container, false);
        mInviteLayout = mBaseView.findViewById(R.id.group_member_invite_layout);
        mInviteLayout.setParentLayout(this);
        init();
        return mBaseView;
    }

    private void init() {
        mInviteLayout.setDataSource((GroupInfo) getArguments().getSerializable(TUIKitConstants.Group.GROUP_INFO));
        mInviteLayout.getTitleBar().setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                backward();
            }
        });
    }
}
