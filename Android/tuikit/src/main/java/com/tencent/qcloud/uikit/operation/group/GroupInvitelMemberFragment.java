package com.tencent.qcloud.uikit.operation.group;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupMemberInvitePanel;
import com.tencent.qcloud.uikit.common.BaseFragment;

/**
 * Created by valexhuang on 2018/8/1.
 */

public class GroupInvitelMemberFragment extends BaseFragment {
    private GroupMemberInvitePanel mInvitePanel;
    private View mBaseView;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.group_fragment_invite_members, container, false);
        mInvitePanel = mBaseView.findViewById(R.id.group_member_invite_panel);
        mInvitePanel.setParent(this);
        init();
        return mBaseView;
    }

    private void init() {
        mInvitePanel.getTitleBar().setLeftClick(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                backward();
            }
        });

    }
}
