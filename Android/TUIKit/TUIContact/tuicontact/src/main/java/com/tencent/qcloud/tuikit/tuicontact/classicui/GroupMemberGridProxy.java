package com.tencent.qcloud.tuikit.tuicontact.classicui;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.classicui.pages.GroupMemberActivity;
import com.tencent.qcloud.tuikit.tuicontact.classicui.pages.StartGroupMemberSelectActivity;
import com.tencent.qcloud.tuikit.tuicontact.classicui.widget.GroupMemberGridAdapter;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.GroupMemberListener;
import com.tencent.qcloud.tuikit.tuicontact.presenter.GroupMemberPresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;
import java.util.ArrayList;
import java.util.List;

public class GroupMemberGridProxy {
    private static final String TAG = "GroupMemberGridProxy";
    private static final int COLUMN_NUM = 5;

    private final GroupMemberPresenter groupMemberPresenter = new GroupMemberPresenter();

    public void raiseExtension(View parentView, GroupProfileBean groupProfileBean) {
        RecyclerView recyclerView = new RecyclerView(parentView.getContext());
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        recyclerView.setLayoutParams(layoutParams);
        GridLayoutManager layoutManager = new GridLayoutManager(parentView.getContext(), COLUMN_NUM);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.setBackgroundResource(com.tencent.qcloud.tuikit.timcommon.R.color.white);

        recyclerView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(View v) {
                groupMemberPresenter.registerListener();
            }

            @Override
            public void onViewDetachedFromWindow(View v) {
                groupMemberPresenter.unregisterListener();
            }
        });

        GroupMemberGridAdapter adapter = new GroupMemberGridAdapter();
        adapter.setGroupProfileBean(groupProfileBean);
        recyclerView.setAdapter(adapter);
        ((ViewGroup) parentView).addView(recyclerView);
        groupMemberPresenter.setGroupID(groupProfileBean.getGroupID());
        groupMemberPresenter.setGroupMemberListener(new GroupMemberListener() {
            @Override
            public void onGroupMemberLoaded(List<GroupMemberInfo> groupMemberBeanList) {
                if (!groupMemberBeanList.isEmpty()) {
                    parentView.setVisibility(View.VISIBLE);
                }
                adapter.setGroupMembers(groupMemberBeanList);
            }
        });
        adapter.setGroupMemberGridListener(groupMemberBean -> {
            FragmentActivity activity = (FragmentActivity) parentView.getContext();
            if (groupMemberBean == adapter.addItem) {
                addGroupMember(activity, groupProfileBean);
            } else if (groupMemberBean == adapter.removeItem) {
                removeGroupMember(activity, groupProfileBean);
            } else {
                openDetails(groupMemberBean);
            }
        });

        groupMemberPresenter.loadGroupMemberList();
    }

    private void addGroupMember(FragmentActivity activity, GroupProfileBean groupProfileBean) {
        groupMemberPresenter.getFriendListInGroup(groupProfileBean.getGroupID(), new TUIValueCallback<List<UserBean>>() {
            @Override
            public void onSuccess(List<UserBean> userBeans) {
                addGroupMember(activity, groupProfileBean.getGroupID(), userBeans);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIContactLog.e(TAG, "add group member error, errorCode: " + errorCode + ", errorMessage: " + errorMessage);
                addGroupMember(activity, groupProfileBean.getGroupID(), null);
            }
        });
    }

    private void addGroupMember(ActivityResultCaller caller, String groupID, List<UserBean> friendsInGroup) {
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
        TUICore.startActivityForResult(caller, StartGroupMemberSelectActivity.class, param, new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result != null && result.getData() != null) {
                    List<String> friends = (List<String>) result.getData().getSerializableExtra(TUIContactConstants.Selection.LIST);
                    groupMemberPresenter.inviteGroupMembers(groupID, friends);
                }
            }
        });
    }

    private void removeGroupMember(FragmentActivity activity, GroupProfileBean groupProfileBean) {
        Bundle param = new Bundle();
        param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, groupProfileBean.getGroupID());
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FOR_CALL, true);

        TUICore.startActivityForResult(activity, StartGroupMemberSelectActivity.class, param, result -> {
            if (result.getData() != null) {
                List<String> groupMembers = (List<String>) result.getData().getSerializableExtra(TUIContactConstants.Selection.LIST);
                groupMemberPresenter.removeGroupMembers(groupProfileBean.getGroupID(), groupMembers);
            }
        });
    }

    private void openDetails(GroupMemberInfo groupMemberBean) {
        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIChat.CHAT_ID, groupMemberBean.getUserId());
        TUICore.startActivity("FriendProfileActivity", bundle);
    }

    public void transferGroupOwner(ActivityResultCaller caller, GroupProfileBean groupProfileBean) {
        ArrayList<String> excludeList = new ArrayList<>();
        excludeList.add(TUILogin.getLoginUser());
        Bundle param = new Bundle();
        param.putBoolean(TUIConstants.TUIContact.IS_SELECT_MODE, true);
        param.putString(TUIConstants.TUIContact.GROUP_ID, groupProfileBean.getGroupID());
        param.putInt(TUIConstants.TUIContact.LIMIT, 1);
        param.putStringArrayList(TUIConstants.TUIContact.EXCLUDE_LIST, excludeList);
        param.putString(TUIConstants.TUIContact.TITLE, TUIContactService.getAppContext().getResources().getString(R.string.group_transfer_group_owner));

        TUICore.startActivityForResult(caller, GroupMemberActivity.class, param, result -> {
            if (result.getData() != null) {
                List<String> selectedList = result.getData().getStringArrayListExtra(TUIContactConstants.Selection.LIST);
                if (selectedList != null && !selectedList.isEmpty()) {
                    String newOwnerId = selectedList.get(0);
                    groupMemberPresenter.transferGroupOwner(groupProfileBean.getGroupID(), newOwnerId);
                }
            }
        });
    }
}
