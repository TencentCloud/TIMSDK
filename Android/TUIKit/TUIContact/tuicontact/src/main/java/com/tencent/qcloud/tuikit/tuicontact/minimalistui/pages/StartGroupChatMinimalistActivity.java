package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.ContactAdapter;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class StartGroupChatMinimalistActivity extends AppCompatActivity {
    private static final String TAG = StartGroupChatMinimalistActivity.class.getSimpleName();

    private TextView cancelButton;
    private TextView nextButton;
    private ContactListView mContactListView;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();
    private int mJoinTypeIndex = 2;
    private ArrayList<String> mJoinTypes = new ArrayList<>();
    private ArrayList<String> mGroupTypeValue = new ArrayList<>();
    private RecyclerView selectedList;
    private GroupMemberSelectedAdapter selectedListAdapter;
    private ContactPresenter presenter;
    private GroupMemberInfo selfInfo;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.minimalist_popup_start_group_chat_activity);
        selfInfo = new GroupMemberInfo();
        selfInfo.setAccount(ContactUtils.getLoginUser());
        selfInfo.setNickName(TUIConfig.getSelfNickName());
        init();
    }

    private void init() {
        String[] array = getResources().getStringArray(R.array.group_type);
        mGroupTypeValue.addAll(Arrays.asList(array));
        array = getResources().getStringArray(R.array.group_join_type);
        mJoinTypes.addAll(Arrays.asList(array));

        cancelButton = findViewById(R.id.cancel_button);
        nextButton = findViewById(R.id.next_button);

        nextButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toCreateGroupChat();
            }
        });
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mContactListView = findViewById(R.id.group_create_member_list);
        selectedList = findViewById(R.id.selected_list);
        selectedListAdapter = new GroupMemberSelectedAdapter();
        selectedList.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        selectedList.setAdapter(selectedListAdapter);
        presenter = new ContactPresenter();
        presenter.setFriendListListener();
        mContactListView.setPresenter(presenter);
        presenter.setContactListView(mContactListView);
        selectedList.setVisibility(View.GONE);
        selectedListAdapter.setSelectedMemberClickedListener(new OnSelectedMemberClickedListener() {
            @Override
            public void onRemove(GroupMemberInfo groupMemberInfo) {
                ContactAdapter adapter = mContactListView.getAdapter();
                adapter.setSelected(groupMemberInfo.getAccount(), false);
            }
        });

        ArrayList<String> alreadySelectedList = new ArrayList<>();
        alreadySelectedList.add(TUILogin.getLoginUser());
        mContactListView.setAlreadySelectedList(alreadySelectedList);
        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getId());
                    memberInfo.setNickName(contact.getNickName());
                    memberInfo.setIconUrl(contact.getAvatarUrl());
                    mMembers.add(memberInfo);
                    selectedListAdapter.setMembers(mMembers);
                    selectedListAdapter.notifyItemInserted(mMembers.indexOf(memberInfo));
                } else {
                    for (int i = mMembers.size() - 1; i >= 0; i--) {
                        if (mMembers.get(i).getAccount().equals(contact.getId())) {
                            selectedListAdapter.notifyItemRemoved(i);
                            mMembers.remove(i);
                            selectedListAdapter.setMembers(mMembers);
                            break;
                        }
                    }
                }

                if (mMembers.size() > 0) {
                    nextButton.setAlpha(1f);
                    nextButton.setEnabled(true);
                    selectedList.setVisibility(View.VISIBLE);
                } else {
                    nextButton.setAlpha(0.5f);
                    nextButton.setEnabled(false);
                    selectedList.setVisibility(View.GONE);
                }
            }
        });

        nextButton.setAlpha(0.5f);
        nextButton.setEnabled(false);
    }

    private void toCreateGroupChat() {
        if (mMembers.isEmpty()) {
            ToastUtil.toastLongMessage(getResources().getString(R.string.tips_empty_group_member));
            return;
        }

        String groupName = selfInfo.getDisplayName();
        for (int i = 1; i < mMembers.size(); i++) {
            groupName = groupName + "、" + mMembers.get(i).getDisplayName();
        }
        if (groupName.length() >= 10) {
            groupName = groupName.substring(0, 7) + "..";
        }

        Intent intent = new Intent(this, CreateGroupMinimalistActivity.class);
        intent.putExtra(TUIConstants.TUIGroup.GROUP_NAME, groupName);
        intent.putExtra(TUIConstants.TUIGroup.JOIN_TYPE_INDEX, mJoinTypeIndex);
        intent.putExtra(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST, mMembers);
        startActivity(intent);
        finish();
    }

    public interface OnSelectedMemberClickedListener {
        void onRemove(GroupMemberInfo groupMemberInfo);
    }

    public static class GroupMemberSelectedAdapter extends RecyclerView.Adapter<GroupMemberSelectedAdapter.GroupMemberSelectedViewHolder> {
        private List<GroupMemberInfo> mMembers;
        private OnSelectedMemberClickedListener selectedMemberClickedListener;

        public void setMembers(List<GroupMemberInfo> mMembers) {
            this.mMembers = mMembers;
        }

        public void setSelectedMemberClickedListener(OnSelectedMemberClickedListener selectedMemberClickedListener) {
            this.selectedMemberClickedListener = selectedMemberClickedListener;
        }

        @NonNull
        @Override
        public GroupMemberSelectedViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new GroupMemberSelectedViewHolder(
                LayoutInflater.from(parent.getContext()).inflate(R.layout.contact_create_group_list_selected_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull GroupMemberSelectedViewHolder holder, int position) {
            GroupMemberInfo groupMemberInfo = mMembers.get(position);
            GlideEngine.loadImage(holder.userIconView, groupMemberInfo.getIconUrl());
            holder.userNameTv.setText(groupMemberInfo.getDisplayName());
            holder.removeIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (selectedMemberClickedListener != null) {
                        selectedMemberClickedListener.onRemove(groupMemberInfo);
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            if (mMembers == null) {
                return 0;
            }
            return mMembers.size();
        }

        public static class GroupMemberSelectedViewHolder extends RecyclerView.ViewHolder {
            public RoundCornerImageView userIconView;
            public ImageView removeIcon;
            public TextView userNameTv;

            public GroupMemberSelectedViewHolder(@NonNull View itemView) {
                super(itemView);
                userIconView = itemView.findViewById(R.id.ivAvatar);
                removeIcon = itemView.findViewById(R.id.remove_icon);
                userNameTv = itemView.findViewById(R.id.user_name_tv);
                userIconView.setRadius(ScreenUtil.dip2px(25));
            }
        }
    }
}
