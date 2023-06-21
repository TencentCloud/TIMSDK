package com.tencent.qcloud.tuikit.tuigroup.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.classicui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.classicui.widget.GroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupMemberActivity extends BaseLightActivity {
    private GroupMemberLayout mMemberLayout;
    private String groupID;
    private GroupInfoPresenter presenter;

    private boolean isSelectMode = false;
    private ArrayList<String> excludeList;
    private ArrayList<String> alreadySelectedList;
    private String userData;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_members_list);
        mMemberLayout = findViewById(R.id.group_member_grid_layout);
        init();
    }

    private void init() {
        Intent intent = getIntent();
        groupID = intent.getStringExtra(TUIConstants.TUIGroup.GROUP_ID);
        isSelectMode = intent.getBooleanExtra(TUIConstants.TUIGroup.IS_SELECT_MODE, true);
        excludeList = intent.getStringArrayListExtra(TUIConstants.TUIGroup.EXCLUDE_LIST);
        alreadySelectedList = intent.getStringArrayListExtra(TUIConstants.TUIGroup.SELECTED_LIST);
        userData = intent.getStringExtra(TUIConstants.TUIGroup.USER_DATA);
        mMemberLayout.setSelectMode(isSelectMode);
        String title = intent.getStringExtra(TUIConstants.TUIGroup.TITLE);
        mMemberLayout.setTitle(title);
        mMemberLayout.setExcludeList(excludeList);
        mMemberLayout.setAlreadySelectedList(alreadySelectedList);
        presenter = new GroupInfoPresenter(mMemberLayout);
        mMemberLayout.setPresenter(presenter);
        int filter = intent.getIntExtra(TUIConstants.TUIGroup.FILTER, GroupInfo.GROUP_MEMBER_FILTER_ALL);
        presenter.loadGroupInfo(groupID, filter);

        mMemberLayout.getTitleBar().setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        int limit = getIntent().getIntExtra(TUIConstants.TUIGroup.LIMIT, Integer.MAX_VALUE);

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
                result.putStringArrayListExtra(TUIConstants.TUIGroup.LIST, members);
                setResult(0, result);

                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.LIST, members);
                param.put(TUIConstants.TUIGroup.USER_DATA, userData);
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_MEMBER_SELECTED, param);

                finish();
            }

            @Override
            public void forwardListMember(GroupInfo info) {}

            @Override
            public void forwardAddMember(GroupInfo info) {
                Bundle param = new Bundle();
                param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, info.getId());
                param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FRIENDS, true);
                ArrayList<String> selectedList = new ArrayList<>();
                for (GroupMemberInfo memberInfo : info.getMemberDetails()) {
                    selectedList.add(memberInfo.getAccount());
                }
                param.putStringArrayList(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECTED_LIST, selectedList);
                TUICore.startActivity(GroupMemberActivity.this, "StartGroupMemberSelectActivity", param, 1);
            }

            @Override
            public void forwardDeleteMember(GroupInfo info) {
                Bundle param = new Bundle();
                param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, info.getId());
                param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FOR_CALL, true);
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
                presenter.deleteGroupMembers(groupID, friends, new IUIKitCallback<List<String>>() {
                    @Override
                    public void onSuccess(List<String> data) {
                        presenter.loadGroupInfo(groupID);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {}
                });
            }
        }
    }

    private void inviteGroupMembers(List<String> friends) {
        if (friends != null && friends.size() > 0) {
            if (presenter != null) {
                presenter.inviteGroupMembers(groupID, friends, new IUIKitCallback<Object>() {
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
