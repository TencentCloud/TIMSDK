package com.tencent.qcloud.tuikit.tuicommunity.ui.page;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityMemberBean;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityMemberActivity;
import com.tencent.qcloud.tuikit.tuicommunity.ui.widget.CommunityMemberList;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;
import java.util.ArrayList;
import java.util.List;

public class CommunityMemberActivity extends BaseLightActivity implements ICommunityMemberActivity {
    private static final int REQUEST_CODE_INVITE_MEMBER = 1;

    private CommunityMemberList memberListLayout;
    private CommunityBean communityBean;
    private CommunityPresenter presenter;

    private boolean isSelectMode = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.community_members_list);
        memberListLayout = findViewById(R.id.member_list_layout);
        init();
    }

    private void init() {
        presenter = new CommunityPresenter();
        memberListLayout.setPresenter(presenter);
        memberListLayout.setCommunityMemberListener(this);
        Intent intent = getIntent();
        communityBean = (CommunityBean) intent.getSerializableExtra(CommunityConstants.COMMUNITY_BEAN);
        memberListLayout.setCommunityBean(communityBean);
        presenter.setCommunityMemberListView(memberListLayout);
        memberListLayout.loadMemberList();

        isSelectMode = intent.getBooleanExtra(CommunityConstants.IS_SELECT_MODE, false);

        String title = intent.getStringExtra(CommunityConstants.TITLE);

        //        int filter = intent.getIntExtra(CommunityConstants.FILTER, CommunityBean.GROUP_MEMBER_FILTER_ALL);
        memberListLayout.setSelectMode(isSelectMode);
        memberListLayout.setTitle(title);

        memberListLayout.getTitleBar().setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        int limit = getIntent().getIntExtra(CommunityConstants.LIMIT, Integer.MAX_VALUE);
        memberListLayout.setGroupMemberListener(new CommunityMemberList.MemberListListener() {
            @Override
            public void setSelectedMember(ArrayList<String> members) {
                if (members == null || members.isEmpty()) {
                    return;
                }
                if (members.size() > limit) {
                    String overLimitTip = getString(R.string.community_over_limit_tip, limit);
                    ToastUtil.toastShortMessage(overLimitTip);
                    return;
                }
                Intent result = new Intent();
                result.putStringArrayListExtra(CommunityConstants.LIST, members);
                setResult(RESULT_OK, result);
                finish();
            }
        });
    }

    private void inviteGroupMembers(List<String> friends) {
        if (friends != null && friends.size() > 0) {
            if (presenter != null) {
                presenter.inviteGroupMembers(communityBean.getGroupId(), friends);
            }
        }
    }

    @Override
    public void onAddCommunityMember() {
        Bundle param = new Bundle();
        param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, communityBean.getGroupId());
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FRIENDS, true);
        if (memberListLayout.getCommunityMemberBeans() != null) {
            ArrayList<String> selectedList = new ArrayList<>();
            for (CommunityMemberBean memberBean : memberListLayout.getCommunityMemberBeans()) {
                selectedList.add(memberBean.getAccount());
            }
            param.putStringArrayList(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECTED_LIST, selectedList);
        }
        TUICore.startActivity(this, "StartGroupMemberSelectActivity", param, REQUEST_CODE_INVITE_MEMBER);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (data != null) {
            List<String> friends = (List<String>) data.getSerializableExtra(CommunityConstants.LIST);
            if (requestCode == REQUEST_CODE_INVITE_MEMBER) {
                inviteGroupMembers(friends);
            }
        }
    }
}
