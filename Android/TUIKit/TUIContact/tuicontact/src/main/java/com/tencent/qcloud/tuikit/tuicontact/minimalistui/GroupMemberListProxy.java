package com.tencent.qcloud.tuikit.tuicontact.minimalistui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResultCaller;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.classicui.pages.GroupMemberActivity;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.GroupMemberListener;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.GroupMemberMinimalistActivity;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.StartGroupMemberSelectMinimalistActivity;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.GroupInfoAdapter;
import com.tencent.qcloud.tuikit.tuicontact.presenter.GroupMemberPresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
import java.util.List;

public class GroupMemberListProxy {
    private static final String TAG = "GroupMemberListProxy";

    private final GroupMemberPresenter groupMemberPresenter = new GroupMemberPresenter();
    private MinimalistLineControllerView addMemberButton;

    public void raiseExtension(View parentView, GroupProfileBean groupProfileBean) {
        View view = LayoutInflater.from(parentView.getContext()).inflate(R.layout.contact_minimalist_group_member_list, null);

        addMemberButton = view.findViewById(R.id.add_group_members);
        addMemberButton.setNameColor(0xFF0365F9);
        addMemberButton.setBackgroundColor(0xF0F9F9F9);

        RecyclerView recyclerView = view.findViewById(R.id.group_members);
        LinearLayoutManager layoutManager = new LinearLayoutManager(parentView.getContext());
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
        GroupInfoAdapter adapter = new GroupInfoAdapter();
        adapter.setGroupProfileBean(groupProfileBean);
        recyclerView.setAdapter(adapter);
        ((ViewGroup) parentView).addView(view);
        groupMemberPresenter.setGroupID(groupProfileBean.getGroupID());
        groupMemberPresenter.setGroupMemberListener(new GroupMemberListener() {
            @Override
            public void onGroupMemberLoaded(List<GroupMemberInfo> groupMemberBeanList) {
                if (!groupMemberBeanList.isEmpty()) {
                    parentView.setVisibility(View.VISIBLE);
                }
                setAddMemberButtonVisibility(groupProfileBean);
                adapter.setMemberList(groupMemberBeanList);
            }
        });
        adapter.setGroupMemberGridListener(this::openDetails);
        addMemberButton.setOnClickListener(v -> {
            FragmentActivity activity = (FragmentActivity) parentView.getContext();
            addGroupMember(activity, groupProfileBean);
        });

        groupMemberPresenter.loadGroupMemberList();
    }

    private void setAddMemberButtonVisibility(GroupProfileBean groupProfileBean) {
        if (groupProfileBean.getApproveOpt() != V2TIMGroupInfo.V2TIM_GROUP_ADD_FORBID) {
            addMemberButton.setVisibility(View.VISIBLE);
        } else {
            addMemberButton.setVisibility(View.GONE);
        }
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
        TUICore.startActivityForResult(caller, StartGroupMemberSelectMinimalistActivity.class, param, result -> {
            if (result != null && result.getData() != null) {
                List<String> friends = (List<String>) result.getData().getSerializableExtra(TUIContactConstants.Selection.LIST);
                groupMemberPresenter.inviteGroupMembers(groupID, friends);
            }
        });
    }

    private void openDetails(GroupMemberInfo groupMemberBean) {
        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIChat.CHAT_ID, groupMemberBean.getUserId());
        TUICore.startActivity("FriendProfileMinimalistActivity", bundle);
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

        TUICore.startActivityForResult(caller, GroupMemberMinimalistActivity.class, param, result -> {
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
