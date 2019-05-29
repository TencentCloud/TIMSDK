package com.tencent.qcloud.uikit.operation.group;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupMemberDelPanel;
import com.tencent.qcloud.uikit.common.BaseFragment;


public class GroupDelMemberFragment extends BaseFragment {
    private GroupMemberDelPanel mMemberDelPanel;
    private View mBaseView;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.group_fragment_del_members, container, false);
        mMemberDelPanel = mBaseView.findViewById(R.id.group_member_del_panel);
        init();
        return mBaseView;
    }

    private void init() {
        mMemberDelPanel.getTitleBar().setLeftClick(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                backward();
            }
        });

    }
}
