package com.tencent.qcloud.uikit.operation.group;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupInfoPanel;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupMemberControler;
import com.tencent.qcloud.uikit.common.BaseFragment;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class GroupInfoFragment extends BaseFragment {
    private View mBaseView;
    private GroupInfoPanel infoPanel;
    private PageTitleBar chatTitleBar;
    private String groupId;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.info_fragment_group, container, false);
        groupId = getArguments().getString(UIKitConstants.GROUP_ID);
        initView();
        return mBaseView;
    }

    private void initView() {
        infoPanel = mBaseView.findViewById(R.id.group_info_panel);
        infoPanel.setGroupInfo(GroupChatManager.getInstance().getCurrentChatInfo());
        chatTitleBar = infoPanel.getTitleBar();
        chatTitleBar.setLeftClick(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getActivity().finish();
            }
        });
        infoPanel.setMemberControler(new GroupMemberControler() {
            @Override
            public void detailMemberControl() {
                GroupMemberFragment memberFragment = new GroupMemberFragment();
                memberFragment.setArguments(getArguments());
                forward(memberFragment, false);
            }

            @Override
            public void addMemberControl() {
                forward(new GroupInvitelMemberFragment(), false);
            }

            @Override
            public void delMemberControl() {
                forward(new GroupDelMemberFragment(), false);
            }
        });

    }
}
