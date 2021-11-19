package com.tencent.qcloud.tuikit.tuicontact.ui.pages;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuikit.tuicontact.ui.view.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.R;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class StartGroupMemberSelectActivity extends Activity {

    private static final String TAG = StartGroupMemberSelectActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();

    private ContactPresenter presenter;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.popup_start_group_select_activity);

        init();
    }

    private ArrayList<String> getMembersNameCard(){
        if (mMembers.size() == 0) {
            return new ArrayList<>();
        }

        ArrayList<String> nameCards = new ArrayList<>();
        for(int i = 0; i < mMembers.size(); i++){
            nameCards.add(mMembers.get(i).getNameCard());
        }
        return nameCards;
    }

    private ArrayList<String> getMembersUserId(){
        if (mMembers.size() == 0) {
            return new ArrayList<>();
        }

        ArrayList<String> userIds = new ArrayList<>();
        for(int i = 0; i < mMembers.size(); i++){
            userIds.add(mMembers.get(i).getAccount());
        }
        return userIds;
    }

    private void init() {
        mMembers.clear();

        String groupId = getIntent().getStringExtra(TUIContactConstants.Group.GROUP_ID);
        boolean isSelectFriends = getIntent().getBooleanExtra(TUIContactConstants.Selection.SELECT_FRIENDS, false);
        boolean isSelectForCall = getIntent().getBooleanExtra(TUIContactConstants.Selection.SELECT_FOR_CALL, false);

        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.sure), ITitleBarLayout.Position.RIGHT);
        mTitleBar.getRightTitle().setTextColor(getResources().getColor(R.color.title_bar_font_color));
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                List<String> friendIdList = new ArrayList<>();
                for (GroupMemberInfo memberInfo : mMembers) {
                    friendIdList.add(memberInfo.getAccount());
                }
                i.putExtra(TUIContactConstants.Selection.LIST, (Serializable) friendIdList);
                i.putStringArrayListExtra(TUIContactConstants.Selection.USER_NAMECARD_SELECT, getMembersNameCard());
                i.putStringArrayListExtra(TUIContactConstants.Selection.USER_ID_SELECT, getMembersUserId());
                i.putExtras(getIntent());
                setResult(3, i);

                finish();
            }
        });
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mContactListView = findViewById(R.id.group_create_member_list);

        presenter = new ContactPresenter();
        presenter.setFriendListListener();
        presenter.setIsForCall(isSelectForCall);
        mContactListView.setPresenter(presenter);
        presenter.setContactListView(mContactListView);

        mContactListView.setGroupId(groupId);
        if (isSelectFriends) {
            mTitleBar.setTitle(getString(R.string.add_group_member), TitleBarLayout.Position.MIDDLE);
            mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        } else {
            mContactListView.loadDataSource(ContactListView.DataSource.GROUP_MEMBER_LIST);
        }

        if (!isSelectForCall && !isSelectFriends) {
            mContactListView.setOnItemClickListener(new ContactListView.OnItemClickListener() {
                @Override
                public void onItemClick(int position, ContactItemBean contact) {
                    if (position == 0) {
                        mMembers.clear();

                        Intent i = new Intent();
                        i.putStringArrayListExtra(TUIContactConstants.Selection.USER_NAMECARD_SELECT, new ArrayList<String>(Arrays.asList(getString(R.string.at_all))));
                        i.putStringArrayListExtra(TUIContactConstants.Selection.USER_ID_SELECT, new ArrayList<String>(Arrays.asList(TUIContactConstants.Selection.SELECT_ALL)));
                        setResult(3, i);

                        finish();
                    }
                }
            });
        }
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getId());
                    memberInfo.setNameCard(TextUtils.isEmpty(contact.getNickName()) ? contact.getId() : contact.getNickName());
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
    }
}
