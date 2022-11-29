package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.activities.SelectionActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.classicui.widget.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.classicui.widget.ForwardContactSelectorAdapter;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ForwardSelectGroupActivity extends BaseLightActivity {

    private static final String TAG = ForwardSelectGroupActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private LineControllerView mJoinType;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();
    private int mGroupType = -1;
    private int mJoinTypeIndex = 2;
    private ArrayList<String> mJoinTypes = new ArrayList<>();
    private ArrayList<String> mGroupTypeValue = new ArrayList<>();
    private boolean mCreating;
    private boolean isCreateNewChat = true;

    private RecyclerView mForwardSelectlistView;
    private ForwardContactSelectorAdapter mAdapter;
    private List<String> mSelectConversationIcons = new ArrayList<>();
    private RelativeLayout mForwardSelectlistViewLayout;
    private TextView mSureView;

    private List<ConversationInfo> mContactDataSource = new ArrayList<>();

    private ContactPresenter presenter;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.forward_select_group_contact);

        init();
    }

    private String getMembersUserId(){
        if (mMembers.size() == 0) {
            return "";
        }

        String userIdString = "";
        for(int i = 0; i < mMembers.size(); i++){
            userIdString += mMembers.get(i).getAccount();
            userIdString += " ";
        }
        return userIdString;
    }

    private void refreshMembers(){
        if (mContactDataSource == null || mContactDataSource.size() ==0){
            mMembers.clear();
            return;
        }

        for (int i=0;i<mContactDataSource.size();i++){
            GroupMemberInfo memberInfo = new GroupMemberInfo();
            memberInfo.setAccount(mContactDataSource.get(i).getId());
            memberInfo.setIconUrl((String)mContactDataSource.get(i).getIconUrlList().get(0));
            mMembers.add(memberInfo);
        }
    }

    private void init() {
        Intent intent = getIntent();
        if (intent != null){
            isCreateNewChat = intent.getBooleanExtra(TUIContactConstants.FORWARD_CREATE_NEW_CHAT, false);
        }

        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mJoinType = findViewById(R.id.group_type_join);
        mJoinType.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showJoinTypePickerView();
            }
        });
        mJoinType.setCanNav(true);
        mJoinType.setContent("Public");
        mJoinType.setVisibility(View.GONE);

        mContactListView = findViewById(R.id.group_create_member_list);

        presenter = new ContactPresenter();
        mContactListView.setPresenter(presenter);
        presenter.setFriendListListener();
        presenter.setContactListView(mContactListView);

        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getId());
                    memberInfo.setIconUrl(contact.getAvatarUrl());
                    mMembers.add(memberInfo);
                } else {
                    for (int i = mMembers.size() - 1; i >= 0; i--) {
                        if (mMembers.get(i).getAccount().equals(contact.getId())) {
                            mMembers.remove(i);
                        }
                    }
                }
                refreshSelectConversations();
            }
        });

        setGroupType(TUIContactConstants.GroupType.PUBLIC);

        mForwardSelectlistViewLayout = findViewById(R.id.forward_contact_select_list_layout);
        mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
        mForwardSelectlistView = findViewById(R.id.forward_contact_select_list);
        mForwardSelectlistView.setLayoutManager(new CustomLinearLayoutManager(this, CustomLinearLayoutManager.HORIZONTAL, false));
        mAdapter = new ForwardContactSelectorAdapter(this);
        mForwardSelectlistView.setAdapter(mAdapter);

        mSureView = findViewById(R.id.btn_msg_ok);
        mSureView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateNewChat){
                    createGroupChat();
                } else {
                    Intent intent = new Intent();
                    HashMap<String, String> conversationMap = new HashMap<>();
                    if (mMembers != null && mMembers.size() != 0){
                        for (int i=0;i<mMembers.size();i++){
                            conversationMap.put(mMembers.get(i).getAccount(), mMembers.get(i).getIconUrl());
                        }
                    }

                    intent.putExtra(TUIContactConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationMap);
                    setResult(TUIContactConstants.FORWARD_SELECT_MEMBERS_CODE, intent);

                    finish();
                }
            }
        });

        refreshSelectConversations();
    }

    private void refreshSelectConversations(){
        mSelectConversationIcons.clear();
        if (mMembers != null && mMembers.size() != 0){
            for (int i=0;i<mMembers.size();i++){
                mSelectConversationIcons.add(mMembers.get(i).getIconUrl());
            }
        }
        mAdapter.setDataSource(mSelectConversationIcons);

        if (mSelectConversationIcons == null || mSelectConversationIcons.size() == 0){
            mSureView.setText(getString(com.tencent.qcloud.tuicore.R.string.sure));
            mSureView.setVisibility(View.GONE);
            mForwardSelectlistViewLayout.setVisibility(View.GONE);
        } else {
            mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
            mSureView.setVisibility(View.VISIBLE);
            mSureView.setText(getString(com.tencent.qcloud.tuicore.R.string.sure) + "(" + mSelectConversationIcons.size() + ")");
        }
    }

    public void setGroupType(int type) {
        mGroupType = type;
        mTitleBar.setTitle(getResources().getString(R.string.contact_title), ITitleBarLayout.Position.MIDDLE);
        mJoinType.setVisibility(View.GONE);
    }

    private void showJoinTypePickerView() {
        Bundle bundle = new Bundle();
        bundle.putString(SelectionActivity.Selection.TITLE, getResources().getString(R.string.group_join_type));
        bundle.putStringArrayList(SelectionActivity.Selection.LIST, mJoinTypes);
        bundle.putInt(SelectionActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, mJoinTypeIndex);
        SelectionActivity.startListSelection(this, bundle, new SelectionActivity.OnResultReturnListener() {
            @Override
            public void onReturn(Object text) {
                mJoinType.setContent(mJoinTypes.get((Integer) text));
                mJoinTypeIndex = (Integer) text;
            }
        });
    }

    private void createGroupChat() {
        if (mCreating || mMembers.isEmpty()) {
            return;
        }
       
        if (mMembers.size() == 1){
            Intent intent = new Intent();
            HashMap<String, Boolean> conversationMap = new HashMap<>();
            conversationMap.put(mMembers.get(0).getAccount(), false);
            intent.putExtra(TUIContactConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationMap);
            setResult(TUIContactConstants.FORWARD_CREATE_GROUP_CODE, intent);

            finish();
            return;
        }
        GroupMemberInfo memberInfo = new GroupMemberInfo();
        memberInfo.setAccount(ContactUtils.getLoginUser());
        mMembers.add(memberInfo);

        final GroupInfo groupInfo = new GroupInfo();
        String groupName = ContactUtils.getLoginUser();
        for (int i = 1; i < mMembers.size(); i++) {
            groupName = groupName + "、" + mMembers.get(i).getAccount();
        }
        if (groupName.length() > 20) {
            groupName = groupName.substring(0, 17) + "...";
        }
        groupInfo.setChatName(groupName);
        groupInfo.setGroupName(groupName);
        groupInfo.setMemberDetails(mMembers);
        groupInfo.setGroupType(TUIContactConstants.GroupType.TYPE_PUBLIC);
        groupInfo.setJoinType(0);

        mCreating = true;
        
        presenter.createGroupChat(groupInfo, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                Intent intent = new Intent();
                HashMap<String, Boolean> conversationMap = new HashMap<>();
                conversationMap.put(data, true);

                intent.putExtra(TUIContactConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationMap);
                setResult(TUIContactConstants.FORWARD_CREATE_GROUP_CODE, intent);

                finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mCreating = false;
                ToastUtil.toastLongMessage("createGroupChat fail:" + errCode + "=" + errMsg);
            }
        });

    }

}
