package com.tencent.qcloud.tuikit.tuigroup.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.classicui.widget.GroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupLog;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupMemberActivity extends BaseLightActivity {
    private static final String TAG = "GroupMemberActivity";
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
            public void forwardAddMember(GroupInfo info) {
                presenter.getFriendListInGroup(info.getId(), new TUIValueCallback<List<UserBean>>() {
                    @Override
                    public void onSuccess(List<UserBean> userBeans) {
                        addGroupMember(info.getId(), userBeans);
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        TUIGroupLog.e(TAG, "add group member error, errorCode: " + errorCode + ", errorMessage: " + errorMessage);
                        addGroupMember(info.getId(), null);
                    }
                });
            }

            @Override
            public void forwardDeleteMember(GroupInfo info) {
                deleteGroupMember(info.getId());
            }
        });
    }

    private void deleteGroupMember(String groupID) {
        Bundle param = new Bundle();
        param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, groupID);
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FOR_CALL, true);
        TUICore.startActivityForResult(GroupMemberActivity.this, "StartGroupMemberSelectActivity", param, new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result != null && result.getData() != null) {
                    List<String> friends = (List<String>) result.getData().getSerializableExtra(TUIGroupConstants.Selection.LIST);
                    deleteGroupMembers(friends);
                }
            }
        });
    }

    private void addGroupMember(String groupID, List<UserBean> friendsInGroup) {
        Bundle param = new Bundle();
        param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, groupID);
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FRIENDS, true);
        ArrayList<String> selectedList = new ArrayList<>();
        if (friendsInGroup != null) {
            for (UserBean userBean : friendsInGroup) {
                selectedList.add(userBean.getUserId());
            }
        }
        param.putStringArrayList(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECTED_LIST, selectedList);
        TUICore.startActivityForResult(GroupMemberActivity.this, "StartGroupMemberSelectActivity", param, new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result != null && result.getData() != null) {
                    List<String> friends = (List<String>) result.getData().getSerializableExtra(TUIGroupConstants.Selection.LIST);
                    inviteGroupMembers(friends);
                }
            }
        });
    }


    private void deleteGroupMembers(List<String> friends) {
        if (friends != null && !friends.isEmpty()) {
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
        if (friends != null && !friends.isEmpty()) {
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
