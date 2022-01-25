package com.tencent.qcloud.tuikit.tuicontact.ui.pages;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.activities.SelectionActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import com.tencent.qcloud.tuikit.tuicontact.ui.view.ContactListView;

import java.util.ArrayList;
import java.util.Arrays;

public class StartGroupChatActivity extends BaseLightActivity {

    private static final String TAG = StartGroupChatActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private LineControllerView mJoinType;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();
    private int mGroupType = -1;
    private int mJoinTypeIndex = 2;
    private ArrayList<String> mJoinTypes = new ArrayList<>();
    private ArrayList<String> mGroupTypeValue = new ArrayList<>();
    private boolean mCreating;

    private ContactPresenter presenter;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.popup_start_group_chat_activity);

        init();
    }

    private void init() {
        String[] array = getResources().getStringArray(R.array.group_type);
        mGroupTypeValue.addAll(Arrays.asList(array));
        array = getResources().getStringArray(R.array.group_join_type);
        mJoinTypes.addAll(Arrays.asList(array));
        GroupMemberInfo memberInfo = new GroupMemberInfo();
        memberInfo.setAccount(ContactUtils.getLoginUser());
        mMembers.add(0, memberInfo);
        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.sure), ITitleBarLayout.Position.RIGHT);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createGroupChat();
            }
        });
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
        mJoinType.setContent(mJoinTypes.get(2));

        mContactListView = findViewById(R.id.group_create_member_list);

        presenter = new ContactPresenter();
        presenter.setFriendListListener();
        mContactListView.setPresenter(presenter);
        presenter.setContactListView(mContactListView);

        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getId());
                    mMembers.add(memberInfo);
                } else {
                    for (int i = mMembers.size() - 1; i >= 0; i--) {
                        if (mMembers.get(i).getAccount().equals(contact.getId())) {
                            mMembers.remove(i);
                        }
                    }
                }
            }
        });

        setGroupType(getIntent().getIntExtra("type", TUIContactConstants.GroupType.PRIVATE));
    }

    public void setGroupType(int type) {
        mGroupType = type;
        switch (type) {
            case TUIContactConstants.GroupType.PUBLIC:
                mTitleBar.setTitle(getResources().getString(R.string.create_group_chat), ITitleBarLayout.Position.MIDDLE);
                mJoinType.setVisibility(View.VISIBLE);
                break;
            case TUIContactConstants.GroupType.CHAT_ROOM:
                mTitleBar.setTitle(getResources().getString(R.string.create_chat_room), ITitleBarLayout.Position.MIDDLE);
                mJoinType.setVisibility(View.VISIBLE);
                break;
            case TUIContactConstants.GroupType.COMMUNITY:
                mTitleBar.setTitle(getResources().getString(R.string.create_community), ITitleBarLayout.Position.MIDDLE);
                mJoinType.setVisibility(View.VISIBLE);
                break;
            case TUIContactConstants.GroupType.PRIVATE:
            default:
                mTitleBar.setTitle(getResources().getString(R.string.create_private_group), ITitleBarLayout.Position.MIDDLE);
                mJoinType.setVisibility(View.GONE);
                break;
        }
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
        if (mCreating) {
            return;
        }
        if (mGroupType < 3 && mMembers.size() == 1) {
            ToastUtil.toastLongMessage(getResources().getString(R.string.tips_empty_group_member));
            return;
        }
        if (mGroupType > 0 && mJoinTypeIndex == -1) {
            ToastUtil.toastLongMessage(getResources().getString(R.string.tips_empty_group_type));
            return;
        }
        if (mGroupType == 0) {
            mJoinTypeIndex = -1;
        }
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
        groupInfo.setGroupType(mGroupTypeValue.get(mGroupType));
        groupInfo.setJoinType(mJoinTypeIndex);

        mCreating = true;

        presenter.createGroupChat(groupInfo, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                ContactUtils.startChatActivity(data, ChatInfo.TYPE_GROUP, groupInfo.getGroupName(), groupInfo.getGroupType());
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
