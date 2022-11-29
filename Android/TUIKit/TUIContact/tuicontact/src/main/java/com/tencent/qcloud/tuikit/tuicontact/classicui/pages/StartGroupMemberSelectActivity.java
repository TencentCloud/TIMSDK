package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.classicui.widget.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class StartGroupMemberSelectActivity extends BaseLightActivity {

    private static final String TAG = StartGroupMemberSelectActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();
    private ArrayList<String> alreadySelectedList;
    private RecyclerView selectedList;
    private SelectedAdapter selectedListAdapter;
    private TextView confirmButton;
    private ContactPresenter presenter;
    private int limit;
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
        limit = getIntent().getIntExtra(TUIContactConstants.Selection.LIMIT, Integer.MAX_VALUE);
        alreadySelectedList = getIntent().getStringArrayListExtra(TUIContactConstants.Selection.SELECTED_LIST);
        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.setTitle(getResources().getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                confirmAndFinish();
            }
        });
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        confirmButton = findViewById(R.id.confirm_button);
        selectedList = findViewById(R.id.selected_list);
        selectedListAdapter = new SelectedAdapter();
        selectedList.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        selectedList.setAdapter(selectedListAdapter);
        mContactListView = findViewById(R.id.group_create_member_list);
        mContactListView.setAlreadySelectedList(alreadySelectedList);
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
                    memberInfo.setIconUrl(contact.getAvatarUrl());
                    memberInfo.setNameCard(TextUtils.isEmpty(contact.getNickName()) ? contact.getId() : contact.getNickName());
                    mMembers.add(memberInfo);
                } else {
                    for (int i = mMembers.size() - 1; i >= 0; i--) {
                        if (mMembers.get(i).getAccount().equals(contact.getId())) {
                            mMembers.remove(i);
                        }
                    }
                }
                selectedListAdapter.setMembers(mMembers);
                selectedListAdapter.notifyDataSetChanged();
            }
        });
        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                confirmAndFinish();
            }
        });

    }

    private void confirmAndFinish() {
        if (mMembers.size() > limit) {
            String overLimitTip = getString(R.string.contact_over_limit_tip, limit);
            ToastUtil.toastShortMessage(overLimitTip);
            return;
        }
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

    public static class SelectedAdapter extends RecyclerView.Adapter<SelectedAdapter.SelectedViewHolder> {
        private List<GroupMemberInfo> mMembers;

        public void setMembers(List<GroupMemberInfo> mMembers) {
            this.mMembers = mMembers;
        }

        @NonNull
        @Override
        public SelectedViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SelectedViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.forward_contact_selector_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull StartGroupMemberSelectActivity.SelectedAdapter.SelectedViewHolder holder, int position) {
            GlideEngine.loadImage(holder.userIconView, mMembers.get(position).getIconUrl());
        }

        @Override
        public int getItemCount() {
            if (mMembers == null) {
                return 0;
            }
            return mMembers.size();
        }

        public class SelectedViewHolder extends RecyclerView.ViewHolder {
            public ImageView userIconView;
            public SelectedViewHolder(@NonNull View itemView) {
                super(itemView);
                userIconView = (ImageView) itemView.findViewById(R.id.ivAvatar);
            }
        }
    }

}
