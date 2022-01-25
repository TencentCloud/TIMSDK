package com.tencent.qcloud.tuikit.tuigroup.ui.page;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import android.view.View;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import com.tencent.qcloud.tuikit.tuigroup.ui.view.GroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberListener;

import java.util.ArrayList;
import java.util.List;

/**
 * 群成员管理
 */
public class GroupMemberActivity extends BaseLightActivity {

    private GroupMemberLayout mMemberLayout;
    private GroupInfo mGroupInfo;
    private GroupInfoPresenter presenter;

    private boolean isSelectMode = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_members_list);
        mMemberLayout = findViewById(R.id.group_member_grid_layout);
        init();
    }

    private void init() {
        Intent intent = getIntent();
        mGroupInfo = (GroupInfo) intent.getSerializableExtra(TUIGroupConstants.Group.GROUP_INFO);

        int limit = getIntent().getIntExtra(TUIGroupConstants.Selection.LIMIT, Integer.MAX_VALUE);

        isSelectMode = intent.getBooleanExtra(TUIGroupConstants.Selection.IS_SELECT_MODE, false);

        String title = intent.getStringExtra(TUIGroupConstants.Selection.TITLE);

        int filter = intent.getIntExtra(TUIGroupConstants.Selection.FILTER, GroupInfo.GROUP_MEMBER_FILTER_ALL);
        mMemberLayout.setSelectMode(isSelectMode);
        mMemberLayout.setTitle(title);

        presenter = new GroupInfoPresenter(mMemberLayout);
        mMemberLayout.setPresenter(presenter);
        presenter.loadGroupInfo(mGroupInfo.getId(), filter);

        mMemberLayout.getTitleBar().setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mMemberLayout.setGroupMemberListener(new IGroupMemberListener() {

            @Override
            public void setSelectedMember(ArrayList<String> members) {
                if (members == null || members.isEmpty()) {
                    return;
                }
                if (members.size() > limit) {
                    String overLimitTip = getString(R.string.group_over_limit_tip, limit);
                    ToastUtil.toastShortMessage(overLimitTip);
                    return;
                }
                Intent result = new Intent();
                result.putStringArrayListExtra(TUIGroupConstants.Selection.LIST, members);
                setResult(0, result);
                finish();
            }

            @Override
            public void forwardListMember(GroupInfo info) {

            }

            @Override
            public void forwardAddMember(GroupInfo info) {
                Bundle param = new Bundle();
                param.putString(TUIGroupConstants.Group.GROUP_ID, info.getId());
                param.putBoolean(TUIGroupConstants.Selection.SELECT_FRIENDS, true);
                TUICore.startActivity(GroupMemberActivity.this, "StartGroupMemberSelectActivity", param, 1);
            }

            @Override
            public void forwardDeleteMember(GroupInfo info) {
                Bundle param = new Bundle();
                param.putString(TUIGroupConstants.Group.GROUP_ID, info.getId());
                param.putBoolean(TUIGroupConstants.Selection.SELECT_FOR_CALL, true);
                TUICore.startActivity(GroupMemberActivity.this, "StartGroupMemberSelectActivity", param, 2);
            }
        });

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == 3) {
            List<String> friends = (List<String>) data.getSerializableExtra(TUIGroupConstants.Selection.LIST);
            if (requestCode == 1) {
                inviteGroupMembers(friends);
            } else if (requestCode == 2) {
                deleteGroupMembers(friends);
            }
        }
    }

    private void deleteGroupMembers(List<String> friends) {
        if (friends != null && friends.size() > 0) {
            if (presenter != null) {
                presenter.deleteGroupMembers(mGroupInfo.getId(), friends, new IUIKitCallback<List<String>>() {
                    @Override
                    public void onSuccess(List<String> data) {
                        presenter.loadGroupInfo(mGroupInfo.getId());
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {

                    }
                });
            }
        }
    }

    private void inviteGroupMembers(List<String> friends) {
        if (friends != null && friends.size() > 0) {
            if (presenter != null) {
                presenter.inviteGroupMembers(mGroupInfo.getId(), friends, new IUIKitCallback<Object>() {
                    @Override
                    public void onSuccess(Object data) {
                        if (data instanceof String) {
                            ToastUtil.toastLongMessage(data.toString());
                        } else {
                            ToastUtil.toastLongMessage(TUIGroupService.getAppContext().getString(R.string.invite_suc));
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastLongMessage(TUIGroupService.getAppContext().getString(R.string.invite_fail) + errCode + "=" + errMsg);
                    }
                });
            }
        }
    }

}
