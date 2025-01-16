package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.GroupMemberLayout;
import com.tencent.qcloud.tuikit.tuicontact.presenter.GroupInfoPresenter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupMemberMinimalistActivity extends BaseMinimalistLightActivity {
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
        setContentView(R.layout.group_minimalist_members_list);
        mMemberLayout = findViewById(R.id.group_member_grid_layout);
        init();
    }

    private void init() {
        Intent intent = getIntent();
        groupID = intent.getStringExtra(TUIConstants.TUIContact.GROUP_ID);
        isSelectMode = intent.getBooleanExtra(TUIConstants.TUIContact.IS_SELECT_MODE, true);
        excludeList = intent.getStringArrayListExtra(TUIConstants.TUIContact.EXCLUDE_LIST);
        alreadySelectedList = intent.getStringArrayListExtra(TUIConstants.TUIContact.SELECTED_LIST);
        userData = intent.getStringExtra(TUIConstants.TUIContact.USER_DATA);
        mMemberLayout.setSelectMode(isSelectMode);
        String title = intent.getStringExtra(TUIConstants.TUIContact.TITLE);
        mMemberLayout.setTitle(title);
        mMemberLayout.setExcludeList(excludeList);
        mMemberLayout.setAlreadySelectedList(alreadySelectedList);
        presenter = new GroupInfoPresenter(mMemberLayout);
        mMemberLayout.setPresenter(presenter);
        int filter = intent.getIntExtra(TUIConstants.TUIContact.FILTER, GroupInfo.GROUP_MEMBER_FILTER_ALL);
        presenter.loadGroupInfo(groupID, filter);

        mMemberLayout.getTitleBar().setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        int limit = getIntent().getIntExtra(TUIConstants.TUIContact.LIMIT, Integer.MAX_VALUE);
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
                result.putStringArrayListExtra(TUIConstants.TUIContact.LIST, members);
                setResult(0, result);

                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.LIST, members);
                param.put(TUIConstants.TUIContact.USER_DATA, userData);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_GROUP_MEMBER_SELECTED, param);

                finish();
            }

        });

        mMemberLayout.setOnGroupMemberClickListener(new GroupMemberLayout.OnGroupMemberClickListener() {
            @Override
            public void onShowInfo(GroupMemberInfo groupMemberInfo) {
                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, groupMemberInfo.getUserId());
                TUICore.startActivity("FriendProfileMinimalistActivity", bundle);
            }

            @Override
            public void onAdminRoleChanged(GroupMemberInfo groupMemberInfo) {
                if (!presenter.isAdmin(groupMemberInfo.getRole())) {
                    presenter.setGroupManager(groupID, groupMemberInfo.getUserId(), new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            ToastUtil.toastLongMessage(getString(com.tencent.qcloud.tuikit.timcommon.R.string.setting_success));
                            GroupMemberMinimalistActivity.this.onAdminRoleChanged(groupMemberInfo);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastLongMessage(
                                getString(com.tencent.qcloud.tuikit.timcommon.R.string.setting_fail) + ", errCode = " + errCode + ", errMsg = " + errMsg);
                        }
                    });
                } else {
                    presenter.setGroupMemberRole(groupID, groupMemberInfo.getUserId(), new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            GroupMemberMinimalistActivity.this.onAdminRoleChanged(groupMemberInfo);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastLongMessage(
                                getString(com.tencent.qcloud.tuikit.timcommon.R.string.setting_fail) + ", errCode = " + errCode + ", errMsg = " + errMsg);
                        }
                    });
                }
            }

            @Override
            public void onDelete(GroupMemberInfo groupMemberInfo) {
                presenter.deleteGroupMembers(groupID, Collections.singletonList(groupMemberInfo.getUserId()), new IUIKitCallback<List<String>>() {
                    @Override
                    public void onSuccess(List<String> data) {
                        ToastUtil.toastLongMessage(getString(R.string.remove_tip_suc));
                        onMemberDeleted(data);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastLongMessage(getString(R.string.remove_fail_tip) + ", errCode = " + errCode + ", errMsg = " + errMsg);
                    }
                });
            }
        });
    }

    private void onMemberDeleted(List<String> memberIDs) {
        mMemberLayout.deleteMember(memberIDs);
    }

    private void onAdminRoleChanged(GroupMemberInfo groupMemberInfo) {
        if (presenter.isAdmin(groupMemberInfo.getRole())) {
            groupMemberInfo.setRole(GroupInfo.GROUP_MEMBER_ROLE_MEMBER);
        } else {
            groupMemberInfo.setRole(GroupInfo.GROUP_MEMBER_ROLE_ADMIN);
        }
        mMemberLayout.memberChanged(groupMemberInfo);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == 3) {
            List<String> friends = (List<String>) data.getSerializableExtra(TUIContactConstants.Selection.LIST);
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
                            ToastUtil.toastLongMessage(TUIContactService.getAppContext().getString(R.string.invite_suc));
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastLongMessage(TUIContactService.getAppContext().getString(R.string.invite_fail) + errCode + "=" + errMsg);
                    }
                });
            }
        }
    }
}
